package com.jd.pzx.jd_flutter

import android.util.Log
import com.jd.pzx.jd_flutter.LivenFaceVerificationActivity.Companion.startOneselfFaceVerification
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startDetect" -> {
                        Log.e("Pan", "arguments=${call.arguments}")
                        startOneselfFaceVerification(
                            this,
                            call.arguments.toString()
                        ) { code, bitmap ->
                            Log.e("Pan", "code=$code")
                            if (code == FACE_VERIFY_SUCCESS) {
                                result.success(bitmapToBase64(bitmap!!))
                            } else {
                                result.error(code.toString(), null, null)
                            }
                        }
                    }

                    else -> result.notImplemented()
                }
            }

    }
/*

    private fun startDetect(
        imagePath: String,
        success: (Boolean) -> Unit
    ) {
        MLLivenessCapture.getInstance().startDetect(this, object : MLLivenessCapture.Callback {
            override fun onSuccess(result: MLLivenessCaptureResult) {
                //检测成功的处理逻辑，检测结果可能是活体或者非活体。

            }

            override fun onFailure(errorCode: Int) {
                //检测未完成，如相机异常CAMERA_ERROR,添加失败的处理逻辑。
                Log.e("Pan", "errorCode=$errorCode")
                success.invoke(false)
            }
        })
    }
*/


}