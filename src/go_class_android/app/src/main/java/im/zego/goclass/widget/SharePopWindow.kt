package im.zego.goclass.widget

import android.content.Context
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import im.zego.goclass.R
import im.zego.goclass.dp2px

/**
 * 课堂内，点击共享按钮后的弹出框
 */
class SharePopWindow(context: Context) : BasePopWindow(
    context,
    contentView = LayoutInflater.from(context).inflate(R.layout.popwindow_share, null, false)
) {
    private var whiteboardBtn: TextView = contentView.findViewById(R.id.share_pop_whiteboard)
    private var fileBtn: TextView = contentView.findViewById(R.id.share_pop_file)


    fun show(anchor: View) {
        show(anchor, Gravity.TOP, 0, dp2px(anchor.context, 13f).toInt())
    }

    fun setWhiteboardClickListener(onWhiteboardClick: () -> Unit) {
        whiteboardBtn.setOnClickListener {
            onWhiteboardClick.invoke()
            dismiss()
        }
    }

    fun setFileClickListener(onFileClick: () -> Unit) {
        fileBtn.setOnClickListener {
            onFileClick.invoke()
            dismiss()
        }
    }
}