package com.jd.pzx.jd_flutter.utils.print

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.os.Build
import android.os.SystemClock
import android.util.Log
import com.jd.pzx.jd_flutter.utils.tscUUID
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import java.io.IOException
import java.util.UUID

/**
 * Created by : PanZX on 2023/12/21
 * Email : 644173944@qq.com
 * Github : https://github.com/Pulini
 * Remark: 蓝牙连接工具
 */
@SuppressLint("MissingPermission", "UnspecifiedRegisterReceiverFlag")
class BleUtil(
    private val context: Context,
    private val uuid: UUID,
) {
    var bleState = -1
    private var isConnected = false
    private var exit = false
    private var bleAdapter: BluetoothAdapter? = null
    var bleDevice: BluetoothDevice? = null
    private var bleSocket: BluetoothSocket? = null
    private var connectSuccessful: () -> Unit={}

    fun refreshBleAdapter() {
        bleAdapter = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.getSystemService(BluetoothManager::class.java).adapter
        } else {
            (context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager).adapter
        }
        if (bleAdapter == null) {
            bleState= BT_STATE_NOT_SUPPORTED
        }
    }


    fun disconnected(){
        bleState= BT_STATE_NOT_CONNECTED
        isConnected = false
        bleSocket = null
    }

    fun stateOff(){
        close()
        bleState= BT_STATE_CLOSED
    }

    /**
     * 是否正在搜索
     */
    fun isSearching() = bleAdapter != null && bleAdapter!!.isDiscovering

    /**
     * 是否已连接
     */
    fun isConnected() = isConnected




    /**
     * 是否有蓝牙
     */
    fun hasBlueTooth(): Boolean {
        if (bleAdapter != null) {
            openBlueTooth()
        }
        return bleAdapter != null
    }

    /**
     * 开启蓝牙
     */

     fun openBlueTooth() {
        if (bleAdapter != null && !bleAdapter!!.isEnabled) bleAdapter!!.enable()
    }


    /**
     * 开始扫描蓝牙
     */
     fun startScan(
        bleScanStart: () -> Unit,
        bleFindDevice: (BluetoothDevice) -> Unit,
        bleScanFinished: () -> Unit,
     ) {
        if (bleAdapter != null) {
            bleScanStart.invoke()
            exit = false
            Thread {
                Log.e("Pan","检查蓝牙----------")
                while (!exit) {
                    SystemClock.sleep(200)
                    if (!bleAdapter!!.isDiscovering ) {
                        exit = true
                        bleScanFinished.invoke()
                    }
                }
            }.start()
            Log.e("Pan","startDiscovery=${bleAdapter!!.startDiscovery()}")
        }
    }

    /**
     * 取消扫描
     */
     fun cancelScan(finishScan:()->Unit) {
        if (bleAdapter != null ) {
            if (bleAdapter!!.isDiscovering) {
                exit = true
                finishScan.invoke()
            }
            if (bleAdapter!!.isDiscovering) bleAdapter!!.cancelDiscovery()
        }
    }

    fun setConnectListener(connected:()->Unit){
        connectSuccessful=connected
    }

    /**
     * 连接蓝牙
     */
    fun connect(bluetooth: BluetoothDevice, connect:(Boolean, BluetoothDevice?)->Unit) {
        Thread {
            try {
                bleSocket = bluetooth.createRfcommSocketToServiceRecord(uuid).apply { connect() }
                bleDevice=bluetooth
                Log.e("Pan", "连接成功")
                runBlocking(Dispatchers.Main) {
                    isConnected = true
                    connect.invoke(true, bluetooth)
                    connectSuccessful.invoke()
                    bleState= BT_STATE_READY
                }
            } catch (e: IOException) {
                Log.e("Pan", "连接失败", e)
                runBlocking(Dispatchers.Main) {
                    isConnected = false
                    bleSocket = null
                    connect.invoke(false, null)
                    bleState= BT_STATE_NOT_CONNECTED
                }
            }
        }.start()
    }

    /**
     * 关闭蓝牙
     */
    fun close() {
        try {
            bleSocket?.close()
            bleSocket = null
            isConnected = false
            exit = true
        } catch (e: IOException) {
            Log.e("Pan", "关闭失败", e)
        }
    }

    /**
     * 合并ByteArray
     */
    private fun bytesMerger(byteArray: ArrayList<ByteArray>) =
        ByteArray(byteArray.sumOf { it.size }).apply {
            var index = 0
            for (bytes in byteArray) {
                System.arraycopy(bytes, 0, this, index, bytes.size)
                index += bytes.size
            }
        }

    /**
     * 发送长指令
     */
    fun sendCommand(array: ArrayList<ByteArray>, callback: (Boolean) -> Unit) {
        Thread {
            if (bleSocket != null) {
                bleSocket!!.outputStream?.write(bytesMerger(array))
                SystemClock.sleep(500)
                runBlocking(Dispatchers.Main) {
                    callback.invoke(true)
                }
            } else {
                runBlocking(Dispatchers.Main) {
                    callback.invoke(false)
                }
            }
        }.start()

    }

    /**
     * 发送长指令
     */
    fun sendCommand(array: ArrayList<ByteArray>) = if (bleSocket != null) {
        bleSocket!!.outputStream?.write(bytesMerger(array))
        true
    } else {
        false
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
}