package com.jd.pzx.jd_flutter.utils

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothDevice.BOND_BONDED
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.location.LocationManager
import android.os.Build
import android.os.SystemClock
import android.util.Log
import androidx.core.content.ContextCompat.getSystemService
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking

import java.io.IOException
import java.util.UUID


/**
 * Created by : PanZX on 2024/02/28
 * Email : 644173944@qq.com
 * Github : https://github.com/Pulini
 * Remark: 经典蓝牙工具
 */
const val REQUEST_ENABLE_BT = 1224
val tscUUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
val deviceList = mutableListOf<BDevice>()
var scanLock: Boolean = false
fun bluetoothAdapter(context: Context): BluetoothAdapter? {
    var adapter: BluetoothAdapter? = null

    try {
        adapter = if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            (context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager).adapter
        } else {
            context.getSystemService(BluetoothManager::class.java).adapter
        }
    } catch (e: Exception) {
        Log.e("Pan", "经典蓝牙操作异常：检查蓝牙\n", e)
    }
    Log.e("Pan", "经典蓝牙adapter=${adapter != null}")
    return adapter
}

/**
 * 蓝牙设备是否可用
 */
fun bluetoothIsEnable(bleAdapter: BluetoothAdapter?) = bleAdapter?.isEnabled == true

@SuppressLint("MissingPermission")
fun isSearching(bleAdapter: BluetoothAdapter) = bleAdapter.isDiscovering

@SuppressLint("MissingPermission")
fun deviceIsConnected(bleAdapter: BluetoothAdapter, mac: String) = bleAdapter.bondedDevices.any {
    it.address == mac && it.bondState == BOND_BONDED
}

fun locationOn(context: Context): Boolean {
    getSystemService(context, LocationManager::class.java).let { lm ->
        if (lm == null) {
            return false
        } else {
            return lm.isProviderEnabled(LocationManager.GPS_PROVIDER)
        }
    }
}


/**
 * 开始扫描蓝牙
 */
@SuppressLint("MissingPermission")
fun bluetoothStartScan(
    bleAdapter: BluetoothAdapter,
    bondedDevices: (BDevice) -> Unit
): Boolean {
    bleAdapter.enable()
    Log.e("Pan", "已绑定设备=${bleAdapter.bondedDevices.size}")
    return if (bleAdapter.startDiscovery()) {
        val bondedList = mutableListOf<BDevice>()
        bleAdapter.bondedDevices.forEach { bonded ->
            deviceList.find { it.device.address == bonded.address }.let { device ->
                val dev = device ?: BDevice(bonded)
                bondedList.add(dev)
                Log.e(
                    "Pan", "已绑定设备：${dev.device.name} isConnected:${dev.socket.isConnected}"
                )
                bondedDevices.invoke(dev)
            }
        }
        deviceList.clear()
        deviceList.addAll(bondedList)

        scanLock = true
        Thread {
            Log.e("Pan", "开启扫描经典蓝牙")
            do {
                if (!bleAdapter.isDiscovering) {
                    Log.e("Pan", "EndScan")
                    scanLock = false
                } else {
                    SystemClock.sleep(200)
                }
            } while (scanLock)
        }.start()
        true
    } else {
        Log.e("Pan", "开启扫描经典蓝牙失败")
        false
    }

}

/**
 * 取消扫描
 */
@SuppressLint("MissingPermission")
fun bluetoothCancelScan(bleAdapter: BluetoothAdapter): Boolean {
    val cd = bleAdapter.cancelDiscovery()
    scanLock = false
    Log.e("Pan", "取消扫描经典蓝牙:$cd")
    return cd
}

/**
 * 连接蓝牙
 */
@SuppressLint("MissingPermission")
fun bluetoothConnect(
    bleAdapter: BluetoothAdapter,
    mac: String,
): Int {
    try {
        if (bleAdapter.isDiscovering) {
            val cd = bleAdapter.cancelDiscovery()
            scanLock = false
            Log.e("Pan", "取消扫描经典蓝牙:$cd")
        }
        Log.e("Pan", "连接经典蓝牙:$mac ")
        deviceList.forEach {
            Log.e("Pan", "经典蓝牙:${it.device.address} ")
        }
        deviceList.find { it.device.address == mac }.let { device ->
            if (device == null) {
                Log.e("Pan", "找不到该蓝牙")
                return 2
            } else {
                device.socket.connect()
                Log.e("Pan", "经典蓝牙连接成功")
                SystemClock.sleep(500)
                return 0
            }
        }
    } catch (e: IOException) {
        Log.e("Pan", "经典蓝牙操作异常：连接经典蓝牙\n", e)
        return 1
    }
}

/**
 * 断开蓝牙
 */
@SuppressLint("MissingPermission")
fun bluetoothClose(mac: String): Boolean {
    try {
        deviceList.find { it.device.address == mac }?.let { device ->
            device.socket.close()
            SystemClock.sleep(200)
            //socket 关闭即结束通道，无法再次连接，需要重新创建通道
            device.socket = device.device.createRfcommSocketToServiceRecord(tscUUID)
            return true
        }
    } catch (e: IOException) {
        Log.e("Pan", "经典蓝牙操作异常：关闭失败\n", e)
        return false
    }
    return false
}

/**
 * 发送长指令
 */
fun bluetoothSendCommand(
    bleSocket: BluetoothSocket,
    dataList: ArrayList<List<ByteArray>>,
    progress: (Int, Int) -> Unit,
    sendCallback: (Int) -> Unit
) {
    if (dataList.isEmpty()) return
    Thread {
        var index = 0
        try {
            do {
                val byte = bytesMerger(dataList[index])
                bleSocket.outputStream?.write(byte)
                index++
                runBlocking(Dispatchers.Main) {
                    progress.invoke(index, dataList.size)
                }
            } while (index < dataList.size)
            // 整条标签发送完成后，等待打印机回执确认空闲（非打印中）再继续，
            // 避免下一条标签的指令与本条打印缓冲串扰导致二维码/内容错乱。
            waitPrinterIdle(bleSocket)
        } catch (e: IOException) {
            Log.e("Pan", "蓝牙操作异常：通道已断开", e)
            sendCallback.invoke(SEND_COMMAND_STATE_BROKEN_PIPE)
        } catch (e: Exception) {
            Log.e("Pan", "蓝牙操作异常：发送数据失败", e)
            sendCallback.invoke(SEND_COMMAND_STATE_FAILED)
        } finally {
            if (index == dataList.size) {
                sendCallback.invoke(SEND_COMMAND_STATE_SUCCESS)
            } else {
                sendCallback.invoke(SEND_COMMAND_STATE_PART_SUCCESS)
            }
        }
    }.start()
}

fun bluetoothSendCommand(
    bleSocket: BluetoothSocket,
    dataList: List<ByteArray>,
    sendCallback: (Int) -> Unit
) {
    if (dataList.isEmpty()) {
        sendCallback.invoke(SEND_COMMAND_STATE_FAILED)
        return
    }
    Thread {
        try {
            val byte = bytesMerger(dataList)
            bleSocket.outputStream?.write(byte)
            Log.e("Pan", "蓝牙发送数据:$byte")
            // 等待打印机回执确认空闲后再回调，保证下一条标签不会与本条串扰
            waitPrinterIdle(bleSocket)
            sendCallback.invoke(SEND_COMMAND_STATE_SUCCESS)
        } catch (e: IOException) {
            Log.e("Pan", "蓝牙操作异常：通道已断开", e)
            sendCallback.invoke(SEND_COMMAND_STATE_BROKEN_PIPE)
        } catch (e: Exception) {
            Log.e("Pan", "蓝牙操作异常：发送数据失败", e)
            sendCallback.invoke(SEND_COMMAND_STATE_FAILED)
        }
    }.start()
}


@SuppressLint("MissingPermission")
data class BDevice(
    var device: BluetoothDevice,
    var socket: BluetoothSocket = device.createRfcommSocketToServiceRecord(tscUUID)
) {
    fun getDeviceMap() = hashMapOf<String, Any>().also {
        it["DeviceName"] = device.name
        it["DeviceMAC"] = device.address
        it["DeviceIsConnected"] = socket.isConnected
        it["DeviceBondState"] = device.bondState == 12
    }
}

/**
 * 每条标签发送完成后，通过打印机回执机制等待其回到就绪状态再返回，以确保
 * 下一条标签的指令不会与上一条的打印缓冲粘连导致 BITMAP/QRCODE 内容错乱。
 *
 * 依据 TSC 官方 TSPL2 文档（<ESC>!S 指令，page 85）：
 *   命令字节：ESC !S = 0x1B 0x21 0x53
 *   返回格式：<STX>[4-byte status]<ETX><CR><LF>  （即 0x02 + 4状态字节 + 0x03 + 0D 0A，共8字节）
 *   状态字节#1（STX 后第 1 个状态字节）含义（ASCII 字符）：
 *     0x40('@')=Normal 就绪   0x50('P')=Printing 打印中   0x42('B')=Backing 回退中
 *     0x43('C')=Cutting 切纸  0x45('E')=Printer error      0x60('`')=Pause 暂停
 *     0x57('W')=Imaging
 *   就绪判定：状态字节#1 == 0x40('@')。
 *
 * 注意：<ESC>!? 是旧版立即指令，需先发 ~!E 启用才回执；本函数改用无需启用的 <ESC>!S。
 * 实现流程（对齐官方 SDK status()）：发命令 → sleep(1000) → 读回传包 → 解析第2字节为'@'即返回；
 * 读到非'@'表示仍在忙则重试；完全读不到则 [timeoutMillis] 兜底放行，避免批量卡死。
 *
 * @param timeoutMillis 总超时（默认 8000ms），超时无论是否就绪都放行，避免批量卡死。
 */
fun waitPrinterIdle(socket: BluetoothSocket, timeoutMillis: Long = 8000) {
    val out = try { socket.outputStream } catch (e: Exception) { null } ?: return
    val input = try { socket.inputStream } catch (e: Exception) { null } ?: return
    // 先清空可能残留的回传数据，确保本次读到的就是对 ESC !S 的应答
    try {
        val leftover = input.available()
        if (leftover > 0) input.skip(leftover.toLong())
    } catch (e: Exception) { /* 忽略 */ }

    val start = System.currentTimeMillis()
    val buf = ByteArray(64)
    var lastBusy = false
    while (System.currentTimeMillis() - start < timeoutMillis) {
        try {
            out.write(byteArrayOf(0x1B, 0x21, 0x53)) // ESC !S
            out.flush()
        } catch (e: Exception) {
            Log.e("Pan", "发送状态查询失败", e)
            return
        }
        // 发完立即读：蓝牙输入流会阻塞到有回执才返回，打印机一就绪即可拿到 '@'，
        // 避免固定 500ms 死等造成批量打印的累积停顿。读不到(超时/异常)则短睡重试。
        val len = try { input.read(buf) } catch (e: Exception) { -1 }
        if (len > 0) {
            // TSC 状态字符（ASCII）：'@'(0x40)=Normal 就绪；'P'(0x50)=打印中，
            // 'B'(0x42)=回退中，'C'(0x43)=切纸中，'W'(0x57)=Imaging，'`'(0x60)=暂停。
            // 只要回传包中不含明显的"忙"状态字符，即视为打印机已就绪，可下发下一条。
            val busy = buf.slice(0 until len).any {
                val c = it.toInt() and 0xFF
                c == 0x50 || c == 0x42 || c == 0x43 || c == 0x57
            }
            if (!busy) {
                Log.d("Pan", "打印机就绪，下发下一张")
                return
            }
            lastBusy = true
        }
        // 读不到有效回传：本轮无应答，短睡后重试（蓝牙 read 阻塞已消耗等待，这里仅兜底）
        Thread.sleep(150)
    }
    if (lastBusy) Log.w("Pan", "等待打印机就绪超时（兜底放行，注意可能串标）")
    else Log.w("Pan", "打印机无回执（固件可能不支持 ESC !S，兜底放行）")
}
