package com.jd.pzx.jd_flutter.utils

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.os.Build
import android.util.Log
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
const val REQUEST_BLUETOOTH_PERMISSIONS = 1223
const val REQUEST_ENABLE_BT = 1224
const val PRINTER_UUID = "00001101-0000-1000-8000-00805F9B34FB"
fun bluetoothInit(context: Context, isReady: (BluetoothAdapter?) -> Unit) {
    try {
        isReady.invoke(
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                context.getSystemService(BluetoothManager::class.java).adapter
            } else {
                (context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager).adapter
            }
        )
    } catch (e: Exception) {
        Log.e("Pan", "经典蓝牙操作异常：检查蓝牙", e)
    }
}

/**
 * 开始扫描蓝牙
 */
@SuppressLint("MissingPermission")
fun bluetoothStartScan(bleAdapter: BluetoothAdapter) {
    try {
        bleAdapter.startDiscovery()
    } catch (e:Exception) {
        Log.e("Pan", "经典蓝牙操作异常：开启扫描经典蓝牙", e)
    }
}

/**
 * 取消扫描
 */
@SuppressLint("MissingPermission")
fun bluetoothCancelScan(bleAdapter: BluetoothAdapter) {
    try {
        bleAdapter.cancelDiscovery()
    } catch (e: Exception) {
        Log.e("Pan", "经典蓝牙操作异常：取消扫描经典蓝牙", e)
    }
}

/**
 * 连接蓝牙
 */
@SuppressLint("MissingPermission")
fun bluetoothConnect(bluetooth: BluetoothDevice, socket: (BluetoothSocket?) -> Unit) {
    Thread {
        try {
            val bleSocket = bluetooth.createRfcommSocketToServiceRecord(
                UUID.fromString(PRINTER_UUID)
            ).apply { connect() }
            Log.e("Pan", "连接成功")
            runBlocking(Dispatchers.Main) {
                socket.invoke(bleSocket)
            }
        } catch (e: Exception) {
            Log.e("Pan", "连接失败", e)
            runBlocking(Dispatchers.Main) {
                socket.invoke(null)
            }
        }
    }.start()
}
