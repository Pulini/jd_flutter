package com.jd.pzx.jd_flutter

import com.huawei.hms.mlsdk.livenessdetection.MLLivenessCapture
import com.huawei.hms.mlsdk.livenessdetection.MLLivenessCaptureResult
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.jd.pzx.jd_flutter"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startDetect" -> {
                        startDetect(
                            success = {
                                result.success(it)
                            },
                            failure = {
                                result.success(it)
                            }
                        )
                    }

                    else -> result.notImplemented()
                }
            }

    }

    private fun startDetect(success: (String) -> Unit, failure: (String) -> Unit) {
        MLLivenessCapture.getInstance().startDetect(this, object : MLLivenessCapture.Callback {
            override fun onSuccess(result: MLLivenessCaptureResult) {
                //检测成功的处理逻辑，检测结果可能是活体或者非活体。
                success.invoke("isLive=${result.isLive}")
            }

            override fun onFailure(errorCode: Int) {
                //检测未完成，如相机异常CAMERA_ERROR,添加失败的处理逻辑。
                failure.invoke("errorCode=$errorCode")
            }
        })
    }

}
