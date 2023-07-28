package com.jd.pzx.jd_flutter.bluetooth

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.util.Log
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.IOException
import java.util.*

/**
 * File Name : BlueToothUtil
 * Created by : PanZX on  2021/05/31 16:50
 * Email : 644173944@qq.com
 * Github : https://github.com/Pulini
 * Remark :
 */
const val BLUETOOTH_ADAPTER_STATE_OFF = "android.bluetooth.BluetoothAdapter.STATE_OFF"
const val BLUETOOTH_ADAPTER_STATE_ON = "android.bluetooth.BluetoothAdapter.STATE_ON"

@SuppressLint("MissingPermission")
class BlueToothUtil {
    /**
     * 实例化工具类
     */
    companion object {
        private var util: BlueToothUtil? = null
            get() {
                if (field == null) {
                    field = BlueToothUtil()
                }
                return field
            }
        val permissions = arrayOf(
            Manifest.permission.BLUETOOTH,
            Manifest.permission.BLUETOOTH_SCAN,
            Manifest.permission.BLUETOOTH_ADMIN,
            Manifest.permission.BLUETOOTH_CONNECT,
            Manifest.permission.ACCESS_FINE_LOCATION,
        )

        @Synchronized
        fun getInstance(): BlueToothUtil {
            return util!!
        }
    }

    private var isConnected = false
    private var bluetoothSocket: BluetoothSocket? = null
    private val uuid = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
    var printer: PrinterUtil? = null




    /**
     * 连接蓝牙
     */
    @OptIn(DelicateCoroutinesApi::class)
    fun connect(bluetooth: BluetoothDevice) {
        GlobalScope.launch(Dispatchers.IO) {
            try {
                bluetoothSocket = bluetooth.createRfcommSocketToServiceRecord(uuid)
                bluetoothSocket!!.connect()
                launch(Dispatchers.Main) {
                    Log.e("Pan", "连接成功")
                    isConnected = true
//                    printer = PrinterUtil(context ,bluetoothSocket!!)
//                    bleDialog!!.connect(isConnected, bluetooth, connect)
                }
            } catch (e: IOException) {
                launch(Dispatchers.Main) {
                    Log.e("Pan", "连接失败", e)
                    isConnected = false
                    printer = null
//                    bleDialog!!.connect(false, bluetooth, connect)
                }
            }

        }
    }


}