package com.jd.pzx.jd_flutter.utils

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothDevice.BOND_BONDED
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.os.Build
import android.os.SystemClock
import android.util.Log
import com.jd.pzx.jd_flutter.EventDeviceMessage
import com.jd.pzx.jd_flutter.OperationType
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import org.greenrobot.eventbus.EventBus
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

/**
 * 开始扫描蓝牙
 */
@SuppressLint("MissingPermission")
fun bluetoothStartScan(bleAdapter: BluetoothAdapter): Boolean {
//    bleAdapter.enable()
    return if (bleAdapter.startDiscovery()) {
        bleAdapter.bondedDevices.forEach { bonded ->
            deviceList.find { it.device.address == bonded.address }.let { device ->
                (device ?: BDevice(bonded).apply { deviceList.add(this) }).let { dev ->
                    Log.e(
                        "Pan", "已绑定设备：${dev.device.name} isConnected:${dev.socket.isConnected}"
                    )
                    EventBus.getDefault().post(
                        EventDeviceMessage(
                            OperationType.BluetoothFind,
                            dev.getDeviceMap()
                        )
                    )
                }
            }
        }
        scanLock = true
        Thread {
            Log.e("Pan", "开启扫描经典蓝牙")
            do {
                if (!bleAdapter.isDiscovering) {
                    Log.e("Pan", "EndScan")
                    scanLock = false
                    EventBus.getDefault().post(
                        EventDeviceMessage(OperationType.BluetoothState, "EndScan")
                    )
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

@SuppressLint("MissingPermission")
fun isSearching(bleAdapter: BluetoothAdapter) = bleAdapter.isDiscovering

@SuppressLint("MissingPermission")
fun isConnected(bleAdapter: BluetoothAdapter, mac: String) = bleAdapter.bondedDevices.any {
    it.address == mac && it.bondState == BOND_BONDED
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
    send: (BluetoothSocket) -> Unit
): Int {

    try {
        if (bleAdapter.isDiscovering) {
            val cd = bleAdapter.cancelDiscovery()
            scanLock = false
            Log.e("Pan", "取消扫描经典蓝牙:$cd")
            EventBus.getDefault().post(
                EventDeviceMessage(OperationType.BluetoothState, "EndScan")
            )
        }
        Log.e("Pan", "连接经典蓝牙:$mac ")
        deviceList.find { it.device.address == mac }.let { device ->
            if (device == null) {
                Log.e("Pan", "找不到该蓝牙")
                return 2
            } else {
                device.socket.connect()
                Log.e("Pan", "经典蓝牙连接成功")
                SystemClock.sleep(500)
                send.invoke(device.socket)
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
                Thread.sleep(300)
                runBlocking(Dispatchers.Main) {
                    progress.invoke(index, dataList.size)
                }
            } while (index < dataList.size)
        } catch (e: Exception) {
            Log.e("Pan", "蓝牙操作异常：发送数据失败", e)
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
    if (dataList.isEmpty()) return
    Thread {
        try {
//            dataList.forEach {byte->
//                Log.e("Pan",byte.joinToString(" ", transform = { it.toInt().and(0xff).toString(16).padStart(2, '0') }))
//            }
            val byte = bytesMerger(dataList)
            bleSocket.outputStream?.write(byte)
            Log.e("Pan", "蓝牙发送数据:$byte")
        } catch (e: Exception) {
            Log.e("Pan", "蓝牙操作异常：发送数据失败", e)
        } finally {
            sendCallback.invoke(SEND_COMMAND_STATE_SUCCESS)
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
        it["DeviceBondState"] = device.bondState== 12
    }
}
