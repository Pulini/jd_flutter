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
import com.jd.pzx.jd_flutter.messageCenter.JMessage
import com.jd.pzx.jd_flutter.utils.CHANNEL_ANDROID_SEND
import com.jd.pzx.jd_flutter.utils.CHANNEL_FLUTTER_SEND
import com.jd.pzx.jd_flutter.utils.FACE_VERIFY_SUCCESS
import com.jd.pzx.jd_flutter.utils.PRINTER_UUID
import com.jd.pzx.jd_flutter.utils.REQUEST_BLUETOOTH_PERMISSIONS
import com.jd.pzx.jd_flutter.utils.REQUEST_ENABLE_BT
import com.jd.pzx.jd_flutter.utils.bitmapToBase64
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

    private val bluetoothAdapter: BluetoothAdapter? by lazy {
        (getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager).adapter
    }
    private var bluetoothSocket: BluetoothSocket? = null
    private var connectedDevice: BluetoothDevice? = null
    private var isScanning = false
    private val devices = mutableListOf<BluetoothDevice>()
    private var temporaryFile: File? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        EventBus.getDefault().register(this)
        registerReceiver()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_FLUTTER_SEND)
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

                    "OpenFile" -> {
                        temporaryFile = File(call.arguments.toString())
                        openFile(this, temporaryFile!!)
                    }

                    "IsEnable" -> result.success(isEnable())
                    "GetScannedDevices" -> {
                        devices.forEach { device ->
                            HashMap<String, Any>().let {
                                it["DeviceName"] = device.name
                                it["DeviceMAC"] = device.address
                                it["DeviceIsConnected"] = isConnected(device.address)
                                it["DeviceBondState"] = device.bondState
                                sendFlutter(CHANNEL_FLUTTER_SEND, "FindBluetooth", it)
                            }
                        }
                    }

                    "IsConnected" -> result.success(isConnected())
                    "OpenBluetooth" -> checkPermissionsAndDevice()
                    "ScanBluetooth" -> scanBluetooth()
                    "EndScanBluetooth" -> endScanBluetooth()
                    "ConnectBluetooth" -> connectBluetooth(call.arguments.toString()) { code ->
                        result.success(code)
                    }

                    "CloseBluetooth" -> if (isConnected(call.arguments.toString())) {
                        bluetoothSocket?.close()
                        result.success(true)
                    } else {
                        result.success(false)
                    }

                    else -> result.notImplemented()
                }
            }

    }


    /**
     * 打开蓝牙
     */
    private fun checkPermissionsAndDevice() {
        if (bluetoothAdapter == null) {
            Toast.makeText(this, "设备不支持蓝牙", Toast.LENGTH_LONG).show()
            sendFlutter(CHANNEL_FLUTTER_SEND, "Bluetooth", 1)
        } else {
            val request = mutableListOf<String>()
            arrayOf(
                Manifest.permission.BLUETOOTH,
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_ADMIN,
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.ACCESS_FINE_LOCATION,
            ).forEach {
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
                    REQUEST_BLUETOOTH_PERMISSIONS
                )
            } else {
                openBluetooth()
            }
        }

    }

    fun closeBluetooth() {
        try {
            devices.clear()
            bluetoothSocket?.close()
            bluetoothSocket = null
            connectedDevice = null
        } catch (e: IOException) {
            Log.e("Pan", "关闭失败", e)
        }
    }

    private fun connectBluetooth(
        mac: String,
        connect: (Int) -> Unit
    ) {
        try {
            endScanBluetooth()
            if (bluetoothSocket != null && bluetoothSocket?.isConnected == true) {
                connect.invoke(0)
                Log.e("Pan", "设备已连接")
            } else {
                devices.find { it.address == mac }.let { device ->
                    if (device != null) {
                        device.createRfcommSocketToServiceRecord(
                            UUID.fromString(PRINTER_UUID)
                        ).let { socket ->
                            if (socket != null) {
                                socket.connect()
                                bluetoothSocket = socket
                                Log.e("Pan", "连接成功")
                                connect.invoke(0)
                            } else {
                                Log.e("Pan", "创建通道失败")
                                connect.invoke(3)
                            }
                        }
                    } else {
                        Log.e("Pan", "未找到设备")
                        connect.invoke(2)
                    }
                }
            }
        } catch (e: IOException) {
            Log.e("Pan", "连接失败")
            connect.invoke(1)
        }
    }

    private fun isEnable() = bluetoothAdapter?.isEnabled
    private fun isConnected() = bluetoothSocket?.isConnected
    private fun isConnected(mac: String) =
        connectedDevice?.address == mac && bluetoothSocket?.isConnected == true

    private fun scanBluetooth() {
        if (isSearching()) {
            Toast.makeText(this, "正在搜索...", Toast.LENGTH_LONG).show()
        } else {
            devices.clear()
            bluetoothAdapter?.bondedDevices?.forEach { device ->
                if (device.address == connectedDevice?.address) {
                    devices.add(device)
                    HashMap<String, Any>().let {
                        it["DeviceName"] = device.name
                        it["DeviceMAC"] = device.address
                        it["DeviceIsConnected"] = isConnected(device.address)
                        it["DeviceBondState"] = device.bondState
                        sendFlutter(CHANNEL_FLUTTER_SEND, "FindBluetooth", it)
                    }
                }
            }
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
        registerReceiver(receiver, IntentFilter(BluetoothDevice.ACTION_ACL_DISCONNECTED))
        registerReceiver(receiver, IntentFilter(BluetoothDevice.ACTION_ACL_CONNECTED))
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


    /**
     * 蓝牙广播接收器
     */
    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            Log.e("Pan", "intent.action=${intent.extras.toString()}")
            when (intent.action) {
                BluetoothAdapter.ACTION_DISCOVERY_STARTED -> {
                    Log.e("Pan", "扫描经典蓝牙")
                    if (!isScanning) {
                        isScanning = true

                        sendFlutter(CHANNEL_FLUTTER_SEND, "Bluetooth", 5)
                    }
                }

                BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                    Log.e("Pan", "经典蓝牙结束")
                    if (isScanning) {
                        isScanning = false
                        sendFlutter(CHANNEL_FLUTTER_SEND, "Bluetooth", 6)
                    }
                }

                BluetoothDevice.ACTION_FOUND -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(
                            BluetoothDevice.EXTRA_DEVICE,
                            BluetoothDevice::class.java
                        )
                    } else {
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                    }?.let { device ->
                        if (!device.name.isNullOrEmpty()
                            && devices.none { device.address == it.address }
//                            && device.uuids?.any { it.uuid == UUID.fromString(PRINTER_UUID) } == true
                        ) {
                            Log.e(
                                "Pan",
                                "发现打印机 name=${device.name} Address=${device.address} state=${device.bondState} "
                            )
                            devices.add(device)
                            HashMap<String, Any>().let {
                                it["DeviceName"] = device.name
                                it["DeviceMAC"] = device.address
                                it["DeviceIsConnected"] = isConnected(device.address)
                                it["DeviceBondState"] = device.bondState
                                sendFlutter(CHANNEL_FLUTTER_SEND, "FindBluetooth", it)
                            }
                        }
                    }
                }

                BluetoothAdapter.ACTION_STATE_CHANGED -> {
                    when (intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, 0)) {
                        BluetoothAdapter.STATE_OFF -> {
                            Log.e("Pan", "蓝牙关闭")
                            closeBluetooth()
                            sendFlutter(CHANNEL_FLUTTER_SEND, "Bluetooth", 4)
                        }

                        BluetoothAdapter.STATE_ON -> {
                            Log.e("Pan", "蓝牙打开")
                            sendFlutter(CHANNEL_FLUTTER_SEND, "Bluetooth", 3)
                        }
                    }
                }

                BluetoothDevice.ACTION_ACL_CONNECTED -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(
                            BluetoothDevice.EXTRA_DEVICE,
                            BluetoothDevice::class.java
                        )
                    } else {
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                    }?.let { device ->
                        connectedDevice = device
                        Log.e("Pan", "蓝牙设备已连接:${device.address}")
                        HashMap<String, String>().let {
                            it["MAC"] = device.address
                            sendFlutter(CHANNEL_FLUTTER_SEND, "Connected", it)
                        }
                    }

                }

                BluetoothDevice.ACTION_ACL_DISCONNECTED -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(
                            BluetoothDevice.EXTRA_DEVICE,
                            BluetoothDevice::class.java
                        )
                    } else {
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                    }?.let { device ->
                        bluetoothSocket?.close()
                        bluetoothSocket = null
                        connectedDevice = null
                        Log.e("Pan", "蓝牙设备已断开:${device.address}")
                        HashMap<String, String>().let {
                            it["MAC"] = device.address
                            sendFlutter(CHANNEL_FLUTTER_SEND, "Disconnected", it)
                        }
                    }
                }
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
        when (requestCode) {
            REQUEST_BLUETOOTH_PERMISSIONS -> {
                var p = 0
                grantResults.forEach {
                    Log.e("Pan", "onRequestPermissionsResult: $it")
                    if (it == PackageManager.PERMISSION_GRANTED) p++
                }
                if (p == permissions.size) {
                    Toast.makeText(this, "用户授权完成", Toast.LENGTH_LONG).show()
                    openBluetooth()
                } else {
                    sendFlutter(CHANNEL_FLUTTER_SEND, "Bluetooth", 2)
                    Toast.makeText(this, "用户拒绝授权", Toast.LENGTH_LONG).show()
                }
            }

        }

    }

    private fun openBluetooth() {
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
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onJPushMessageEvent(event: JMessage) {
        Log.e("Pan", "do:${event.doSomething}\ncontent:${event.content}")
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