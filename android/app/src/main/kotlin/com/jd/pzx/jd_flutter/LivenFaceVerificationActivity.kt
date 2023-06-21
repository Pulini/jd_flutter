package com.jd.pzx.jd_flutter

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.ActivityInfo
import android.content.res.Configuration
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Rect
import android.os.Bundle
import android.util.Log
import android.widget.FrameLayout
import android.widget.ImageView
import com.huawei.hms.mlsdk.common.MLFrame
import com.huawei.hms.mlsdk.faceverify.MLFaceVerificationAnalyzerFactory
import com.huawei.hms.mlsdk.faceverify.MLFaceVerificationAnalyzerSetting
import com.huawei.hms.mlsdk.livenessdetection.MLLivenessCaptureResult
import com.huawei.hms.mlsdk.livenessdetection.MLLivenessDetectView
import com.huawei.hms.mlsdk.livenessdetection.OnMLLivenessDetectCallback
import java.io.FileInputStream


/**
 * File Name : LivenFaceVerificationActivity
 * Created by : PanZX on  2021/05/03 15:40
 * Email : 644173944@qq.com
 * Github : https://github.com/Pulini
 * Remark :华为HiAI引擎 人脸活体验证+人脸对比
 */
class LivenFaceVerificationActivity : Activity() {

    companion object {
        lateinit var verifyResult: (Int, Bitmap?) -> Unit
        fun startOneselfFaceVerification(
            context: Context,
            photo: String,
            result: (Int, Bitmap?) -> Unit
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
            result: (Int, Bitmap?) -> Unit
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

    //人事档案人脸bitmap
    private var imageBitmap: Bitmap? = null

    //活体检测结果bitmap
    private var faceBitmap: Bitmap? = null



    @SuppressLint("SourceLockedOrientationActivity")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        bundle = savedInstanceState
        //判断是否是平板
        if (isPad()) {
            //加载平板的主界面并强制横屏
            requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
            setContentView(R.layout.activity_liveness_custom_detection_pad)
        } else {
            //加载手机的主界面并强制竖屏
            requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
            setContentView(R.layout.activity_liveness_custom_detection_phone)
        }
        ivBack.setOnClickListener { finish() }
        startFaceVerification()
    }

    private fun startFaceVerification() {
        intent.extras?.run {
            if (getBoolean("isLivingVerification")) {
                initLivingDetectView { a, b -> verifyResult.invoke(a, b) }.onResume()
            } else {
                imageBitmap = BitmapFactory.decodeStream(FileInputStream(getString("image")))
                //设置人事档案照片到界面上
                image.setImageBitmap(imageBitmap)
                //设置活体验证
                initLivingDetectView { code, bitmap ->
                    if (code==FACE_VERIFY_SUCCESS){
                        faceBitmap = bitmap
                        face.setImageBitmap(faceBitmap)
                        compare(verifyResult)
                    } else {
                        verifyResult.invoke(code, null)
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
                //平板和手机区分检测区域大小
                Rect(
                    0,
                    0,
                    display().widthPixels,
                    if (isPad()) display().heightPixels else dp2px( 480f)
                )
            )
            .setDetectCallback(object : OnMLLivenessDetectCallback {
                //活体检测完成
                override fun onCompleted(result: MLLivenessCaptureResult) {
                    if(result.isLive){
                        //活体检测成功
                        callback.invoke(FACE_VERIFY_SUCCESS, result.bitmap)
                    }else{
                        //活体检测失败
                        callback.invoke(FACE_VERIFY_FAIL_NOT_LIVE, null)
                    }
                }

                //活体检测异常
                override fun onError(error: Int) {
                    Log.e("Pan", "活体检测异常：$error")
                    callback.invoke(FACE_VERIFY_FAIL_NOT_ME, null)
                }

                override fun onInfo(infoCode: Int, bundle: Bundle) {}
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
    private fun compare(callback: (Int, Bitmap?) -> Unit) {
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
            if (results.isEmpty()) Log.e("Pan", "照片载入失败")

            analyzer.asyncAnalyseFrame(face2)
                .addOnSuccessListener { mlCompareList ->
                    if(mlCompareList[0].similarity > 0.75){
                        callback.invoke(FACE_VERIFY_SUCCESS,  faceBitmap!!)
                    }else{
                        callback.invoke(FACE_VERIFY_FAIL_NOT_ME, null)
                    }
                    finish()
                }.addOnFailureListener {
                    Log.e("Pan", it.toString())
                    callback.invoke(FACE_VERIFY_FAIL_ERROR, null)
                }
        } catch (e: RuntimeException) {
            Log.e("Pan", e.toString())
            callback.invoke(FACE_VERIFY_FAIL_ERROR, null)
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
}