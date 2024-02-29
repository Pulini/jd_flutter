package com.jd.pzx.jd_flutter.dialogs

import android.app.Dialog
import android.content.Context
import android.view.WindowManager
import android.widget.TextView
import androidx.annotation.StringRes
import com.jd.pzx.jd_flutter.R
import com.jd.pzx.jd_flutter.utils.dp2px
import com.jd.pzx.jd_flutter.utils.setDelayClickListener

/**
 * File Name : InquiryDialog
 * Created by : PanZX on  2021/01/25 13:52
 * Email : 644173944@qq.com
 * Github : https://github.com/Pulini
 * Remark :
 */
class InquiryDialog(context: Context) : Dialog(context, R.style.MessageDialog) {

    private val tvTitle: TextView by lazy { findViewById(R.id.tv_title) }
    private val tvMsg: TextView by lazy { findViewById(R.id.tv_msg) }
    private val tvCancel: TextView by lazy { findViewById(R.id.tv_cancel) }
    private val tvConfirm: TextView by lazy { findViewById(R.id.tv_confirm) }

    init {
        setContentView(R.layout.dialog_inquiry)
        setCanceledOnTouchOutside(false)
        setCancelable(false)
        val lp: WindowManager.LayoutParams? = window?.attributes
        lp?.width = context.dp2px(260f)
        window?.attributes = lp
        tvCancel.setDelayClickListener {
            dismiss()
        }
        tvConfirm.setDelayClickListener {
            dismiss()
        }
    }

    fun title(text: String): InquiryDialog = apply {
        tvTitle.text = text
    }

    fun title(@StringRes id: Int): InquiryDialog = apply {
        tvTitle.text = context.getString(id)
    }


    fun msg(text: String): InquiryDialog = apply {
        tvMsg.text = text
    }

    fun msg(@StringRes id: Int): InquiryDialog = apply {
        tvMsg.text = context.getString(id)
    }


    fun cancel(
        text: String = context.getString(R.string.dialog_cancel),
        cancel: (InquiryDialog) -> Unit={}
    ): InquiryDialog = apply {
        tvCancel.run {
            this.text = text
            setDelayClickListener {
                dismiss()
                cancel.invoke(this@InquiryDialog)
            }
        }
    }

    fun cancel(
        @StringRes id: Int,
        cancel: (InquiryDialog) -> Unit={}
    ): InquiryDialog = apply {
        tvCancel.run {
            this.text = context.getString(id)
            setDelayClickListener {
                dismiss()
                cancel.invoke(this@InquiryDialog)
            }
        }
    }

    fun confirm(
        text: String = context.getString(R.string.dialog_confirm),
        confirm: (InquiryDialog) -> Unit={}
    ): InquiryDialog = apply {
        tvConfirm.run {
            this.text = text
            setDelayClickListener {
                dismiss()
                confirm.invoke(this@InquiryDialog)
            }
        }
    }

    fun confirm(
        @StringRes id: Int,
        confirm: (InquiryDialog) -> Unit={}
    ): InquiryDialog = apply {
        tvConfirm.run {
            this.text = context.getString(id)
            setDelayClickListener {
                dismiss()
                confirm.invoke(this@InquiryDialog)
            }
        }
    }

    inline fun show(func: InquiryDialog.() -> Unit): InquiryDialog = apply {
        if (isShowing) return@apply
        this.func()
        this.show()
    }

}