package com.jd.pzx.jd_flutter

import android.app.Activity
import android.content.Context
import android.content.res.Configuration
import android.graphics.Bitmap
import android.util.Base64
import android.util.DisplayMetrics
import android.view.View
import java.io.ByteArrayOutputStream
import java.math.BigDecimal
import java.math.RoundingMode
import java.text.DecimalFormat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

const val CHANNEL_ANDROID_SEND = "com.jd.pzx.jd_flutter_android_send"
const val CHANNEL_FLUTTER_SEND = "com.jd.pzx.jd_flutter_flutter_send"
const val FACE_VERIFY_SUCCESS = 1
const val FACE_VERIFY_FAIL_NOT_LIVE = 2
const val FACE_VERIFY_FAIL_NOT_ME = 3
const val FACE_VERIFY_FAIL_ERROR = 4

fun bitmapToBase64(bitmap: Bitmap): String = Base64.encodeToString(
    ByteArrayOutputStream().apply {
        bitmap.compress(Bitmap.CompressFormat.JPEG, 70, this)
        flush()
        close()
    }.toByteArray(), Base64.DEFAULT
)

fun Activity.display() = DisplayMetrics().apply {
    windowManager.defaultDisplay.getMetrics(this)
}

fun Context.dp2px(dp: Float) = (dp * resources.displayMetrics.density + 0.5).toInt()

fun Context.isPad()=
    ((resources.configuration.screenLayout and Configuration.SCREENLAYOUT_SIZE_MASK) >= Configuration.SCREENLAYOUT_SIZE_LARGE)

infix fun View.setDelayClickListener(clickAction: () -> Unit) {
    var hash = 0
    var lastClickTime = 0L
    val spaceTime = 1000L
    setOnClickListener {
        if (this.hashCode() != hash) {
            hash = this.hashCode()
            lastClickTime = System.currentTimeMillis()
            clickAction()
        } else {
            val currentTime = System.currentTimeMillis()
            if (currentTime - lastClickTime > spaceTime) {
                lastClickTime = System.currentTimeMillis()
                clickAction()
            }
        }
    }
}
fun <T> averageAssign(
    source: MutableList<T>?,
    splitItemNum: Int
): MutableList<MutableList<T>> {
    val result = mutableListOf<MutableList<T>>()

    if (!source.isNullOrEmpty() && splitItemNum > 0) {
        if (source.size <= splitItemNum) {
            // 源List元素数量小于等于目标分组数量
            result.add(source)
        } else {
            // 计算拆分后list数量
            val splitNum =
                if (source.size % splitItemNum == 0) source.size / splitItemNum else source.size / splitItemNum + 1

            for (i in 0 until splitNum) {
                result.add(
                    if (i < splitNum - 1) {
                        source.subList(i * splitItemNum, (i + 1) * splitItemNum)
                    } else {
                        // 最后一组
                        source.subList(i * splitItemNum, source.size)
                    }
                )
            }
        }
    }

    return result
}

/**
 * 去double小数点后的 0
 */
fun Double.removeDecimalZero(): String =
    DecimalFormat("##########.###").format(this)

/**
 * 获取时间
 * @param type 0(2020-01-01)、1(00:00:00)、else(2020-01-01 00:00:00)
 */
fun getFormatDate(date: Date? = Date(), type: Int = 0): String =
    if (date == null)
        ""
    else
        SimpleDateFormat(
            when (type) {
                0 -> "yyyy-MM-dd"
                1 -> "HH:mm:ss"
                2 -> "yyyyMMdd"//sap时间格式
                3 -> "yyyy-MM-dd HH:mm:ss"
                else -> "yyyy-MM-dd HH:mm:ss.SSS"
            }, Locale.CHINA
        ).format(date)


fun Double.add(value: Double) =
    BigDecimal(toString()).add(BigDecimal(value.toString())).toDouble()

fun Double.sub(value: Double) =
    BigDecimal(toString()).subtract(BigDecimal(value.toString())).toDouble()

fun Double.mul(value: Double) =
    BigDecimal(toString()).multiply(BigDecimal(value.toString())).toDouble()

fun Double.divide(value: Double) = BigDecimal(toString()).divide(
    BigDecimal(value.toString()), 21,
    RoundingMode.HALF_UP
).toDouble()

/**
 * 带异常捕获的toDouble
 */
fun String.toDoubleTry() = if (isNullOrEmpty()) {
    0.0
} else try {
    toDouble()
} catch (e: NumberFormatException) {
    0.0
}
