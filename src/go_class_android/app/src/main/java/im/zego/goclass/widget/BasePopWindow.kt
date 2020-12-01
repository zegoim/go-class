package im.zego.goclass.widget

import android.content.Context
import android.graphics.drawable.ColorDrawable
import android.view.Gravity
import android.view.View
import android.widget.PopupWindow

open class BasePopWindow(context: Context, contentView: View) : PopupWindow(context) {
    private val TAG = "BasePopWindow"

    init {
        this.contentView = contentView
        contentView.measure(
            View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
            View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
        )
        width = contentView.measuredWidth
        height = contentView.measuredHeight
        setBackgroundDrawable(ColorDrawable())
        isOutsideTouchable = true
        contentView.systemUiVisibility = View.SYSTEM_UI_FLAG_LAYOUT_STABLE
    }

    /**
     *
     * @param anchor View 作为锚点的view
     * @param gravity Int 相对于锚点的位置
     */
    fun show(anchor: View, gravity: Int) {
        show(anchor, gravity, 0, 0)
    }

    /**
     *
     * @param anchor View View 作为锚点的view
     * @param gravity Int 相对于锚点的位置
     * @param offsetX Int x偏移值，注意 +是向右边偏移，-是向左边偏移
     * @param offsetY Int y偏移值，注意 +是向下偏移，-是向上偏移
     */
    fun show(anchor: View, gravity: Int, offsetX: Int, offsetY: Int) {
        val location = IntArray(2)
        anchor.getLocationInWindow(location)
        var showX: Int
        var showY: Int
        when (gravity) {
            Gravity.TOP -> {
                showX = location[0] + anchor.width / 2 - width / 2 + offsetX
                showY = location[1] - height + offsetY
                showAtLocation(anchor, Gravity.NO_GRAVITY, showX, showY)
            }
            Gravity.START, Gravity.LEFT -> {
                showX = location[0] - width + offsetX
                showY = location[1] + anchor.height / 2 - height / 2 + offsetY
                showAtLocation(anchor, Gravity.NO_GRAVITY, showX, showY)
            }
            Gravity.BOTTOM -> {
                showX = location[0] + anchor.width / 2 - width / 2 + offsetX
                showY = location[1] + anchor.height + +offsetY
                showAtLocation(anchor, Gravity.NO_GRAVITY, showX, showY)
            }
            else -> {
            }
        }
    }
}