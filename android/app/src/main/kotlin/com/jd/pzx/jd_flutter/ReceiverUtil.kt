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
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.jd.pzx.jd_flutter.utils.BDevice
import com.jd.pzx.jd_flutter.utils.deviceList
import com.jd.pzx.jd_flutter.utils.PL2303GWeighbridgeUtil
import android.widget.Toast
import com.jd.pzx.jd_flutter.utils.jsonToList

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
const val ACTION_ID5 = "com.action.ai.x1"
const val BarCode5 = "decoded_json_results"
const val ACTION_ID6 = "com.action.ai.x1.broadcast"
const val BarCode6 = "decoded results"

enum class WeightState {
    WEIGHT_MSG_DEVICE_NOT_INITIALIZED,
    WEIGHT_MSG_DEVICE_DETACHED,
    WEIGHT_MSG_DEVICE_NOT_CONNECTED,
    WEIGHT_MSG_OPEN_DEVICE_SUCCESS,
    WEIGHT_MSG_OPEN_DEVICE_FAILED,
    WEIGHT_MSG_READ_ERROR,
}

var usbIsAttached: Boolean = false

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
    private val scanCodeList: (List<String>) -> Unit,
) {
    //东集扫码枪密码:4007770876
    private var permissionListener: (Boolean) -> Unit = {}
    val mainHandler = Handler(Looper.getMainLooper())

    /**
     * USB广播接收器
     */
    @Suppress("DEPRECATION")
    private val broadcastReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                ACTION_ID1 -> scanCode.invoke(intent.getStringExtra(BarCode1).toString())
                ACTION_ID2 -> scanCode.invoke(intent.getStringExtra(BarCode2).toString())
                ACTION_ID3 -> scanCode.invoke(intent.getStringExtra(BarCode3).toString())
                ACTION_ID4 -> scanCode.invoke(intent.getStringExtra(BarCode4).toString())
                ACTION_ID5 -> scanCodeList.invoke(jsonToList(intent.getStringExtra(BarCode5).toString()))
                ACTION_ID6 -> scanCode.invoke(intent.getStringExtra(BarCode6).toString())
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
                    Toast.makeText(context, "USB设备插入", Toast.LENGTH_SHORT).show()
                    usbIsAttached = true
                    usbAttached.invoke()
                }

                ACTION_USB_DEVICE_DETACHED, ACTION_USB_ACCESSORY_DETACHED -> {
                    Log.e("Pan", "USB设备拔出")
                    Toast.makeText(context, "USB设备拔出", Toast.LENGTH_SHORT).show()
                    usbIsAttached = false
                    usbDetached.invoke()
                }

                ACTION_ACL_CONNECTED -> {
                    Log.e("Pan", "蓝牙设备已连接")
                    bleConnected.invoke()
                }

                ACTION_ACL_DISCONNECTED -> {
                    Log.e("Pan", "蓝牙设备断开")
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
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
            context.registerReceiver(broadcastReceiver, IntentFilter(ACTION_USB_PERMISSION).apply {
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
                addAction(ACTION_ID5)
                addAction(ACTION_ID6)
            }, Context.RECEIVER_EXPORTED)
        } else {
            context.registerReceiver(broadcastReceiver, IntentFilter(ACTION_USB_PERMISSION).apply {
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
                addAction(ACTION_ID5)
                addAction(ACTION_ID6)
            })
        }
    }

    fun destroy() {
        context.unregisterReceiver(broadcastReceiver)
    }


    fun weighbridgeOpen() {
        PL2303GWeighbridgeUtil.getInstance().init(context, object : PL2303GWeighbridgeUtil.Listener {
            override fun onWeightRead(weight: Double) {
                mainHandler.post { weighbridgeRead.invoke(weight) }
            }

            override fun onStatusChanged(status: PL2303GWeighbridgeUtil.Status) {
                mainHandler.post {
                    weighbridgeState.invoke(
                        when (status) {
                            PL2303GWeighbridgeUtil.Status.DEVICE_NOT_INITIALIZED -> WeightState.WEIGHT_MSG_DEVICE_NOT_INITIALIZED
                            PL2303GWeighbridgeUtil.Status.DEVICE_DETACHED -> WeightState.WEIGHT_MSG_DEVICE_DETACHED
                            PL2303GWeighbridgeUtil.Status.DEVICE_NOT_CONNECTED -> WeightState.WEIGHT_MSG_DEVICE_NOT_CONNECTED
                            PL2303GWeighbridgeUtil.Status.OPEN_SUCCESS -> WeightState.WEIGHT_MSG_OPEN_DEVICE_SUCCESS
                            PL2303GWeighbridgeUtil.Status.OPEN_FAILED -> WeightState.WEIGHT_MSG_OPEN_DEVICE_FAILED
                            PL2303GWeighbridgeUtil.Status.READ_ERROR -> WeightState.WEIGHT_MSG_READ_ERROR
                        }
                    )
                }
            }
        })
        PL2303GWeighbridgeUtil.getInstance().open()
    }

    fun weighbridgeDestroy() {
        PL2303GWeighbridgeUtil.getInstance().destroy()
    }


}