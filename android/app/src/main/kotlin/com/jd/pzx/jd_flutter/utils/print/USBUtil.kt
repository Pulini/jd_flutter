package com.jd.pzx.jd_flutter.utils.print

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.hardware.usb.UsbConstants
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbEndpoint
import android.hardware.usb.UsbInterface
import android.hardware.usb.UsbManager
import android.os.Build
import android.os.SystemClock
import com.jd.pzx.jd_flutter.ACTION_USB_PERMISSION
import com.jd.pzx.jd_flutter.utils.bytesMerger
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking

class USBUtil(
    private val context: Context,
    private val deviceVendorId: Int,
) {
    var usbState = -1
    private var usbInterface: UsbInterface? = null
    private var usbEndpoint: UsbEndpoint? = null
    private var usbConnection: UsbDeviceConnection? = null
    private var usbEndpointIn: UsbEndpoint? = null
    private var usbEndpointOut: UsbEndpoint? = null
    val usbManager: UsbManager by lazy {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.getSystemService(UsbManager::class.java)
        } else {
            context.getSystemService(Context.USB_SERVICE) as UsbManager
        }
    }

    private var permissionListener: (Boolean) -> Unit = {}

    fun setState(state:Int) {usbState=state}

    fun clean() {
        usbInterface = null
        usbEndpoint = null
        usbConnection = null
        usbEndpointIn = null
        usbEndpointOut = null
    }

    /**
     * 查找TSC打印机设备
     */
    fun findDevice(vendorId: Int): UsbDevice? {
        usbManager.deviceList?.forEach {
            if (it.value.vendorId == vendorId) return it.value
        }
        return null
    }

    /**
     * 检查USB权限并在尚未获得权限的时候主动发起申请
     */
    fun usbDeviceRequestPermission(device: UsbDevice?, permission: (Boolean) -> Unit) {
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

    /**
     * 校验状态并打开USB串口链接
     */
    private fun openPort(): Boolean {
        val usbDevice = findDevice(deviceVendorId) ?: return false
        usbInterface = usbDevice.getInterface(0)
        usbEndpoint = usbInterface!!.getEndpoint(0)
        usbConnection = usbManager.openDevice(usbDevice)
        if (usbConnection == null) return false

        usbConnection!!.claimInterface(usbInterface, true)

        for (i in 0 until usbInterface!!.endpointCount) {
            usbInterface!!.getEndpoint(i).let { usbEndpoint ->
                if (usbEndpoint.direction == UsbConstants.USB_DIR_IN) {
                    usbEndpointIn = usbEndpoint
                } else {
                    usbEndpointOut = usbEndpoint
                }
            }
        }
        return true
    }


    /**
     * 发送长指令
     */
    fun sendCommand(array: List<ByteArray>, callback: (Boolean) -> Unit) {
        Thread {
            if (openPort() && (usbConnection != null)) {
                val byte = bytesMerger(array)
                usbConnection!!.bulkTransfer(usbEndpoint, byte, byte.size, 100)
                SystemClock.sleep(500)
                runBlocking(Dispatchers.Main) {
                    callback.invoke(true)
                }
            } else {
                runBlocking(Dispatchers.Main) {
                    callback.invoke(false)
                }
            }
        }.start()

    }

    /**
     * 发送长指令
     */
    fun sendCommand(array: List<ByteArray>) =
        if (openPort() && (usbConnection != null)) {
            bytesMerger(array).run {
                usbConnection!!.bulkTransfer(usbEndpoint, this, size, 100)
            }
            true
        } else {
            false
        }

}