package im.zego.goclass.widget

import android.app.Activity
import android.graphics.drawable.ColorDrawable
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.PopupWindow
import android.widget.TextView
import im.zego.goclass.R
import im.zego.goclass.dp2px
import im.zego.goclass.getRoundRectDrawable


class LoadingPopWindow(context: Activity) : PopupWindow(context)  {

    init {
        contentView = LayoutInflater.from(context).inflate(
            R.layout.popwindow_loading_layout,
            null,
            false
        )
        setBackgroundDrawable(ColorDrawable())
        height = ViewGroup.LayoutParams.WRAP_CONTENT
        width = ViewGroup.LayoutParams.WRAP_CONTENT
        contentView.systemUiVisibility = View.SYSTEM_UI_FLAG_LAYOUT_STABLE
        contentView.background = getRoundRectDrawable("#99000000", dp2px(context, 5f))
    }

    private var content: TextView = contentView.findViewById(R.id.upload_state_content)

    fun show(anchor: View, popWindow: LoadingPopWindow) {
        popWindow.isOutsideTouchable = false;
        popWindow.isFocusable = false;
        popWindow.isTouchable = true;
        showAtLocation(anchor, Gravity.TOP, 0, dp2px(anchor.context, 54f).toInt())
    }

    fun updateText(text: String) {
        content.text = text
        if (text.isEmpty()) {
            content.visibility = View.GONE
        } else {
            content.visibility = View.VISIBLE
        }
    }
}