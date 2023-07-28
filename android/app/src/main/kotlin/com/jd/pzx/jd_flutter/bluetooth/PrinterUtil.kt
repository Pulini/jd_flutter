package com.jd.pzx.jd_flutter.bluetooth

import android.bluetooth.BluetoothSocket
import android.content.Context
import android.graphics.*
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import com.jd.pzx.jd_flutter.R
import com.jd.pzx.jd_flutter.averageAssign
import com.jd.pzx.jd_flutter.getFormatDate
import com.jd.pzx.jd_flutter.mul
import com.jd.pzx.jd_flutter.removeDecimalZero
import com.jd.pzx.jd_flutter.toDoubleTry
import io.flutter.Log
import kotlin.experimental.xor
import kotlin.math.ceil

/**
 * File Name : BLEUtil
 * Created by : PanZX on  2021/03/03 16:02
 * Email : 644173944@qq.com
 * Github : https://github.com/Pulini
 * Remark :
 */
class PrinterUtil(
    private var context: Context,
    private var bluetoothSocket: BluetoothSocket,
) {

    private val textType: Typeface = Typeface.createFromAsset(context.assets, "fonts/text.ttf")
    private val titleType: Typeface = Typeface.createFromAsset(context.assets, "fonts/title.ttf")

    /**
     * 下发打印标签指令
     *
     * @param quantity
     * @param copy
     * @return
     */
    private fun print(quantity: Int = 1, copy: Int = 1) {
        Log.e("Pan","进行打印")
        bluetoothSocket.outputStream?.write("PRINT $quantity, $copy\r\n".toByteArray())
    }

    /**
     * 下发拆切指令
     *
     * @return
     */
    private fun cutter() {
        bluetoothSocket.outputStream?.write("SET CUTTER 1\r\n".toByteArray())
    }


    /**
     * 打印文本
     *
     * @param xCoordinates X坐标
     * @param yCoordinates Y坐标
     * @param typeface      文本字体
     * @param fontSize      文字大小
     * @param textToPrint   文字内容
     *  字体尺寸为 60 时，中文实际占用宽度为7.5毫米 英文及字符则只占中文的一半
     *  字体尺寸为 40 时，中文实际占用宽度为5毫米 英文及字符则只占中文的一半
     * @return
     */
    private fun windowsFont(
        xCoordinates: Int,
        yCoordinates: Int,
        typeface: Typeface,
        fontSize: Int,
        textToPrint: String
    ) {

        val textPaint = TextPaint(Paint().also {
            it.style = Paint.Style.FILL
            it.color = -16777216
            it.isAntiAlias = true
            it.typeface = typeface
            it.textSize = fontSize.toFloat()
        })
        val staticLayout = StaticLayout(
            textToPrint,
            textPaint,
            832,
            Layout.Alignment.ALIGN_NORMAL,
            1.0f,
            0.0f,
            false
        )

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
        val grayBitmap = bitmap2Gray(originalBitmap)
        val binaryBitmap = gray2Binary(grayBitmap)
        val xAxis = xCoordinates.toString()
        val yAxis = yCoordinates.toString()
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
        bluetoothSocket.outputStream?.write(command.toByteArray() + stream + "\r\n".toByteArray())
    }

    fun printerFont(
        x: Int,
        y: Int,
        size: String,
        rotation: Int,
        xMultiplication: Int,
        yMultiplication: Int,
        text: String
    ) {
        bluetoothSocket.outputStream?.write("TEXT $x,$y ,\\$size\\ ,$rotation ,$xMultiplication ,$yMultiplication ,$text\r\n".toByteArray())
    }

    /**
     * 画线
     *
     * @param x      X坐标
     * @param y      Y坐标
     * @param width  宽
     * @param height 高
     * @return
     */
    private fun line(x: Int, y: Int, width: Int, height: Int) {
        bluetoothSocket.outputStream?.write("BAR $x,$y,$width,$height\r\n".toByteArray())
    }

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
    private fun box(sx: Int, sy: Int, ex: Int, ey: Int, crude: Int = 4) {
        bluetoothSocket.outputStream?.write("BOX $sx,$sy,$ex,$ey,$crude\n".toByteArray())
    }


    /**
     * 画圆
     *
     * @param x         X坐标
     * @param y         Y坐标
     * @param diameter  直径
     * @param thickness 粗细
     * @return
     */
    private fun circle(x: Int, y: Int, diameter: Int, thickness: Int) {
        bluetoothSocket.outputStream?.write("CIRCLE $x,$y,$diameter,$thickness\r\n".toByteArray())
    }


    /**
     * 清除缓存
     *
     * @return
     */
    private fun clearBuffer() {
        bluetoothSocket.outputStream?.write("CLS\r\n".toByteArray())
    }

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
    private fun qrCode(
        x: Int,
        y: Int,
        content: String,
        ecc: String = "H",
        cell: String = "4",
        mode: String = "A",
        rotation: String = "0",
        model: String = "M2",
        mask: String = "S7"
    ) {
        bluetoothSocket.outputStream?.write("QRCODE $x,$y,$ecc,$cell,$mode,$rotation,$model,$mask,\"$content\"\r\n".toByteArray())
    }

    /**
     * 打印条形码
     *
     * @param x        X坐标
     * @param y        Y坐标
     * @param content  内容
     * @param sym      条码类型
     * @param rotate   旋转角度 0 - 270
     * @param pixMult  模组宽度  1 - 10
     * @param sepHt    分隔符高度  1 和  2 可选
     * @param linHeight    UCC/EAN - 128 高度  单位DOT(1-500可选)
     * @return
     */
    private fun barCode(
        x: Int,
        y: Int,
        content: String,
        sym: String = "UCC128CCA",
        rotate: String = "0",
        pixMult: String = "2",
        sepHt: String = "2",
        segWidth: String = "35"
    ) {
        Log.e("Pan","内容是：$content")
        bluetoothSocket.outputStream?.write("RSS $x,$y,\"$sym\",$rotate,$pixMult,$sepHt,$segWidth,\"$content\"\r\n".toByteArray())
    }


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
    private fun setUp(
        width: Int,
        height: Int,
        speed: Int = 4,
        density: Int = 12,
        sensor: Int = 0,
        sensorDistance: Int = 2,
        sensorOffset: Int = 0
    ) {
        val size = "SIZE $width mm, $height mm"
        val speedValue = "SPEED $speed"
        val densityValue = "DENSITY $density"
        var sensorValue = ""
        if (sensor == 0) {
            sensorValue = "GAP $sensorDistance mm, $sensorOffset mm"
        } else if (sensor == 1) {
            sensorValue = "BLINE $sensorDistance mm, $sensorOffset mm"
        }

        val msgBuffer = """
             $size
             $speedValue
             $densityValue
             $sensorValue
             
             """.trimIndent()

        bluetoothSocket.outputStream?.write(msgBuffer.toByteArray())
    }


    private fun bitmap2Gray(bmSrc: Bitmap): Bitmap =
        Bitmap.createBitmap(bmSrc.width, bmSrc.height, Bitmap.Config.RGB_565).apply {
            Canvas(this).drawBitmap(bmSrc, 0.0f, 0.0f, Paint().apply {
                colorFilter = ColorMatrixColorFilter(ColorMatrix().apply { setSaturation(0.0f) })
            })
        }

    private fun gray2Binary(grayBitmap: Bitmap): Bitmap {
        val binaryBitmap = grayBitmap.copy(Bitmap.Config.ARGB_8888, true)
        for (i in 0 until grayBitmap.width) {
            for (j in 0 until grayBitmap.height) {
                val col = binaryBitmap.getPixel(i, j)
                val alpha = col and -16777216
                val red = col and 16711680 shr 16
                val green = col and '\uff00'.toInt() shr 8
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

    /**
     * 读取设备状态
     */
    fun readStatus(): String {
        bluetoothSocket.outputStream?.write(byteArrayOf(27, 33, 63))
        val readBuf = ByteArray(1024)
        Thread.sleep(300L)
        while (bluetoothSocket.inputStream?.available()!! > 0) {
            bluetoothSocket.inputStream?.read(readBuf)
        }
        return when {
            readBuf[0] == 0.toByte() -> context.getString(R.string.bluetooth_error_1)
            readBuf[0] == 1.toByte() -> context.getString(R.string.bluetooth_error_2)
            readBuf[0] == 2.toByte() -> context.getString(R.string.bluetooth_error_3)
            readBuf[0] == 3.toByte() -> context.getString(R.string.bluetooth_error_4)
            readBuf[0] == 4.toByte() -> context.getString(R.string.bluetooth_error_5)
            readBuf[0] == 5.toByte() -> context.getString(R.string.bluetooth_error_6)
            readBuf[0] == 8.toByte() -> context.getString(R.string.bluetooth_error_7)
            readBuf[0] == 9.toByte() -> context.getString(R.string.bluetooth_error_8)
            readBuf[0] == 10.toByte() -> context.getString(R.string.bluetooth_error_9)
            readBuf[0] == 11.toByte() -> context.getString(R.string.bluetooth_error_10)
            readBuf[0] == 12.toByte() -> context.getString(R.string.bluetooth_error_11)
            readBuf[0] == 13.toByte() -> context.getString(R.string.bluetooth_error_12)
            readBuf[0] == 16.toByte() -> context.getString(R.string.bluetooth_error_13)
            readBuf[0] == 32.toByte() -> context.getString(R.string.bluetooth_error_14)
            readBuf[0] == 128.toByte() -> context.getString(R.string.bluetooth_error_15)
            else -> context.getString(R.string.bluetooth_error_16)
        }
    }

    /**
     * 发送[70x40]贴标打印参数
     * 打印单张标签  840*480
     *
     * @param FInterID  资产ID
     * @param Name      资产名称
     * @param Number    资产编号
     * @param Date      日期
     */
    fun printPropertyLabel70x40(
        FInterID: String,
        Name: String,
        Number: String,
        Date: String
    ) {

        clearBuffer()
        setUp(70, 40)
        line(10, 350, 820, 4)
        qrCode(
            500, 30,
            "http://jdwx.goldemperor.com/aspx/FACard/CardInfo.aspx?FInterID=$FInterID",
            cell = "6"
        )
        windowsFont(100, 360, titleType, 85, "Gold Emperor")
        if (Name.length > 6) {
            windowsFont(50, 60, textType, 45, "名称：${Name.substring(0, 6)}")
            windowsFont(200, 110, textType, 45, Name.substring(6, Name.length))
        } else {
            windowsFont(50, 60, textType, 45, "名称：$Name")
        }
        windowsFont(50, 160, textType, 45, "编号：$Number")
        windowsFont(50, 260, textType, 45, "日期：$Date")
        print()
    }

    /**
     * 发送[75x45]跑码物料贴标打印参数
     * 目前te244打印机dpi有2种 参数分别是8和12
     * 200 DPI : 1mm = 8 dots
     * 300 DPI : 1mm = 12 dots
     */
    fun newPrint_75x45_200dpi(
        typeBody: String,
        barCode: String,
        parts: String,
        mustQty: Double,
        size: String,
        unit: String,
        instructions: MutableList<String>,
        group: String,
    ) {
        val dpi = 8
        val paperWidth = 75
        val paperHeight = 45
        val widthDpi = paperWidth * dpi
        val heightDpi = paperHeight * dpi

        clearBuffer()
        setUp(paperWidth, paperHeight)
        box(dpi, dpi, widthDpi - dpi, heightDpi - dpi) //画线框
        qrCode(dpi * 2, dpi * 2, barCode, cell = "4")


        line(dpi * 19, dpi, 4, dpi * 30)  //竖线


        line(dpi * 19, dpi * 11, widthDpi - dpi * 20, 4)  //横线


        line(dpi, dpi * 19, widthDpi - dpi * 2, 4)
        line(dpi, heightDpi - dpi * 14, widthDpi - dpi * 2, 4)


        windowsFont(dpi * 21, dpi * 3, textType, dpi * 5, typeBody)  //型体

        windowsFont(dpi * 20, dpi * 13, textType, dpi * 4, group) //组别

        windowsFont(dpi * 5, dpi * 20, textType, dpi * 5, "$size #")
        windowsFont(dpi * 2, dpi * 26, textType, dpi * 4, "${mustQty.removeDecimalZero()}$unit")


        val str1 = "部件：$parts"

        if (str1.length > 13) {
            Log.e("Pan","str1=$str1")
            for ((index, i) in (str1.indices step 13).withIndex()) {
                windowsFont(
                    dpi * 20,
                    dpi * 21 + index * 4 * dpi,
                    textType,
                    dpi * 4,
                    if (i + 13 > str1.length) {
                        str1.substring(i, str1.length)
                    } else {
                        str1.substring(i, i + 13)
                    }
                )
                if (index == 1) break
            }
        } else {
            windowsFont(dpi * 20, dpi * 21, textType, dpi * 4, str1)
        }


        val data = mutableListOf<String>()
        data.clear()

        instructions.forEach {
//            if (!data.contains("${it.Mtono}(${it.CreateQty.toString()})")) {
//                data.add("${it.Mtono}(${it.CreateQty.toString()})")
//            }
            if (!data.contains(it)) {
                data.add(it)
            }
        }

        var str2 = "指令:"
        data.forEach {
            str2 += "$it、"
        }

        str2 = str2.substring(0, str2.length - 1)
        if (str2.length > 42) {
            Log.e("Pan","str2=$str2")
            for ((index, i) in (str2.indices step 42).withIndex()) {
                windowsFont(
                    dpi * 2,
                    dpi * 32 + index * 4 * dpi,
                    textType,
                    dpi * 3,
                    if (i + 43 > str2.length) {
                        str2.substring(i, str2.length)
                    } else {
                        str2.substring(i, i + 42)
                    }
                )
                if (index == 2) break
            }
        } else {
            windowsFont(dpi * 2, dpi * 32, textType, dpi * 3, str2)
        }
        print()
    }

    /**
     * 发送[75x45]跑码物料贴标打印参数
     * 目前te244打印机dpi有2种 参数分别是8和12
     * 200 DPI : 1 mm = 8 dots
     * 300 DPI : 1mm = 12 dots
     */
    fun printProcessDispatchRegister_75x45_200dpi(
        typeBody: String,
        barCode: String,
        processName: String,
        mustQty: Double,
        size: String,
        unit: String,
        workerNumber: String,
        workerName: String,
        position: Int,
        instructions: MutableList<String>,
    ) {
        val dpi = 8
        val paperWidth = 75
        val paperHeight = 45


        clearBuffer()
        setUp(paperWidth, paperHeight)

        qrCode(dpi * 2, dpi * 2, barCode, cell = "4")

        windowsFont(dpi * 22, dpi * 2, textType, dpi * 6, typeBody)

        windowsFont(dpi * 22, dpi * 10, textType, dpi * 4, processName)

        windowsFont(dpi * 22, dpi * 16, textType, dpi * 4, "贴标序号：$position")


        val newList = averageAssign(instructions, 2)
        for (i in 0 until newList.size) {
            var str = ""
            newList[i].forEach { s ->
//                str += "${s.Mtono}(${s.MtonoMustQty.removeDecimalZero()})    "
                str += s
            }
            str = str.substring(0, str.length - 4)
            windowsFont(dpi * 3, (i * dpi * 4) + (dpi * 21), textType, dpi * 4, str)
            if (i == 2) break
        }
        windowsFont(dpi * 2, dpi * 34, textType, dpi * 5, "$size #")
        windowsFont(dpi * 2, dpi * 39, textType, dpi * 5, "${mustQty.removeDecimalZero()}$unit")

        windowsFont(dpi * 14, dpi * 34, textType, dpi * 5, "员")
        windowsFont(dpi * 14, dpi * 39, textType, dpi * 5, "工")
        windowsFont(dpi * 20, dpi * 36, textType, dpi * 5, "$workerName$workerNumber")


        print()
    }


    /**
     * 发送[75x45]跑码物料贴标打印参数
     * 起始坐标x20 y15 高540  宽900  内容高490  内容宽850
     *
     * @param materialCode      物料编码
     * @param pickUpCode        取件码
     * @param batchNumber       色系
     * @param warehouseName     工厂名称
     * @param quantity          数量
     * @param jobNumber         工号
     */
    fun printMaterielLabel75x45(
        materialCode: String,
        pickUpCode: String,
        batchNumber: String,
        warehouseName: String,
        quantity: String,
        jobNumber: String
    ) {
        clearBuffer()
        setUp(75, 45)
        box(20, 20, 860, 500) //画线框

        line(20, 96 + 20, 860 - (192 + 20) - 20, 4)
        line(20, 192 + 20, 860 - 20, 4)
        line(20, 288 + 20, 860 - 20, 4)
        line(20, 384 + 20, 860 - 20, 4)
        line(260, 20, 4, 500 - 20)
        line(860 - 192 - 20, 20, 4, 288)

        qrCode(670, 30, pickUpCode, cell = "7")
        windowsFont(30, 48, textType, 45, "物料代码")
        windowsFont(270, 48, textType, 45, materialCode)

        windowsFont(30, 96 + 48, textType, 45, "数量")
        windowsFont(270, 96 + 48, textType, 45, quantity)

        windowsFont(30, 192 + 48, textType, 45, "色系")
        windowsFont(270, 192 + 48, textType, 45, batchNumber)
        windowsFont(860 - 192 - 10, 192 + 48, textType, 35, warehouseName)

        windowsFont(30, 288 + 48, textType, 45, "取件码")
        windowsFont(270, 288 + 48, textType, 45, pickUpCode)

        windowsFont(30, 384 + 48, textType, 45, "工号/日期")
        windowsFont(270, 384 + 48, textType, 45, "$jobNumber/${getFormatDate()}")

        print()
    }


    /**
     * 发送[75x45]机台派工物料贴标打印参数
     * 起始坐标x20 y15 高540  宽900  内容高490  内容宽850
     *
     * @param qrCodeMsg         二维吗内容
     * @param productName       工厂型体
     * @param color             色系
     * @param order             单号
     * @param unit              单位
     * @param depName           部门名称
     * @param factoryArea       厂区
     * @param materialName      物料名称
     */
    fun printMaterialLabel75x45ToDrawing(
        qrCodeMsg: String,
        productName: String,
        color: String,
        order: String,
        unit: String,
        depName: String,
        factoryArea: String,
        materialName: String,
        BillNo: String,
        PickUpCode: String,
        PartName: String,
        Position: String,
        Date: String,
        MaterialNumber: String
    ) {

        clearBuffer()
        setUp(75, 45)
        box(10, 12, 585, 347, 1) //画线框
        line(10, 60, 432, 1)//第二条横线
        line(10, 258, 575, 1)//第三条横线
        line(10, 307, 431, 1)//第四条横线
        line(441, 180, 145, 1)//时间与指令间隔线
        line(10, 219, 575, 1)//机台上横线

        line(10, 95, 115, 1)//物料名称下的横线


        windowsFont(43, 25, textType, 23, "型体")
        windowsFont(20, 65, textType, 20, MaterialNumber)
        windowsFont(17, 270, textType, 23, "色系/数量")
        windowsFont(28, 317, textType, 23, Position)
        windowsFont(43, 229, textType, 23, "部件")

        Log.e("Pan","部位：$PartName")

        var parName = ""

        parName = if (PartName.length > 13) PartName.substring(0, 13) else PartName
        windowsFont(136, 229, textType, 23, parName)


        windowsFont(136, 21, textType, 32, productName)
        if (color.isEmpty()) {
            windowsFont(136, 270, textType, 27, "$order $unit")
        } else {
            windowsFont(136, 270, textType, 27, "$color - $order $unit")
        }

        windowsFont(136, 317, textType, 23, PickUpCode)

        //"$depName/${getFormatDate()}"

        windowsFont(447, 188, textType, 23, Date)
        if (depName.length > 4) {
            windowsFont(447, 229, textType, 23, depName.substring(0, depName.length - 2))
        } else {
            windowsFont(447, 229, textType, 23, depName)
        }
        //二维码
        qrCode(17, 105, qrCodeMsg, cell = "3")

        line(126, 12, 1, 337)//第一条竖线

        if (factoryArea.isNotEmpty()) {
            when {
                factoryArea.length <= 2 -> {
                    windowsFont(455, 270, textType, 60, factoryArea)
                }

                factoryArea.length in 3..4 -> {
                    windowsFont(446, 295, textType, 31, factoryArea)
                }

                else -> {
                    windowsFont(446, 270, textType, 23, factoryArea.substring(0, 4))
                    windowsFont(446, 315, textType, 23, factoryArea.substring(4))
                }
            }
        }

        if (materialName.length <= 55) {

            val num = ceil(materialName.length.toDouble() / 11).toInt()

            for (index in 1..num) {
                if (index * 11 <= materialName.length) {
                    windowsFont(
                        131,
                        32 + 31 * index,
                        textType,
                        26,
                        materialName.substring((index - 1) * 11, index * 11)
                    )
                } else {
                    windowsFont(
                        131,
                        32 + 31 * index,
                        textType,
                        26,
                        materialName.substring((index - 1) * 11, materialName.length)
                    )
                }
            }
        } else {
            val num2 = ceil(materialName.length.toDouble() / 13).toInt()

            for (index in 1..num2) {
                if (index * 13 < materialName.length) {
                    windowsFont(
                        131,
                        39 + 25 * index,
                        textType,
                        23,
                        materialName.substring((index - 1) * 13, index * 13)
                    )
                } else {
                    windowsFont(
                        131,
                        39 + 25 * index,
                        textType,
                        23,
                        materialName.substring((index - 1) * 13, materialName.length)
                    )
                }
            }
        }


        if (BillNo.isNotEmpty()) {
            windowsFont(
                450,
                23,
                textType,
                25,
                BillNo
            )
        }

        line(441, 12, 1, 337)//二维码框线

        print()
    }


    /**
     * 发送[75x45]金甄打印料头信息
     *
     * @param qrCodeMsg         二维吗内容
     * @param DecrementNumber   递减编号
     * @param InterID           派工单号
     * @param StartDate         派工日期
     * @param Machine           派工机台
     * @param FactoryType       工厂型体
     */
    fun printMachineHeaderLabel(
        StuBarCode: String,//料头编码
        bean: String,//二维码信息
        DecrementNumber: String,  //递减编号
        InterID: String,  //派工单号
        StartDate: String,  //派工日期
        Machine: String,  //派工机台
        FactoryType: String,  //工厂型体
        StubBar: String,  //料头编号
        Shift: String,  //班次

    ) {
        val dpi = 8
        val paperWidth = 75
        val paperHeight = 45

        clearBuffer()
        setUp(paperWidth, paperHeight)

        qrCode(dpi * 2, dpi * 2, bean, cell = "2")  //二维码信息

        windowsFont(dpi * 24, dpi * 2, textType, dpi * 4, "递减编号：$DecrementNumber")

        windowsFont(dpi * 24, dpi * 8, textType, dpi * 4, "派工单号：$InterID")

        windowsFont(dpi * 24, dpi * 14, textType, dpi * 4, "派工日期：$StartDate")

        windowsFont(dpi * 3, dpi * 24, textType, dpi * 4, "派工机台：$Machine${" - "}${Shift}")

        windowsFont(dpi * 3, dpi * 29, textType, dpi * 4, "工厂型体：$FactoryType")

        if (StubBar.length > 12) {
            windowsFont(
                dpi * 3,
                dpi * 34,
                textType,
                dpi * 4,
                "料头名称：${StubBar.substring(0, 12)}"
            )
        } else {
            windowsFont(dpi * 3, dpi * 34, textType, dpi * 4, "料头名称：${StubBar}")
        }

        windowsFont(dpi * 3, dpi * 39, textType, dpi * 4, "料头编码：${StuBarCode}")


        print()
    }

    /**
     * 发送[75x45]金甄机台派工单打印信息
     *
     * @param shift       班次
     * @param DispatchNumber       派工单号
     * @param DecrementNumber       递减编号
     * @param Machine       派工机台
     * @param BQID       BQID
     * @param FactoryType       型体
     * @param BoxNum       箱容
     * @param Size       尺码
     * @param processes       制程
     * @param materialName    物料
     * @param startDate       开工日期
     */
    fun printMachineLabel(
        Last: String,//尾标
        Num: String,//序列号
        Unit: String, //单位
        Shift: String, //班次
        DispatchNumber: String, //派工单号
        DecrementNumber: String, //递减编号
        Machine: String, //派工机台
        BQID: String,//BQID
        FactoryType: String,  //型体
        BoxNum: String,  //箱容
        Size: String,  //尺码
        processes: String,  //制程
        materialName: String,  //物料
        StartDate: String, //开工日期
    ) {
        val dpi = 8
        val paperWidth = 75
        val paperHeight = 45

        clearBuffer()
        setUp(paperWidth, paperHeight)

        box(2, 2, 74 * dpi, 44 * dpi)//画线框

        Log.e("Pan","BQID:$BQID")
        Log.e("Pan","Num:$Num")
        Log.e("Pan","Shift:$Shift")
        Log.e("Pan","DispatchNumber:$DispatchNumber")
        Log.e("Pan","DecrementNumber:$DecrementNumber")
        Log.e("Pan","Machine:$Machine")
        Log.e("Pan","FactoryType:$FactoryType")
        Log.e("Pan","BoxNum:$BoxNum")
        Log.e("Pan","Size:$Size")
        Log.e("Pan","processes:$processes")
        Log.e("Pan","materialName:$materialName")
        Log.e("Pan","StartDate:$StartDate")

        windowsFont(dpi * 23, dpi * 14, textType, dpi * 4, FactoryType)

        windowsFont(dpi * 2, dpi * 2, textType, dpi * 3, "班次：$Shift")

        windowsFont(dpi * 23, dpi * 21, textType, dpi * 3, "递减编号：$DecrementNumber")

        windowsFont(dpi * 2, dpi * 9, textType, dpi * 3, "机台：${Machine}")

        windowsFont(dpi * 23, dpi * 27, textType, dpi * 3, "派工单号：${DispatchNumber}")

        windowsFont(dpi * 2, dpi * 34, textType, dpi * 4, "$Size #")

        windowsFont(dpi * 14, dpi * 34, textType, dpi * 4, Last)

        windowsFont(dpi * 23, dpi * 33, textType, dpi * 3, "生产日期：${StartDate}")

        windowsFont(dpi * 2, dpi * 39, textType, dpi * 4, "$BoxNum $Unit")

        windowsFont(dpi * 23, dpi * 39, textType, dpi * 3, "生产制程：${processes}")

        windowsFont(dpi * 55, dpi * 39, textType, dpi * 3, "序号：$Num")

        line(dpi * 1, dpi * 7, 20 * dpi, 1)//二维码上面第一条

        qrCode(dpi * 5, dpi * 15, BQID, cell = "4")  //二维码信息

        line(dpi * 21, dpi * 20, 73 * dpi, 1)//二维码下面第一条

        line(dpi * 21, dpi * 26, 73 * dpi, 1)//二维码下面第二条

        line(dpi * 1, dpi * 32, 73 * dpi, 1)//二维码下面第三条


        line(dpi * 21, dpi * 1, 1, 43 * dpi)//二维码右边第一条竖线

        line(dpi * 1, dpi * 13, 73 * dpi, 1)//二维码右边第一条横线

        line(dpi * 21, dpi * 38, 53 * dpi, 1)//二维码下面第四条

        if (materialName.isNotEmpty() && materialName.length <= 32) {

            val num = ceil(materialName.length.toDouble() / 16).toInt()

            for (index in 1..num) {
                if (index * 16 < materialName.length) {
                    windowsFont(
                        dpi * 23,
                        dpi * 1 + dpi * 4 * (index - 1),
                        textType,
                        dpi * 4,
                        materialName.substring((index - 1) * 16, index * 16)
                    )
                } else {
                    windowsFont(
                        dpi * 23,
                        dpi * 1 + dpi * 4 * (index - 1),
                        textType,
                        dpi * 4,
                        materialName.substring((index - 1) * 16, materialName.length)
                    )
                }
            }

        } else if (materialName.isNotEmpty() && materialName.length > 32) {

            val num = ceil(materialName.length.toDouble() / 16).toInt()

            for (index in 1..num) {
                if (index * 16 < materialName.length) {
                    windowsFont(
                        dpi * 23,
                        dpi * 1 + dpi * 3 * (index - 1),
                        textType,
                        dpi * 3,
                        materialName.substring((index - 1) * 16, index * 16)
                    )
                } else {
                    windowsFont(
                        dpi * 23,
                        dpi * 1 + dpi * 3 * (index - 1),
                        textType,
                        dpi * 3,
                        materialName.substring((index - 1) * 16, materialName.length)
                    )
                }
            }
        }
        print()
    }


    fun printTestBarCode(code: String) {
        val dpi = 8
        clearBuffer()
        setUp(75, 45)
        barCode(dpi * 2, dpi * 10, code)
        windowsFont(dpi * 2, dpi * 20, textType, dpi * 3, code)
        print()
    }

    fun printTestQrCode(code: String) {
        val dpi = 8
        clearBuffer()
        setUp(75, 45)
        qrCode(dpi * 2, dpi * 2, code, cell = "4")
        windowsFont(dpi * 2, dpi * 20, textType, dpi * 3, code)
        print()
    }

    fun printText() {
        val dpi = 8
        clearBuffer()
        setUp(75, 45)
        for (i in 1..15) {
            line(i * 5 * dpi, 1, 1, 45 * dpi)
        }
        windowsFont(dpi * 5, dpi * 5, textType, 20, "测试-Test-123")
        windowsFont(dpi * 5, dpi * 8, textType, 30, "测试-Test-123")
        windowsFont(dpi * 5, dpi * 16, textType, 40, "测试-Test-123")
        windowsFont(dpi * 5, dpi * 26, textType, 50, "测试-Test-123")
        windowsFont(dpi * 5, dpi * 36, textType, 60, "测试-Test-123")
        print()
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
    ) {
        val dpi = 8
        clearBuffer()
        setUp(75, 45)
        qrCode(dpi * 4, dpi * 2, labelNumber, cell = "4")
        windowsFont(dpi * 20, dpi * 2, textType, 40, factoryType)
        windowsFont(dpi * 20, dpi * 8, textType, 50, instruct)
        "$materialCode($materialName)".chunked(28).forEachIndexed { index, s ->
            windowsFont(dpi * 4, dpi * 16 + (dpi * 5 * index), textType, 30, s)
        }
        windowsFont(dpi * 20, dpi * 36, textType, 25, "页码：$pageNumber")
        windowsFont(dpi * 20, dpi * 40, textType, 25, "交期：$deliveryDate")
        if (size.isNotEmpty()) {
            windowsFont(dpi * 4, dpi * 36, textType, 50, "$size #")
        }
        windowsFont(dpi * 50, dpi * 36, textType, 50, "${qty.removeDecimalZero()} $unit")
        print()
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
    ) {
        val dpi = 8
        clearBuffer()
        setUp(75, 45)
        qrCode(dpi * 4, dpi * 2, labelNumber, cell = "4")
        windowsFont(dpi * 20, dpi * 2, textType, 40, factoryType)
        windowsFont(dpi * 20, dpi * 8, textType, 50, instruct)
        "$materialCode($materialName)".chunked(28).forEachIndexed { index, s ->
            windowsFont(dpi * 4, dpi * 16 + (dpi * 5 * index), textType, 30, s)
        }
        windowsFont(
            dpi * 4,
            dpi * 28,
            textType,
            25,
            "GW:${grossWeight.mul(qty).removeDecimalZero()}KG  NW:${
                (netWeight.mul(qty).removeDecimalZero())
            }KG"
        )
        windowsFont(dpi * 4, dpi * 32, textType, 25, "MEAS:$specs")
        windowsFont(dpi * 4, dpi * 36, textType, 50, "$size #")
        windowsFont(dpi * 23, dpi * 36, textType, 25, "Page:$pageNumber")
        windowsFont(dpi * 23, dpi * 40, textType, 25, "Made in China")
        windowsFont(dpi * 50, dpi * 36, textType, 50, "${qty.removeDecimalZero()} PRS")
        print()
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
    ) {
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
        cutter()
        //清除缓存
        clearBuffer()


        //设置标签尺寸 width:标签宽度73 height:标签高度 = 上边距 + 固定区高度 + 动态物料高度 + 动态指令高度 + 页码高度 +下边距
        setUp(
            width,
            marginTop + fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight + pageNumberHeight + marginButton,
            sensorDistance = 0
        )

        //绘制底部裁切线 x坐标=0 y坐标=上边距 +固定区高度 + 动态物料高度 + 动态指令高度 + 页码高度 + 下边距 - 缩进1 width长度=标签宽度
        for (i in 0..width step 2) {
            line(
                i * dpi,
                (marginTop + fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight + pageNumberHeight + marginButton) * dpi - 2,
                dpi,
                2
            )
        }


        //绘制固定区线框
        box(
            0,
            marginTop * dpi,
            width * dpi,
            (fixedHeight + marginTop) * dpi,
            2
        )

        //绘制二维码与文本的分割线 x坐标=固定区高度 y坐标=上边距 width宽度=2 height高度=固定区高度
        line(
            fixedHeight * dpi,
            marginTop * dpi,
            2,
            fixedHeight * dpi,
        )

        //绘制二维码 x坐标=缩进2 y坐标=上边距 + 缩进2
        qrCode(
            2 * dpi,
            marginTop * dpi + 2 * dpi,
            barCode,
            cell = if (barCode.length > 20) "3" else "4"
        )

        //绘制型体文本 x坐标=固定区高度 + 缩进2 y坐标=上边距 + 缩进2
        windowsFont(
            fixedHeight * dpi + 2 * dpi,
            marginTop * dpi + 2 * dpi,
            textType,
            40,
            if (factoryType.isEmpty()) unit else "$factoryType($unit)"
        )

        //绘制交期 x坐标=固定区高度 + 缩进2 y坐标=上边距 + 行间距8 + 缩进2
        windowsFont(
            fixedHeight * dpi + 2 * dpi,
            marginTop * dpi + 8 * dpi + 2 * dpi,
            textType,
            30,
            "组别：$departName"
        )

        //绘制物料名称区线框 x坐标=0 y坐标=固定区高度 + 上边距 width宽度=标签宽度 height高度=固定区高度 + 动态物料高度 + 上边距
        box(
            0,
            (fixedHeight + marginTop) * dpi,
            width * dpi,
            (fixedHeight + dynamicMaterialHeight + marginTop) * dpi,
            2
        )

        //循环绘制多行物料名称
        materialText.forEachIndexed { index, s ->
            //绘制物料名称 x坐标=缩进2 y坐标=固定区高度 + 上边距 + 动态行间距4*index + 缩进1
            windowsFont(
                2 * dpi,
                ((fixedHeight + marginTop + 6 * index) + 1) * dpi,
                textType,
                30,
                s
            )
        }

        //绘制指令区线框 x坐标=0 y坐标=固定区高度 + 动态物料高度 + 上边距 width宽度=标签宽度 height高度=固定区高度 + 动态物料高度 + 动态指令高度 + 上边距
        box(
            0,
            (fixedHeight + dynamicMaterialHeight + marginTop) * dpi,
            width * dpi,
            (fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight + marginTop) * dpi,
            2
        )

        //循环绘制多行指令
        var index = 0
        instructions.forEach {
            //绘制指令区线框 x坐标=0 y坐标=固定区高度 + 动态物料高度 + 上边距 + 动态行间距6*index width宽度=标签宽度 height高度=固定区高度 + 动态物料高度 + 动态指令高度 + 上边距 +行间距6+动态行间距
            box(
                0,
                (fixedHeight + dynamicMaterialHeight + marginTop + 6 * index) * dpi,
                width * dpi,
                (fixedHeight + dynamicMaterialHeight + marginTop + 6 + 6 * index) * dpi,
                2
            )

            //绘制指令 x坐标=缩进2 y坐标=固定区高度 + 动态物料高度 + 上边距 + 动态行间距6*index + 缩进1
            windowsFont(
                2 * dpi,
                ((fixedHeight + dynamicMaterialHeight + marginTop + 6 * index) + 1) * dpi,
                textType,
                30,
                "指令：${it.key}"
            )


            var sizeIndex = 0
            it.value.forEachIndexed { i, s ->
                if (i % 4 == 0) {
                    index++
                    sizeIndex = 0
                } else {
                    sizeIndex++
                }
                box(
                    (73.0.div(4) * sizeIndex * dpi).toInt(),
                    (marginTop + fixedHeight + dynamicMaterialHeight + index * 6) * dpi,
                    (73.0.div(4) * sizeIndex * dpi).toInt() + (73.0.div(4) * dpi).toInt(),
                    (marginTop + fixedHeight + dynamicMaterialHeight + index * 6 + 6) * dpi,
                    2
                )
                windowsFont(
                    (73.0.div(4) * sizeIndex * dpi).toInt() + dpi,
                    (marginTop + fixedHeight + dynamicMaterialHeight + index * 6 + 1) * dpi,
                    textType,
                    30,
                    s
                )
            }

            index++
        }

        //绘制页码区线框 x坐标=0 y坐标=上边距+固定区高度 + 动态物料高度 + 动态指令高度  width宽度=标签宽度 height高度=上边距+固定区高度 + 动态物料高度 + 动态指令高度 + 页码高度
        box(
            0,
            (marginTop + fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight) * dpi,
            width * dpi,
            (marginTop + fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight + pageNumberHeight) * dpi,
            2
        )

        //绘制页码 x坐标=缩进25 y坐标=上边距+固定区高度 + 动态物料高度 + 动态指令高度 + 缩进1
        windowsFont(
            if (deliveryDate.isEmpty()) dpi * 25 else dpi * 15,
            (marginTop + fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight + 1) * dpi,
            textType,
            30,
            if (deliveryDate.isEmpty()) "页码：$pageNumber" else "页码：$pageNumber  交期：$deliveryDate"
        )

        cutter()

        //打印
        print()
    }

    /**
     * 生成物料标签
     */
    fun materialFixedLabel(
        labelNumber: String,
        materialName: String,
        materialCode: String,
        typeBody: String,
        qty: Double,
        unit: String,
        pageNumber: String
    ) {
        val dpi = 8
        clearBuffer()
        setUp(75, 45)
        qrCode(dpi * 5, dpi * 5, labelNumber, cell = "4")
        windowsFont(dpi * 24, dpi * 5, textType, 40, typeBody)
        windowsFont(dpi * 24, dpi * 15, textType, 40, "${qty.removeDecimalZero()} $unit")
        windowsFont(dpi * 53, dpi * 16, textType, 30, "页码：$pageNumber")
        "$materialCode($materialName)".chunked(18).forEachIndexed { index, s ->
            windowsFont(dpi * 5, dpi * 24 + (dpi * 5 * index), textType, 40, s)
        }
        print()
    }

    /**
     * 动态尺寸贴标
     */
    fun printCuttingProcessLabel(
        colorStr:String,//色系
        foot:String,//左右脚
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
    ) {
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

        //物料名称自动分行
        val materialText = processName.chunked(20)


        //物料名称自动分行
        val parNameList = parNames.chunked(15)

        //物料名称动态高度 每行字体高度为6dpi
        val dynamicMaterialHeight = materialText.size * 6

        //指令行数量
        var lines = instructions.size
        instructions.forEach {
            if (it.value.size > 2) {
                lines += if (type == 1) {
                    ceil(it.value.size.div(2.0)).toInt()
                } else {
                    ceil(it.value.size.div(3.0)).toInt()
                }

            } else {
                lines++
            }
        }

        //指令动态高度 每行字体高度为6dpi
        val dynamicInstructionsHeight = lines * 6

        val pageNumberHeight = 6

        val colorSystem = 6

        //清除缓存
        clearBuffer()

        //设置标签尺寸 width:标签宽度73 height:标签高度 = 上边距 + 固定区高度 + 动态物料高度 + 动态指令高度 + 页码高度 +下边距
        setUp(
            width,
            marginTop + fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight + pageNumberHeight + colorSystem + marginButton,
            sensorDistance = 0
        )

        //绘制底部裁切线 x坐标=0 y坐标=上边距 +固定区高度 + 动态物料高度 + 动态指令高度 + 页码高度 + 下边距 - 缩进1 width长度=标签宽度
        for (i in 0..width step 2) {
            line(
                i * dpi,
                (marginTop + fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight + pageNumberHeight + marginButton + colorSystem) * dpi - 2,
                dpi,
                2
            )
        }


        //绘制固定区线框
        box(
            0,
            marginTop * dpi,
            width * dpi,
            (fixedHeight + marginTop) * dpi,
            2
        )

        //绘制二维码与文本的分割线 x坐标=固定区高度 y坐标=上边距 width宽度=2 height高度=固定区高度
        line(
            fixedHeight * dpi,
            marginTop * dpi,
            2,
            fixedHeight * dpi,
        )

        Log.e("Pan","打印内容：$barCode")

        //绘制二维码 x坐标=缩进2 y坐标=上边距 + 缩进2
        qrCode(1 * dpi, marginTop * dpi + 1 * dpi, barCode, cell = "3")

        //绘制型体文本 x坐标=固定区高度 + 缩进2 y坐标=上边距 + 缩进2
        windowsFont(
            fixedHeight * dpi + 1 * dpi,
            marginTop * dpi + 1 * dpi,
            textType,
            27,
            "$factoryType   $allTotal"
        )

        line(dpi * 21, dpi * 8, 52 * dpi, 1)//型体下面的第一条线

        line(dpi * 21, dpi * 17, 52 * dpi, 1)//型体下面的第二条线
        //绘制交期 x坐标=固定区高度 + 缩进2 y坐标=上边距 + 行间距8 + 缩进2
        windowsFont(
            fixedHeight * dpi + 1 * dpi,
            marginTop * dpi + 14 * dpi + 2 * dpi,
            textType,
            27,
            "组别：$departName"
        )

        if (foot.isNotEmpty()){
            windowsFont(
                60 * dpi,
                marginTop * dpi + 14 * dpi + 2 * dpi,
                textType,
                27,
                "<$foot>"
            )
        }

        //绘制物料名称区线框 x坐标=0 y坐标=固定区高度 + 上边距 width宽度=标签宽度 height高度=固定区高度 + 动态物料高度 + 上边距
        box(
            0,
            (fixedHeight + marginTop) * dpi,
            width * dpi,
            (fixedHeight + dynamicMaterialHeight + marginTop) * dpi,
            2
        )

        parNameList.forEachIndexed { index, s ->
            Log.e("Pan","序号：$index---内容：$s")
            if (index < 2) {
                windowsFont(
                    22 * dpi,
                    ((8 + 4 * index) + 1) * dpi,
                    textType,
                    27,
                    s
                )
            }
        }

        //循环绘制多行物料名称
        materialText.forEachIndexed { index, s ->
            //绘制物料名称 x坐标=缩进2 y坐标=固定区高度 + 上边距 + 动态行间距4*index + 缩进1
            windowsFont(
                2 * dpi,
                ((fixedHeight + marginTop + 6 * index) + 1) * dpi,
                textType,
                30,
                s
            )
        }

        //绘制指令区线框 x坐标=0 y坐标=固定区高度 + 动态物料高度 + 上边距 width宽度=标签宽度 height高度=固定区高度 + 动态物料高度 + 动态指令高度 + 上边距
        box(
            0,
            (fixedHeight + dynamicMaterialHeight + marginTop) * dpi,
            width * dpi,
            (fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight + marginTop) * dpi,
            2
        )

        //循环绘制多行指令
        var index = 0
        instructions.forEach {
            //绘制指令区线框 x坐标=0 y坐标=固定区高度 + 动态物料高度 + 上边距 + 动态行间距6*index width宽度=标签宽度 height高度=固定区高度 + 动态物料高度 + 动态指令高度 + 上边距 +行间距6+动态行间距
            box(
                0,
                (fixedHeight + dynamicMaterialHeight + marginTop + 6 * index) * dpi,
                width * dpi,
                (fixedHeight + dynamicMaterialHeight + marginTop + 6 + 6 * index) * dpi,
                2
            )

            //绘制指令 x坐标=缩进2 y坐标=固定区高度 + 动态物料高度 + 上边距 + 动态行间距6*index + 缩进1
            windowsFont(
                2 * dpi,
                ((fixedHeight + dynamicMaterialHeight + marginTop + 6 * index) + 1) * dpi,
                textType,
                30,
                if (packageType == "2") packageType + ":" + it.key + "#" + "合计："+it.value.sumOf { value -> value.toDoubleTry() }
                    .removeDecimalZero() else packageType + ":" + it.key + "#"
            )


            var sizeIndex = 0
            it.value.forEachIndexed { i, s ->
                if (type == 1) {
                    if (i % 2 == 0) {
                        index++
                        sizeIndex = 0
                    } else {
                        sizeIndex++
                    }
                    box(
                        (73.0.div(2) * sizeIndex * dpi).toInt(),
                        (marginTop + fixedHeight + dynamicMaterialHeight + index * 6) * dpi,
                        (73.0.div(2) * sizeIndex * dpi).toInt() + (73.0.div(2) * dpi).toInt(),
                        (marginTop + fixedHeight + dynamicMaterialHeight + index * 6 + 6) * dpi,
                        2
                    )
                    windowsFont(
                        (73.0.div(2) * sizeIndex * dpi).toInt() + dpi,
                        (marginTop + fixedHeight + dynamicMaterialHeight + index * 6 + 1) * dpi,
                        textType,
                        27,
                        s
                    )
                } else {
                    if (i % 3 == 0) {
                        index++
                        sizeIndex = 0
                    } else {
                        sizeIndex++
                    }
                    box(
                        (73.0.div(3) * sizeIndex * dpi).toInt(),
                        (marginTop + fixedHeight + dynamicMaterialHeight + index * 6) * dpi,
                        (73.0.div(3) * sizeIndex * dpi).toInt() + (73.0.div(3) * dpi).toInt(),
                        (marginTop + fixedHeight + dynamicMaterialHeight + index * 6 + 6) * dpi,
                        2
                    )
                    windowsFont(
                        (73.0.div(3) * sizeIndex * dpi).toInt() + dpi,
                        (marginTop + fixedHeight + dynamicMaterialHeight + index * 6 + 1) * dpi,
                        textType,
                        27,
                        s
                    )
                }
            }

            index++
        }

        //绘制页码区线框 x坐标=0 y坐标=上边距+固定区高度 + 动态物料高度 + 动态指令高度  width宽度=标签宽度 height高度=上边距+固定区高度 + 动态物料高度 + 动态指令高度 + 页码高度
        box(
            0,
            (marginTop + fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight) * dpi,
            width * dpi,
            (marginTop + fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight + pageNumberHeight) * dpi,
            2
        )

        //绘制页码 x坐标=缩进25 y坐标=上边距+固定区高度 + 动态物料高度 + 动态指令高度 + 缩进1
        windowsFont(
            8,
            (marginTop + fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight + 1) * dpi,
            textType,
            27,
            "序号：$pageNumber",
        )

        //绘制页码区线框 x坐标=0 y坐标=上边距+固定区高度 + 动态物料高度 + 动态指令高度  width宽度=标签宽度 height高度=上边距+固定区高度 + 动态物料高度 + 动态指令高度 + 页码高度 + 色系高度
        box(
            0,
            (marginTop + fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight + pageNumberHeight) * dpi,
            width * dpi,
            (marginTop + fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight + pageNumberHeight +colorSystem) * dpi,
            2
        )

        windowsFont(
            8,
            (marginTop + fixedHeight + dynamicMaterialHeight + dynamicInstructionsHeight +colorSystem+ 1) * dpi,
            textType,
            27,
            "配色批次：$colorStr",
        )

        //打印
        print()
    }

}
