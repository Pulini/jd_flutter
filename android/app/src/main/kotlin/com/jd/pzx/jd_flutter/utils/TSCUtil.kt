package com.jd.pzx.jd_flutter.utils

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Paint
import android.graphics.Typeface
import android.os.Build
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import kotlin.experimental.xor

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
 */

class TSCUtil(context: Context) {
    companion object {
        @Volatile
        private var instance: TSCUtil? = null
        private lateinit var textType: Typeface
        private lateinit var titleType: Typeface
        fun init(context: Context): TSCUtil =
            synchronized(this) {
                instance ?: TSCUtil(context).apply {
                    instance = this
                    textType = Typeface.createFromAsset(context.assets, "fonts/text.ttf")
                    titleType = Typeface.createFromAsset(context.assets, "fonts/title.ttf")
                }
            }

        fun getInstance(): TSCUtil = instance!!

        /**
         * 财产标签
         * 发送[70x40]贴标打印参数
         *
         * @param fInterID  资产ID
         * @param name      资产名称
         * @param number    资产编号
         * @param date      日期
         */
        fun propertyLabel(
            fInterID: String,
            name: String,
            number: String,
            date: String
        ) = arrayListOf<ByteArray>().apply {

            add(tscClearBuffer())
            add(tscSetUp(70, 40))
            add(tscLine(10, 350, 820, 4))
            add(
                tscQrCode(
                    500, 30,
                    "http://jdwx.goldemperor.com/aspx/FACard/CardInfo.aspx?FInterID=$fInterID",
                    cell = "6"
                )
            )
            add(tscBitmapFont(100, 360, titleType, 85, "Gold Emperor"))
            if (name.length > 6) {
                add(tscBitmapFont(50, 60, textType, 45, "名称：${name.substring(0, 6)}"))
                add(tscBitmapFont(200, 110, textType, 45, name.substring(6, name.length)))
            } else {
                add(tscBitmapFont(50, 60, textType, 45, "名称：$name"))
            }
            add(tscBitmapFont(50, 160, textType, 45, "编号：$number"))
            add(tscBitmapFont(50, 260, textType, 45, "日期：$date"))
            add(tscPrint())
        }

        /**
         * 料头贴标
         */
        fun surplusMaterialLabel(
            qrCode: String,//二维码信息
            machine: String,  //派工机台
            shift: String,  //班次
            startDate: String,  //派工日期
            factoryType: String,  //工厂型体
            stubBar: String,  //料头名称
            stuBarCode: String,//料头编码
        ): ArrayList<ByteArray> = arrayListOf<ByteArray>().apply {
            val dpi = 8
            add(tscClearBuffer())
            add(tscSetUp(75, 45))
            add(tscQrCode(2 * dpi, 2 * dpi + 4, qrCode.replace("\"", "\\[\"]"), cell = "5"))
            add(tscBitmapFont(39 * dpi, 2 * dpi, textType, 26, "机台:$machine  班次:$shift"))
            add(tscBitmapFont(39 * dpi, 7 * dpi, textType, 26, "派工日期:$startDate"))
            add(tscBitmapFont(2 * dpi, 39 * dpi, textType, 30, "型体:$factoryType"))
            contextFormat("($stuBarCode)$stubBar", 30f, dpi * 33).forEachIndexed { index, s ->
                add(tscBitmapFont(39 * dpi, (13 + 4 * index) * dpi, textType, 30, s))
            }

            add(tscBox(dpi, dpi, 74 * dpi, 43 * dpi, crude = 2))
            add(tscLine(39 * dpi - 4, dpi, 2, 38 * dpi))
            add(tscLine(39 * dpi - 4, 6 * dpi, 36 * dpi - 4, 2))
            add(tscLine(39 * dpi - 4, 12 * dpi, 36 * dpi - 4, 2))
            add(tscLine(dpi, 39 * dpi - 4, 73 * dpi, 2))

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
            if(subTitleWrap){
                if (subTitle.isNotEmpty()) {
                    contextFormat(subTitle, 30f, dpi * 54).forEachIndexed { index, s ->
                        //限制子标题行数为2
                        if (index >= 2) return@forEachIndexed
                        add(tscBitmapFont(19 * dpi + 4, (11 + 4 * index) * dpi - 4, textType, 30, s))
                    }
                }
            }else{
                add(tscBitmapFont(19 * dpi + 4, 12* dpi , textType, 40, subTitle))
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
            val tableTitleWidth = 54
            //表格子标题文本高度
            val tableSubTitleHeight = 4 * contextFormat(tableSubTitle, 30f, dpi * 71).size

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
                margin + padding + qrCodeWidth + tableTitleHeight + tableSubTitleHeight + tableHeight + bottomTextHeight + padding + margin

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
                (margin + padding + qrCodeWidth + tableTitleHeight + tableSubTitleHeight + tableHeight) * dpi
            val bLeftText2X = (1 + padding) * dpi
            val bLeftText2Y =
                (margin + padding + qrCodeWidth + tableTitleHeight + tableSubTitleHeight + tableHeight + 4) * dpi
            val bRightText1X = (1 + padding + 35) * dpi
            val bRightText1Y =
                (margin + padding + qrCodeWidth + tableTitleHeight + tableSubTitleHeight + tableHeight) * dpi
            val bRightText2X = (1 + padding + 35) * dpi
            val bRightText2Y =
                (margin + padding + qrCodeWidth + tableTitleHeight + tableSubTitleHeight + tableHeight + 4) * dpi


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
                contextFormat(subTitle, 30f, dpi * 54).forEachIndexed { line, s ->
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
                add(tscBitmapFont(tableTitleTipsX, tableTitleTipsY, textType, 30, tableTitleTips))
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

        private fun tableFormat(
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
                }
            }

        /**
         * 文本换行格式化
         * @param   text        文本内容
         * @param   fontSize    字体大小（px）
         * @param   maxWidthPx  文本限宽（px）
         */
        private fun contextFormat(text: String, fontSize: Float=30f, maxWidthPx: Int) =
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

            @Suppress("DEPRECATION") val staticLayout =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
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