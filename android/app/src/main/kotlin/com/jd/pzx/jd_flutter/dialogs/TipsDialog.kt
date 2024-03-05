package com.jd.pzx.jd_flutter.dialogs

import android.app.Dialog
import android.content.Context
import android.view.WindowManager
import android.widget.TextView
import androidx.annotation.StringRes
import com.jd.pzx.jd_flutter.R
import com.jd.pzx.jd_flutter.utils.dp2px


/**
 * File Name : TipsDialog
 * Created by : PanZX on 2020/06/03
 * Email : 644173944@qq.com
 * Github : https://github.com/Pulini
 * Remark：提示弹窗
 */
class TipsDialog(context: Context) : Dialog(context, R.style.MessageDialog) {


    private val tvMsg: TextView by lazy { findViewById(R.id.tv_msg) }
    private val tvConfirm: TextView by lazy { findViewById(R.id.tv_confirm) }

    init {
        setContentView(R.layout.dialog_tips)
        setCanceledOnTouchOutside(false)
        setCancelable(false)
        val lp: WindowManager.LayoutParams? = window?.attributes
        lp?.width = context.dp2px( 260f)
        window?.attributes = lp
    }

    fun show(@StringRes msg: Int,click: () -> Unit) {
        show(context.getString(msg),click)
    }
    fun show(msg: String, click: () -> Unit) {
        show()
        tvMsg.text = msg
        tvConfirm.setOnClickListener {
            dismiss()
            click.invoke()
        }
    }

    fun show(@StringRes msg: Int) {
        show(context.getString(msg))
    }

    fun show(msg: String) {
        show()
        tvMsg.text = msg
        tvConfirm.setOnClickListener{ dismiss() }
    }

}