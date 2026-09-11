package com.jd.pzx.jd_flutter.utils

import android.app.PendingIntent.FLAG_IMMUTABLE
import android.app.PendingIntent.getBroadcast
import android.content.Context
import android.content.Intent
import android.hardware.usb.UsbConstants
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbEndpoint
import android.hardware.usb.UsbManager
import android.os.Build
import android.util.Log
import android.widget.Toast
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking

const val DEVICE_VENDOR_ID = 4611//TSC打印机USB串口ID
const val SEND_COMMAND_STATE_SUCCESS = 1000//串口发送成功
const val SEND_COMMAND_STATE_PART_SUCCESS = 1001//串口发送部分成功
const val SEND_COMMAND_STATE_FAILED = 1003//发送失败
const val SEND_COMMAND_STATE_USB_ERROR = 1004//usb设备异常
const val SEND_COMMAND_STATE_NO_PERMISSION = 1005//没有串口指定权限
const val SEND_COMMAND_STATE_NO_DEVICE = 1006//找不到指定设备
const val SEND_COMMAND_STATE_BROKEN_PIPE = 1007//蓝牙通道已断开
// USB 已断开/不可用（设备被拔出、或发送中断）。上层收到该码后可等待设备重新接入，
// 然后从中断的那一标签继续打印，而不是简单记为失败。
const val SEND_COMMAND_STATE_USB_DISCONNECTED = 1008
private const val ACTION_USB_PERMISSION = "com.android.example.USB_PERMISSION"

// 单张标签发送的总超时：USB 松动/断开后 bulkTransfer 会持续失败，
// 没有总超时保护会让发送线程陷入死循环，上层永远收不到回调（表现为“卡住”）
private const val USB_SEND_TIMEOUT_MILLIS = 5000L
// 单个分片连续发送失败次数上限，超过即判定本次发送失败并中止
private const val USB_SEND_MAX_RETRY = 5

fun usbQuickSendCommand(
    context: Context,
    dataList: List<ByteArray>,
    sendCallback: (Int) -> Unit
) {
    try {
        val usbManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.getSystemService(UsbManager::class.java)
        } else {
            context.getSystemService(Context.USB_SERVICE) as UsbManager
        }
        if (usbManager != null) {//USB无异常
            var device: UsbDevice? = null
            usbManager.deviceList?.forEach {
                if (it.value.vendorId == DEVICE_VENDOR_ID) {
                    device = it.value
                    return@forEach
                }
            }
            if (device != null) {//已找到指定USB设备
                if (!usbManager.hasPermission(device)) {
                    // 权限丢失（重新插拔后可能出现）：请求权限的同时必须回调，
                    // 否则上层一直等不到结果，同样表现为“卡住”
                    usbManager.requestPermission(
                        device,
                        getBroadcast(context, 0, Intent(ACTION_USB_PERMISSION), FLAG_IMMUTABLE)
                    )
                    sendCallback.invoke(SEND_COMMAND_STATE_NO_PERMISSION)
                } else {//以获取指定USB串口权限
                    val usbInterface = device.getInterface(0)
                    val usbEndpoint = usbInterface.getEndpoint(0)
                    // 查找 IN 端点用于读取打印机状态回执
                    var usbEndpointIn: UsbEndpoint? = null
                    for (i in 0 until usbInterface.endpointCount) {
                        val ep = usbInterface.getEndpoint(i)
                        if (ep.direction == UsbConstants.USB_DIR_IN) {
                            usbEndpointIn = ep
                            break
                        }
                    }
                    val usbConnection = usbManager.openDevice(device)
                    if (usbConnection == null) {
                        // 打开失败：设备刚松动重连时可能短暂不可用，必须回调，不能静默返回
                        Log.e("Pan", "USB 打开设备失败（设备可能刚重连）")
                        sendCallback.invoke(SEND_COMMAND_STATE_USB_DISCONNECTED)
                        return
                    }

                    // claim 失败在重新插拔后较常见，必须判定并回调，不能继续发送
                    if (!usbConnection.claimInterface(usbInterface, true)) {
                        Log.e("Pan", "USB claimInterface 失败（设备可能刚重连）")
                        try {
                            usbConnection.close()
                        } catch (e: Exception) {
                            Log.w("Pan", "关闭USB连接失败：$e")
                        }
                        sendCallback.invoke(SEND_COMMAND_STATE_USB_DISCONNECTED)
                        return
                    }
                    //串口打开成功 开始发送数据
                    Thread {
                        var status=-1
                        // 是否因设备断开导致失败（用于区分“普通失败”与“等待重连”）
                        var disconnected=false
                        try {
                            val byte = bytesMerger(dataList)
                            // bulkTransfer 单次调用并不保证把整个数组发完（返回值=实际发送字节数），
                            // 单张标签指令较长（含大 BITMAP/QRCODE 时往往有几千字节）时，一次调用
                            // 只发出前一部分，剩余字节丢失/错位就会导致第 3、4 张"内容重叠/报错"。
                            // 因此按端点包大小(maxPacketSize)循环分片发送，并严格累加已发送字节，
                            // 确保整张标签指令完整下发后再等打印机回执，避免指令追尾。
                            var offset = 0
                            var failCount = 0
                            val startAt = System.currentTimeMillis()
                            val packetSize = usbEndpoint.maxPacketSize.takeIf { it > 0 } ?: 64
                            while (offset < byte.size) {
                                // 总超时保护：设备断开后 bulkTransfer 会恒失败，
                                // 若无此保护会陷入死循环，线程永不结束、回调永不触发
                                if (System.currentTimeMillis() - startAt > USB_SEND_TIMEOUT_MILLIS) {
                                    Log.e("Pan", "USB 发送超时，已发送 $offset/${byte.size} 字节")
                                    disconnected=true
                                    status = -1
                                    break
                                }
                                val len = (byte.size - offset).coerceAtMost(packetSize)
                                val sent = usbConnection.bulkTransfer(
                                    usbEndpoint,
                                    byte,
                                    offset,
                                    len,
                                    200
                                )
                                if (sent <= 0) {
                                    // 发送受阻：累计连续失败次数，超过上限即放弃，
                                    // 避免 USB 松动/重连后无限重试导致线程卡死
                                    failCount++
                                    Log.w("Pan", "USB 分片发送受阻 sent=$sent，第 $failCount 次，offset=$offset")
                                    if (failCount >= USB_SEND_MAX_RETRY) {
                                        Log.e("Pan", "USB 连续发送失败达上限，判定设备已断开")
                                        disconnected=true
                                        status = -1
                                        break
                                    }
                                    Thread.sleep(30)
                                    continue
                                }
                                failCount = 0
                                offset += sent
                            }
                            if (offset == byte.size) {
                                status = byte.size
                                // 每下发完一张标签后：先稳定等待 300ms，再查询打印机状态，
                                // 确认其回到就绪(@)状态后再返回，由上层继续下发下一张，
                                // 避免缓冲粘连导致的内容重叠/报错。
                                Thread.sleep(300)
                                getPrinterReadyUsb(usbConnection, usbEndpoint, usbEndpointIn)
                            }
                        } catch (e: Exception) {
                            Log.e("Pan", "USB 发送异常", e)
                            runBlocking(Dispatchers.Main) {
                                Toast.makeText(context, e.toString(), Toast.LENGTH_LONG).show()
                            }
                        } finally {
                            // 释放接口并关闭连接：每次发送都 openDevice，
                            // 不释放会造成句柄泄漏，重新插拔后旧连接残留导致后续发送卡死
                            try {
                                usbConnection.releaseInterface(usbInterface)
                                usbConnection.close()
                            } catch (e: Exception) {
                                Log.w("Pan", "释放USB连接失败：$e")
                            }
                            runBlocking(Dispatchers.Main) {
                                when {
                                    status >= 0 -> sendCallback.invoke(SEND_COMMAND_STATE_SUCCESS)
                                    // 设备断开：交由上层等待重连后继续
                                    disconnected -> sendCallback.invoke(
                                        SEND_COMMAND_STATE_USB_DISCONNECTED
                                    )
                                    else -> sendCallback.invoke(SEND_COMMAND_STATE_FAILED)
                                }
                            }
                        }
                    }.start()
                }
            } else {
                Toast.makeText(context, "USB操作异常：没有找到指定设备", Toast.LENGTH_LONG).show()
                sendCallback.invoke(SEND_COMMAND_STATE_NO_DEVICE)
            }
        } else {
            Toast.makeText(context, "USB操作异常：USB设备异常", Toast.LENGTH_LONG).show()
            sendCallback.invoke(SEND_COMMAND_STATE_USB_ERROR)
        }
    } catch (e: Exception) {
        Toast.makeText(context, "USB操作异常：${e.message}", Toast.LENGTH_LONG).show()
        sendCallback.invoke(SEND_COMMAND_STATE_USB_ERROR)
    }
}

fun usbPrinterIsAttached(context: Context):Boolean{
    val usbManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        context.getSystemService(UsbManager::class.java)
    } else {
        context.getSystemService(Context.USB_SERVICE) as UsbManager
    }
    var device: UsbDevice? = null
    usbManager?.deviceList?.forEach {
        if (it.value.vendorId == DEVICE_VENDOR_ID) {
            device = it.value
            return@forEach
        }
    }
    return  device!=null
}

/**
 * 初始化usb
 */
fun usbInit(context: Context, isReady: (UsbManager?, UsbDevice?) -> Unit) {
    try {
        val usbManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.getSystemService(UsbManager::class.java)
        } else {
            context.getSystemService(Context.USB_SERVICE) as UsbManager
        }
        var device: UsbDevice? = null
        usbManager?.deviceList?.forEach {
            if (it.value.vendorId == DEVICE_VENDOR_ID) {
                device = it.value
                return@forEach
            }
        }
        isReady.invoke(usbManager, device)
    } catch (e: Exception) {
        Log.e("Pan", "USB操作异常：检查usb状态", e)
    }
}

/**
 * 申请usb设备串口使用权限
 */
fun requestUsbPermission(context: Context, usbManager: UsbManager, usbDevice: UsbDevice) {
    if (!usbManager.hasPermission(usbDevice)) {
        usbManager.requestPermission(
            usbDevice,
            getBroadcast(context, 0, Intent(ACTION_USB_PERMISSION), FLAG_IMMUTABLE)
        )
    }
}

/**
 * 打开串口
 */
fun openPort(
    usbManager: UsbManager,
    usbDevice: UsbDevice,
    port: (UsbDeviceConnection, UsbEndpoint?) -> Unit
) {
    try {
        val usbInterface = usbDevice.getInterface(0)
        val usbEndpoint = usbInterface.getEndpoint(0)
        val usbConnection = usbManager.openDevice(usbDevice)
        usbConnection?.claimInterface(usbInterface, true)
        port.invoke(usbConnection, usbEndpoint)
    } catch (e: Exception) {
        Log.e("Pan", "USB操作异常：打开USB串口", e)
    }
}


/**
 * 发送长指令
 */

fun sendCommand(
    usbConnection: UsbDeviceConnection,
    usbEndpoint: UsbEndpoint,
    array: ArrayList<ByteArray>,
    callback: (Boolean) -> Unit
) {
    Thread {
        try {
            val byte = bytesMerger(array)
            usbConnection.bulkTransfer(usbEndpoint, byte, byte.size, 100)
            runBlocking(Dispatchers.Main) {
                callback.invoke(true)
            }
        } catch (e: Exception) {
            Log.e("Pan", "USB操作异常：发送数据", e)
            runBlocking(Dispatchers.Main) {
                callback.invoke(false)
            }
        }
    }.start()
}


/**
 * 发送长指令
 */
fun sendCommand(
    usbConnection: UsbDeviceConnection,
    usbEndpoint: UsbEndpoint,
    array: ArrayList<ByteArray>
) = try {
    val byte = bytesMerger(array)
    usbConnection.bulkTransfer(usbEndpoint, byte, byte.size, 100)
    true
} catch (e: Exception) {
    Log.e("Pan", "USB操作异常：发送数据", e)
    false
}

/**
 * 每下发完一张标签后调用：先由上层 sleep(300) 让打印机消化，再查询打印机状态，
 * 只有当状态明确回到"正常就绪(@)"时才返回，确保下一张标签的指令不会与上一帧
 * 打印缓冲粘连（避免 BITMAP/QRCODE 内容重叠/报错）。
 *
 * 依据 TSC 官方 TSPL2 文档（<ESC>!S 指令，page 85）：
 *   命令字节：ESC !S = 0x1B 0x21 0x53
 *   返回格式：<STX>[4-byte status]<ETX><CR><LF>（共8字节），状态字节为 ASCII 字符。
 *   状态字符：'@'(0x40)=Normal 就绪；'P'(0x50)=打印中；'B'(0x42)=回退中；
 *             'C'(0x43)=切纸中；'W'(0x57)=Imaging；'`'(0x60)=暂停。
 * 注意：<ESC>!? 需先 ~!E 启用才回执，故本函数改用无需启用的 <ESC>!S。
 *
 * 流程：用 OUT 端点发 ESC !S → 用 IN 端点读回传包 → 必须扫描到明确的就绪字符 '@'
 * (0x40) 才视为"状态正常"返回；读到忙(P/B/C/W)或暂停(`)、或读不到回执时持续重试；
 * 直到 [timeoutMillis] 超时兜底放行（避免批量卡死），并打告警日志。
 *
 * [outEndpoint] 主机->设备的端点（下发 ESC!S 查询）；[inEndpoint] 设备->主机的端点（读回执）。
 */
fun getPrinterReadyUsb(
    connection: UsbDeviceConnection?,
    outEndpoint: UsbEndpoint?,
    inEndpoint: UsbEndpoint?,
    timeoutMillis: Long = 8000
) {
    if (connection == null || outEndpoint == null || inEndpoint == null) return
    val start = System.currentTimeMillis()
    val buf = ByteArray(64)
    var lastBusy = false
    while (System.currentTimeMillis() - start < timeoutMillis) {
        try {
            // ESC !S —— 查询打印机状态（无需 ~!E 启用）。
            // 注意：查询指令必须用 OUT 端点下发（主->设备），IN 端点仅用于读回执。
            connection.bulkTransfer(outEndpoint, byteArrayOf(0x1B, 0x21, 0x53), 3, 200)
        } catch (e: Exception) {
            Log.e("Pan", "USB 发送状态查询失败", e)
            return
        }
        // 读状态回执：读超时设较短值（250ms 超时）。打印机一回到就绪(@)会立即回传，
        // bulkTransfer 随即返回；仍在忙(P)时仅等 250ms 即进入下一轮（配合下方 30ms
        // 极短重试），相比长超时大幅减少"打印机忙时每轮的无效空等"，缩短批量总停顿。
        val len = try {
            connection.bulkTransfer(inEndpoint, buf, buf.size, 250)
        } catch (e: Exception) { -1 }
        if (len > 0) {
            // TSC 状态字符（ASCII）：'@'(0x40)=Normal 就绪；'P'(0x50)=打印中；
            // 'B'(0x42)=回退中；'C'(0x43)=切纸中；'W'(0x57)=Imaging；'`'(0x60)=暂停。
            // 只有明确读到就绪字符 '@'(0x40) 才视为"状态正常"，可继续下发下一张；
            // 其余（忙/暂停/其它）一律视为未就绪，继续重发查询。
            val ready = buf.slice(0 until len).any {
                (it.toInt() and 0xFF) == 0x40
            }
            if (ready) {
                Log.d("Pan", "USB 打印机状态正常(就绪)，下发下一张")
                return
            }
            val busy = buf.slice(0 until len).any {
                val c = it.toInt() and 0xFF
                c == 0x50 || c == 0x42 || c == 0x43 || c == 0x57 || c == 0x60
            }
            lastBusy = lastBusy || busy
            // 未就绪：打印机仍在忙/暂停，极短休眠后立刻重发查询，尽快捕获回到就绪的瞬间
            Thread.sleep(30)
        } else {
            // 本轮无应答（读超时）：极短休眠后重试，直到总超时兜底放行
            Thread.sleep(30)
        }
    }
    if (lastBusy) Log.w("Pan", "USB 等待打印机就绪超时（兜底放行，注意可能串标）")
    else Log.w("Pan", "USB 打印机无回执（固件可能不支持 ESC !S，兜底放行）")
}

