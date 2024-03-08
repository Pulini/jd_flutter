package com.jd.pzx.jd_flutter

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.gson.Gson
import com.jd.pzx.jd_flutter.LivenFaceVerificationActivity.Companion.startOneselfFaceVerification
import com.jd.pzx.jd_flutter.utils.CHANNEL_ANDROID_SEND
import com.jd.pzx.jd_flutter.utils.CHANNEL_FLUTTER_SEND
import com.jd.pzx.jd_flutter.utils.FACE_VERIFY_SUCCESS
import com.jd.pzx.jd_flutter.utils.REQUEST_BLUETOOTH_PERMISSIONS
import com.jd.pzx.jd_flutter.utils.REQUEST_ENABLE_BT
import com.jd.pzx.jd_flutter.utils.bitmapToBase64
import com.jd.pzx.jd_flutter.utils.bluetoothAdapter
import com.jd.pzx.jd_flutter.utils.bluetoothCancelScan
import com.jd.pzx.jd_flutter.utils.bluetoothClose
import com.jd.pzx.jd_flutter.utils.bluetoothConnect
import com.jd.pzx.jd_flutter.utils.bluetoothGetDevicesList
import com.jd.pzx.jd_flutter.utils.bluetoothIsEnable
import com.jd.pzx.jd_flutter.utils.bluetoothStartScan
import com.jd.pzx.jd_flutter.utils.openFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import java.io.File
import java.io.IOException
import java.util.*


@SuppressLint("MissingPermission")
class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        EventBus.getDefault().register(this)

    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_FLUTTER_SEND)
            .setMethodCallHandler { call, result ->
                Log.e("Pan", "method=${call.method} arguments=${call.arguments}")
                when (call.method) {
                    "StartDetect" -> startOneselfFaceVerification(
                        this,
                        call.arguments.toString()
                    ) { code, bitmap ->
                        Log.e("Pan", "code=$code")
                        if (code == FACE_VERIFY_SUCCESS) {
                            result.success(bitmapToBase64(bitmap!!))
                        } else {
                            result.error(code.toString(), null, null)
                        }
                    }

                    "OpenFile" -> openFile(this, File(call.arguments.toString()))

                    "ScanBluetooth" -> bluetoothAdapter(this)?.let { bluetoothStartScan(it) }

                    "EndScanBluetooth" -> bluetoothAdapter(this)?.let { bluetoothCancelScan(it) }

                    "ConnectBluetooth" -> bluetoothConnect(call.arguments.toString())

                    "CloseBluetooth" -> bluetoothClose()

                    "IsEnable" -> bluetoothIsEnable(bluetoothAdapter(this))

                    "GetScannedDevices" -> bluetoothAdapter(this)?.let {
                        bluetoothGetDevicesList(it).forEach { map ->
                            sendFlutter(CHANNEL_FLUTTER_SEND, "FindBluetooth", map)
                        }
                    }


                    else -> result.notImplemented()
                }
            }

    }

//    /**
//     * 蓝牙广播接收器
//     */
//    private val receiver = object : BroadcastReceiver() {
//        override fun onReceive(context: Context, intent: Intent) {
//            Log.e("Pan", "intent.action=${intent.extras.toString()}")
//            when (intent.action) {
//                BluetoothAdapter.ACTION_DISCOVERY_STARTED -> {
//                    Log.e("Pan", "扫描经典蓝牙")
//                    if (!isScanning) {
//                        isScanning = true
//
//                        sendFlutter(CHANNEL_FLUTTER_SEND, "Bluetooth", 5)
//                    }
//                }
//
//                BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
//                    Log.e("Pan", "经典蓝牙结束")
//                    if (isScanning) {
//                        isScanning = false
//                        sendFlutter(CHANNEL_FLUTTER_SEND, "Bluetooth", 6)
//                    }
//                }
//
//                BluetoothDevice.ACTION_FOUND -> {
//                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
//                        intent.getParcelableExtra(
//                            BluetoothDevice.EXTRA_DEVICE,
//                            BluetoothDevice::class.java
//                        )
//                    } else {
//                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
//                    }?.let { device ->
//                        if (!device.name.isNullOrEmpty()
//                            && devices.none { device.address == it.address }
////                            && device.uuids?.any { it.uuid == UUID.fromString(PRINTER_UUID) } == true
//                        ) {
//                            Log.e(
//                                "Pan",
//                                "发现打印机 name=${device.name} Address=${device.address} state=${device.bondState} "
//                            )
//                            devices.add(device)
//                            HashMap<String, Any>().let {
//                                it["DeviceName"] = device.name
//                                it["DeviceMAC"] = device.address
//                                it["DeviceIsConnected"] = isConnected(device.address)
//                                it["DeviceBondState"] = device.bondState
//                                sendFlutter(CHANNEL_FLUTTER_SEND, "FindBluetooth", it)
//                            }
//                        }
//                    }
//                }
//
//                BluetoothAdapter.ACTION_STATE_CHANGED -> {
//                    when (intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, 0)) {
//                        BluetoothAdapter.STATE_OFF -> {
//                            Log.e("Pan", "蓝牙关闭")
//                            closeBluetooth()
//                            sendFlutter(CHANNEL_FLUTTER_SEND, "Bluetooth", 4)
//                        }
//
//                        BluetoothAdapter.STATE_ON -> {
//                            Log.e("Pan", "蓝牙打开")
//                            sendFlutter(CHANNEL_FLUTTER_SEND, "Bluetooth", 3)
//                        }
//                    }
//                }
//
//                BluetoothDevice.ACTION_ACL_CONNECTED -> {
//                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
//                        intent.getParcelableExtra(
//                            BluetoothDevice.EXTRA_DEVICE,
//                            BluetoothDevice::class.java
//                        )
//                    } else {
//                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
//                    }?.let { device ->
//                        connectedDevice = device
//                        Log.e("Pan", "蓝牙设备已连接:${device.address}")
//                        HashMap<String, String>().let {
//                            it["MAC"] = device.address
//                            sendFlutter(CHANNEL_FLUTTER_SEND, "Connected", it)
//                        }
//                    }
//
//                }
//
//                BluetoothDevice.ACTION_ACL_DISCONNECTED -> {
//                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
//                        intent.getParcelableExtra(
//                            BluetoothDevice.EXTRA_DEVICE,
//                            BluetoothDevice::class.java
//                        )
//                    } else {
//                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
//                    }?.let { device ->
//                        bluetoothSocket?.close()
//                        bluetoothSocket = null
//                        connectedDevice = null
//                        Log.e("Pan", "蓝牙设备已断开:${device.address}")
//                        HashMap<String, String>().let {
//                            it["MAC"] = device.address
//                            sendFlutter(CHANNEL_FLUTTER_SEND, "Disconnected", it)
//                        }
//                    }
//                }
//            }
//        }
//    }
//

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        Log.e("Pan", "onActivityResult  requestCode$requestCode resultCode$resultCode")
        if (requestCode == REQUEST_ENABLE_BT && resultCode == RESULT_OK) {
            Log.e("Pan", "onActivityResult   蓝牙打开成功")
            sendFlutter(CHANNEL_FLUTTER_SEND, "Bluetooth", 3)
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onJPushMessageEvent(event: Any) {
        Log.e("Pan", "do:$event")
        HashMap<String, String>().let {
            it["json"] = Gson().toJson(event)
            sendFlutter(CHANNEL_ANDROID_SEND, "JMessage", it)
        }
    }

    private fun sendFlutter(channel: String, method: String, data: Any) {
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, channel).invokeMethod(method, data)
        }
    }

    /*

        private fun startDetect(
            imagePath: String,
            success: (Boolean) -> Unit
        ) {
            MLLivenessCapture.getInstance().startDetect(this, object : MLLivenessCapture.Callback {
                override fun onSuccess(result: MLLivenessCaptureResult) {
                    //检测成功的处理逻辑，检测结果可能是活体或者非活体。

                }

                override fun onFailure(errorCode: Int) {
                    //检测未完成，如相机异常CAMERA_ERROR,添加失败的处理逻辑。
                    Log.e("Pan", "errorCode=$errorCode")
                    success.invoke(false)
                }
            })
        }
    */


}