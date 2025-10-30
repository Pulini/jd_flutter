package com.jd.pzx.jd_flutter

import android.annotation.SuppressLint
import android.content.Intent
import android.graphics.Bitmap
import android.os.Bundle
import android.util.Log
import com.jd.pzx.jd_flutter.LivenFaceVerificationActivity.Companion.startOneselfFaceVerification
import com.jd.pzx.jd_flutter.utils.CHANNEL_BLUETOOTH_ANDROID_TO_FLUTTER
import com.jd.pzx.jd_flutter.utils.CHANNEL_BLUETOOTH_FLUTTER_TO_ANDROID
import com.jd.pzx.jd_flutter.utils.CHANNEL_DISPLAY_METRICS_FLUTTER_TO_ANDROID
import com.jd.pzx.jd_flutter.utils.CHANNEL_FACE_VERIFICATION_FLUTTER_TO_ANDROID
import com.jd.pzx.jd_flutter.utils.CHANNEL_PRINTER_FLUTTER_TO_ANDROID
import com.jd.pzx.jd_flutter.utils.CHANNEL_SCAN_FLUTTER_TO_ANDROID
import com.jd.pzx.jd_flutter.utils.CHANNEL_USB_ANDROID_TO_FLUTTER
import com.jd.pzx.jd_flutter.utils.CHANNEL_USB_FLUTTER_TO_ANDROID
import com.jd.pzx.jd_flutter.utils.CHANNEL_WEIGHBRIDGE_ANDROID_TO_FLUTTER
import com.jd.pzx.jd_flutter.utils.CHANNEL_WEIGHBRIDGE_FLUTTER_TO_ANDROID
import com.jd.pzx.jd_flutter.utils.FACE_VERIFY_SUCCESS
import com.jd.pzx.jd_flutter.utils.REQUEST_ENABLE_BT
import com.jd.pzx.jd_flutter.utils.bitmapToByteArray
import com.jd.pzx.jd_flutter.utils.bluetoothAdapter
import com.jd.pzx.jd_flutter.utils.bluetoothCancelScan
import com.jd.pzx.jd_flutter.utils.bluetoothClose
import com.jd.pzx.jd_flutter.utils.bluetoothConnect
import com.jd.pzx.jd_flutter.utils.bluetoothIsEnable
import com.jd.pzx.jd_flutter.utils.bluetoothSendCommand
import com.jd.pzx.jd_flutter.utils.bluetoothStartScan
import com.jd.pzx.jd_flutter.utils.deviceList
import com.jd.pzx.jd_flutter.utils.locationOn
import com.jd.pzx.jd_flutter.utils.openFile
import com.jd.pzx.jd_flutter.utils.print.printPdf
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File


@SuppressLint("MissingPermission")
class MainActivity : FlutterActivity() {
    private val receiverUtil = ReceiverUtil(
        this,
        usbAttached = {
            sendFlutter(CHANNEL_USB_FLUTTER_TO_ANDROID, "UsbState", "Attached")
        },
        usbDetached = {
            sendFlutter(CHANNEL_USB_FLUTTER_TO_ANDROID, "UsbState", "Detached")
        },
        weighbridgeState = {
            sendFlutter(CHANNEL_WEIGHBRIDGE_FLUTTER_TO_ANDROID, "WeighbridgeState", it.name)
        },
        weighbridgeRead = {
            sendFlutter(CHANNEL_WEIGHBRIDGE_FLUTTER_TO_ANDROID, "WeighbridgeRead", it)
        },
        bleDisconnected = {
            sendFlutter(CHANNEL_BLUETOOTH_FLUTTER_TO_ANDROID, "BluetoothState", "Disconnected")
        },
        bleConnected = {
            sendFlutter(CHANNEL_BLUETOOTH_FLUTTER_TO_ANDROID, "BluetoothState", "Connected")
        },
        bleScanStart = {
            sendFlutter(CHANNEL_BLUETOOTH_FLUTTER_TO_ANDROID, "BluetoothState", "StartScan")
        },
        bleFindDevice = {
            sendFlutter(CHANNEL_BLUETOOTH_FLUTTER_TO_ANDROID, "BluetoothFind", it)
        },
        bleScanFinished = {
            sendFlutter(CHANNEL_BLUETOOTH_FLUTTER_TO_ANDROID, "BluetoothState", "EndScan")
        },
        bleStateOff = {
            sendFlutter(CHANNEL_BLUETOOTH_FLUTTER_TO_ANDROID, "BluetoothState", "Off")
        },
        bleStateOn = {
            sendFlutter(CHANNEL_BLUETOOTH_FLUTTER_TO_ANDROID, "BluetoothState", "On")
        },
        bleStateClose = {
            sendFlutter(CHANNEL_BLUETOOTH_FLUTTER_TO_ANDROID, "BluetoothState", "Close")
        },
        bleStateOpen = {
            sendFlutter(CHANNEL_BLUETOOTH_FLUTTER_TO_ANDROID, "BluetoothState", "Open")
        },
        scanCode = {
            sendFlutter(CHANNEL_SCAN_FLUTTER_TO_ANDROID, "PdaScanner", it)
        },
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        receiverUtil.create()
    }

    override fun onResume() {
        receiverUtil.resume()
        super.onResume()
    }

    override fun onDestroy() {
        receiverUtil.destroy()
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        //人脸识别通道
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_FACE_VERIFICATION_FLUTTER_TO_ANDROID
        ).setMethodCallHandler { call, result ->
            if (call.method == "StartDetect") {
                startOneselfFaceVerification(
                    this,
                    call.arguments.toString()
                ) { code, bitmap ,msg->
                    Log.e("Pan", "code=$code msg=$msg")
                    if (code == FACE_VERIFY_SUCCESS) {
                        result.success(bitmapToByteArray(bitmap!!, Bitmap.CompressFormat.JPEG))
                    } else {
                        result.error(code.toString(), msg, null)
                    }
                }
            }
        }

        //基础数据通道
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_USB_ANDROID_TO_FLUTTER
        ).setMethodCallHandler { call, _ ->
            if (call.method == "OpenFile") openFile(this, File(call.arguments.toString()))
        }

        //蓝牙通道
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_BLUETOOTH_FLUTTER_TO_ANDROID
        ).setMethodCallHandler { call, result ->
            Log.e("Pan", "method=${call.method} arguments=${call.arguments}")
            when (call.method) {
                "ScanBluetooth" -> bluetoothAdapter(this).let {
                    if (it == null) {
                        result.success(false)
                    } else {
                        result.success(
                            bluetoothStartScan(it, bondedDevices = { bonded ->
                                sendFlutter(
                                    CHANNEL_BLUETOOTH_FLUTTER_TO_ANDROID,
                                    "BluetoothFind",
                                    bonded.getDeviceMap()
                                )
                            }),
                        )
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
                        Thread {
                            result.success(
                                bluetoothConnect(
                                    it,
                                    call.arguments.toString()
                                )
                            )
                        }.start()
                    }
                }

                "CloseBluetooth" -> result.success(bluetoothClose(call.arguments.toString()))

                "IsEnable" -> result.success(bluetoothIsEnable(bluetoothAdapter(this)))
                "IsLocationOn" -> result.success(locationOn(this))

                "GetScannedDevices" -> result.success(mutableListOf<HashMap<String, Any>>().apply {
                    deviceList.forEach { add(it.getDeviceMap()) }
                })

                "SendTSC" -> deviceList.find { it.socket.isConnected }?.let {
                    bluetoothSendCommand(
                        it.socket,
                        call.arguments as List<ByteArray>,
                        sendCallback = { code ->
                            result.success(code)
                        }
                    )
                }


                else -> result.notImplemented()
            }
        }


        //地磅设备通道
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_WEIGHBRIDGE_ANDROID_TO_FLUTTER
        ).setMethodCallHandler { call, _ ->
            if (call.method == "OpenDevice") receiverUtil.openDevice()
        }
        //打印机通道
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_PRINTER_FLUTTER_TO_ANDROID
        ).setMethodCallHandler { call, result ->
            if (call.method == "PrintFile") {
//                printBitmap(context, base64ToBitmap(call.arguments.toString()),"物料列表"){
//                    result.success(it)
//                }
                Log.e("Pan", "arguments=${call.arguments}")
                printPdf(this, "拣货清单", (call.arguments as List<String>)) {
                    result.success(it)
                }
            }
        }

        //设备信息通道
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_DISPLAY_METRICS_FLUTTER_TO_ANDROID
        ).setMethodCallHandler { call, result ->
            if (call.method == "GetXDpi") {
                val dpi = resources.displayMetrics.xdpi
                result.success(dpi)
            } else {
                result.notImplemented()
            }
        }

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_ENABLE_BT && resultCode == RESULT_OK) {
            Log.e("Pan", "onActivityResult   蓝牙打开成功")
            sendFlutter(CHANNEL_BLUETOOTH_ANDROID_TO_FLUTTER, "Bluetooth", 3)
        }
    }

    private fun sendFlutter(channel: String, method: String, data: Any) {
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            Log.e("Pan", "method=$method data=$data")
            MethodChannel(messenger, channel).invokeMethod(method, data)
        }
    }
//    private fun checkFeiShu() {
//        val scopeList = ArrayList<String>()
//        scopeList.add("contact:user.employee_id:readonly")
//        scopeList.add("contact:user.id:readonly")
//        scopeList.add("wiki:wiki:readonly")
//        val builder = LarkSSO.Builder().setAppId("cli_a646a42958f2d00b")
//            .setServer("Feishu")
//            .setLanguage("zh")
//            .setChallengeMode(false)
//            .setScopeList(scopeList)
//            .setContext(this)
//        LarkSSO.inst().startSSOVerify(builder, object : IGetDataCallback {
//            override fun onSuccess(callBackData: CallBackData) {
//
//            }
//            override fun onError(callBackData: CallBackData) {
//
//            }
//        })
//    }

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