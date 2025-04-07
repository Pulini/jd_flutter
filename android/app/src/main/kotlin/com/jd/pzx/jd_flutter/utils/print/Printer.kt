package com.jd.pzx.jd_flutter.utils.print

import android.app.Activity
import android.content.Context
import android.graphics.pdf.PdfDocument
import android.os.Bundle
import android.os.CancellationSignal
import android.os.ParcelFileDescriptor
import android.print.PageRange
import android.print.PrintAttributes
import android.print.PrintDocumentAdapter
import android.print.PrintDocumentInfo
import android.print.PrintManager
import androidx.print.PrintHelper
import com.jd.pzx.jd_flutter.utils.base64ToBitmap
import java.io.FileOutputStream
import java.io.IOException


fun printBitmap(activity: Activity, jobName: String, base64List:List<String> ) {
    activity.also { context ->
        PrintHelper(context).apply {
            scaleMode = PrintHelper.SCALE_MODE_FIT
        }.also { printHelper ->
            base64List.forEach {
                printHelper.printBitmap(jobName, base64ToBitmap(it))
            }
        }
    }
}
fun printPdf(
    context: Context,
    jobName: String,
    base64List: List<String>,
    printerCallback: (Boolean) -> Unit
) {
    val printManager = context.getSystemService(Context.PRINT_SERVICE) as PrintManager
    if (printManager == null) {
        printerCallback.invoke(false)
    } else {
   printManager.print(
            jobName,
            BitmapPrintDocumentAdapter(context,jobName,base64List, printerCallback),
            PrintAttributes.Builder().build()
        )
    }

}

class BitmapPrintDocumentAdapter(
    val context: Context,
    private val jobName: String,
    private val base64List: List<String>,
    private val printerCallback: (Boolean) -> Unit
) : PrintDocumentAdapter() {

    override fun onFinish() {
        printerCallback.invoke(true)
        println("------打印完成------")
        super.onFinish()
    }

    /**
     * 处理打印文档的写入
     *
     * @param pages 要打印的页面范围
     * @param destination 打印目标的 ParcelFileDescriptor
     * @param cancellationSignal 取消信号
     * @param callback 写入结果回调
     */
    override fun onWrite(
        pages: Array<out PageRange>,
        destination: ParcelFileDescriptor,
        cancellationSignal: CancellationSignal,
        callback: WriteResultCallback
    ) {

        val pdfDocument = PdfDocument()
        for (base64 in base64List) {
            val bitmap= base64ToBitmap(base64)
            val pageInfo = PdfDocument.PageInfo.Builder(
                bitmap.width,
                bitmap.height,
                base64List.size
            ).create()
            val page = pdfDocument.startPage(pageInfo)
            val canvas = page.canvas
            canvas.drawBitmap(bitmap, 0f, 0f, null)
            pdfDocument.finishPage(page)
        }

        // 将 PdfDocument 写入到指定的 ParcelFileDescriptor
        var fileOutputStream: FileOutputStream? = null
        try {
            fileOutputStream = FileOutputStream(destination.fileDescriptor)
            pdfDocument.writeTo(fileOutputStream)
            // 回调写入完成
            callback.onWriteFinished(arrayOf(PageRange.ALL_PAGES))
//            printerCallback.invoke(1)
        } catch (e: IOException) {
            // 如果写入失败，回调写入失败
            callback.onWriteFailed(e.toString())
        } finally {
            // 关闭 PdfDocument 和 FileOutputStream
            try {
                pdfDocument.close()
                fileOutputStream?.close()
            } catch (e: IOException) {
                e.printStackTrace()
            }
        }
    }

    /**
     * 处理打印文档的布局
     *
     * @param oldAttributes 旧的打印属性
     * @param newAttributes 新的打印属性
     * @param cancellationSignal 取消信号
     * @param callback 布局结果回调
     * @param extras 额外的 Bundle 数据
     */
    override fun onLayout(
        oldAttributes: PrintAttributes?,
        newAttributes: PrintAttributes,
        cancellationSignal: CancellationSignal,
        callback: LayoutResultCallback,
        extras: Bundle?
    ) {
        // 如果取消信号被触发，则取消布局
        if (cancellationSignal.isCanceled) {
            callback.onLayoutCancelled()
            return
        }

        // 创建打印文档信息
        val printInfo = PrintDocumentInfo.Builder("$jobName.pdf")
            .setContentType(PrintDocumentInfo.CONTENT_TYPE_DOCUMENT)
            .setPageCount(base64List.size)
            .build()

        // 回调布局完成
        callback.onLayoutFinished(printInfo, newAttributes != oldAttributes)
    }
}
