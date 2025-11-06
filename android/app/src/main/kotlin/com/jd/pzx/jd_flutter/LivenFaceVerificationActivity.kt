package com.jd.pzx.jd_flutter

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.ActivityInfo
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Rect
import android.os.Build
import android.os.Bundle
import android.util.DisplayMetrics
import android.util.Log
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.core.view.postDelayed
import com.huawei.hms.mlsdk.common.MLFrame
import com.huawei.hms.mlsdk.faceverify.MLFaceVerificationAnalyzerFactory
import com.huawei.hms.mlsdk.faceverify.MLFaceVerificationAnalyzerSetting
import com.huawei.hms.mlsdk.livenessdetection.MLLivenessCaptureResult
import com.huawei.hms.mlsdk.livenessdetection.MLLivenessDetectInfo
import com.huawei.hms.mlsdk.livenessdetection.MLLivenessDetectView
import com.huawei.hms.mlsdk.livenessdetection.OnMLLivenessDetectCallback
import com.jd.pzx.jd_flutter.dialogs.InquiryDialog
import com.jd.pzx.jd_flutter.dialogs.TipsDialog
import com.jd.pzx.jd_flutter.utils.FACE_VERIFY_FAIL_ERROR
import com.jd.pzx.jd_flutter.utils.FACE_VERIFY_FAIL_NOT_LIVE
import com.jd.pzx.jd_flutter.utils.FACE_VERIFY_FAIL_NOT_ME
import com.jd.pzx.jd_flutter.utils.FACE_VERIFY_SUCCESS
import com.jd.pzx.jd_flutter.utils.dp2px
import com.jd.pzx.jd_flutter.utils.isPad


/**
 * File Name : LivenFaceVerificationActivity
 * Created by : PanZX on  2021/05/03 15:40
 * Email : 644173944@qq.com
 * Github : https://github.com/Pulini
 * Remark :华为HiAI引擎 人脸活体验证+人脸对比
 */
class LivenFaceVerificationActivity : Activity() {

    companion object {
        lateinit var verifyResult: (Int, Bitmap?, String?) -> Unit
        fun startOneselfFaceVerification(
            context: Context,
            photo: String,
            result: (Int, Bitmap?, String?) -> Unit
        ) {
            verifyResult = result
            context.startActivity(
                Intent(context, LivenFaceVerificationActivity::class.java)
                    .putExtra("isLivingVerification", false)
                    .putExtra("image", photo)
            )
        }

        fun startLivingVerification(
            context: Context,
            result: (Int, Bitmap?, String?) -> Unit
        ) {
            verifyResult = result
            context.startActivity(
                Intent(context, LivenFaceVerificationActivity::class.java)
                    .putExtra("isLivingVerification", true)
            )
        }
    }

    private var bundle: Bundle? = null


    //活体检测插件
    private var mlLivenDetectView: MLLivenessDetectView? = null

    //活体检测插件承载
    private val previewContainer: FrameLayout by lazy { findViewById(R.id.surface_layout) }

    //返回
    private val ivBack: ImageView by lazy { findViewById(R.id.iv_back) }

    //活体检测结果人脸照片
    private val face: ImageView by lazy { findViewById(R.id.face) }

    //人事档案人脸照片
    private val image: ImageView by lazy { findViewById(R.id.image) }

    //照片对比相似度
    private val tvSimilarity: TextView by lazy { findViewById(R.id.tv_similarity) }

    //人事档案人脸bitmap
    private var imageBitmap: Bitmap? = null

    //活体检测结果bitmap
    private var faceBitmap: Bitmap? = null

    @SuppressLint("SourceLockedOrientationActivity")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        bundle = savedInstanceState
//        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
//        setContentView(R.layout.activity_liveness_custom_detection)
        if (isPad()) {
            //加载平板的主界面并强制横屏
            setContentView(R.layout.activity_liveness_custom_detection_pad)
            requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
        } else {
            //加载手机的主界面并强制竖屏
            setContentView(R.layout.activity_liveness_custom_detection_phone)
            requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        }
        ivBack.setOnClickListener { finish() }
        previewContainer.postDelayed(300) {
            //预览界面加载存在位置偏移bug,需要延迟加载预览界面
            startFaceVerification()
        }
    }

    private fun startFaceVerification() {
        intent.extras?.run {
            if (getBoolean("isLivingVerification")) {
                initLivingDetectView { a, b ->
                    TipsDialog(this@LivenFaceVerificationActivity).show(
                        getString(R.string.liven_detection_living_verification_successful)
                    ) {
                        verifyResult.invoke(a, b, null)
                        finish()
                    }
                }.onResume()
            } else {
                imageBitmap = BitmapFactory.decodeFile(getString("image"))
                //设置人事档案照片到界面上
                image.setImageBitmap(imageBitmap)
                //设置活体验证
                initLivingDetectView { code, bitmap ->
                    if (code == FACE_VERIFY_SUCCESS) {
                        faceBitmap = bitmap
                        face.setImageBitmap(faceBitmap)
                        compare(verifyResult)
                    } else {
                        verifyResult.invoke(code, null, "")
                    }
                }.onResume()
            }
        }
    }


    private fun initLivingDetectView(callback: (Int, Bitmap?) -> Unit): MLLivenessDetectView {
        return MLLivenessDetectView.Builder()
            .setContext(this)
            .setOptions(MLLivenessDetectView.DETECT_MASK)
            .setFaceFrameRect(
                Rect(
                    0,
                    0,
                    resources.displayMetrics.widthPixels,
                    resources.displayMetrics.heightPixels,
                )
            )
            .setDetectCallback(object : OnMLLivenessDetectCallback {
                //活体检测完成
                override fun onCompleted(result: MLLivenessCaptureResult) {
                    if (result.isLive) {
                        //活体检测成功
                        callback.invoke(FACE_VERIFY_SUCCESS, result.bitmap)
                    } else {
                        //活体检测失败
                        showFailDialog(
                            getString(R.string.liven_detection_liven_fail),
                            FACE_VERIFY_FAIL_NOT_LIVE
                        )
                    }
                }

                //活体检测异常
                override fun onError(error: Int) {
                    Log.e("Pan", "活体检测异常：$error")
                    showFailDialog(
                        String.format(getString(R.string.liven_detection_liven_error), error),
                        FACE_VERIFY_FAIL_ERROR
                    )
                }

                override fun onInfo(infoCode: Int, bundle: Bundle) {
                    Log.e("Pan", "infoCode=$infoCode")
                    tvSimilarity.text = when (infoCode) {
                        MLLivenessDetectInfo.NO_FACE_WAS_DETECTED -> "未识别到人脸"
                        MLLivenessDetectInfo.MASK_WAS_DETECTED -> "检测到口罩"
                        MLLivenessDetectInfo.SUNGLASS_WAS_DETECTED -> "检测到墨镜"
                        MLLivenessDetectInfo.FACE_ROTATION -> "脸部旋转"
                        else -> ""
                    }
                }
                override fun onStateChange(state: Int, bundle: Bundle) {}
            })
            .build()
            .apply {
                //加载活体验证插件到界面
                previewContainer.addView(this)
                onCreate(bundle)
                mlLivenDetectView = this
            }

    }

    /**
     * 人脸照片对比
     */
    private fun compare(callback: (Int, Bitmap?, String?) -> Unit) {
        try {  //设置被对比照片bitmap
            val analyzer = MLFaceVerificationAnalyzerFactory
                .getInstance()
                .getFaceVerificationAnalyzer(
                    MLFaceVerificationAnalyzerSetting
                        .Factory()
                        .setMaxFaceDetected(1)
                        .create()
                )

            Log.e("Pan", "Bitmap1 ${imageBitmap == null}")
            val face1 = MLFrame.fromBitmap(imageBitmap)
            Log.e("Pan", "face1 ${face1 == null}")

            Log.e("Pan", "Bitmap2 ${faceBitmap == null}")
            val face2 = MLFrame.fromBitmap(faceBitmap)
            Log.e("Pan", "face2 ${face2 == null}")

            val results = analyzer.setTemplateFace(face1)
            if (results.isEmpty()) {
                Log.e("Pan", "照片载入失败")
                callback.invoke(FACE_VERIFY_FAIL_ERROR, null, "照片载入失败")
                finish()
            } else {
                analyzer.asyncAnalyseFrame(face2)
                    .addOnSuccessListener { mlCompareList ->
                        if (mlCompareList.isNotEmpty()) {
                            mlCompareList[0]?.run {
                                tvSimilarity.text = String.format(
                                    getString(R.string.liven_detection_similarity),
                                    "${similarity * 100} %"
                                )
                                if (similarity > 0.75) {
                                    TipsDialog(this@LivenFaceVerificationActivity).show(
                                        getString(
                                            R.string.liven_detection_face_verification_successful
                                        )
                                    ) {
                                        callback.invoke(
                                            FACE_VERIFY_SUCCESS,
                                            faceBitmap!!,
                                            "验证成功"
                                        )
                                        finish()
                                    }
                                } else {
                                    showFailDialog(
                                        getString(R.string.liven_detection_photo_not_me),
                                        FACE_VERIFY_FAIL_NOT_ME
                                    )
                                }
                            }
                        }
                    }.addOnFailureListener {
                        Log.e("Pan", it.toString())
                        showFailDialog(
                            getString(R.string.liven_detection_photo_not_me),
                            FACE_VERIFY_FAIL_NOT_ME
                        )
                    }
            }
        } catch (e: RuntimeException) {
            Log.e("Pan", e.toString())
            callback.invoke(FACE_VERIFY_FAIL_ERROR, null, e.toString())
        }
    }

    private fun showFailDialog(msg: String, code: Int, retry: Boolean = true) {
        if (retry) {
            InquiryDialog(this@LivenFaceVerificationActivity).show {
                title(R.string.liven_detection_validation_failed)
                msg(msg)
                confirm(R.string.liven_detection_retry) {
                    startFaceVerification()
                }
                cancel {
                    verifyResult.invoke(code, null, msg)
                    finish()
                }
            }
        } else {
            TipsDialog(this@LivenFaceVerificationActivity).show(msg) {
                finish()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        mlLivenDetectView?.onDestroy()
    }

    override fun onPause() {
        super.onPause()
        mlLivenDetectView?.onPause()
    }

    override fun onResume() {
        super.onResume()
        mlLivenDetectView?.onResume()
    }

    override fun onStart() {
        super.onStart()
        mlLivenDetectView?.onStart()
    }

    override fun onStop() {
        super.onStop()
        mlLivenDetectView?.onStop()
    }
}