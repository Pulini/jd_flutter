package com.jd.pzx.jd_flutter.messageCenter

/**
 * File Name : JMessage
 * Created by : PanZX on  2021/02/25 09:37
 * Email : 644173944@qq.com
 * Github : https://github.com/Pulini
 * Remark :
 */
data class JMessage(
    val doSomething: String = "",
    val content: String = ""
) {
    companion object {
        const val UpGrade = "UpGrade"
        const val ReLogin = "ReLogin"
        const val UpData = "UpData"
    }
}