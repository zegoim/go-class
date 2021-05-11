package im.zego.goclass.widget

import android.content.Context
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import im.zego.goclass.R
import im.zego.goclass.dp2px

/**
 * 课堂内点击相机按钮后弹出框
 */
class CameraPopWindow(context: Context) : BasePopWindow(
    context,
    contentView = LayoutInflater.from(context).inflate(R.layout.popwindow_camera, null, false)
) {
    private var switchBtn: TextView = contentView.findViewById(R.id.camera_pop_switch)
    private var closeBtn: TextView = contentView.findViewById(R.id.camera_pop_close)

    fun show(anchor: View) {
        show(anchor, Gravity.TOP, 0, dp2px(anchor.context, 13f).toInt())
    }

    fun setSwitchClickListener(onSwitchClick: () -> Unit) {
        switchBtn.setOnClickListener {
            onSwitchClick.invoke()
            dismiss()
        }
    }

    fun setCloseClickListener(onCloseClick: () -> Unit) {
        closeBtn.setOnClickListener {
            onCloseClick.invoke()
            dismiss()
        }
    }
}