package com.jd.pzx.jd_flutter.utils

import android.app.Activity
import android.content.Context
import android.hardware.usb.UsbManager
import android.os.SystemClock

import tw.com.prolific.pl2303gmultilib.PL2303GMultiLib

class WeighbridgeUtil {
    interface WeighbridgeListener {
        fun onWeighbridgeRead(weight: Double)
        fun onWeighbridgeMessage(msg: Int)
    }
    private lateinit var mSerialMulti: PL2303GMultiLib
    private val usbIndex = 0
    private var readThread: WeighbridgeReadThread? = null
    private var listener: WeighbridgeListener? = null

    companion object {


        const val MSG_DeviceNotConnected = 1
        const val MSG_OpenDeviceSuccess = 2
        const val MSG_OpenDeviceFailed = 3
        const val MSG_ReadError = 4

        private var weighbridgeUtil: WeighbridgeUtil? = null
            get() {
                if (field == null) {
                    field = WeighbridgeUtil()
                }
                return field
            }

        @Synchronized
        fun getInstance(): WeighbridgeUtil {
            return weighbridgeUtil!!
        }
    }

    fun init(context: Context, listener: WeighbridgeListener) {
        this.listener = listener
        mSerialMulti = PL2303GMultiLib(
            context.getSystemService(Activity.USB_SERVICE) as UsbManager,
            context,
            "com.prolific.pl2300G_multisimpletest.USB_PERMISSION"
        )
    }


    fun openDevice() {
        if (!mSerialMulti.PL2303IsDeviceConnectedByIndex(usbIndex)) {
            listener?.onWeighbridgeMessage(MSG_DeviceNotConnected)
            return
        }
        mSerialMulti.PL2303OpenDevByUARTSetting(
            usbIndex,
            PL2303GMultiLib.BaudRate.B9600,
            PL2303GMultiLib.DataBits.D8,
            PL2303GMultiLib.StopBits.S1,
            PL2303GMultiLib.Parity.NONE,
            PL2303GMultiLib.FlowControl.OFF
        ).let {
            if (it) {
                listener?.onWeighbridgeMessage(MSG_OpenDeviceSuccess)
                if (readThread != null) readThread?.interrupt()
                WeighbridgeReadThread(
                    mSerialMulti,
                    read = { weight ->
                        listener?.onWeighbridgeRead(weight)
                    }, error = { msg ->
                        listener?.onWeighbridgeMessage(msg)
                    }
                ).apply {
                    readThread = this
                    readThread?.start()
                }
            } else {
                listener?.onWeighbridgeMessage(MSG_OpenDeviceFailed)
            }
        }
    }

    fun destroy() {
        mSerialMulti.PL2303Release()
        readThread?.interrupt()
        readThread = null
    }

    fun resume() {
        synchronized(this) {
            mSerialMulti.PL2303G_ReSetStatus()
            mSerialMulti.PL2303Enumerate()
        }
    }

    class WeighbridgeReadThread(
        private val device: PL2303GMultiLib?,
        private val read: (Double) -> Unit,
        private val error: (Int) -> Unit
    ) : Thread() {
        private var text = ""
        private val readByte = ByteArray(64)
        override fun run() {
            super.run()
            try {
                while (!isInterrupted) {
                    device?.PL2303Read(0, readByte)?.let { line ->
                        if (line > 0) {
                            readByte.forEach { text += it.toInt().toChar() }
                            read.invoke(getDoubleValue(text))
                            text = ""
                        }
                    }
                    SystemClock.sleep(100)
                }
            } catch (e: Exception) {
                error.invoke(MSG_ReadError)
            }
        }

        private fun getDoubleValue(str: String): Double {
            var d = 0.0
            if (str.isNotEmpty()) {
                val bf = StringBuffer()
                val chars = str.toCharArray()
                for (i in chars.indices) {
                    val c = chars[i]
                    if (c in '0'..'9') {
                        bf.append(c)
                    } else if (c == '.') {
                        if (bf.isEmpty()) {
                            continue
                        } else if (bf.indexOf(".") != -1) {
                            break
                        } else {
                            bf.append(c)
                        }
                    } else {
                        if (bf.isNotEmpty()) {
                            break
                        }
                    }
                }
                try {
                    d = bf.toString().toDouble()
                } catch (_: Exception) {
                }
            }
            return d
        }
    }
}
