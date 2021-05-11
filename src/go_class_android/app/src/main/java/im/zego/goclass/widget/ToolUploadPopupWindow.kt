package im.zego.goclass.widget

import android.content.Context
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import im.zego.goclass.dp2px
import im.zego.goclass.R
import kotlinx.android.synthetic.main.popwindow_upload_file.view.*

/**
 * 点击工具栏上传按钮后的弹出框
 */
class ToolUploadPopupWindow(context: Context, onSelect: (isDynamic: Boolean) -> Unit) :
    BasePopWindow(
        context,
        contentView = LayoutInflater.from(context).inflate(R.layout.popwindow_upload_file, null)
    ) {

    init {
        contentView.rl_static.setOnClickListener {
            onSelect(false)
        }

        contentView.rl_dynamic.setOnClickListener {
            onSelect(true)
        }
    }

    fun show(anchor: View) {
        if (!isShowing) {
            show(anchor, Gravity.START, -dp2px(anchor.context, 2f).toInt(),
            anchor.height / 2 - contentView.measuredHeight / 2)
        }
    }
}