package com.jd.pzx.jd_flutter

import android.annotation.SuppressLint
import android.app.Activity
import android.app.PendingIntent
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothAdapter.ACTION_DISCOVERY_FINISHED
import android.bluetooth.BluetoothAdapter.ACTION_DISCOVERY_STARTED
import android.bluetooth.BluetoothAdapter.ACTION_STATE_CHANGED
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothDevice.ACTION_ACL_CONNECTED
import android.bluetooth.BluetoothDevice.ACTION_ACL_DISCONNECTED
import android.bluetooth.BluetoothDevice.ACTION_FOUND
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.hardware.usb.UsbManager.ACTION_USB_ACCESSORY_ATTACHED
import android.hardware.usb.UsbManager.ACTION_USB_ACCESSORY_DETACHED
import android.hardware.usb.UsbManager.ACTION_USB_DEVICE_ATTACHED
import android.hardware.usb.UsbManager.ACTION_USB_DEVICE_DETACHED
import android.os.Build
import android.os.SystemClock
import android.util.Log
import com.jd.pzx.jd_flutter.utils.BDevice
import com.jd.pzx.jd_flutter.utils.deviceList
import tw.com.prolific.pl2303gmultilib.PL2303GMultiLib

/**
 * File Name : USBReceiver
 * Created by : PanZX on  2022/05/04 16:56
 * Email : 644173944@qq.com
 * Github : https://github.com/Pulini
 * Remark :
 */
const val ACTION_USB_PERMISSION = "com.android.example.USB_PERMISSION"
const val BLUETOOTH_STATE_OFF = "android.bluetooth.BluetoothAdapter.STATE_OFF"
const val BLUETOOTH_STATE_ON = "android.bluetooth.BluetoothAdapter.STATE_ON"
const val ACTION_ID1 = "nlscan.action.SCANNER_RESULT"
const val BarCode1 = "SCAN_BARCODE1"
const val ACTION_ID2 = "com.android.server.scannerservice.broadcast"
const val BarCode2 = "scannerdata"
const val ACTION_ID3 = "com.sunmi.scanner.ACTION_DATA_CODE_RECEIVED"
const val BarCode3 = "data"
const val ACTION_ID4 = "android.intent.ACTION_DECODE_DATA"
const val BarCode4 = "barcode_string"
const val WEIGHT_DEVICE_DETACHED = "tw.PL2303MultiUSBMessage"
const val WEIGHT_DEVICE_NAME = "com.prolific.pl2300G_multisimpletest.USB_PERMISSION"
enum class WeightState {
    WEIGHT_MSG_DEVICE_DETACHED,
    WEIGHT_MSG_DEVICE_NOT_CONNECTED,
    WEIGHT_MSG_OPEN_DEVICE_SUCCESS,
    WEIGHT_MSG_OPEN_DEVICE_FAILED,
    WEIGHT_MSG_READ_ERROR,
}

@SuppressLint("MissingPermission", "UnspecifiedRegisterReceiverFlag")
class ReceiverUtil(
    private val context: Context,
    private val usbAttached: () -> Unit,
    private val usbDetached: () -> Unit,
    private val weighbridgeState: (WeightState) -> Unit,
    private val weighbridgeRead: (Double) -> Unit,
    private val bleDisconnected: () -> Unit,
    private val bleConnected: () -> Unit,
    private val bleScanStart: () -> Unit,
    private val bleFindDevice: (HashMap<String, Any>) -> Unit,
    private val bleScanFinished: () -> Unit,
    private val bleStateOff: () -> Unit,
    private val bleStateOn: () -> Unit,
    private val bleStateClose: () -> Unit,
    private val bleStateOpen: () -> Unit,
    private val scanCode: (String) -> Unit,
) {
    //东集扫码枪密码:4007770876
    private var permissionListener: (Boolean) -> Unit = {}
    private var serialMulti: PL2303GMultiLib? = null
    private var readThread: WeighbridgeReadThread? = null

    /**
     * USB广播接收器
     */
    @Suppress("DEPRECATION")
    private val usbReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                ACTION_ID1 -> scanCode.invoke(intent.getStringExtra(BarCode1).toString())
                ACTION_ID2 -> scanCode.invoke(intent.getStringExtra(BarCode2).toString())
                ACTION_ID3 -> scanCode.invoke(intent.getStringExtra(BarCode3).toString())
                ACTION_ID4 -> scanCode.invoke(intent.getStringExtra(BarCode4).toString())
                ACTION_USB_PERMISSION -> {
                    Log.e("Pan", "USB设备权限申请结果")
                    synchronized(this) {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            intent.getParcelableExtra(
                                UsbManager.EXTRA_DEVICE,
                                UsbDevice::class.java
                            )
                        } else {
                            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                        }.let { device ->
                            permissionListener.invoke(
                                if (device != null) {
                                    intent.getBooleanExtra(
                                        UsbManager.EXTRA_PERMISSION_GRANTED,
                                        false
                                    )
                                } else {
                                    false
                                }
                            )
                        }
                    }
                }

                ACTION_USB_DEVICE_ATTACHED, ACTION_USB_ACCESSORY_ATTACHED -> {
                    Log.e("Pan", "USB设备插入")
                    usbAttached.invoke()
                }

                ACTION_USB_DEVICE_DETACHED, ACTION_USB_ACCESSORY_DETACHED,WEIGHT_DEVICE_DETACHED -> {
                    Log.e("Pan", "USB设备拔出")
                    if(intent.action==WEIGHT_DEVICE_DETACHED){
                        weighbridgeState.invoke(WeightState.WEIGHT_MSG_DEVICE_DETACHED)
                    }else{
                        usbDetached.invoke()
                    }
                }

                ACTION_ACL_CONNECTED -> {
                    Log.e("Pan", "蓝牙设备已连接")
                    bleConnected.invoke()
                }

                ACTION_ACL_DISCONNECTED -> {
                    Log.e("Pan", "蓝牙设备断开")
                    val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(
                            BluetoothDevice.EXTRA_DEVICE,
                            BluetoothDevice::class.java
                        )
                    } else {
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                    }?.let { device ->
                        Log.e("Pan", "device=${device.address}")
                        deviceList.forEach {
                            Log.e("Pan", "${it.device.name}---${it.socket.isConnected}")
                        }
                    }
                    bleDisconnected.invoke()
                }


                ACTION_DISCOVERY_STARTED -> {
                    Log.e("Pan", "扫描经典蓝牙")
                    bleScanStart.invoke()
                }

                ACTION_DISCOVERY_FINISHED -> {
                    Log.e("Pan", "经典蓝牙结束")
                    bleScanFinished.invoke()
                }

                ACTION_FOUND -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    intent.getParcelableExtra(
                        BluetoothDevice.EXTRA_DEVICE,
                        BluetoothDevice::class.java
                    )
                } else {
                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                }?.let { device ->
                    if (!device.name.isNullOrEmpty()) {
                        if (deviceList.none { it.device.address == device.address }) {
                            Log.e(
                                "Pan",
                                "发现经典蓝牙 Name=${device.name} Address=${device.address}"
                            )
                            BDevice(device).let {
                                deviceList.add(it)
                                bleFindDevice.invoke(it.getDeviceMap())
                            }
                        }
                    }
                }

                BLUETOOTH_STATE_OFF -> {
                    bleStateOff.invoke()
                }

                BLUETOOTH_STATE_ON -> {
                    bleStateOn.invoke()
                }

                ACTION_STATE_CHANGED -> {
                    when (intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, 0)) {
                        BluetoothAdapter.STATE_OFF -> {
                            Log.e("Pan", "蓝牙关闭")
                            bleStateClose.invoke()
                        }

                        BluetoothAdapter.STATE_ON -> {
                            Log.e("Pan", "蓝牙打开")
                            bleStateOpen.invoke()
                        }
                    }
                }
            }
        }
    }

    /**
     * 检查USB权限并在尚未获得权限的时候主动发起申请
     */
    fun usbDeviceRequestPermission(
        usbManager: UsbManager,
        device: UsbDevice?,
        permission: (Boolean) -> Unit
    ) {
        if (device == null) {
            permission.invoke(false)
        } else {
            permissionListener = permission
            if (usbManager.hasPermission(device)) {
                permissionListener.invoke(true)
            } else {
                usbManager.requestPermission(
                    device,
                    PendingIntent.getBroadcast(
                        context,
                        0,
                        Intent(ACTION_USB_PERMISSION),
                        PendingIntent.FLAG_IMMUTABLE
                    )
                )
            }
        }
    }

    fun create() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.registerReceiver(usbReceiver, IntentFilter(ACTION_USB_PERMISSION).apply {
                addAction(ACTION_USB_DEVICE_ATTACHED)
                addAction(ACTION_USB_ACCESSORY_ATTACHED)
                addAction(ACTION_USB_DEVICE_DETACHED)
                addAction(ACTION_USB_ACCESSORY_DETACHED)
                addAction(ACTION_STATE_CHANGED)
                addAction(BLUETOOTH_STATE_OFF)
                addAction(BLUETOOTH_STATE_ON)
                addAction(ACTION_ACL_DISCONNECTED)
                addAction(ACTION_ACL_CONNECTED)
                addAction(ACTION_DISCOVERY_STARTED)
                addAction(ACTION_DISCOVERY_FINISHED)
                addAction(ACTION_FOUND)
                addAction(ACTION_ID1)
                addAction(ACTION_ID2)
                addAction(ACTION_ID3)
                addAction(ACTION_ID4)
                addAction(WEIGHT_DEVICE_DETACHED)
            }, Context.RECEIVER_EXPORTED)
        } else {
            context.registerReceiver(usbReceiver, IntentFilter(ACTION_USB_PERMISSION).apply {
                addAction(ACTION_USB_DEVICE_ATTACHED)
                addAction(ACTION_USB_ACCESSORY_ATTACHED)
                addAction(ACTION_USB_DEVICE_DETACHED)
                addAction(ACTION_USB_ACCESSORY_DETACHED)
                addAction(ACTION_STATE_CHANGED)
                addAction(BLUETOOTH_STATE_OFF)
                addAction(BLUETOOTH_STATE_ON)
                addAction(ACTION_ACL_DISCONNECTED)
                addAction(ACTION_ACL_CONNECTED)
                addAction(ACTION_DISCOVERY_STARTED)
                addAction(ACTION_DISCOVERY_FINISHED)
                addAction(ACTION_FOUND)
                addAction(ACTION_ID1)
                addAction(ACTION_ID2)
                addAction(ACTION_ID3)
                addAction(ACTION_ID4)
                addAction(WEIGHT_DEVICE_DETACHED)
            })
        }
    }


    fun openDevice() {
        if (serialMulti == null) {
            serialMulti = PL2303GMultiLib(
                context.getSystemService(Activity.USB_SERVICE) as UsbManager,
                context,
                WEIGHT_DEVICE_NAME
            )
        }
        if (serialMulti?.PL2303IsDeviceConnectedByIndex(0) == false) {
            weighbridgeState.invoke(WeightState.WEIGHT_MSG_DEVICE_NOT_CONNECTED)
            return
        }
        serialMulti?.PL2303OpenDevByUARTSetting(
            0,
            PL2303GMultiLib.BaudRate.B9600,
            PL2303GMultiLib.DataBits.D8,
            PL2303GMultiLib.StopBits.S1,
            PL2303GMultiLib.Parity.NONE,
            PL2303GMultiLib.FlowControl.OFF
        ).let {
            if (it == true) {
                weighbridgeState.invoke(WeightState.WEIGHT_MSG_OPEN_DEVICE_SUCCESS)
                if (readThread != null) readThread?.interrupt()
                WeighbridgeReadThread(
                    serialMulti,
                    read = { weight ->
                        weighbridgeRead.invoke(weight)
                    }, error = {
                        weighbridgeState.invoke(WeightState.WEIGHT_MSG_READ_ERROR)
                    }
                ).apply {
                    readThread = this
                    readThread?.start()
                }
            } else {
                weighbridgeState.invoke(WeightState.WEIGHT_MSG_OPEN_DEVICE_FAILED)
            }
        }
    }

    class WeighbridgeReadThread(
        private val device: PL2303GMultiLib?,
        private val read: (Double) -> Unit,
        private val error: () -> Unit
    ) : Thread() {
        private var text = ""
        private val readByte = ByteArray(64)
        override fun run() {
            super.run()
            try {
                while (!isInterrupted) {
                    device?.PL2303Read(0, readByte)?.let { line ->
                        if (line > 0) {
                            readByte.forEach { text += it.toInt().toChar() }
                            read.invoke(getDoubleValue(text))
                            text = ""
                        }
                    }
                    SystemClock.sleep(100)
                }
            } catch (e: Exception) {
                print(e.toString())
                error.invoke()
            }
        }

        private fun getDoubleValue(str: String): Double {
            var d = 0.0
            if (str.isNotEmpty()) {
                val bf = StringBuffer()
                val chars = str.toCharArray()
                for (i in chars.indices) {
                    val c = chars[i]
                    if (c in '0'..'9') {
                        bf.append(c)
                    } else if (c == '.') {
                        if (bf.isEmpty()) {
                            continue
                        } else if (bf.indexOf(".") != -1) {
                            break
                        } else {
                            bf.append(c)
                        }
                    } else {
                        if (bf.isNotEmpty()) {
                            break
                        }
                    }
                }
                try {
                    d = bf.toString().toDouble()
                } catch (_: Exception) {
                }
            }
            return d
        }
    }

    fun destroy() {
        serialMulti?.let {
            it.PL2303Release()
            readThread?.interrupt()
            readThread = null
            serialMulti = null
        }
        context.unregisterReceiver(usbReceiver)
    }

    fun resume() {
        serialMulti?.let {
            synchronized(this) {
                it.PL2303G_ReSetStatus()
                it.PL2303Enumerate()
            }
        }
    }

}