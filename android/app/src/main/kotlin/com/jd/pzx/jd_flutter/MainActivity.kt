package com.jd.pzx.jd_flutter

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import android.widget.Toast
import com.huawei.hms.mlsdk.common.MLFrame
import com.huawei.hms.mlsdk.faceverify.MLFaceVerificationAnalyzerFactory
import com.huawei.hms.mlsdk.faceverify.MLFaceVerificationAnalyzerSetting
import com.huawei.hms.mlsdk.livenessdetection.MLLivenessCapture
import com.huawei.hms.mlsdk.livenessdetection.MLLivenessCaptureResult
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.FileInputStream


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.jd.pzx.jd_flutter"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startDetect" -> {
                        Log.e("Pan", "arguments=${call.arguments as String}")
                        startDetect(
                            call.arguments.toString(),
                            success = {
                                result.success(it)
                            }
                        )
                    }

                    else -> result.notImplemented()
                }
            }

    }

    private fun startDetect(
        imagePath: String,
        success: (Boolean) -> Unit
    ) {
        MLLivenessCapture.getInstance().startDetect(this, object : MLLivenessCapture.Callback {
            override fun onSuccess(result: MLLivenessCaptureResult) {
                //检测成功的处理逻辑，检测结果可能是活体或者非活体。
                compare(imagePath, result.bitmap, success)
            }

            override fun onFailure(errorCode: Int) {
                //检测未完成，如相机异常CAMERA_ERROR,添加失败的处理逻辑。
                Log.e("Pan", "errorCode=$errorCode")
                success.invoke(false)
            }
        })
    }

    private fun compare(
        imagePath: String,
        faceBitmap: Bitmap,
        success: (Boolean) -> Unit
    ) {
        try {  //设置被对比照片bitmap
            val analyzer = MLFaceVerificationAnalyzerFactory
                .getInstance()
                .getFaceVerificationAnalyzer(
                    MLFaceVerificationAnalyzerSetting
                        .Factory()
                        .setMaxFaceDetected(1)
                        .create()
                )

            val image = BitmapFactory.decodeStream(FileInputStream(imagePath))
            val face1 = MLFrame.fromBitmap(image)
            Log.e("Pan", "face1 ${face1 == null}")

            val face2 = MLFrame.fromBitmap(faceBitmap)
            Log.e("Pan", "face2 ${face2 == null}")

            val results = analyzer.setTemplateFace(face1)
            if (results.isEmpty()) Log.e("Pan", "照片载入失败")

            analyzer.asyncAnalyseFrame(face2)
                .addOnSuccessListener { mlCompareList ->
                    success.invoke(mlCompareList[0].similarity > 0.75)
                }.addOnFailureListener {
                    Log.e("Pan", "addOnFailureListener ${it.message}")
                    Toast.makeText(this, it.message, Toast.LENGTH_SHORT).show()
                    success.invoke(false)
                }
        } catch (e: Exception) {
            Log.e("Pan", e.toString())
            Toast.makeText(this, e.message, Toast.LENGTH_SHORT).show()
            success.invoke(false)
        }
    }

}
