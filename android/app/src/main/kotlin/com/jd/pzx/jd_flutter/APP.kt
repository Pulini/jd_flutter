package com.jd.pzx.jd_flutter

import android.app.Application
import cn.jpush.android.api.JPushInterface

class APP : Application() {
    override fun onCreate() {
        super.onCreate()
        JPushInterface.setDebugMode(true)
        JPushInterface.init(this)
    }
}