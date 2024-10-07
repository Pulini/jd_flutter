package com.jd.pzx.jd_flutter.utils.print

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Paint
import android.graphics.Typeface
import android.location.LocationManager
import android.os.Build
import android.os.SystemClock
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.util.Log
import androidx.core.content.ContextCompat.getSystemService
import com.google.gson.Gson
import com.jd.pzx.jd_flutter.utils.add
import com.jd.pzx.jd_flutter.utils.mul
import com.jd.pzx.jd_flutter.utils.removeDecimalZero
import com.jd.pzx.jd_flutter.utils.toDoubleTry
import java.util.UUID
import kotlin.experimental.xor
import kotlin.math.ceil


/**
 * Created by : PanZX on 2023/12/15
 * Email : 644173944@qq.com
 * Github : https://github.com/Pulini
 * Remark: TSC打印机指令工具 使用前需要先校验蓝牙权限
 * 目前te244打印机dpi有2种 参数分别是8和12
 * 200 DPI : 1mm = 8 dots
 * 300 DPI : 1mm = 12 dots
 *
 * 使用前确保有蓝牙权限申请
 * 创建贴标会比较耗时，建议使用子线程进行创建
 * vm.loading.value = "生成贴标中..."
 *     Thread {
 *         val list = mutableListOf<ArrayList<ByteArray>>().apply {
 *             for (a in 0 until 20) {
 *                 add(
 *                     TSCUtil.colorsSeparationLabel(
 *                         "MaterialCode",
 *                         "PickUpCode",
 *                         "BatchNumber",
 *                         "DefaultStockName",
 *                         "200 Unit",
 *                         "Number"
 *                     )
 *                 )
 *             }
 *         }
 *         runOnUiThread {
 *             vm.loading.value = ""
 *             goPrint(list,false){success->
 *                 if (success){
 *                     vm.tips.value="完成"
 *                 }else{
 *                     vm.error.value="失败"
 *                 }
 *             }
 *         }
 *     }.start()
 */

const val USB_STATE_READY = 0//USB已连接
const val USB_STATE_NO_PERMISSION = 1//USB权限被拒绝

const val BT_STATE_READY = 0//蓝牙设备已就绪
const val BT_STATE_NOT_SUPPORTED = 1//该设备不支持蓝牙
const val BT_STATE_CLOSED = 2//蓝牙被关闭
const val BT_STATE_NOT_CONNECTED = 3//蓝牙设备未连接

const val TSC_DEVICE_VENDOR_ID = 4611//tsc usb设备id
const val TSC_BLUETOOTH_UUID = "00001101-0000-1000-8000-00805F9B34FB"//tsc 蓝牙uuid

class TSCUtil(context: Context) {


    /**
     * usb工具
     */

    val usbUtil: USBUtil by lazy { USBUtil(context, TSC_DEVICE_VENDOR_ID) }


    /**
     * 蓝牙工具
     */

    val bleUtil: BleUtil by lazy { BleUtil(context, UUID.fromString(TSC_BLUETOOTH_UUID)) }

    /**
     * 刷新蓝牙适配器
     */
    fun refreshBleAdapter() {
        bleUtil.refreshBleAdapter()
    }

//    private fun bluetoothScan() {
//        if (bleUtil.isSearching()) {
//            bleUtil.cancelScan { bleDialog.finishScan() }
//        } else {
//            bleUtil.startScan(
//                bleScanStart = {
//                    bleDialog.startScan()
//                },
//                bleFindDevice = { device ->
//                    bleDialog.findDevice(device)
//                },
//                bleScanFinished = {
//                    bleDialog.finishScan()
//                },
//            )
//        }
//    }
//
//     fun bluetoothConnect(device: BlueToothDevice?) {
//        if (device == null) return
//        bleUtil.cancelScan { bleDialog.finishScan() }
//        bleUtil.connect(device) { isConnected, dev ->
//            if (isConnected) {
//                bleDialog.connect(true, dev)
//            } else {
//                bleDialog.connect(false, null)
//            }
//        }
//    }




//
//    /**
//     * 打印前检测设备状态
//     */
//    fun printCheck(ready: () -> Unit) {
//        if (usbUtil.usbState == USB_STATE_READY) {
//            ready.invoke()
//        } else {
//            if (bleUtil.bleState == BT_STATE_READY) {
//                ready.invoke()
//            } else {
//                if (!bleDialog.isShowing) {
//                    bleUtil.setConnectListener(ready)
//                    bleDialog.show(bleUtil.hasBlueTooth())
//                }
//            }
//        }
//    }

    /**
     * 发送单张标签打印指令
     * 注：如设备已通过USB链接，则直接使用USB下发打印指令，否则掉起蓝牙连接模块，通过蓝牙发送指令。
     */
    fun printLabel(array: ArrayList<ByteArray>, callback: (Boolean) -> Unit) {
        if (usbUtil.usbState == USB_STATE_READY) {
            usbUtil.sendCommand(array, callback)
            return
        }
        if (bleUtil.bleState == BT_STATE_READY) {
            bleUtil.sendCommand(array, callback)
            return
        }
        callback.invoke(false)
    }

    /**
     * 发送打印指令
     * 注：如设备已通过USB链接，则直接使用USB下发打印指令，否则掉起蓝牙连接模块，通过蓝牙发送指令。
     */
    private fun printLabel(array: ArrayList<ByteArray>) = if (usbUtil.usbState == USB_STATE_READY) {
        usbUtil.sendCommand(array)
    } else {
        if (bleUtil.bleState == BT_STATE_READY) {
            bleUtil.sendCommand(array)
        } else {
            false
        }
    }

    /**
     * 发送多张标签打印指令
     * 注：如设备已通过USB链接，则直接使用USB下发打印指令，否则掉起蓝牙连接模块，通过蓝牙发送指令。
     */
    fun printLabelList(
        list: MutableList<ArrayList<ByteArray>>,
        finish: (Boolean) -> Unit
    ) {

        Thread {
            Log.e("Pan", "printLabelList=${list.size}")
            try {
                if (list.isNotEmpty()) {
                    if (printLabel(list[0])) {
                        list.removeAt(0)
                        SystemClock.sleep(500)
                        if (list.isEmpty()) {
                            finish.invoke(true)
                        } else {
                            printLabelList(list, finish)
                        }
                    } else {
                        finish.invoke(false)
                    }
                } else {
                    finish.invoke(false)
                }
            } catch (e: Exception) {

            }
        }.start()
    }


//↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ 标签指令 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

    companion object {
        @Volatile
        private var instance: TSCUtil? = null
        private lateinit var textType: Typeface
        private lateinit var titleType: Typeface
        private lateinit var locationManager: LocationManager

        fun init(context: Context): TSCUtil =
            synchronized(this) {
                instance ?: TSCUtil(context).apply {
                    instance = this
                    locationManager = getSystemService(context, LocationManager::class.java)!!
                    textType = Typeface.createFromAsset(context.assets, "fonts/text.ttf")
                    titleType = Typeface.createFromAsset(context.assets, "fonts/title.ttf")
                }
            }

        fun getInstance(): TSCUtil = instance!!

        fun bitmapLabel(
            bitmap: Bitmap
        ) = arrayListOf<ByteArray>().apply {
            val dpi = 8
            add(tscClearBuffer())
            add(tscSetUp(75, 45))
            add(tscBitmap(1, 1, bitmap, dpi * 73, dpi * 43))
            add(tscPrint())
        }

        /**
         * 集团外箱标    中文固定标签
         * @param labelNumber 标签编号
         * @param instruct 指令
         * @param materialName 物料名称
         * @param factoryType 工厂型体
         * @param deliveryDate 交期
         * @param qty 数量
         * @param size 尺寸
         * @param unit 单位
         * @param pageNumber 页码
         */
        fun chineseFixedLabel(
            labelNumber: String,
            instruct: String,
            materialName: String,
            materialCode: String,
            factoryType: String,
            deliveryDate: String,
            qty: Double,
            unit: String,
            size: String,
            pageNumber: String
        ) = arrayListOf<ByteArray>().apply {
            val dpi = 8
            add(tscClearBuffer())
            add(tscSetUp(75, 45))
            add(tscQrCode(dpi * 4, dpi * 2, labelNumber, cell = "4"))
            add(tscBitmapFont(dpi * 20, dpi * 2, textType, 40, factoryType))
            add(tscBitmapFont(dpi * 20, dpi * 8, textType, 50, instruct))
            add(tscBitmapFont(dpi * 4, dpi * 16, textType, 30, "条码序号：$labelNumber"))

            "$materialCode($materialName)".chunked(28).forEachIndexed { index, s ->
                add(tscBitmapFont(dpi * 4, dpi * 22 + (dpi * 5 * index), textType, 30, s))
            }
            add(tscBitmapFont(dpi * 20, dpi * 36, textType, 25, "页码：$pageNumber"))
            add(tscBitmapFont(dpi * 20, dpi * 40, textType, 25, "交期：$deliveryDate"))
            if (size.isNotEmpty()) {
                add(tscBitmapFont(dpi * 4, dpi * 36, textType, 50, "$size #"))
            }
            add(tscBitmapFont(dpi * 50, dpi * 36, textType, 50, "${qty.removeDecimalZero()} $unit"))
            add(tscPrint())
        }


        /**
         * 集团外箱标    英文固定标签
         * @param labelNumber 标签编号
         * @param instruct 指令
         * @param materialName 物料名称
         * @param materialCode 物料编码
         * @param factoryType 工厂型体
         * @param grossWeight 毛重
         * @param netWeight 净重
         * @param qty 数量
         * @param specs 规格
         * @param size 尺寸
         * @param pageNumber 页码
         */
        fun englishFixedLabel(
            labelNumber: String,
            instruct: String,
            materialName: String,
            materialCode: String,
            factoryType: String,
            qty: Double,
            grossWeight: Double,
            netWeight: Double,
            specs: String,
            size: String,
            pageNumber: String
        ) = arrayListOf<ByteArray>().apply {
            val dpi = 8
            add(tscClearBuffer())
            add(tscSetUp(75, 45))
            add(tscQrCode(dpi * 4, dpi * 2, labelNumber, cell = "4"))
            add(tscBitmapFont(dpi * 20, dpi * 2, textType, 40, factoryType))
            add(tscBitmapFont(dpi * 20, dpi * 8, textType, 50, instruct))
            "$materialCode($materialName)".chunked(28).forEachIndexed { index, s ->
                add(tscBitmapFont(dpi * 4, dpi * 16 + (dpi * 5 * index), textType, 30, s))
            }
            add(
                tscBitmapFont(
                    dpi * 4,
                    dpi * 28,
                    textType,
                    25,
                    "GW:${grossWeight.mul(qty).removeDecimalZero()}KG  NW:${
                        (netWeight.mul(qty).removeDecimalZero())
                    }KG"
                )
            )
            add(tscBitmapFont(dpi * 4, dpi * 32, textType, 25, "MEAS:$specs"))
            add(tscBitmapFont(dpi * 4, dpi * 36, textType, 50, "$size #"))
            add(tscBitmapFont(dpi * 23, dpi * 36, textType, 25, "Page:$pageNumber"))
            add(tscBitmapFont(dpi * 23, dpi * 40, textType, 25, "Made in China"))
            add(tscBitmapFont(dpi * 50, dpi * 36, textType, 50, "${qty.removeDecimalZero()} PRS"))
            add(tscPrint())
        }


        /**
         * 动态尺寸贴标
         * @param barCode 条码
         * @param factoryType 工厂型体
         * @param materialName 物料名称
         * @param materialCode 物料编码
         * @param pageNumber 页码
         * @param deliveryDate 交期
         * @param unit 单位
         * @param departName 部门名称
         * @param instructions 指令
         */
        fun chineseDynamicLabel(
            barCode: String,
            factoryType: String,
            materialName: String,
            materialCode: String,
            pageNumber: String,
            deliveryDate: String,
            unit: String,
            departName: String,
            instructions: MutableMap<String, MutableList<String>>
        ) = arrayListOf<ByteArray>().apply {

            //标签宽度 纸张75 左右各缩进1 = 75-2
            val width = 73

            //打印机dp为200 dpi=8
            val dpi = 8

            //距离上边距3
            val marginTop = 3

            //距离下边距3
            val marginButton = 3

            //固定区高度 13 加上上下边距2
            val fixedHeight = 13 + 2 + 2

            //物料名称自动分行
            val materialText = "$materialCode($materialName)".chunked(28)

            //物料名称动态高度 每行字体高度为6dpi
            val dynamicMaterialHeight = materialText.size * 6

            //指令行数量
            var lines = instructions.size
            instructions.forEach {
                if (it.value.size > 4) {
                    lines += ceil(it.value.size.div(4.0)).toInt()
                } else {
                    lines++
                }
            }

            //指令动态高度 每行字体高度为6dpi
            val dynamicInstructionsHeight = lines * 6

            val pageNumberHeight = 6

            add(tscCutter())
            //清除缓存
            add(tscClearBuffer())


            //设置标签尺寸 width:标签宽度73 height:标签高度 = 上边距 + 固定区高度 + 动态物料高度 + 动态指令高度 + 页码高度 +下边距
            add(
                tscSetUp(
                    width,
                    marginTop + fixedHeight + 10 + dynamicMaterialHeight + dynamicInstructionsHeight + pageNumberHeight + marginButton,
                    sensorDistance = 0
                )
            )

            //绘制底部裁切线 x坐标=0 y坐标=上边距 +固定区高度 + 动态物料高度 + 动态指令高度 + 页码高度 + 下边距 - 缩进1 width长度=标签宽度
            for (i in 0..width step 2) {
                add(
                    tscLine(
                        i * dpi,
                        (marginTop + fixedHeight + 10 + dynamicMaterialHeight + dynamicInstructionsHeight + pageNumberHeight + marginButton) * dpi - 2,
                        dpi,
                        2
                    )
                )
            }


            //绘制固定区线框
            add(
                tscBox(
                    0,
                    marginTop * dpi,
                    width * dpi,
                    (fixedHeight + marginTop) * dpi,
                    2
                )
            )

            //绘制二维码与文本的分割线 x坐标=固定区高度 y坐标=上边距 width宽度=2 height高度=固定区高度
            add(
                tscLine(
                    fixedHeight * dpi,
                    marginTop * dpi,
                    2,
                    fixedHeight * dpi,
                )
            )

            //绘制二维码 x坐标=缩进2 y坐标=上边距 + 缩进2
            add(
                tscQrCode(
                    2 * dpi,
                    marginTop * dpi + 2 * dpi,
                    barCode,
                    cell = if (barCode.length > 20) "3" else "4"
                )
            )

            //绘制型体文本 x坐标=固定区高度 + 缩进2 y坐标=上边距 + 缩进2
            add(
                tscBitmapFont(
                    fixedHeight * dpi + 2 * dpi,
                    marginTop * dpi + 2 * dpi,
                    textType,
                    40,
                    if (factoryType.isEmpty()) unit else "$factoryType($unit)"
                )
            )

            //绘制交期 x坐标=固定区高度 + 缩进2 y坐标=上边距 + 行间距8 + 缩进2
            add(
                tscBitmapFont(
                    fixedHeight * dpi + 2 * dpi,
                    marginTop * dpi + 8 * dpi + 2 * dpi,
                    textType,
                    30,
                    "组别：$departName"
                )
            )

            //绘制物料名称区线框 x坐标=0 y坐标=固定区高度 + 上边距 width宽度=标签宽度 height高度=固定区高度 + 动态物料高度 + 上边距
            add(
                tscBox(
                    0,
                    (fixedHeight + marginTop) * dpi,
                    width * dpi,
                    (fixedHeight + dynamicMaterialHeight + marginTop) * dpi,
                    2
                )
            )

            //循环绘制多行物料名称
            materialText.forEachIndexed { index, s ->
                //绘制物料名称 x坐标=缩进2 y坐标=固定区高度 + 上边距 + 动态行间距4*index + 缩进1
                add(
                    tscBitmapFont(
                        2 * dpi,
                        ((fixedHeight + marginTop + 6 * index) + 1) * dpi,
                        textType,
                        30,
                        s
                    )
                )
            }

            //绘制指令区线框 x坐标=0 y坐标=固定区高度 + 动态物料高度 + 上边距 width宽度=标签宽度 height高度=固定区高度 + 动态物料高度 + 动态指令高度 + 上边距
            add(
                tscBox(
                    0,
                    (fixedHeight + dynamicMaterialHeight + marginTop) * dpi,
                    width * dpi,
                    (fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight + marginTop) * dpi,
                    2
                )
            )

            //循环绘制多行指令
            var index = 0
            instructions.forEach {
                //绘制指令区线框 x坐标=0 y坐标=固定区高度 + 动态物料高度 + 上边距 + 动态行间距6*index width宽度=标签宽度 height高度=固定区高度 + 动态物料高度 + 动态指令高度 + 上边距 +行间距6+动态行间距
                add(
                    tscBox(
                        0,
                        (fixedHeight + dynamicMaterialHeight + marginTop + 6 * index) * dpi,
                        width * dpi,
                        (fixedHeight + dynamicMaterialHeight + marginTop + 6 + 6 * index) * dpi,
                        2
                    )
                )

                //绘制指令 x坐标=缩进2 y坐标=固定区高度 + 动态物料高度 + 上边距 + 动态行间距6*index + 缩进1
                add(
                    tscBitmapFont(
                        2 * dpi,
                        ((fixedHeight + dynamicMaterialHeight + marginTop + 6 * index) + 1) * dpi,
                        textType,
                        30,
                        "指令：${it.key}"
                    )
                )


                var sizeIndex = 0
                it.value.forEachIndexed { i, s ->
                    if (i % 4 == 0) {
                        index++
                        sizeIndex = 0
                    } else {
                        sizeIndex++
                    }
                    add(
                        tscBox(
                            (73.0.div(4) * sizeIndex * dpi).toInt(),
                            (marginTop + fixedHeight + dynamicMaterialHeight + index * 6) * dpi,
                            (73.0.div(4) * sizeIndex * dpi).toInt() + (73.0.div(4) * dpi).toInt(),
                            (marginTop + fixedHeight + dynamicMaterialHeight + index * 6 + 6) * dpi,
                            2
                        )
                    )
                    add(
                        tscBitmapFont(
                            (73.0.div(4) * sizeIndex * dpi).toInt() + dpi,
                            (marginTop + fixedHeight + dynamicMaterialHeight + index * 6 + 1) * dpi,
                            textType,
                            30,
                            s
                        )
                    )
                }

                index++
            }

            //绘制页码区线框 x坐标=0 y坐标=上边距+固定区高度 + 动态物料高度 + 动态指令高度  width宽度=标签宽度 height高度=上边距+固定区高度 + 动态物料高度 + 动态指令高度 + 页码高度
            add(
                tscBox(
                    0,
                    (marginTop + fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight) * dpi,
                    width * dpi,
                    (marginTop + fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight + pageNumberHeight) * dpi,
                    2
                )
            )

            //绘制页码 x坐标=缩进25 y坐标=上边距+固定区高度 + 动态物料高度 + 动态指令高度 + 缩进1
            add(
                tscBitmapFont(
                    if (deliveryDate.isEmpty()) dpi * 25 else dpi * 15,
                    (marginTop + fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight + 1) * dpi,
                    textType,
                    30,
                    if (deliveryDate.isEmpty()) "页码：$pageNumber" else "页码：$pageNumber  交期：$deliveryDate"
                )
            )

            add(tscCutter())


            //打印
            add(tscPrint())
        }


        /**
         * 发送[75x45]金甄打印料头信息
         *
         * @param bean         二维吗内容
         * @param decrementNumber   递减编号
         * @param interID           派工单号
         * @param startDate         派工日期
         * @param machine           派工机台
         * @param factoryType       工厂型体
         */

        fun printMachineHeaderLabel(
            stuBarCode: String,//料头编码
            bean: String,//二维码信息
            decrementNumber: String,  //递减编号
            interID: String,  //派工单号
            startDate: String,  //派工日期
            machine: String,  //派工机台
            factoryType: String,  //工厂型体
            stubBar: String,  //料头编号
            shift: String,  //班次
        ): ArrayList<ByteArray> = arrayListOf<ByteArray>().apply {

            val dpi = 8
            val paperWidth = 75
            val paperHeight = 45

            add(tscClearBuffer())
            add(tscSetUp(paperWidth, paperHeight))
            add(tscQrCode(dpi * 2, dpi * 2, bean, ecc = "H", cell = "2"))  //二维码信息
            add(tscBitmapFont(dpi * 24, dpi * 2, textType, dpi * 4, "递减编号：$decrementNumber"))
            add(tscBitmapFont(dpi * 24, dpi * 8, textType, dpi * 4, "派工单号：$interID"))
            add(tscBitmapFont(dpi * 24, dpi * 14, textType, dpi * 4, "派工日期：$startDate"))
            add(
                tscBitmapFont(
                    dpi * 3,
                    dpi * 24,
                    textType,
                    dpi * 4,
                    "派工机台：$machine${" - "}${shift}"
                )
            )
            add(tscBitmapFont(dpi * 3, dpi * 29, textType, dpi * 4, "工厂型体：$factoryType"))
            if (stubBar.length > 12) {
                add(
                    tscBitmapFont(
                        dpi * 3,
                        dpi * 34,
                        textType,
                        dpi * 4,
                        "料头名称：${stubBar.substring(0, 12)}"
                    )
                )
            } else {
                add(tscBitmapFont(dpi * 3, dpi * 34, textType, dpi * 4, "料头名称：${stubBar}"))
            }
            add(tscBitmapFont(dpi * 3, dpi * 39, textType, dpi * 4, "料头编码：${stuBarCode}"))
            add(tscPrint())
        }

        /**
         * 发送[75x45]金甄机台派工单打印信息
         *
         * @param shift       班次
         * @param dispatchNumber       派工单号
         * @param decrementNumber       递减编号
         * @param machine       派工机台
         * @param bQID       BQID
         * @param factoryType       型体
         * @param boxNum       箱容
         * @param size       尺码
         * @param processes       制程
         * @param materialName    物料
         * @param startDate       开工日期
         */
        fun printMachineLabel(
            last: String,//尾标
            num: String,//序列号
            unit: String, //单位
            shift: String, //班次
            dispatchNumber: String, //派工单号
            decrementNumber: String, //递减编号
            machine: String, //派工机台
            bQID: String,//BQID
            factoryType: String,  //型体
            boxNum: String,  //箱容
            size: String,  //尺码
            processes: String,  //制程
            materialName: String,  //物料
            startDate: String, //开工日期
        ): ArrayList<ByteArray> = arrayListOf<ByteArray>().apply {

            val dpi = 8
            val paperWidth = 75
            val paperHeight = 45

            add(tscClearBuffer())
            add(tscSetUp(paperWidth, paperHeight))

            add(tscBox(2, 2, 74 * dpi, 44 * dpi))//画线框
            add(tscBitmapFont(dpi * 23, dpi * 14, textType, dpi * 4, factoryType))
            add(tscBitmapFont(dpi * 2, dpi * 2, textType, dpi * 3, "班次：$shift"))
            add(tscBitmapFont(dpi * 23, dpi * 21, textType, dpi * 3, "递减编号：$decrementNumber"))
            add(tscBitmapFont(dpi * 2, dpi * 9, textType, dpi * 3, "机台：${machine}"))
            add(tscBitmapFont(dpi * 23, dpi * 27, textType, dpi * 3, "派工单号：${dispatchNumber}"))
            add(tscBitmapFont(dpi * 2, dpi * 34, textType, dpi * 4, "$size #"))
            add(tscBitmapFont(dpi * 14, dpi * 34, textType, dpi * 4, last))
            add(tscBitmapFont(dpi * 23, dpi * 33, textType, dpi * 3, "生产日期：${startDate}"))
            add(tscBitmapFont(dpi * 2, dpi * 39, textType, dpi * 4, "$boxNum $unit"))
            add(tscBitmapFont(dpi * 23, dpi * 39, textType, dpi * 3, "生产制程：${processes}"))
            add(tscBitmapFont(dpi * 55, dpi * 39, textType, dpi * 3, "序号：$num"))
            add(tscLine(dpi * 1, dpi * 7, 20 * dpi, 1))//二维码上面第一条
            add(tscQrCode(dpi * 5, dpi * 15, bQID, cell = "4"))  //二维码信息
            add(tscLine(dpi * 21, dpi * 20, 73 * dpi, 1))//二维码下面第一条
            add(tscLine(dpi * 21, dpi * 26, 73 * dpi, 1))//二维码下面第二条
            add(tscLine(dpi * 1, dpi * 32, 73 * dpi, 1))//二维码下面第三条
            add(tscLine(dpi * 21, dpi * 1, 1, 43 * dpi))//二维码右边第一条竖线
            add(tscLine(dpi * 1, dpi * 13, 73 * dpi, 1))//二维码右边第一条横线
            add(tscLine(dpi * 21, dpi * 38, 53 * dpi, 1))//二维码下面第四条
            if (materialName.isNotEmpty() && materialName.length <= 32) {
                val num1 = ceil(materialName.length.toDouble() / 16).toInt()
                for (index in 1..num1) {
                    if (index * 16 < materialName.length) {
                        add(
                            tscBitmapFont(
                                dpi * 23,
                                dpi * 1 + dpi * 4 * (index - 1),
                                textType,
                                dpi * 4,
                                materialName.substring((index - 1) * 16, index * 16)
                            )
                        )
                    } else {
                        add(
                            tscBitmapFont(
                                dpi * 23,
                                dpi * 1 + dpi * 4 * (index - 1),
                                textType,
                                dpi * 4,
                                materialName.substring((index - 1) * 16, materialName.length)
                            )
                        )
                    }
                }
            } else if (materialName.isNotEmpty() && materialName.length > 32) {
                val num2 = ceil(materialName.length.toDouble() / 16).toInt()
                for (index in 1..num2) {
                    if (index * 16 < materialName.length) {
                        add(
                            tscBitmapFont(
                                dpi * 23,
                                dpi * 1 + dpi * 3 * (index - 1),
                                textType,
                                dpi * 3,
                                materialName.substring((index - 1) * 16, index * 16)
                            )
                        )
                    } else {
                        add(
                            tscBitmapFont(
                                dpi * 23,
                                dpi * 1 + dpi * 3 * (index - 1),
                                textType,
                                dpi * 3,
                                materialName.substring((index - 1) * 16, materialName.length)
                            )
                        )
                    }
                }
            }
            add(tscPrint())
        }


        /**
         * 裁断指令打标或者条码打标
         */
        fun printCuttingProcessLabel(
            colorStr: String,//色系
            foot: String,//左右脚
            allTotal: String,//型体上面的合计
            type: Int,//打印类型
            packageType: String,//打标类型类型
            barCode: String,  //二维码
            parNames: String, //部件
            factoryType: String, //型体
            processName: String,  //工序
            pageNumber: String,  //序号
            departName: String,  //部门
            instructions: MutableMap<String, MutableList<String>>
        ): ArrayList<ByteArray> = arrayListOf<ByteArray>().apply {

            //标签宽度 纸张75 左右各缩进1 = 75-2
            val width = 73
            //打印机dp为200 dpi=8
            val dpi = 8
            //距离上边距3
            val marginTop = 3
            //距离下边距3
            val marginButton = 3
            //固定区高度 14 加上上下边距2
            val fixedHeight = 17 + 2 + 2
            //工序名称自动分行
            val materialText = processName.chunked(17)
            //部件自动分行
            val parNameList = parNames.chunked(15)
            //工序动态高度 每行字体高度为6dpi
            val dynamicMaterialHeight = materialText.size * 8
            //指令行数量
            var lines = instructions.size
            instructions.forEach {
                if (it.value.size > 2) {
                    lines += ceil(it.value.size.div(2.0)).toInt()
                } else {
                    lines++
                }
            }
            //指令动态高度 每行字体高度为6dpi
            val dynamicInstructionsHeight = lines * 8
            val pageNumberHeight = 6
            val colorSystem = 6
            //清除缓存
            add(tscClearBuffer())
            //设置标签尺寸 width:标签宽度73 height:标签高度 = 上边距 + 固定区高度 + 动态物料高度 + 动态指令高度 + 页码高度 +下边距
            add(
                tscSetUp(
                    width,
                    marginTop + fixedHeight + 10 + dynamicMaterialHeight + dynamicInstructionsHeight + pageNumberHeight + colorSystem + marginButton,
                    sensorDistance = 0
                )
            )
            //绘制底部裁切线 x坐标=0 y坐标=上边距 +固定区高度 + 动态物料高度 + 动态指令高度 + 页码高度 + 下边距 - 缩进1 width长度=标签宽度
            for (i in 0..width step 2) {
                add(
                    tscLine(
                        i * dpi,
                        (marginTop + fixedHeight + 10 + dynamicMaterialHeight + dynamicInstructionsHeight + pageNumberHeight + marginButton + colorSystem) * dpi - 2,
                        dpi,
                        2
                    )
                )

            }
            //绘制固定区线框
            add(
                tscBox(
                    0,
                    marginTop * dpi,
                    width * dpi,
                    (fixedHeight + marginTop) * dpi,
                    2
                )
            )
            //绘制二维码与文本的分割线 x坐标=固定区高度 y坐标=上边距 width宽度=2 height高度=固定区高度
            add(
                tscLine(
                    fixedHeight * dpi,
                    marginTop * dpi,
                    2,
                    fixedHeight * dpi,
                )
            )
            //绘制二维码 x坐标=缩进2 y坐标=上边距 + 缩进2
            add(tscQrCode(1 * dpi, marginTop * dpi + 1 * dpi, barCode, cell = "3"))

            add(tscLine(dpi * 21, dpi * 17, 52 * dpi, 1))//型体下面的第二条线
            //绘制交期 x坐标=固定区高度 + 缩进2 y坐标=上边距 + 行间距8 + 缩进2
            add(
                tscBitmapFont(
                    fixedHeight * dpi + 1 * dpi,
                    marginTop * dpi + 14 * dpi + 2 * dpi,
                    textType,
                    27,
                    "组别：$departName"
                )
            )
            if (foot.isNotEmpty()) {
                add(
                    tscBitmapFont(
                        60 * dpi,
                        marginTop * dpi + 14 * dpi + 2 * dpi,
                        textType,
                        27,
                        "<$foot>"
                    )
                )
            }
            //绘制型体文本 x坐标=固定区高度 + 缩进2 y坐标=上边距 + 缩进2  型体和数量
            add(
                tscBitmapFont(
                    2 * dpi,
                    (fixedHeight + 1 + marginTop) * dpi,
                    textType,
                    40,
                    "$factoryType   $allTotal"
                )
            )
            //工序上面的横线
            add(
                tscLine(
                    0,
                    (fixedHeight + 8 + marginTop) * dpi,
                    width * dpi,
                    1,
                )
            )
            add(
                tscBox(
                    0,
                    (fixedHeight + marginTop) * dpi,
                    width * dpi,
                    (fixedHeight + dynamicMaterialHeight + 10 + marginTop) * dpi,
                    2
                )
            )
            parNameList.forEachIndexed { index, s ->
                if (index < 2) {
                    add(
                        tscBitmapFont(
                            22 * dpi,
                            ((3 + 4 * index) + 1) * dpi,
                            textType,
                            35,
                            s
                        )
                    )
                }
            }
            //循环绘制多行工序
            materialText.forEachIndexed { index, s ->
                //绘制物料名称 x坐标=缩进2 y坐标=固定区高度 + 上边距 + 动态行间距4*index + 缩进1
                add(
                    tscBitmapFont(
                        2 * dpi,
                        ((fixedHeight + 8 + marginTop + 6 * index) + 1) * dpi,
                        textType,
                        35,
                        s
                    )
                )
            }
            //绘制指令区线框 x坐标=0 y坐标=固定区高度 + 动态物料高度 + 上边距 width宽度=标签宽度 height高度=固定区高度 + 动态物料高度 + 动态指令高度 + 上边距
            add(
                tscBox(
                    0,
                    (fixedHeight + 10 + dynamicMaterialHeight + marginTop) * dpi,
                    width * dpi,
                    (fixedHeight + 10 + dynamicMaterialHeight + dynamicInstructionsHeight + marginTop) * dpi,
                    2
                )
            )
            //循环绘制多行指令
            var index = 0
            instructions.forEach {
                //绘制指令区线框 x坐标=0 y坐标=固定区高度 + 动态物料高度 + 上边距 + 动态行间距6*index width宽度=标签宽度 height高度=固定区高度 + 动态物料高度 + 动态指令高度 + 上边距 +行间距6+动态行间距
                add(
                    tscBox(
                        0,
                        (fixedHeight + 10 + dynamicMaterialHeight + marginTop + 8 * index) * dpi,
                        width * dpi,
                        (fixedHeight + 10 + dynamicMaterialHeight + marginTop + 8 + 8 * index) * dpi,
                        2
                    )
                )
                var addQty = 0.0
                it.value.forEach { qty ->
                    addQty += qty.split("/")[1].toDoubleTry()
                }
                //绘制指令 x坐标=缩进2 y坐标=固定区高度 + 动态物料高度 + 上边距 + 动态行间距6*index + 缩进1
                add(
                    tscBitmapFont(
                        1 * dpi,
                        ((fixedHeight + 10 + dynamicMaterialHeight + marginTop + 8 * index) + 2) * dpi,
                        textType,
                        37,
                        if (packageType == "2") packageType + ":" + it.key + "#" + " 合计:" + addQty.removeDecimalZero()
                        else packageType + ":" + it.key + "#" + " 合计:" + addQty.removeDecimalZero()
                    )
                )
                var sizeIndex = 0
                it.value.forEachIndexed { i, s ->
                    if (i % 2 == 0) {
                        index++
                        sizeIndex = 0
                    } else {
                        sizeIndex++
                    }
                    add(
                        tscBox(
                            (73.0.div(2) * sizeIndex * dpi).toInt(),
                            (marginTop + fixedHeight + 10 + dynamicMaterialHeight + index * 8) * dpi,
                            (73.0.div(2) * sizeIndex * dpi).toInt() + (73.0.div(2) * dpi).toInt(),
                            (marginTop + fixedHeight + 10 + dynamicMaterialHeight + index * 8 + 8) * dpi,
                            2
                        )
                    )
                    add(
                        tscBitmapFont(
                            (73.0.div(2) * sizeIndex * dpi).toInt() + dpi,
                            (marginTop + fixedHeight + 10 + dynamicMaterialHeight + index * 8 + 2) * dpi,
                            textType,
                            32,
                            s
                        )
                    )
                }
                index++
            }
            //绘制页码区线框 x坐标=0 y坐标=上边距+固定区高度 + 动态物料高度 + 动态指令高度  width宽度=标签宽度 height高度=上边距+固定区高度 + 动态物料高度 + 动态指令高度 + 页码高度
            add(
                tscBox(
                    0,
                    (marginTop + fixedHeight + 10 + dynamicMaterialHeight + dynamicInstructionsHeight) * dpi,
                    width * dpi,
                    (marginTop + fixedHeight + 10 + dynamicMaterialHeight + dynamicInstructionsHeight + pageNumberHeight) * dpi,
                    2
                )
            )
            //绘制页码 x坐标=缩进25 y坐标=上边距+固定区高度 + 动态物料高度 + 动态指令高度 + 缩进1
            add(
                tscBitmapFont(
                    8,
                    (marginTop + fixedHeight + 10 + dynamicMaterialHeight + dynamicInstructionsHeight + 1) * dpi,
                    textType,
                    27,
                    "序号：$pageNumber",
                )
            )
            //绘制页码区线框 x坐标=0 y坐标=上边距+固定区高度 + 动态物料高度 + 动态指令高度  width宽度=标签宽度 height高度=上边距+固定区高度 + 动态物料高度 + 动态指令高度 + 页码高度 + 色系高度
            add(
                tscBox(
                    0,
                    (marginTop + fixedHeight + 10 + dynamicMaterialHeight + dynamicInstructionsHeight + pageNumberHeight) * dpi,
                    width * dpi,
                    (marginTop + fixedHeight + 10 + dynamicMaterialHeight + dynamicInstructionsHeight + pageNumberHeight + colorSystem) * dpi,
                    2
                )
            )
            add(
                tscBitmapFont(
                    8,
                    (marginTop + fixedHeight + 10 + dynamicMaterialHeight + dynamicInstructionsHeight + colorSystem + 1) * dpi,
                    textType,
                    27,
                    "配色批次：$colorStr",
                )
            )
            //打印
            add(tscPrint())
        }

        /**
         * 通用固定标签
         *
         * @param   qrCode                  二维码内容
         * @param   title                   主标题文本
         * @param   subTitle                子标题文本
         * @param   content                 主内容文本
         * @param   subContent1             子内容文本1
         * @param   subContent2             字内容文本2
         * @param   bottomLeftText1         左下文本1
         * @param   bottomLeftText2         左下文本2
         * @param   bottomMiddleText1       中下文本1
         * @param   bottomMiddleText2       中下文本2
         * @param   bottomRightText1        右下文本1
         * @param   bottomRightText2        右下文本2
         */
        fun multipurposeFixedLabel(
            qrCode: String = "",
            title: String = "",
            subTitle: String = "",
            subTitleWrap: Boolean = true,
            content: String = "",
            subContent1: String = "",
            subContent2: String = "",
            bottomLeftText1: String = "",
            bottomLeftText2: String = "",
            bottomMiddleText1: String = "",
            bottomMiddleText2: String = "",
            bottomRightText1: String = "",
            bottomRightText2: String = "",
        ) = arrayListOf<ByteArray>().apply {
            val dpi = 8
            add(tscClearBuffer())
            add(tscSetUp(75, 45))

            if (qrCode.isNotEmpty()) {
                add(
                    tscQrCode(
                        2 * dpi,
                        2 * dpi + 4,
                        if (qrCode.contains("\"")) qrCode.replace("\"", "\\[\"]") else qrCode
                    )
                )
                add(tscBitmapFont(19 * dpi + 4, 2 * dpi, textType, 16, qrCode))
            }
            if (title.isNotEmpty()) {
                add(tscBitmapFont(19 * dpi + 4, 4 * dpi + 4, textType, 40, title))
            }
            if (subTitleWrap) {
                if (subTitle.isNotEmpty()) {
                    contextFormat(subTitle, 30f, dpi * 54).forEachIndexed { index, s ->
                        //限制子标题行数为2
                        if (index >= 2) return@forEachIndexed
                        add(
                            tscBitmapFont(
                                19 * dpi + 4,
                                (11 + 4 * index) * dpi - 4,
                                textType,
                                30,
                                s
                            )
                        )
                    }
                }
            } else {
                add(tscBitmapFont(19 * dpi + 4, 12 * dpi, textType, 40, subTitle))
            }

            if (content.isNotEmpty()) {
                contextFormat(content, 30f, dpi * 71).forEachIndexed { index, s ->
                    //如子内容不为空，则主内容限制行数为2
                    if (subContent1.isNotEmpty() && subContent2.isNotEmpty() && index >= 2) return@forEachIndexed
                    //如子内容2不为空，则主内容限制行数为3
                    if (subContent1.isEmpty() && subContent2.isNotEmpty() && index >= 3) return@forEachIndexed
                    //如子内容为空则限制主内容行数为4
                    if (index >= 4) return@forEachIndexed
                    add(tscBitmapFont(2 * dpi, (20 + 4 * index) * dpi, textType, 30, s))
                }
            }

            if (subContent1.isNotEmpty()) {
                add(tscBitmapFont(2 * dpi, 28 * dpi, textType, 28, subContent1))
            }
            if (subContent2.isNotEmpty()) {
                add(tscBitmapFont(2 * dpi, 32 * dpi, textType, 28, subContent2))
            }
            if (bottomLeftText1.isNotEmpty()) {
                if (bottomLeftText2.isNotEmpty()) {
                    add(tscBitmapFont(dpi * 2, 37 * dpi, textType, 24, bottomLeftText1))
                    add(tscBitmapFont(dpi * 2, 40 * dpi, textType, 24, bottomLeftText2))
                } else {
                    add(tscBitmapFont(dpi * 2, 38 * dpi, textType, 36, bottomLeftText1))
                }
            }
            if (bottomMiddleText1.isNotEmpty()) {
                if (bottomMiddleText2.isNotEmpty()) {
                    add(tscBitmapFont(23 * dpi + 4, 37 * dpi, textType, 24, bottomMiddleText1))
                    add(tscBitmapFont(23 * dpi + 4, 40 * dpi, textType, 24, bottomMiddleText2))
                } else {
                    add(tscBitmapFont(23 * dpi + 4, 38 * dpi, textType, 34, bottomMiddleText1))
                }
            }
            if (bottomRightText1.isNotEmpty()) {
                if (bottomRightText2.isNotEmpty()) {
                    add(tscBitmapFont(62 * dpi, 37 * dpi, textType, 24, bottomRightText1))
                    add(tscBitmapFont(62 * dpi, 40 * dpi, textType, 24, bottomRightText2))
                } else {
                    add(tscBitmapFont(62 * dpi, 38 * dpi, textType, 36, bottomRightText1))
                }
            }

            add(tscBox(dpi, dpi, 74 * dpi, 44 * dpi, crude = 2))

            add(tscLine(19 * dpi, dpi, 2, 19 * dpi - 4))
            add(tscLine(23 * dpi, 36 * dpi + 4, 2, 8 * dpi - 4))
            add(tscLine(61 * dpi + 4, 36 * dpi + 4, 2, 8 * dpi - 4))

            add(tscLine(19 * dpi, 4 * dpi + 2, 55 * dpi, 2))
            add(tscLine(19 * dpi, 10 * dpi, 55 * dpi, 2))
            add(tscLine(dpi, 20 * dpi - 4, 73 * dpi, 2))
            add(tscLine(dpi, 36 * dpi + 4, 73 * dpi, 2))

            add(tscPrint())
        }

        /**
         * 通用动态标签
         * @param   qrCode              二维码内容
         * @param   title               主标题文本
         * @param   subTitle            子标题文本
         * @param   tableTitle          表格标题文本
         * @param   tableTitleTips      表格标题提示文本
         * @param   tableSubTitle       表格子标题文本
         * @param   tableData           表格表体数据
         * @param   bottomLeftText1     左下文本1
         * @param   bottomLeftText2     左下文本2
         * @param   bottomRightText1    右下文本1
         * @param   bottomRightText2    右下文本2
         */
        fun multipurposeDynamicLabel(
            qrCode: String = "",
            title: String = "",
            subTitle: String = "",
            tableTitle: String = "",
            tableTitleTips: String = "",
            tableSubTitle: String = "",
            tableSubTitle2: MutableList<String> = mutableListOf(),
            tableFirstLineTitle: String = "",
            tableLastLineTitle: String = "",
            tableData: HashMap<String, MutableList<Array<String>>> = hashMapOf(),
            bottomLeftText1: String = "",
            bottomLeftText2: String = "",
            bottomRightText1: String = "",
            bottomRightText2: String = "",
        ) = arrayListOf<ByteArray>().apply {

            //打印机dp为200 dpi=8
            val dpi = 8

            //半dpi
            val halfDpi = 4

            //标签宽度 纸张75 左右各缩进1 = 75-2
            val width = 73

            //边距
            val margin = 3

            //内缩
            val padding = 1

            //二维码宽度
            val qrCodeWidth = 18
            val qrCodeShowHeight = 2

            //主标题文本高度
            val titleTextHeight = 6
            //表格主标题高度
            val tableTitleHeight = 4
            val tableTitleWidth = 50
            //表格子标题文本高度
            val tableSubTitleHeight = 4 * contextFormat(tableSubTitle, 30f, dpi * 71).size

            //指令文本高度
            val tableSubTitleHeight2 = ceil(tableSubTitle2.size / 3.0).toInt() * 4

            //表格行高
            val tableLineHeight = 5
            //表格换行 行高
            val tableLineWrap = 2
            //表格上下边距
            val tableMargin = 4

            //表格数据
            val table = tableFormat(tableFirstLineTitle, tableLastLineTitle, tableData)

            //表格高度
            val tableHeight =
                table.filter { it.isEmpty() }.size * tableLineWrap + table.filter { it.isNotEmpty() }.size * tableLineHeight + tableMargin

            //底部文本高度
            val bottomTextHeight = 8

            //height:标签高度 = 边距 + 内缩 + 二维码高度 + 表格主标题高度 + 表格子标题高度 + 动态指令高度 + 底部文本高度 + 内缩 + 边距
            val height =
                margin + padding + qrCodeWidth + tableTitleHeight + tableSubTitleHeight + tableHeight + bottomTextHeight + padding + margin + tableSubTitleHeight2

            val qrCodeX = (1 + padding) * dpi
            val qrCodeY = (margin + padding) * dpi
            val qrCodeShowX = (1 + padding + qrCodeWidth) * dpi
            val qrCodeShowY = margin * dpi
            val titleX = (1 + padding + qrCodeWidth) * dpi
            val titleY = (margin + qrCodeShowHeight) * dpi + halfDpi
            val subTitleX = (1 + padding + qrCodeWidth) * dpi
            val subTitleY = (margin + qrCodeShowHeight + titleTextHeight) * dpi + halfDpi
            val tableTitleX = (1 + padding) * dpi
            val tableTitleY = (margin + padding + qrCodeWidth) * dpi
            val tableTitleTipsX = (1 + tableTitleWidth + padding) * dpi
            val tableTitleTipsY = (margin + padding + qrCodeWidth) * dpi
            val tableSubTitleX = (1 + padding) * dpi
            val tableSubTitleY = (margin + padding + qrCodeWidth + tableTitleHeight) * dpi
            val bLeftText1X = (1 + padding) * dpi
            val bLeftText1Y =
                (margin + padding + qrCodeWidth + tableTitleHeight + tableSubTitleHeight + tableHeight + tableSubTitleHeight2) * dpi
            val bLeftText2X = (1 + padding) * dpi
            val bLeftText2Y =
                (margin + padding + qrCodeWidth + tableTitleHeight + tableSubTitleHeight + tableHeight + 4 + tableSubTitleHeight2) * dpi
            val bRightText1X = (1 + padding + 35) * dpi
            val bRightText1Y =
                (margin + padding + qrCodeWidth + tableTitleHeight + tableSubTitleHeight + tableHeight + tableSubTitleHeight2) * dpi
            val bRightText2X = (1 + padding + 35) * dpi
            val bRightText2Y =
                (margin + padding + qrCodeWidth + tableTitleHeight + tableSubTitleHeight + tableHeight + 4 + tableSubTitleHeight2) * dpi


            add(tscClearBuffer())
            //设置标签尺寸
            add(tscSetUp(width, height, sensorDistance = 0))

            if (qrCode.isNotEmpty()) {
                add(
                    tscQrCode(
                        qrCodeX,
                        qrCodeY,
                        if (qrCode.contains("\"")) qrCode.replace("\"", "\\[\"]") else qrCode
                    )
                )
                add(tscBitmapFont(qrCodeShowX, qrCodeShowY, textType, 16, qrCode))
            }
            if (title.isNotEmpty()) {
                add(tscBitmapFont(titleX, titleY, textType, 40, title))
            }
            if (subTitle.isNotEmpty()) {
                contextFormat(subTitle, 30f, dpi * 52).forEachIndexed { line, s ->
                    //只允许行数为2
                    if (line >= 2) return@forEachIndexed
                    //行高
                    val lineHeight = 4
                    add(
                        tscBitmapFont(
                            subTitleX,
                            subTitleY + lineHeight * line * dpi,
                            textType,
                            30,
                            s
                        )
                    )
                }
            }

            if (tableTitle.isNotEmpty()) {
                add(tscBitmapFont(tableTitleX, tableTitleY, textType, 30, tableTitle))
            }
            if (tableTitleTips.isNotEmpty()) {
                add(
                    tscBitmapFont(
                        tableTitleTipsX + 2,
                        tableTitleTipsY,
                        textType,
                        30,
                        tableTitleTips
                    )
                )
            }
            if (tableSubTitle.isNotEmpty()) {
                contextFormat(tableSubTitle, 30f, dpi * 71).forEachIndexed { line, s ->
                    //行高
                    val lineHeight = 4
                    add(
                        tscBitmapFont(
                            tableSubTitleX,
                            tableSubTitleY + lineHeight * line * dpi,
                            textType,
                            30,
                            s
                        )
                    )
                }
            }
            val num = ceil(tableSubTitle2.size / 3.0).toInt()

            Log.e("Pan", "打印有几行：" + tableSubTitle2.size)
            Log.e("Pan", "打印有几行：$num")

            if (tableSubTitle2.isNotEmpty()) {

                for (i in 1..num) {
                    Log.e("Pan", "打印第几行：$i")
                    var mes = ""
                    tableSubTitle2.forEachIndexed { index, s ->

                        if (index >= (i - 1) * 3 && index < i * 3) {
                            mes += "$s  "
                            Log.e("Pan", "打印内容：" + mes)
                        }
                    }
                    add(
                        tscBitmapFont(
                            tableSubTitleX,
                            tableSubTitleY + 4 * i * dpi,
                            textType,
                            30,
                            mes
                        )
                    )
                }
            }


            if (table.isNotEmpty()) {
                var boxY =
                    (margin + padding + qrCodeWidth + tableTitleHeight + tableSubTitleHeight + 1) * dpi
                table.forEach { line ->
                    var boxX = (1 + padding) * dpi
                    var boxH = tableLineHeight * dpi
                    if (line.isEmpty()) {
                        boxY += tableLineWrap * dpi
                        boxH += tableLineWrap * dpi
                    } else {
                        var boxW: Int
                        line.forEachIndexed { columnIndex, s ->
                            boxW = if (columnIndex == 0) 22 * dpi else 8 * dpi
                            if (s.isNotEmpty()) {
                                add(tscBitmapFont(boxX + dpi, boxY + dpi, textType, 28, s))
                            }
                            add(tscBox(boxX, boxY + halfDpi, boxW + boxX, boxH + boxY + halfDpi, 2))
                            boxX += boxW
                        }
                        boxY += tableLineHeight * dpi
                        boxH += tableLineHeight * dpi
                    }
                }
            }
            if (bottomLeftText1.isNotEmpty()) {
                add(tscBitmapFont(bLeftText1X, bLeftText1Y, textType, 30, bottomLeftText1))
            }
            if (bottomLeftText2.isNotEmpty()) {
                add(tscBitmapFont(bLeftText2X, bLeftText2Y, textType, 30, bottomLeftText2))
            }
            if (bottomRightText1.isNotEmpty()) {
                add(tscBitmapFont(bRightText1X, bRightText1Y, textType, 30, bottomRightText1))
            }
            if (bottomRightText2.isNotEmpty()) {
                add(tscBitmapFont(bRightText2X, bRightText2Y, textType, 30, bottomRightText2))
            }

            add(tscLine((padding + qrCodeWidth) * dpi, margin * dpi, 2, qrCodeWidth * dpi))
            add(
                tscLine(
                    (padding + qrCodeWidth) * dpi,
                    (margin + qrCodeShowHeight) * dpi,
                    (width - qrCodeWidth - padding) * dpi,
                    2
                )
            )
            add(
                tscLine(
                    (padding + qrCodeWidth) * dpi,
                    (margin + qrCodeShowHeight + titleTextHeight) * dpi,
                    (width - qrCodeWidth - padding) * dpi,
                    2
                )
            )
            add(
                tscLine(
                    dpi,
                    (margin + qrCodeWidth) * dpi,
                    (width - padding) * dpi,
                    2
                )
            )
            add(tscBox(dpi, margin * dpi, width * dpi, (height - margin) * dpi, crude = 2))

            //绘制底部裁切线 x坐标=0 y坐标=上边距 +固定区高度 + 动态物料高度 + 动态指令高度 + 页码高度 + 下边距 - 缩进1 width长度=标签宽度
            for (i in 0..width step 2) {
                add(tscLine(i * dpi, height * dpi - 2, dpi, 2))
            }
            add(tscCutter())
            //打印
            add(tscPrint())


        }

        fun tableFormat(
            title: String,
            bottom: String,
            list: HashMap<String, MutableList<Array<String>>>
        ) =
            mutableListOf<MutableList<String>>().apply {
                if (list.isEmpty()) return@apply
                //取出所有尺码
                var titleList = mutableListOf<String>()
                val columnsTitleList = mutableListOf<String>()
                list.forEach { ins ->
                    ins.value.forEach { indexText ->
                        if (!titleList.contains(indexText[0])) {
                            titleList.add(indexText[0])
                        }
                    }
                }
                titleList = titleList.sorted().toMutableList()
                Log.e("Pan", "titleList=${Gson().toJson(titleList)}")

                //指令缺的尺码做补位处理
                list.forEach { ins ->
                    val text = mutableListOf<Array<String>>()
                    titleList.forEach { indexText ->
                        ins.value.find { it[0] == indexText }.let { data ->
                            if (data == null) {
                                text.add(arrayOf(indexText, ""))
                            } else {
                                text.add(data)
                            }
                        }
                    }
                    ins.value.clear()
                    ins.value.addAll(text)
                }
                mutableListOf<MutableList<String>>().also { printList ->
                    //添加表格头行
                    printList.add(mutableListOf<String>().also { print ->
                        //保存表格列第一格
                        columnsTitleList.add(title)
                        //保存表格第一行
                        titleList.forEach { s -> print.add(s) }
                    })

                    //添加表格体
                    list.forEach { ins ->
                        printList.add(mutableListOf<String>().also { print ->
                            //保存表格列第一格
                            columnsTitleList.add(ins.key)
                            //保存表格本体所有行
                            ins.value.forEach { data -> print.add(data[1]) }
                        })
                    }

                    //添加表格尾行
                    printList.add(mutableListOf<String>().also { print ->
                        //保存表格列第一格
                        columnsTitleList.add(bottom)
                        //保存表格最后一行
                        titleList.forEachIndexed { index, _ ->
                            var sum = 0.0
                            list.forEach { ins ->
                                if (index < titleList.size) {
                                    sum = sum.add(ins.value[index][1].toDoubleTry())
                                }
                            }
                            print.add(sum.removeDecimalZero())
                        }
                    })

                    printList.forEach {
                        Log.e("Pan", "print=${Gson().toJson(it)}")
                    }

                    val max = 6
                    val maxColumns =
                        (titleList.size / max) + if ((titleList.size % max) > 0) 1 else 0
                    for (i in 0 until maxColumns) {
                        //添加表格
                        printList.forEachIndexed { index, data ->
                            val s = i * max
                            val t = i * max + max
                            add(
                                mutableListOf<String>().also { subData ->
                                    //添加行表头
                                    subData.add(columnsTitleList[index])
                                    //添加行
                                    subData.addAll(
                                        data.subList(
                                            s,
                                            if (s < data.size && t <= data.size) t else data.size
                                        )
                                    )
                                }
                            )
                        }
                        if (i < maxColumns - 1) {
                            //加入空行用于区分表格换行
                            add(mutableListOf())
                        }
                    }
                    forEach {
                        Log.e("Pan", Gson().toJson(it))
                    }
                }
            }

        /**
         * 文本换行格式化
         * @param   text        文本内容
         * @param   fontSize    字体大小（px）
         * @param   maxWidthPx  文本限宽（px）
         */
        fun contextFormat(text: String, fontSize: Float, maxWidthPx: Int) =
            mutableListOf<String>().apply {
                var context = ""
                text.forEach { c ->
                    val textWidthPx = Paint().apply { textSize = fontSize }.measureText(context + c)
                    if (textWidthPx <= maxWidthPx) {
                        context += c
                    } else {
                        add(context)
                        context = c.toString()
                    }
                }
                add(context)
            }
        //↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ 标签指令 ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑


        //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ 打印机指令 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

        /**
         * 下发打印标签指令
         *
         * @param quantity
         * @param copy
         * @return
         */
        private fun tscPrint(quantity: Int = 1, copy: Int = 1) =
            "PRINT $quantity, $copy\r\n".toByteArray()

        /**
         * 下发拆切指令
         *
         * @return
         */
        private fun tscCutter() = "SET CUTTER 1\r\n".toByteArray()


        /**
         * 下发图片指令
         * @param   xAxis   x轴
         * @param   yAxis   y轴
         * @param   bitmap  图片Bitmap
         * @param   reSizeWidth     设定宽度
         * @param   reSizeHeight    设定高度
         */
        private fun tscBitmap(
            xAxis: Int,
            yAxis: Int,
            bitmap: Bitmap,
            reSizeWidth: Int,
            reSizeHeight: Int
        ): ByteArray {

            val resizedBitmap = Bitmap.createScaledBitmap(bitmap, reSizeWidth, reSizeHeight, false)
            val grayBitmap = bitmap2Gray(resizedBitmap)
            val binaryBitmap = gray2Binary(grayBitmap)
            val pictureWidth = ((binaryBitmap.width + 7) / 8).toString()
            val pictureHeight = binaryBitmap.height.toString()
            val mode = 0.toString()
            val command = "BITMAP $xAxis,$yAxis,$pictureWidth,$pictureHeight,$mode,"
            val stream = ByteArray((binaryBitmap.width + 7) / 8 * binaryBitmap.height)
            val widthBytes = (binaryBitmap.width + 7) / 8
            val width = binaryBitmap.width
            val height = binaryBitmap.height
            var y = 0
            while (y < height * widthBytes) {
                stream[y] = -1
                ++y
            }

            y = 0
            while (y < height) {
                for (x in 0 until width) {
                    val pixelColor = binaryBitmap.getPixel(x, y)
                    val colorR = Color.red(pixelColor)
                    val colorG = Color.green(pixelColor)
                    val colorB = Color.blue(pixelColor)
                    val total = (colorR + colorG + colorB) / 3
                    if (total == 0) {
                        stream[y * ((width + 7) / 8) + x / 8] =
                            (stream[y * ((width + 7) / 8) + x / 8].toInt() xor (128 shr x % 8).toByte()
                                .toInt()).toByte()
                    }
                }
                ++y
            }

            return command.toByteArray() + stream + "\r\n".toByteArray()
        }

        /**
         * 打印文本
         *
         * @param xAxis X坐标
         * @param yAxis Y坐标
         * @param typeface      文本字体
         * @param fontSize      文字大小
         * @param textToPrint   文字内容
         *  字体尺寸为 60 时，中文实际占用宽度为7.5毫米 英文及字符则只占中文的一半
         *  字体尺寸为 40 时，中文实际占用宽度为5毫米 英文及字符则只占中文的一半
         * @return
         */
        private fun tscBitmapFont(
            xAxis: Int,
            yAxis: Int,
            typeface: Typeface,
            fontSize: Int,
            textToPrint: String
        ): ByteArray {
            val textPaint = TextPaint(Paint().also {
                it.style = Paint.Style.FILL
                it.color = -16777216
                it.isAntiAlias = true
                it.typeface = typeface
                it.textSize = fontSize.toFloat()
            })

            val staticLayout = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                StaticLayout.Builder
                    .obtain(
                        textToPrint,
                        0,
                        textToPrint.length,
                        textPaint,
                        832,
                    )
                    .setAlignment(Layout.Alignment.ALIGN_NORMAL)
                    .setLineSpacing(
                        0.0f,
                        1.0f
                    )
                    .setIncludePad(false)
                    .build()
            } else {
                StaticLayout(
                    textToPrint,
                    textPaint,
                    832,
                    Layout.Alignment.ALIGN_NORMAL,
                    1.0f,
                    0.0f,
                    false
                )
            }
            var height = staticLayout.height
            if (height > 2378) {
                height = 2378
            }
            val width = Layout.getDesiredWidth(textToPrint, textPaint).toInt()
            val originalBitmap = Bitmap.createBitmap(width + 8, height, Bitmap.Config.RGB_565)
            staticLayout.draw(Canvas(originalBitmap).apply {
                drawColor(-1)
                translate(0.0f, 0.0f)
            })
            val binaryBitmap = gray2Binary(bitmap2Gray(originalBitmap))
            val pictureWidth = (binaryBitmap.width + 7) / 8
            val pictureHeight = binaryBitmap.height

            val command = "BITMAP $xAxis,$yAxis,$pictureWidth,$pictureHeight,0,"

            val stream = ByteArray(pictureWidth * binaryBitmap.height)

            var y = 0
            while (y < binaryBitmap.height * pictureWidth) {
                stream[y] = -1
                ++y
            }
            y = 0
            while (y < binaryBitmap.height) {
                for (x in 0 until binaryBitmap.width) {
                    val pixelColor = binaryBitmap.getPixel(x, y)

                    if (((Color.red(pixelColor) + Color.green(pixelColor) + Color.blue(pixelColor)) / 3) == 0) {
                        stream[y * pictureWidth + x / 8] =
                            stream[y * pictureWidth + x / 8] xor (128 shr x % 8).toByte()
                    }
                }
                ++y
            }
            return command.toByteArray() + stream + "\r\n".toByteArray()
        }

        /**
         * 文本
         *
         * @param x                 X坐标
         * @param y                 Y坐标
         * @param font              字体
         * @param rotation          旋转角度
         * @param xMultiplication   水平放大
         * @param yMultiplication   垂直放大
         *
         * 打印机不支持中文打印，需要通过《Diagnostic Tool》工具进行字体库生成并导入，且中文字符需要通过GB2312转码。
         * -----------打印机自带字体库-----------
         * 0            Monotye CG Triumvirate Bold Condensed, font width and height is stretchable
         * 1            8 x 12 fixed pitch dot font
         * 2            12 x 20 fixed pitch dot font
         * 3            16 x 24 fixed pitch dot font
         * 4            24 x 32 fixed pitch dot font
         * 5            32 x 48 dot fixed pitch font
         * 6            14 x 19 dot fixed pitch font OCR-B
         * 7            21 x 27 dot fixed pitch font OCR-B
         * 8            14 x25 dot fixed pitch font OCR-A
         * ROMAN.TTF    ROMAN 向量字体
         * -----------------------------------
         * @return
         */
        private fun tscTextFont(
            x: Int,
            y: Int,
            font: String,
            rotation: Int,
            xMultiplication: Int,
            yMultiplication: Int,
            text: String
        ) =
            "TEXT $x,$y ,\"$font\" ,$rotation ,$xMultiplication ,$yMultiplication ,\"".toByteArray() + text.toByteArray(
                charset("GB2312")
            ) + "\"\n".toByteArray()

        /**
         * 画线
         *
         * @param x      X坐标
         * @param y      Y坐标
         * @param width  宽
         * @param height 高
         * @return
         */
        private fun tscLine(x: Int, y: Int, width: Int, height: Int) =
            "BAR $x,$y,$width,$height\r\n".toByteArray()

        /**
         * 画线框
         *
         * @param sx    起始X坐标
         * @param sy    起始Y坐标
         * @param ex    结束X坐标
         * @param ey    结束Y坐标
         * @param crude 粗
         * @return
         */
        private fun tscBox(sx: Int, sy: Int, ex: Int, ey: Int, crude: Int = 4) =
            "BOX $sx,$sy,$ex,$ey,$crude\n".toByteArray()

        /**
         * 画圆
         *
         * @param x         X坐标
         * @param y         Y坐标
         * @param diameter  直径
         * @param thickness 粗细
         * @return
         */
        fun tscCircle(x: Int, y: Int, diameter: Int, thickness: Int) =
            "CIRCLE $x,$y,$diameter,$thickness\r\n".toByteArray()

        /**
         * 清除缓存
         *
         * @return
         */
        private fun tscClearBuffer() = "CLS\r\n".toByteArray()

        /**
         * 打印二维码
         *
         * @param x        X坐标
         * @param y        Y坐标
         * @param content  内容
         * @param ecc      纠错等级 L:7% M:15% Q:25% H：30%
         * @param cell     线宽  1~10
         * @param mode     模式  A:自动 M:手动
         * @param rotation 旋转 0 90 180 270
         * @param model    模式 M1:(默认)原始版本 M2:扩大版本
         * @param mask     S0~S8, 默认为 S7
         * @return
         */
        private fun tscQrCode(
            x: Int,
            y: Int,
            content: String,
            ecc: String = "H",
            cell: String = "4",
            mode: String = "A",
            rotation: String = "0",
            model: String = "M2",
            mask: String = "S7"
        ) = "QRCODE $x,$y,$ecc,$cell,$mode,$rotation,$model,$mask,\"$content\"\r\n".toByteArray()

        /**
         * 打印条形码
         *
         * @param x        X坐标
         * @param y        Y坐标
         * @param content  内容
         * @param sym      条码类型
         * @param rotate   旋转角度 0 - 270
         * @param moduleWidth  模组宽度  1 - 10
         * @param sepHt    分隔符高度  1 和  2 可选
         * @param segWidth    UCC/EAN - 128 高度  单位DOT(1-500可选)
         * @return
         */
        private fun tscBarCode(
            x: Int,
            y: Int,
            content: String,
            sym: String = "UCC128CCA",
            rotate: String = "0",
            moduleWidth: String = "2",
            sepHt: String = "2",
            segWidth: String = "35"
        ) =
            "RSS $x,$y,\"$sym\",$rotate,$moduleWidth,$sepHt,$segWidth,\"$content\"\r\n".toByteArray()

        /**
         * 打印设置
         *
         * @param width             打印纸宽mm
         * @param height            打印纸高mm
         * @param speed             打印速度 1.0 1.5 2 3 4 6 8 10
         * @param density           打印浓度 0~15
         * @param sensor            感应器列表 0:垂直間距感測器(gap sensor) 1:黑標感測器(black mark )
         * @param sensorDistance    打印纸间距
         * @param sensorOffset      打印纸偏移
         * @return
         */
        private fun tscSetUp(
            width: Int,
            height: Int,
            speed: Int = 4,
            density: Int = 6,
            sensor: Int = 0,
            sensorDistance: Int = 2,
            sensorOffset: Int = 0
        ): ByteArray {
            val size = "SIZE $width mm, $height mm"
            val speedValue = "SPEED $speed"
            val densityValue = "DENSITY $density"
            var sensorValue = ""
            if (sensor == 0) {
                sensorValue = "GAP $sensorDistance mm, $sensorOffset mm"
            } else if (sensor == 1) {
                sensorValue = "BLINE $sensorDistance mm, $sensorOffset mm"
            }

            return """
             $size
             $speedValue
             $densityValue
             $sensorValue
             
             """.trimIndent().toByteArray()
        }


        private fun bitmap2Gray(bmSrc: Bitmap): Bitmap =
            Bitmap.createBitmap(bmSrc.width, bmSrc.height, Bitmap.Config.RGB_565).apply {
                Canvas(this).drawBitmap(bmSrc, 0.0f, 0.0f, Paint().apply {
                    colorFilter =
                        ColorMatrixColorFilter(ColorMatrix().apply { setSaturation(0.0f) })
                })
            }

        private fun gray2Binary(grayBitmap: Bitmap): Bitmap {
            val binaryBitmap = grayBitmap.copy(Bitmap.Config.ARGB_8888, true)
            for (i in 0 until grayBitmap.width) {
                for (j in 0 until grayBitmap.height) {
                    val col = binaryBitmap.getPixel(i, j)
                    val alpha = col and -16777216
                    val red = col and 16711680 shr 16
                    val green = col and '\uff00'.code shr 8
                    val blue = col and 255
                    var gray = (red.toFloat().toDouble() * 0.3 + green.toFloat()
                        .toDouble() * 0.59 + blue.toFloat()
                        .toDouble() * 0.11).toInt()
                    gray = if (gray <= 127) {
                        0
                    } else {
                        255
                    }
                    val newColor = alpha or (gray shl 16) or (gray shl 8) or gray
                    binaryBitmap.setPixel(i, j, newColor)
                }
            }
            return binaryBitmap
        }
    }


//↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ 打印机指令 ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

}