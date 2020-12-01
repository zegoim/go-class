package im.zego.goclass.widget

import android.content.Context
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import im.zego.goclass.R
import kotlinx.android.synthetic.main.popwindow_select_role.view.*

/**
 * 登陆界面选择角色 PopWindow
 */
class SelectRolePopWindow(context: Context, selectRole: String) : BasePopWindow(
    context,
    contentView = LayoutInflater.from(context).inflate(R.layout.popwindow_select_role, null, false)
) {
    private var confirmListener: (String) -> Unit = {}
    private val mContext = context;

    // 当前所选角色
    private var mSelectRole = context.getString(R.string.join_role_teacher)

    init {
        width = ViewGroup.LayoutParams.MATCH_PARENT

        if (selectRole.isNotEmpty()) {
            mSelectRole = selectRole
        }

        contentView.role_list.let {
            val list = listOf(
                context.getString(R.string.join_role_teacher),
                context.getString(R.string.join_role_student)
            )
            it.data = list
            it.isResetSelectedPosition = false
            it.setOnItemSelectedListener { wheelView, any, position ->
                mSelectRole = any as String
            }
        }

        contentView.cancel.setOnClickListener {
            if (super.isShowing()) super.dismiss()
        }

        contentView.confirm.setOnClickListener {
            confirmListener.invoke(mSelectRole)
            if (super.isShowing()) super.dismiss()
        }
    }

    fun show(anchor: View) {
        val location = IntArray(2)
        anchor.getLocationOnScreen(location)
        mSelectRole = mContext.getString(R.string.join_role_teacher)
        super.showAtLocation(anchor, Gravity.BOTTOM, 0, 0)
    }

    fun setOnConfirmClickListener(listener: (String) -> Unit) {
        this.confirmListener = listener
    }
}
