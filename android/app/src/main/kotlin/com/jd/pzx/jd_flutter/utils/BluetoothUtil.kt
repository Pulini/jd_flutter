package com.jd.pzx.jd_flutter.utils

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothDevice.BOND_BONDED
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.os.Build
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import java.io.IOException
import java.util.HashMap
import java.util.UUID

/**
 * Created by : PanZX on 2024/02/28
 * Email : 644173944@qq.com
 * Github : https://github.com/Pulini
 * Remark: 经典蓝牙工具
 */
const val REQUEST_BLUETOOTH_PERMISSIONS = 1223
const val REQUEST_ENABLE_BT = 1224
const val PRINTER_UUID = "00001101-0000-1000-8000-00805F9B34FB"
val tscUUID: UUID = UUID.fromString(PRINTER_UUID)
val devices = mutableListOf<BluetoothDevice>()
var bluetoothSocket: BluetoothSocket? = null
fun bluetoothAdapter(context: Context): BluetoothAdapter? {
    return try {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            (context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager).adapter
        } else {
            context.getSystemService(BluetoothManager::class.java).adapter
        }
    } catch (e: Exception) {
        Log.e("Pan", "经典蓝牙操作异常：检查蓝牙\n", e)
        null
    }
}

/**
 * 蓝牙设备是否可用
 */
fun bluetoothIsEnable(bleAdapter: BluetoothAdapter?) = bleAdapter?.isEnabled == true

/**
 * 开始扫描蓝牙
 */
@SuppressLint("MissingPermission")
fun bluetoothStartScan(bleAdapter: BluetoothAdapter) {
    devices.clear()
    bleAdapter.startDiscovery()
    Log.e("Pan", "开启扫描经典蓝牙")
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
fun bluetoothCancelScan(bleAdapter: BluetoothAdapter) {
    bleAdapter.cancelDiscovery()
    Log.e("Pan", "取消扫描经典蓝牙")
}

/**
 * 连接蓝牙
 */
@SuppressLint("MissingPermission")
fun bluetoothConnect(mac: String): Boolean {
    try {
        Log.e("Pan", "连接经典蓝牙:$mac")
        devices.find { it.address == mac }?.let { device ->
            bluetoothSocket = device.createRfcommSocketToServiceRecord(tscUUID)
            bluetoothSocket?.connect()
            Log.e("Pan", "经典蓝牙连接成功:$mac")
            return true
        }
        return false
    } catch (e: IOException) {
        Log.e("Pan", "经典蓝牙操作异常：连接经典蓝牙\n", e)
        return false
    }
}

/**
 * 断开蓝牙
 */
@SuppressLint("MissingPermission")
fun bluetoothClose() {
    try {
        if (bluetoothSocket?.isConnected == true) {
            bluetoothSocket?.close()
            bluetoothSocket = null
        }
        devices.clear()
    } catch (e: IOException) {
        Log.e("Pan", "经典蓝牙操作异常：关闭失败\n", e)
    }
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
            } while (index <= dataList.size)
        } catch (e: Exception) {
            Log.e("Pan", "USB操作异常：发送数据失败", e)
        } finally {
            if (index == dataList.size) {
                sendCallback.invoke(SEND_COMMAND_STATE_SUCCESS)
            } else {
                sendCallback.invoke(SEND_COMMAND_STATE_PART_SUCCESS)
            }
        }
    }.start()
}

@SuppressLint("MissingPermission")
fun bluetoothGetDevicesList(bleAdapter: BluetoothAdapter) = HashMap<String, Any>().also {
    bleAdapter.bondedDevices.forEach { device ->
        it["DeviceName"] = device.name
        it["DeviceMAC"] = device.address
        it["DeviceIsConnected"] = device.bondState == BOND_BONDED
        it["DeviceBondState"] = device.bondState
    }
}
