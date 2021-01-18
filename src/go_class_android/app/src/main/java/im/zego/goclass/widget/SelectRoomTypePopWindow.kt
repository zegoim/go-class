package im.zego.goclass.widget

import android.content.Context
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import im.zego.goclass.R
import kotlinx.android.synthetic.main.popwindow_select_role.view.cancel
import kotlinx.android.synthetic.main.popwindow_select_role.view.confirm
import kotlinx.android.synthetic.main.popwindow_select_room_type.view.*

/**
 * 登陆界面选择课堂类型 PopWindow
 */
class SelectRoomTypePopWindow(context: Context, selectRoomType: String) : BasePopWindow(
    context,
    contentView = LayoutInflater.from(context).inflate(R.layout.popwindow_select_room_type, null, false)
) {
    private var confirmListener: (String) -> Unit = {}
    private val mContext = context;

    // 当前所选课堂类型，默认为小班课
    private var mSelectRoomType = context.getString(R.string.login_small_class)

    init {
        width = ViewGroup.LayoutParams.MATCH_PARENT

        if (selectRoomType.isNotEmpty()) {
            mSelectRoomType = selectRoomType
        }

        contentView.type_list.let {
            val list = listOf(
                context.getString(R.string.login_small_class),
                context.getString(R.string.login_large_class)
            )
            it.data = list
            it.isResetSelectedPosition = false
            it.setOnItemSelectedListener { wheelView, any, position ->
                mSelectRoomType = any as String
            }
        }

        contentView.cancel.setOnClickListener {
            if (super.isShowing()) super.dismiss()
        }

        contentView.confirm.setOnClickListener {
            confirmListener.invoke(mSelectRoomType)
            if (super.isShowing()) super.dismiss()
        }
    }

    fun show(anchor: View) {
        val location = IntArray(2)
        anchor.getLocationOnScreen(location)
        mSelectRoomType = mContext.getString(R.string.login_small_class)
        super.showAtLocation(anchor, Gravity.BOTTOM, 0, 0)
    }

    fun setOnConfirmClickListener(listener: (String) -> Unit) {
        this.confirmListener = listener
    }
}
