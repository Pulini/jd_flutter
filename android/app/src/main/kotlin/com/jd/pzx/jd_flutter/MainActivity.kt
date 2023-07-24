package com.jd.pzx.jd_flutter

import android.os.Bundle
import android.util.Log
import com.google.gson.Gson
import com.jd.pzx.jd_flutter.LivenFaceVerificationActivity.Companion.startOneselfFaceVerification
import com.jd.pzx.jd_flutter.messageCenter.JMessage
import com.jd.pzx.jd_flutter.messageCenter.JMessage.Companion.ReLogin
import com.jd.pzx.jd_flutter.messageCenter.JMessage.Companion.UpGrade
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode


class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        EventBus.getDefault().register(this)
    }

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

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onJPushMessageEvent(event: JMessage) {
        Log.e("Pan", "do:${event.doSomething}\ncontent:${event.content}")
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, CHANNEL).invokeMethod(
                "JMessage",
                HashMap<String, String>().also {
                    it["json"] = Gson().toJson(event)
                }
            )
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