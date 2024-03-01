package com.jd.pzx.jd_flutter.utils

import android.Manifest
import android.Manifest.permission.ACCESS_FINE_LOCATION
import android.Manifest.permission.BLUETOOTH
import android.Manifest.permission.BLUETOOTH_ADMIN
import android.Manifest.permission.BLUETOOTH_CONNECT
import android.Manifest.permission.BLUETOOTH_SCAN
import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.app.ActivityCompat.requestPermissions
import androidx.core.content.ContextCompat
import androidx.core.content.ContextCompat.checkSelfPermission
import androidx.core.content.PermissionChecker.PERMISSION_GRANTED
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


fun checkBluetooth(activity: Activity) {
    requestPermissions(
        activity,
        arrayOf(
            BLUETOOTH,
            BLUETOOTH_SCAN,
            BLUETOOTH_ADMIN,
            BLUETOOTH_CONNECT,
            ACCESS_FINE_LOCATION,
        ),
        REQUEST_BLUETOOTH_PERMISSIONS
    )
    val request = arrayOf(
        BLUETOOTH,
        BLUETOOTH_SCAN,
        BLUETOOTH_ADMIN,
        BLUETOOTH_CONNECT,
        ACCESS_FINE_LOCATION,
    ).filter { checkSelfPermission(activity, it) != PERMISSION_GRANTED }
    if (request.isNotEmpty()) {
        requestPermissions(
            activity,
            request.toTypedArray(),
            REQUEST_BLUETOOTH_PERMISSIONS
        )
    }else{
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            activity.getSystemService(BluetoothManager::class.java).adapter
        } else {
            (activity.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager).adapter
        }

    }
}

fun bluetoothIsEnable(context: Context): Boolean {
    return try {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.getSystemService(BluetoothManager::class.java).adapter
        } else {
            (context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager).adapter
        }?.isEnabled == true
    } catch (e: Exception) {
        Log.e("Pan", "经典蓝牙操作异常：检查蓝牙", e)
        false
    }
}

/**
 * 开始扫描蓝牙
 */
@SuppressLint("MissingPermission")
fun bluetoothStartScan(bleAdapter: BluetoothAdapter) {
    try {
        bleAdapter.startDiscovery()
    } catch (e: Exception) {
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
