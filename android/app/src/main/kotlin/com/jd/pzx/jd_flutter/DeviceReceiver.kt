package com.jd.pzx.jd_flutter

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter.ACTION_DISCOVERY_FINISHED
import android.bluetooth.BluetoothAdapter.ACTION_DISCOVERY_STARTED
import android.bluetooth.BluetoothAdapter.ACTION_STATE_CHANGED
import android.bluetooth.BluetoothAdapter.EXTRA_STATE
import android.bluetooth.BluetoothAdapter.STATE_OFF
import android.bluetooth.BluetoothAdapter.STATE_ON
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothDevice.ACTION_ACL_DISCONNECTED
import android.bluetooth.BluetoothDevice.ACTION_FOUND
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.hardware.usb.UsbManager.ACTION_USB_ACCESSORY_ATTACHED
import android.hardware.usb.UsbManager.ACTION_USB_ACCESSORY_DETACHED
import android.hardware.usb.UsbManager.ACTION_USB_DEVICE_ATTACHED
import android.hardware.usb.UsbManager.ACTION_USB_DEVICE_DETACHED
import android.os.Build
import android.util.Log
import com.jd.pzx.jd_flutter.utils.USB_STATE_NO_PERMISSION
import com.jd.pzx.jd_flutter.utils.USB_STATE_READY

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
const val WEIGHT_DEVICE_DETACHED = "MultiUSB.Detached"

const val ACTION_USB_PERMISSION = "com.android.example.USB_PERMISSION"
const val BLUETOOTH_ADAPTER_STATE_OFF = "android.bluetooth.BluetoothAdapter.STATE_OFF"
const val BLUETOOTH_ADAPTER_STATE_ON = "android.bluetooth.BluetoothAdapter.STATE_ON"


@SuppressLint("MissingPermission", "UnspecifiedRegisterReceiverFlag")
class DeviceReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        Log.e("Pan", "接收广播")
        when (intent.action) {
            ACTION_ID1 -> {//扫码枪广播
                intent.getStringExtra(BarCode1).toString().let { barcode ->
                    if (barcode.isNotEmpty() && barcode != "null") {
                    }
                }
            }

            ACTION_ID2 -> {//扫码枪广播
                intent.getStringExtra(BarCode2).toString().let { barcode ->
                    if (barcode.isNotEmpty() && barcode != "null") {
                    }
                }
            }

            ACTION_ID3 -> {//扫码枪广播
                intent.getStringExtra(BarCode3).toString().let { barcode ->
                    if (barcode.isNotEmpty() && barcode != "null") {
                    }
                }
            }

            ACTION_ID4 -> {//扫码枪广播
                intent.getStringExtra(BarCode4).toString().let { barcode ->
                    if (barcode.isNotEmpty() && barcode != "null") {
                    }
                }
            }

            ACTION_USB_PERMISSION -> {//监听USB权限
                Log.e("Pan", "监听USB权限")
                synchronized(this) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(
                            UsbManager.EXTRA_DEVICE,
                            UsbDevice::class.java
                        )
                    } else {
                        intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                    }.let { device ->
                        val hasPermission = if (device != null) {
                            intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
                        } else {
                            false
                        }
                        if (hasPermission) USB_STATE_READY else USB_STATE_NO_PERMISSION
                    }
                }
            }

            ACTION_USB_ACCESSORY_ATTACHED, ACTION_USB_DEVICE_ATTACHED -> {//检测到USB插入
                Log.e("Pan", "检测到USB插入")
            }

            ACTION_USB_ACCESSORY_DETACHED, ACTION_USB_DEVICE_DETACHED -> {//检测到USB拔出
                Log.e("Pan", "检测到USB拔出")
            }

            WEIGHT_DEVICE_RECEIVER -> {//地磅称广播监听
                Log.e("Pan", "地磅称广播监听")
            }

            ACTION_ACL_DISCONNECTED -> {//蓝牙设备断开
                Log.e("Pan", "蓝牙设备断开")
            }

            ACTION_DISCOVERY_STARTED -> {//开始扫描经典蓝牙
                Log.e("Pan", "开始扫描经典蓝牙")
            }

            ACTION_DISCOVERY_FINISHED -> {//扫描经典蓝牙结束
                Log.e("Pan", "扫描经典蓝牙结束")
            }

            ACTION_FOUND -> {//发现经典蓝牙
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    intent.getParcelableExtra(
                        BluetoothDevice.EXTRA_DEVICE,
                        BluetoothDevice::class.java
                    )
                } else {
                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                }?.run {
                    if (!name.isNullOrEmpty()) {
                        Log.e("Pan", "发现经典蓝牙 Name=${name} Address=${address}")
                    }
                }
            }

            BLUETOOTH_ADAPTER_STATE_OFF -> {//蓝牙不可用
                Log.e("Pan", "蓝牙不可用")
            }
            BLUETOOTH_ADAPTER_STATE_ON -> {//蓝牙可用
                Log.e("Pan", "蓝牙可用")
            }
            ACTION_STATE_CHANGED -> {//蓝牙开关状态监听
                when (intent.getIntExtra(EXTRA_STATE, 0)) {
                    STATE_OFF -> {
                        Log.e("Pan", "蓝牙关闭")
                    }

                    STATE_ON -> {
                        Log.e("Pan", "蓝牙打开")
                    }
                }
            }
        }

    }

}