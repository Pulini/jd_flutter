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
                Thread.sleep(300)
                runBlocking(Dispatchers.Main) {
                    progress.invoke(index, dataList.size)
                }
            } while (index < dataList.size)
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
