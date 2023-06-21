package com.jd.pzx.jd_flutter

import android.app.Activity
import android.content.Context
import android.content.res.Configuration
import android.graphics.Bitmap
import android.util.Base64
import android.util.DisplayMetrics
import java.io.ByteArrayOutputStream

const val CHANNEL = "com.jd.pzx.jd_flutter"
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