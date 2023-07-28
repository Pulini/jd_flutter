package com.jd.pzx.jd_flutter

import android.annotation.SuppressLint

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
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
import com.jd.pzx.jd_flutter.bluetooth.BLUETOOTH_ADAPTER_STATE_OFF
import com.jd.pzx.jd_flutter.bluetooth.BLUETOOTH_ADAPTER_STATE_ON
import com.jd.pzx.jd_flutter.bluetooth.BlueToothUtil.Companion.permissions
import com.jd.pzx.jd_flutter.messageCenter.JMessage
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import java.io.IOException


const val REQUEST_PERMISSIONS = 1223
const val REQUEST_ENABLE_BT = 1224

@SuppressLint("MissingPermission")
class MainActivity : FlutterActivity() {

    private val bluetoothAdapter: BluetoothAdapter? by lazy {
        (getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager).adapter
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        EventBus.getDefault().register(this)
        registerReceiver()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "StartDetect" -> {
                        Log.e("Pan", "arguments=${call.arguments}")
                        startOneselfFaceVerification(
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
                    }

                    "OpenBluetooth" -> openBluetooth()
                    "ScanBluetooth" -> scanBluetooth()
                    "EndScanBluetooth" -> endScanBluetooth()
                    else -> result.notImplemented()
                }
            }

    }

    /**
     * 打开蓝牙
     */
    private fun openBluetooth() {
        if (bluetoothAdapter == null) {
            Toast.makeText(this, "设备不支持蓝牙", Toast.LENGTH_LONG).show()
            sendFlutter("Bluetooth", 1)
        } else {
            val request = mutableListOf<String>()
            permissions.forEach {
                if (ContextCompat.checkSelfPermission(
                        this,
                        it
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    request.add(it)
                    Log.e("Pan", "permissions=$it")
                }
            }

            if (request.isNotEmpty()) {
                ActivityCompat.requestPermissions(
                    this,
                    request.toTypedArray(),
                    REQUEST_PERMISSIONS
                )
            }
        }

    }
    fun closeBluetooth() {
        try {
//            bluetoothSocket?.close()
//            bluetoothSocket = null
//            printer = null
//            isConnected = false
//            exit = true
        } catch (e: IOException) {
            Log.e("Pan", "关闭失败", e)
        }
    }

    private fun scanBluetooth() {
        if (isSearching()) {
            Toast.makeText(this, "正在搜索...", Toast.LENGTH_LONG).show()
        } else {
            bluetoothAdapter?.startDiscovery()
        }
    }
    private fun endScanBluetooth() {
        if (isSearching()) {
            bluetoothAdapter?.cancelDiscovery()
        }
    }

    private fun isSearching() = bluetoothAdapter?.isDiscovering == true


    /**
     * 注册系统蓝牙广播接受器
     */
    private fun registerReceiver() {
        Log.e("Pan", "注册广播")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(
                receiver,
                IntentFilter(BLUETOOTH_ADAPTER_STATE_OFF),
                RECEIVER_NOT_EXPORTED
            )
            registerReceiver(
                receiver,
                IntentFilter(BLUETOOTH_ADAPTER_STATE_ON),
                RECEIVER_NOT_EXPORTED
            )
        } else {
            registerReceiver(receiver, IntentFilter(BLUETOOTH_ADAPTER_STATE_OFF))
            registerReceiver(receiver, IntentFilter(BLUETOOTH_ADAPTER_STATE_ON))
        }
        registerReceiver(receiver, IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED))
        registerReceiver(receiver, IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_STARTED))
        registerReceiver(receiver, IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_FINISHED))
        registerReceiver(receiver, IntentFilter(BluetoothDevice.ACTION_FOUND))
    }


    /**
     * 取消注册
     */
    private fun unregisterReceiver() {
        Log.e("Pan", "注销广播")
        unregisterReceiver(receiver)
    }

    private var isScanning= false
    private val devices = mutableListOf<BluetoothDevice>()

    /**
     * 蓝牙广播接收器
     */
    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                BluetoothAdapter.ACTION_DISCOVERY_STARTED -> {
                    Log.e("Pan", "扫描经典蓝牙")
                    if(!isScanning){
                        isScanning=true
                        sendFlutter("Bluetooth", 5)
                    }
                }
                BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                    Log.e("Pan", "经典蓝牙结束")
                    if(isScanning){
                        isScanning=false
                        sendFlutter("Bluetooth", 6)
                    }
                }
                BluetoothDevice.ACTION_FOUND ->
                    intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
                        ?.let { device ->
                            if (!device.name.isNullOrEmpty() && devices.none { device.address == it.address }) {
                                Log.e(
                                    "Pan",
                                    "发现经典蓝牙 Name=${device.name} Address=${device.address}"
                                )
                                devices.add(device)
                                HashMap<String, String>().let {
                                    it["DeviceName"] = device.name
                                    it["DeviceMAC"] = device.address
                                    sendFlutter("FindBluetooth", it)
                                }
                            }
                        }

                BluetoothAdapter.ACTION_STATE_CHANGED -> {
                    when (intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, 0)) {
                        BluetoothAdapter.STATE_OFF -> {
                            Log.e("Pan", "蓝牙关闭")
                            closeBluetooth()
                            sendFlutter("Bluetooth", 4)
                        }

                        BluetoothAdapter.STATE_ON -> {
                            Log.e("Pan", "蓝牙打开")
                            sendFlutter("Bluetooth", 3)
                        }
                    }
                }
            }
        }
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_ENABLE_BT && resultCode == RESULT_OK) {
            Log.e("Pan", "onActivityResult   蓝牙打开成功")
            sendFlutter("Bluetooth", 3)
        }
    }

    override fun onDestroy() {
        unregisterReceiver()
        super.onDestroy()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String?>,
        grantResults: IntArray
    ) {
        // 这里是用户授予或拒绝权限后回调的地方
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_PERMISSIONS) {
            var p = 0
            grantResults.forEach {
                Log.e("Pan", "onRequestPermissionsResult: $it")
                if (it == PackageManager.PERMISSION_GRANTED) p++
            }
            if (p == permissions.size) {
                Toast.makeText(this, "用户授权完成", Toast.LENGTH_LONG).show()
                if (bluetoothAdapter?.isEnabled == false) {
                    Log.e("Pan", "蓝牙未开启")
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        Log.e("Pan", "新版打开蓝牙")
                        startActivityForResult(
                            Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE),
                            REQUEST_ENABLE_BT
                        )
                    } else {
                        Log.e("Pan", "旧版打开蓝牙")
                        bluetoothAdapter?.enable()
                    }
                }
            } else {
                sendFlutter("Bluetooth", 2)
                Toast.makeText(this, "用户拒绝授权", Toast.LENGTH_LONG).show()
            }
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onJPushMessageEvent(event: JMessage) {
        Log.e("Pan", "do:${event.doSomething}\ncontent:${event.content}")
        HashMap<String, String>().let {
            it["json"] = Gson().toJson(event)
            sendFlutter("JMessage", it)
        }
    }

    private fun sendFlutter(method: String, data: Any) {
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, CHANNEL).invokeMethod(method, data)
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