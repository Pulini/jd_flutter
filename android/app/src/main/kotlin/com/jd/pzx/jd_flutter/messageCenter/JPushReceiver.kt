package com.jd.pzx.jd_flutter.messageCenter

import android.content.Context
import android.util.Log
import cn.jpush.android.api.NotificationMessage
import cn.jpush.android.service.JPushMessageReceiver
import com.jd.pzx.jd_flutter.messageCenter.JMessage.Companion.ReLogin
import com.jd.pzx.jd_flutter.messageCenter.JMessage.Companion.UpGrade
import org.greenrobot.eventbus.EventBus
import org.json.JSONObject


/**
 * File Name : JPushReceiver
 * Created by : PanZX on  2021/02/24 16:53
 * Email : 644173944@qq.com
 * Github : https://github.com/Pulini
 * Remark :
 */
class JPushReceiver : JPushMessageReceiver() {


    //打开通知
    override fun onNotifyMessageOpened(context: Context, message: NotificationMessage) {
        Log.e("Pan", "[onNotifyMessageOpened] $message")
        JSONObject(message.notificationExtras).let { json ->
            when (json.getString("doType")) {
                UpGrade, ReLogin -> {
//                    goLogin(context)
                }

                else -> {}
            }
        }
    }

    //收到通知
    override fun onNotifyMessageArrived(context: Context, message: NotificationMessage) {
        Log.e("Pan", "[onNotifyMessageArrived] $message")
        JSONObject(message.notificationExtras).let { json ->
            EventBus.getDefault().post(
                JMessage(
                    json.getString("doType"),
                    json.getString("message"),
                )
            )
        }

    }

//    private fun goLogin(context: Context) {
//        try {
//            context.startActivity(Intent(context, LoginActivity::class.java).apply {
//                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
//            })
//        } catch (throwable: Throwable) {
//            Log.e("Pan","打开登录页面失败")
//        }
//    }
}