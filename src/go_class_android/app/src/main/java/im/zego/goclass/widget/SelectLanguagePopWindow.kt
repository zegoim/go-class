package im.zego.goclass.widget

import android.content.Context
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import im.zego.goclass.AppLanguage.setCurrentLanguageLocale
import im.zego.goclass.R
import kotlinx.android.synthetic.main.popwindow_select_language.view.*
import java.util.*

/**
 * 设置界面选择语言 PopWindow
 */
class SelectLanguagePopWindow(context: Context, selectLanguage: String) : BasePopWindow(
    context,
    contentView = LayoutInflater.from(context).inflate(R.layout.popwindow_select_language, null, false)
) {
    private var confirmListener: (String) -> Unit = {}
    private val mContext = context;

    // 当前所选语言
    private var mSelectLanguage = "简体中文"

    init {
        width = ViewGroup.LayoutParams.MATCH_PARENT

        if (selectLanguage.isNotEmpty()) {
            mSelectLanguage = selectLanguage
        }

        contentView.language_list.let {
            val list = listOf(
                "简体中文",
                "English"
            )
            it.data = list
            it.isResetSelectedPosition = false
            it.setOnItemSelectedListener { wheelView, any, position ->
                mSelectLanguage = any as String
            }
        }

        contentView.cancel.setOnClickListener {
            if (super.isShowing()) super.dismiss()
        }

        contentView.confirm.setOnClickListener {
            when {
                mSelectLanguage.equals("English") -> {
                    setCurrentLanguageLocale(mContext, Locale.ENGLISH)
                }
                else -> {
                    setCurrentLanguageLocale(mContext, Locale.CHINESE)
                }
            }
            confirmListener.invoke(mSelectLanguage)
            if (super.isShowing()) super.dismiss()
        }
    }

    fun show(anchor: View) {
        val location = IntArray(2)
        anchor.getLocationOnScreen(location)
        mSelectLanguage = "简体中文"
        super.showAtLocation(anchor, Gravity.BOTTOM, 0, 0)
    }

    fun setOnConfirmClickListener(listener: (String) -> Unit) {
        this.confirmListener = listener
    }
}
