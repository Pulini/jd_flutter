package com.jd.pzx.jd_flutter.utils

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.*
import android.os.Build
import android.os.SystemClock
import android.util.Log
import androidx.core.content.ContextCompat

/**
 * PL2303G 地磅设备工具类（单例）
 *
 * 合并了原 PL2303GUtil 和 PL2303GWeighbridgeUtil，去除未使用的 modem 控制、
 * 流控、trace 日志等功能，内置 USB 插拔监听和自动权限处理。
 *
 * 用法：
 * ```kotlin
 * PL2303GWeighbridgeUtil.getInstance().init(context, object : Listener {
 *     override fun onWeightRead(weight: Double) { ... }
 *     override fun onStatusChanged(status: Status) { ... }
 * })
 * PL2303GWeighbridgeUtil.getInstance().open()
 * PL2303GWeighbridgeUtil.getInstance().destroy()
 * ```
 */
class PL2303GWeighbridgeUtil private constructor() {

    companion object {
        private const val TAG = "PL2303GWeighbridge"

        /** Prolific 厂商 ID */
        const val VENDOR_ID = 0x067B

        /** USB 权限请求 action */
        private const val ACTION_USB_PERMISSION = "com.prolific.pl2300G_multisimpletest.USB_PERMISSION"

        /** USB 控制传输超时 (ms) */
        private const val USB_TIMEOUT = 200

        /** Vendor request type: Host-to-Device */
        private const val REQ_TYPE_WRITE = UsbConstants.USB_TYPE_VENDOR or UsbConstants.USB_DIR_OUT

        /** Vendor request type: Device-to-Host */
        private const val REQ_TYPE_READ  = UsbConstants.USB_TYPE_VENDOR or UsbConstants.USB_DIR_IN

        private const val REQ_CODE = 0x01

        @Volatile
        private var instance: PL2303GWeighbridgeUtil? = null

        @Synchronized
        fun getInstance(): PL2303GWeighbridgeUtil {
            if (instance == null) instance = PL2303GWeighbridgeUtil()
            return instance!!
        }
    }

    // ---- 配置枚举 ----

    enum class BaudRate(val rate: Int) {
        B9600(9600), B19200(19200), B38400(38400),
        B57600(57600), B115200(115200);
    }

    enum class DataBits(val value: Int) { D8(3) }
    enum class StopBits(val value: Int) { S1(0), S2(2) }
    enum class Parity(val value: Int) { NONE(0), ODD(1), EVEN(2) }

    data class UartConfig(
        val baudRate: BaudRate = BaudRate.B9600,
        val dataBits: DataBits = DataBits.D8,
        val stopBits: StopBits = StopBits.S1,
        val parity: Parity = Parity.NONE,
    )

    // ---- 状态 & 监听器 ----

    enum class Status {
        DEVICE_NOT_INITIALIZED,
        DEVICE_DETACHED,
        DEVICE_NOT_CONNECTED,
        OPEN_SUCCESS,
        OPEN_FAILED,
        READ_ERROR,
    }

    interface Listener {
        fun onWeightRead(weight: Double)
        fun onStatusChanged(status: Status)
    }

    // ---- 内部状态 ----

    private var context: Context? = null
    private var listener: Listener? = null
    private var usbManager: UsbManager? = null
    private var usbDevice: UsbDevice? = null
    private var usbConnection: UsbDeviceConnection? = null
    private var usbInterface: UsbInterface? = null
    private var bulkInEndpoint: UsbEndpoint? = null
    private var bulkOutEndpoint: UsbEndpoint? = null
    private var readThread: ReadThread? = null
    private var deviceReceiver: BroadcastReceiver? = null
    private var receiverRegistered = false
    private var isOpen = false

    // ==================== 公开 API ====================

    /**
     * 初始化并注册 USB 插拔广播监听
     * @param context 建议传 Activity（用于权限对话框），内部会转 applicationContext
     */
    fun init(context: Context, listener: Listener) {
        this.context = context.applicationContext
        this.listener = listener
        registerDeviceReceiver(context)
    }

    /**
     * 恢复时重新枚举设备（onResume 中调用）
     */
    fun resume() {
        synchronized(this) { usbManager = null }
    }

    /**
     * 打开设备并开始读数。无权限时自动申请，授权后自动打开。
     */
    fun open() {
        val ctx = context ?: run { listener?.onStatusChanged(Status.DEVICE_NOT_INITIALIZED); return }
        val mgr = initUsbManager(ctx) ?: return

        val dev = scanForDevice(mgr) ?: run {
            listener?.onStatusChanged(Status.DEVICE_NOT_CONNECTED)
            return
        }

        if (!mgr.hasPermission(dev)) {
            requestPermissionAndOpen(ctx, mgr, dev)
            return
        }

        doOpen(dev)
    }

    /**
     * 关闭设备连接，但保留广播监听（用于暂停场景）
     */
    fun close() {
        stopReadThread()
        releaseUsb()
    }

    /**
     * 完全销毁：关闭设备、停止线程、注销广播（onDestroy 中调用）
     */
    fun destroy() {
        close()
        unregisterDeviceReceiver()
        listener = null
    }

    // ==================== 设备扫描 ====================

    private fun initUsbManager(ctx: Context): UsbManager? {
        if (usbManager == null) {
            usbManager = ctx.getSystemService(Context.USB_SERVICE) as? UsbManager
        }
        return usbManager
    }

    private fun scanForDevice(mgr: UsbManager): UsbDevice? {
        return mgr.deviceList.values.firstOrNull { it.vendorId == VENDOR_ID }
    }

    // ==================== 权限处理 ====================

    private fun requestPermissionAndOpen(ctx: Context, mgr: UsbManager, dev: UsbDevice) {
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                context?.unregisterReceiver(this)
                val granted = intent?.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false) == true
                if (granted) {
                    if (mgr.hasPermission(dev)) doOpen(dev)
                    else listener?.onStatusChanged(Status.OPEN_FAILED)
                } else {
                    listener?.onStatusChanged(Status.OPEN_FAILED)
                }
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ctx.registerReceiver(receiver, IntentFilter(ACTION_USB_PERMISSION), Context.RECEIVER_NOT_EXPORTED)
        } else {
            ContextCompat.registerReceiver(
                ctx,
                receiver,
                IntentFilter(ACTION_USB_PERMISSION),
                ContextCompat.RECEIVER_NOT_EXPORTED
            )
        }

        mgr.requestPermission(
            dev,
            PendingIntent.getBroadcast(ctx, 0, Intent(ACTION_USB_PERMISSION), PendingIntent.FLAG_IMMUTABLE)
        )
    }

    // ==================== 打开 / 关闭设备 ====================

    private fun doOpen( dev: UsbDevice) {
        releaseUsb()

        try {
            val conn = mgr?.openDevice(dev) ?: run {
                listener?.onStatusChanged(Status.OPEN_FAILED); return
            }
            usbConnection = conn
            usbDevice = dev

            val iface = dev.getInterface(0)
            usbInterface = iface
            if (!conn.claimInterface(iface, true)) {
                releaseUsb()
                listener?.onStatusChanged(Status.OPEN_FAILED); return
            }

            findEndpoints(iface)
            initializeChip()

            // 配置串口：写波特率分频 + 线路控制
            configureUart(UartConfig())

            isOpen = true
            listener?.onStatusChanged(Status.OPEN_SUCCESS)
            startReadThread()
        } catch (e: Exception) {
            Log.e(TAG, "打开设备失败", e)
            releaseUsb()
            listener?.onStatusChanged(Status.OPEN_FAILED)
        }
    }

    private fun findEndpoints(iface: UsbInterface) {
        for (i in 0 until iface.endpointCount) {
            val ep = iface.getEndpoint(i)
            when (ep.direction) {
                UsbConstants.USB_DIR_IN -> {
                    if (ep.type == UsbConstants.USB_ENDPOINT_XFER_BULK && bulkInEndpoint == null) bulkInEndpoint = ep
                }
                UsbConstants.USB_DIR_OUT -> {
                    if (ep.type == UsbConstants.USB_ENDPOINT_XFER_BULK && bulkOutEndpoint == null) bulkOutEndpoint = ep
                }
            }
        }
        // 回退：某些 PL2303G 使用 interrupt 端点
        if (bulkInEndpoint == null) {
            for (i in 0 until iface.endpointCount) {
                val ep = iface.getEndpoint(i)
                if (ep.direction == UsbConstants.USB_DIR_IN) { bulkInEndpoint = ep; break }
            }
        }
    }

    private fun releaseUsb() {
        try { usbInterface?.let { usbConnection?.releaseInterface(it) } } catch (_: Exception) {}
        try { usbConnection?.close() } catch (_: Exception) {}
        isOpen = false
        usbDevice = null
        usbConnection = null
        usbInterface = null
        bulkInEndpoint = null
        bulkOutEndpoint = null
    }

    // ---- 初始化芯片 ----

    private fun initializeChip() {
        val chipType = vendorRead(0x8383)
        vendorWrite(0x0000, 0)
        vendorWrite(0x0100, 0)
        chipType?.let {
            if (it.size >= 2 && it[0].toInt() >= 0x30) {
                vendorWrite(0x0404, 0)
                vendorWrite(0x0500, 0)
            }
        }
    }

    // ---- 配置串口 ----

    private fun configureUart(config: UartConfig) {
        // 波特率分频 = 12,000,000 / baud_rate
        val divisor = 12_000_000 / config.baudRate.rate
        vendorWrite(0x0000, divisor and 0xFF)
        vendorWrite(0x0100, (divisor shr 8) and 0xFF)

        // 线路控制：数据位 + 停止位 + 校验位
        val lineCtrl = config.dataBits.value or (config.stopBits.value shl 2) or (config.parity.value shl 3)
        vendorWrite(0x0300 or lineCtrl, 0)
    }

    // ---- 数据读写 ----

    fun write(data: ByteArray): Int {
        val conn = usbConnection ?: return -1
        val ep = bulkOutEndpoint ?: return -1
        return try {
            conn.bulkTransfer(ep, data, data.size, USB_TIMEOUT)
        } catch (e: Exception) {
            Log.e(TAG, "write 失败", e)
            -1
        }
    }

    fun readInto(buffer: ByteArray): Int {
        val conn = usbConnection ?: return -1
        val ep = bulkInEndpoint ?: return -1
        return try {
            conn.bulkTransfer(ep, buffer, buffer.size, USB_TIMEOUT)
        } catch (e: Exception) {
            Log.e(TAG, "read 失败", e)
            -1
        }
    }

    // ---- Vendor 控制传输 ----

    private val mgr: UsbManager?
        get() {
            if (usbManager == null) usbManager = context?.getSystemService(Context.USB_SERVICE) as? UsbManager
            return usbManager
        }

    private fun vendorWrite(wValue: Int, wIndex: Int = 0): Boolean {
        val conn = usbConnection ?: return false
        return try {
            conn.controlTransfer(REQ_TYPE_WRITE, REQ_CODE, wValue, wIndex, null, 0, USB_TIMEOUT) >= 0
        } catch (e: Exception) {
            Log.e(TAG, "vendorWrite(0x${wValue.toString(16)}) 失败", e)
            false
        }
    }

    private fun vendorRead(wValue: Int, maxLen: Int = 2): ByteArray? {
        val conn = usbConnection ?: return null
        val buffer = ByteArray(maxLen)
        return try {
            val len = conn.controlTransfer(REQ_TYPE_READ, REQ_CODE, wValue, 0, buffer, maxLen, USB_TIMEOUT)
            if (len > 0) buffer.copyOf(len) else null
        } catch (e: Exception) {
            Log.e(TAG, "vendorRead(0x${wValue.toString(16)}) 失败", e)
            null
        }
    }

    // ==================== 读数线程 ====================

    private fun startReadThread() {
        stopReadThread()
        readThread = ReadThread(
            onRead = { listener?.onWeightRead(it) },
            onError = { listener?.onStatusChanged(Status.READ_ERROR) }
        ).also { it.start() }
    }

    private fun stopReadThread() {
        readThread?.interrupt()
        readThread = null
    }

    private inner class ReadThread(
        private val onRead: (Double) -> Unit,
        private val onError: () -> Unit,
    ) : Thread() {
        private val buffer = ByteArray(64)

        override fun run() {
            var text = ""
            try {
                while (!isInterrupted) {
                    val count = readInto(buffer)
                    if (count > 0) {
                        for (i in 0 until count) text += buffer[i].toInt().toChar()
                        val weight = extractDouble(text)
                        if (weight > 0) onRead(weight)
                        text = ""
                    }
                    SystemClock.sleep(100)
                }
            } catch (e: Exception) {
                Log.e(TAG, "读取线程异常", e)
                onError()
            }
        }

        private fun extractDouble(str: String): Double {
            if (str.isEmpty()) return 0.0
            val bf = StringBuilder()
            for (c in str.toCharArray()) {
                when (c) {
                    in '0'..'9' -> bf.append(c)
                    '.' -> {
                        if (bf.isEmpty()) continue
                        if (bf.indexOf(".") != -1) break
                        bf.append(c)
                    }
                    else -> if (bf.isNotEmpty()) break
                }
            }
            return try { bf.toString().toDouble() } catch (_: Exception) { 0.0 }
        }
    }

    // ==================== USB 插拔广播 ====================

    private fun registerDeviceReceiver(context: Context) {
        if (receiverRegistered) return

        deviceReceiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context?, intent: Intent?) {
                when (intent?.action) {
                    UsbManager.ACTION_USB_DEVICE_ATTACHED -> {
                        val device: UsbDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
                        } else {
                            @Suppress("DEPRECATION") intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                        }
                        if (device?.vendorId == VENDOR_ID) {
                            Log.d(TAG, "PL2303G 插入，自动打开")
                            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                                resume()
                                open()
                            }, 500)
                        }
                    }

                    UsbManager.ACTION_USB_DEVICE_DETACHED -> {
                        val device: UsbDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
                        } else {
                            @Suppress("DEPRECATION") intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                        }
                        if (device?.vendorId == VENDOR_ID) {
                            Log.d(TAG, "PL2303G 拔出")
                            stopReadThread()
                            releaseUsb()
                            listener?.onStatusChanged(Status.DEVICE_DETACHED)
                        }
                    }
                }
            }
        }

        val filter = IntentFilter().apply {
            addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED)
            addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(deviceReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            context.registerReceiver(deviceReceiver, filter)
        }
        receiverRegistered = true
    }

    private fun unregisterDeviceReceiver() {
        if (!receiverRegistered) return
        try { context?.unregisterReceiver(deviceReceiver) } catch (_: Exception) {}
        deviceReceiver = null
        receiverRegistered = false
    }
}
