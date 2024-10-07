package com.jd.pzx.jd_flutter

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.jd.pzx.jd_flutter.LivenFaceVerificationActivity.Companion.startOneselfFaceVerification
import com.jd.pzx.jd_flutter.utils.CHANNEL_ANDROID_SEND
import com.jd.pzx.jd_flutter.utils.CHANNEL_FLUTTER_SEND
import com.jd.pzx.jd_flutter.utils.FACE_VERIFY_SUCCESS
import com.jd.pzx.jd_flutter.utils.REQUEST_ENABLE_BT
import com.jd.pzx.jd_flutter.utils.bitmapToBase64
import com.jd.pzx.jd_flutter.utils.bluetoothAdapter
import com.jd.pzx.jd_flutter.utils.bluetoothCancelScan
import com.jd.pzx.jd_flutter.utils.bluetoothClose
import com.jd.pzx.jd_flutter.utils.bluetoothConnect
import com.jd.pzx.jd_flutter.utils.bluetoothIsEnable
import com.jd.pzx.jd_flutter.utils.bluetoothSendCommand
import com.jd.pzx.jd_flutter.utils.bluetoothStartScan
import com.jd.pzx.jd_flutter.utils.deviceList
import com.jd.pzx.jd_flutter.utils.openFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File


@SuppressLint("MissingPermission")
class MainActivity : FlutterActivity() {
    val receiverUtil = ReceiverUtil(
        this,
        usbAttached = {
            sendFlutter(CHANNEL_FLUTTER_SEND, "UsbState", "Attached")
        },
        usbDetached = {
            sendFlutter(CHANNEL_FLUTTER_SEND, "UsbState", "Detached")
        },
        weighbridgeDetached = {
            sendFlutter(CHANNEL_FLUTTER_SEND, "WeighbridgeDetached", "Detached")
        },
        bleDisconnected = {
            sendFlutter(CHANNEL_FLUTTER_SEND, "BluetoothState", "Disconnected")
        },
        bleConnected = {
            sendFlutter(CHANNEL_FLUTTER_SEND, "BluetoothState", "Connected")
        },
        bleScanStart = {
            sendFlutter(CHANNEL_FLUTTER_SEND, "BluetoothState", "StartScan")
        },
        bleFindDevice = {
            sendFlutter(CHANNEL_FLUTTER_SEND, "BluetoothFind", it)
        },
        bleScanFinished = {
            sendFlutter(CHANNEL_FLUTTER_SEND, "BluetoothState", "EndScan")
        },
        bleStateOff = {
            sendFlutter(CHANNEL_FLUTTER_SEND,"BluetoothState","Off")
        },
        bleStateOn = {
            sendFlutter(CHANNEL_FLUTTER_SEND,"BluetoothState","On")
        },
        bleStateClose = {
            sendFlutter(CHANNEL_FLUTTER_SEND,"BluetoothState","Close")
        },
        bleStateOpen = {
            sendFlutter(CHANNEL_FLUTTER_SEND,"BluetoothState","Open")
        },
        scanCode = {
            sendFlutter(CHANNEL_ANDROID_SEND, "PdaScanner", it)
        },
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        receiverUtil.registerReceiver()
    }

    override fun onDestroy() {
        receiverUtil.unRegisterReceiver()
        super.onDestroy()
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

                    "ScanBluetooth" -> bluetoothAdapter(this).let {
                        if (it == null) {
                            result.success(false)
                        } else {
                            result.success(bluetoothStartScan(it))
                        }
                    }

                    "EndScanBluetooth" -> bluetoothAdapter(this).let {
                        if (it == null) {
                            result.success(false)
                        } else {
                            result.success(bluetoothCancelScan(it))
                        }
                    }

                    "ConnectBluetooth" -> bluetoothAdapter(this).let {
                        if (it == null) {
                            result.success(3)
                        } else {
                            result.success(
                                bluetoothConnect(
                                    it,
                                    call.arguments.toString()
                                ) { socket ->
//                                    bluetoothSendCommand(
//                                        socket,
//                                        arrayListOf<List<ByteArray>>().apply {
//                                            add(
//                                                TSCUtil.getInstance().propertyLabel(
//                                                    fInterID = "123123123",
//                                                    name = "asd123",
//                                                    number = "333333",
//                                                    date = "xxxxxxxx",
//                                                )
//                                            )
//                                        },
//                                        progress = { s, t ->
//
//                                        }, sendCallback = {
//
//                                        }
//                                    )
                                })
                        }
                    }

                    "CloseBluetooth" -> result.success(bluetoothClose(call.arguments.toString()))

                    "IsEnable" -> {
                        val b = bluetoothIsEnable(bluetoothAdapter(this))
                        Log.e("Pan", "IsEnable=$b")
                        result.success(b)
                    }

                    "GetScannedDevices" -> deviceList.forEach { device ->
                        Log.e("Pan", "device=${device.device.name}")
                        sendFlutter(
                            CHANNEL_FLUTTER_SEND,
                            "BluetoothFind",
                            device.getDeviceMap()
                        )
                    }

                    "SendTSC" -> {
                        Log.e("Pan", "1data=${call.arguments}")
                        deviceList.find { it.socket.isConnected }?.let {
                            bluetoothSendCommand(
                                it.socket,
                                call.arguments as List<ByteArray>,
                                sendCallback = {

                                }
                            )
                        }
                    }

                    else -> result.notImplemented()
                }
            }

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        Log.e("Pan", "onActivityResult  requestCode$requestCode resultCode$resultCode")
        if (requestCode == REQUEST_ENABLE_BT && resultCode == RESULT_OK) {
            Log.e("Pan", "onActivityResult   蓝牙打开成功")
            sendFlutter(CHANNEL_FLUTTER_SEND, "Bluetooth", 3)
        }
    }

    private fun sendFlutter(channel: String, method: String, data: Any) {
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            Log.e("Pan", "method=$method data=$data")
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