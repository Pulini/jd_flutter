package com.jd.pzx.jd_flutter.utils

import android.app.PendingIntent.FLAG_IMMUTABLE
import android.app.PendingIntent.getBroadcast
import android.content.Context
import android.content.Intent
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbEndpoint
import android.hardware.usb.UsbManager
import android.os.Build
import android.os.SystemClock
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking

const val DEVICE_VENDOR_ID = 4611//TSC打印机USB串口ID
const val SEND_COMMAND_STATE_SUCCESS = 1000//串口发送成功
const val SEND_COMMAND_STATE_PART_SUCCESS = 1001//串口发送部分成功
const val SEND_COMMAND_STATE_FAILED = 1003//发送失败
const val SEND_COMMAND_STATE_USB_ERROR = 1004//usb设备异常
const val SEND_COMMAND_STATE_NO_PERMISSION = 1005//没有串口指定权限
const val SEND_COMMAND_STATE_NO_DEVICE = 1006//找不到指定设备
const val SEND_COMMAND_STATE_BROKEN_PIPE = 1007//蓝牙通道已断开
private const val ACTION_USB_PERMISSION = "com.android.example.USB_PERMISSION"

fun usbQuickSendCommand(
    context: Context,
    dataList: ArrayList<List<ByteArray>>,
    progress: (Int, Int) -> Unit,
    sendCallback: (Int) -> Unit
) {
    try {
        val usbManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.getSystemService(UsbManager::class.java)
        } else {
            context.getSystemService(Context.USB_SERVICE) as UsbManager
        }
        if (usbManager != null) {//USB无异常
            var device: UsbDevice? = null
            usbManager.deviceList?.forEach {
                if (it.value.vendorId == DEVICE_VENDOR_ID) {
                    device = it.value
                    return@forEach
                }
            }
            if (device != null) {//已找到指定USB设备
                if (!usbManager.hasPermission(device)) {
                    usbManager.requestPermission(
                        device,
                        getBroadcast(context, 0, Intent(ACTION_USB_PERMISSION), FLAG_IMMUTABLE)
                    )
                } else {//以获取指定USB串口权限
                    val usbInterface = device!!.getInterface(0)
                    val usbEndpoint = usbInterface.getEndpoint(0)
                    val usbConnection = usbManager.openDevice(device)
                    usbConnection?.claimInterface(usbInterface, true)
                    //串口打开成功 开始发送数据
                    var index = 0
                    Thread {
                        try {
                            var status: Int
                            do {
                                val byte = bytesMerger(dataList[index])
                                status = usbConnection.bulkTransfer(
                                    usbEndpoint,
                                    byte,
                                    byte.size,
                                    100
                                )
                                index++
                                Thread.sleep(300)
                                runBlocking(Dispatchers.Main) {
                                    progress.invoke(index, dataList.size)
                                }
                            } while (status == 0 && index <= dataList.size)

                        } catch (e: Exception) {
                            Log.e("Pan", "USB操作异常：发送数据失败", e)
                        } finally {
                            runBlocking(Dispatchers.Main) {
                                if (index == dataList.size) {
                                    sendCallback.invoke(SEND_COMMAND_STATE_SUCCESS)
                                } else {
                                    sendCallback.invoke(SEND_COMMAND_STATE_PART_SUCCESS)
                                }
                            }
                        }
                    }.start()
                }
            } else {
                Log.e("Pan", "USB操作异常：没有找到指定设备")
                sendCallback.invoke(SEND_COMMAND_STATE_NO_DEVICE)
            }
        } else {
            Log.e("Pan", "USB操作异常：USB设备异常")
            sendCallback.invoke(SEND_COMMAND_STATE_USB_ERROR)
        }
    } catch (e: Exception) {
        Log.e("Pan", "USB操作异常：检查usb状态", e)
        sendCallback.invoke(SEND_COMMAND_STATE_USB_ERROR)
    }
}


/**
 * 初始化usb
 */
fun usbInit(context: Context, isReady: (UsbManager?, UsbDevice?) -> Unit) {
    try {
        val usbManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.getSystemService(UsbManager::class.java)
        } else {
            context.getSystemService(Context.USB_SERVICE) as UsbManager
        }
        var device: UsbDevice? = null
        usbManager?.deviceList?.forEach {
            if (it.value.vendorId == DEVICE_VENDOR_ID) {
                device = it.value
                return@forEach
            }
        }
        isReady.invoke(usbManager, device)
    } catch (e: Exception) {
        Log.e("Pan", "USB操作异常：检查usb状态", e)
    }
}

/**
 * 申请usb设备串口使用权限
 */
fun requestUsbPermission(context: Context, usbManager: UsbManager, usbDevice: UsbDevice) {
    if (!usbManager.hasPermission(usbDevice)) {
        usbManager.requestPermission(
            usbDevice,
            getBroadcast(context, 0, Intent(ACTION_USB_PERMISSION), FLAG_IMMUTABLE)
        )
    }
}

/**
 * 打开串口
 */
fun openPort(
    usbManager: UsbManager,
    usbDevice: UsbDevice,
    port: (UsbDeviceConnection, UsbEndpoint?) -> Unit
) {
    try {
        val usbInterface = usbDevice.getInterface(0)
        val usbEndpoint = usbInterface.getEndpoint(0)
        val usbConnection = usbManager.openDevice(usbDevice)
        usbConnection?.claimInterface(usbInterface, true)
        port.invoke(usbConnection, usbEndpoint)
    } catch (e: Exception) {
        Log.e("Pan", "USB操作异常：打开USB串口", e)
    }
}


/**
 * 发送长指令
 */

fun sendCommand(
    usbConnection: UsbDeviceConnection,
    usbEndpoint: UsbEndpoint,
    array: ArrayList<ByteArray>,
    callback: (Boolean) -> Unit
) {
    Thread {
        try {
            val byte = bytesMerger(array)
            usbConnection.bulkTransfer(usbEndpoint, byte, byte.size, 100)
            SystemClock.sleep(500)
            runBlocking(Dispatchers.Main) {
                callback.invoke(true)
            }
        } catch (e: Exception) {
            Log.e("Pan", "USB操作异常：发送数据", e)
            runBlocking(Dispatchers.Main) {
                callback.invoke(true)
            }
        }
    }.start()
}


/**
 * 发送长指令
 */
fun sendCommand(
    usbConnection: UsbDeviceConnection,
    usbEndpoint: UsbEndpoint,
    array: ArrayList<ByteArray>
) = try {
    val byte = bytesMerger(array)
    usbConnection.bulkTransfer(usbEndpoint, byte, byte.size, 100)
    true
} catch (e: Exception) {
    Log.e("Pan", "USB操作异常：发送数据", e)
    false
}

