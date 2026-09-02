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
private const val ACTION_USB_PERMISSION = "com.android.example.USB_PERMISSION"

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
                    usbManager.requestPermission(
                        device,
                        getBroadcast(context, 0, Intent(ACTION_USB_PERMISSION), FLAG_IMMUTABLE)
                    )
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

                    usbConnection?.claimInterface(usbInterface, true)
                    //串口打开成功 开始发送数据
                    Thread {
                        var status=-1
                        try {
                            val byte = bytesMerger(dataList)
                            // bulkTransfer 单次调用并不保证把整个数组发完（返回值=实际发送字节数），
                            // 单张标签指令较长（含大 BITMAP/QRCODE 时往往有几千字节）时，一次调用
                            // 只发出前一部分，剩余字节丢失/错位就会导致第 3、4 张"内容重叠/报错"。
                            // 因此按端点包大小(maxPacketSize)循环分片发送，并严格累加已发送字节，
                            // 确保整张标签指令完整下发后再等打印机回执，避免指令追尾。
                            var offset = 0
                            val packetSize = usbEndpoint.maxPacketSize.takeIf { it > 0 } ?: 64
                            while (offset < byte.size) {
                                val len = (byte.size - offset).coerceAtMost(packetSize)
                                val sent = usbConnection.bulkTransfer(
                                    usbEndpoint,
                                    byte,
                                    offset,
                                    len,
                                    100
                                )
                                if (sent <= 0) {
                                    // 发送受阻：短暂让出后重试该分片，避免丢字节
                                    Log.w("Pan", "USB 分片发送受阻 sent=$sent，重试 offset=$offset")
                                    Thread.sleep(20)
                                    continue
                                }
                                offset += sent
                            }
                            status = if (offset == byte.size) byte.size else -1
                            // 每下发完一张标签后：先稳定等待 300ms，再查询打印机状态，
                            // 确认其回到就绪(@)状态后再返回，由上层继续下发下一张，
                            // 避免缓冲粘连导致的内容重叠/报错。
                            Thread.sleep(300)
                            getPrinterReadyUsb(usbConnection, usbEndpoint, usbEndpointIn)
                        } catch (e: Exception) {
                            runBlocking(Dispatchers.Main) {
                                Toast.makeText(context, e.toString(), Toast.LENGTH_LONG).show()
                            }
                        } finally {
                            runBlocking(Dispatchers.Main) {
                                if (status >= 0) {
                                    sendCallback.invoke(SEND_COMMAND_STATE_SUCCESS)
                                } else {
                                    sendCallback.invoke(SEND_COMMAND_STATE_FAILED)
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

