package com.jd.pzx.jd_flutter

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter.ACTION_DISCOVERY_FINISHED
import android.bluetooth.BluetoothAdapter.ACTION_DISCOVERY_STARTED
import android.bluetooth.BluetoothAdapter.ACTION_STATE_CHANGED
import android.bluetooth.BluetoothAdapter.EXTRA_STATE
import android.bluetooth.BluetoothAdapter.STATE_OFF
import android.bluetooth.BluetoothAdapter.STATE_ON
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothDevice.ACTION_ACL_CONNECTED
import android.bluetooth.BluetoothDevice.ACTION_ACL_DISCONNECTED
import android.bluetooth.BluetoothDevice.ACTION_FOUND
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.hardware.usb.UsbManager.ACTION_USB_ACCESSORY_ATTACHED
import android.hardware.usb.UsbManager.ACTION_USB_ACCESSORY_DETACHED
import android.hardware.usb.UsbManager.ACTION_USB_DEVICE_ATTACHED
import android.hardware.usb.UsbManager.ACTION_USB_DEVICE_DETACHED
import android.os.Build
import android.util.Log
import com.jd.pzx.jd_flutter.utils.BDevice
import com.jd.pzx.jd_flutter.utils.deviceList

import org.greenrobot.eventbus.EventBus

/**
 * Created by : PanZX on 2024/02/28
 * Email : 644173944@qq.com
 * Github : https://github.com/Pulini
 * Remark: 设备广播
 */
const val ACTION_ID1 = "nlscan.action.SCANNER_RESULT"
const val BarCode1 = "SCAN_BARCODE1"
const val ACTION_ID2 = "com.android.server.scannerservice.broadcast"
const val BarCode2 = "scannerdata"
const val ACTION_ID3 = "com.sunmi.scanner.ACTION_DATA_CODE_RECEIVED"
const val BarCode3 = "data"
const val ACTION_ID4 = "android.intent.ACTION_DECODE_DATA"
const val BarCode4 = "barcode_string"

const val WEIGHT_DEVICE_RECEIVER = "tw.PL2303MultiUSBMessage"
//const val WEIGHT_DEVICE_DETACHED = "MultiUSB.Detached"


const val BLUETOOTH_ADAPTER_STATE_OFF = "android.bluetooth.BluetoothAdapter.STATE_OFF"
const val BLUETOOTH_ADAPTER_STATE_ON = "android.bluetooth.BluetoothAdapter.STATE_ON"


@SuppressLint("MissingPermission", "UnspecifiedRegisterReceiverFlag")
class DeviceReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        Log.e("Pan", "接收广播${intent.action}")
        when (intent.action) {
            ACTION_ID1, ACTION_ID2, ACTION_ID3, ACTION_ID4 -> {//扫码枪广播
                intent.getStringExtra(
                    when (intent.action) {
                        ACTION_ID1 -> BarCode1
                        ACTION_ID2 -> BarCode2
                        ACTION_ID3 -> BarCode3
                        else -> BarCode4
                    }
                ).toString().let { barcode ->
                    if (barcode.isNotEmpty() && barcode != "null") {
                        EventBus.getDefault().post(
                            EventDeviceMessage(OperationType.PdaScanner, barcode)
                        )
                    }
                }
            }

            ACTION_USB_ACCESSORY_ATTACHED, ACTION_USB_DEVICE_ATTACHED -> {//检测到USB插入
                Log.e("Pan", "检测到USB插入")
                EventBus.getDefault().post(
                    EventDeviceMessage(OperationType.UsbState, "Attached")
                )
            }

            ACTION_USB_ACCESSORY_DETACHED, ACTION_USB_DEVICE_DETACHED -> {//检测到USB拔出
                Log.e("Pan", "检测到USB拔出")
                EventBus.getDefault().post(
                    EventDeviceMessage(OperationType.UsbState, "Detached")
                )
            }

            WEIGHT_DEVICE_RECEIVER -> {//地磅称设备断开广播监听
                Log.e("Pan", "地磅称广播监听")
                EventBus.getDefault().post(
                    EventDeviceMessage(OperationType.WeighbridgeDetached, "Detached")
                )
            }

            ACTION_ACL_CONNECTED -> {
                Log.e("Pan", "蓝牙设备已连接")
                EventBus.getDefault().post(
                    EventDeviceMessage(OperationType.BluetoothState, "Connected")
                )
            }

            ACTION_ACL_DISCONNECTED -> {//蓝牙设备断开
                Log.e("Pan", "蓝牙设备断开")
                val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    intent.getParcelableExtra(
                        BluetoothDevice.EXTRA_DEVICE,
                        BluetoothDevice::class.java
                    )
                } else {
                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                }?.let {device->
                    Log.e("Pan", "device=${device.address}")
                    deviceList.forEach {
                        Log.e("Pan", "${it.device.name}---${it.socket.isConnected}")
                    }
                }

                EventBus.getDefault().post(
                    EventDeviceMessage(OperationType.BluetoothState, "Disconnected")
                )
            }

            ACTION_DISCOVERY_STARTED -> {//开始扫描经典蓝牙
                Log.e("Pan", "开始扫描经典蓝牙")
                EventBus.getDefault().post(
                    EventDeviceMessage(OperationType.BluetoothState, "StartScan")
                )
            }

            ACTION_DISCOVERY_FINISHED -> {//扫描经典蓝牙结束
                Log.e("Pan", "扫描经典蓝牙结束")
                EventBus.getDefault().post(
                    EventDeviceMessage(OperationType.BluetoothState, "EndScan")
                )
            }

            ACTION_FOUND -> {//发现经典蓝牙
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    intent.getParcelableExtra(
                        BluetoothDevice.EXTRA_DEVICE,
                        BluetoothDevice::class.java
                    )
                } else {
                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                }?.let { bluetooth ->
                    if (!bluetooth.name.isNullOrEmpty()) {
                        (deviceList.find {
                            it.device.address == bluetooth.address
                        } ?: BDevice(bluetooth).apply { deviceList.add(this) }).let { device ->
                            Log.e(
                                "Pan",
                                "发现经典蓝牙 Name=${device.device.name} Address=${device.device.address} isConnected=${device.socket.isConnected}"
                            )
                            EventBus.getDefault().post(
                                EventDeviceMessage(
                                    OperationType.BluetoothFind,
                                    device.getDeviceMap()
                                )
                            )
                        }
                    }
                }
            }

            BLUETOOTH_ADAPTER_STATE_OFF -> {//蓝牙不可用
                Log.e("Pan", "蓝牙不可用")
                EventBus.getDefault().post(
                    EventDeviceMessage(OperationType.BluetoothState, "Off")
                )
            }

            BLUETOOTH_ADAPTER_STATE_ON -> {//蓝牙可用
                Log.e("Pan", "蓝牙可用")
                EventBus.getDefault().post(
                    EventDeviceMessage(OperationType.BluetoothState, "On")
                )
            }

            ACTION_STATE_CHANGED -> {//蓝牙开关状态监听
                when (intent.getIntExtra(EXTRA_STATE, 0)) {
                    STATE_OFF -> {
                        Log.e("Pan", "蓝牙关闭")
                        EventBus.getDefault().post(
                            EventDeviceMessage(OperationType.BluetoothState, "Close")
                        )
                    }

                    STATE_ON -> {
                        Log.e("Pan", "蓝牙打开")
                        EventBus.getDefault().post(
                            EventDeviceMessage(OperationType.BluetoothState, "Open")
                        )
                    }
                }
            }
        }

    }

}