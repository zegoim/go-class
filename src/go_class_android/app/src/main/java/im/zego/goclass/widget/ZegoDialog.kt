package im.zego.goclass.widget

import android.app.Dialog
import android.content.Context
import android.content.DialogInterface
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Build
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.TextView
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import im.zego.goclass.R
import im.zego.goclass.dp2px

/**
 * 不抢焦点，就不会导致底部导航栏显示出来
 */
class ZegoDialog internal constructor(builder: Builder) : Dialog(builder.mContext) {

    private lateinit var dialogView: ViewGroup

    init {
        setCancelable(builder.mCancelable)
        if (builder.mCancelable) {
            setCanceledOnTouchOutside(true)
        }
        setOnCancelListener(builder.mOnCancelListener)
        setOnDismissListener(builder.mOnDismissListener)
    }

    val title: CharSequence? = builder.mTitle
    val message: CharSequence? = builder.mMessage
    val positiveButtonText: CharSequence? = builder.mPositiveButtonText
    val positiveButtonBackground: Int = builder.mPositiveButtonBackground
    val positiveButtonTextColor: Int = builder.mPositiveButtonTextColor
    val positiveButtonListener: DialogInterface.OnClickListener? = builder.mPositiveButtonListener
    val negativeButtonText: CharSequence? = builder.mNegativeButtonText
    val negativeButtonBackground: Int = builder.mNegativeButtonBackground
    val negativeButtonTextColor: Int = builder.mNegativeButtonTextColor
    val negativeButtonListener: DialogInterface.OnClickListener? = builder.mNegativeButtonListener
    val maxDialogWidth: Int = builder.mMaxDialogWidth
    val buttonWidth: Int = builder.mButtonWidth

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        dialogView =
            LayoutInflater.from(context).inflate(R.layout.dialog_layout, null, false) as ViewGroup

        dialogView.findViewById<TextView>(R.id.dialog_title).let {
            if (title.isNullOrEmpty()) {
                it.visibility = View.GONE
            } else {
                it.text = title
            }
        }

        dialogView.findViewById<TextView>(R.id.dialog_message).let {
            if (message.isNullOrEmpty()) {
                it.visibility = View.GONE
            } else {
                it.text = message
            }
        }

        dialogView.findViewById<TextView>(R.id.dialog_confirm).let {
            if (positiveButtonText.isNullOrEmpty()) {
                it.visibility = View.GONE
            } else {
                it.text = positiveButtonText
                it.setOnClickListener {
                    positiveButtonListener?.onClick(this, BUTTON_POSITIVE)
                }
            }
            if (positiveButtonTextColor != 0) {
                it.setTextColor(positiveButtonTextColor)
            }
            if (positiveButtonBackground != 0) {
                it.setBackgroundResource(positiveButtonBackground)
            }
            if (buttonWidth != 0) {
//                it.width = buttonWidth
                it.layoutParams.width =  dp2px(context, buttonWidth.toFloat()).toInt()
            }
        }

        dialogView.findViewById<TextView>(R.id.dialog_cancel).let {
            if (negativeButtonText.isNullOrEmpty()) {
                it.visibility = View.GONE
            } else {
                it.text = negativeButtonText
                it.setOnClickListener {
                    negativeButtonListener?.onClick(this, BUTTON_NEGATIVE)
                }
            }
            if (negativeButtonTextColor != 0) {
                it.setTextColor(negativeButtonTextColor)
            }
            if (negativeButtonBackground != 0) {
                it.setBackgroundResource(negativeButtonBackground)
            }
            if (buttonWidth != 0) {
                it.layoutParams.width =  dp2px(context, buttonWidth.toFloat()).toInt()
//                it.width = buttonWidth
            }
        }

        if (maxDialogWidth == 0) {
            setContentView(dialogView)
        } else {
            setContentView(
                dialogView, ViewGroup.LayoutParams(
                    dp2px(context, maxDialogWidth.toFloat()).toInt(),
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )
            )
        }

        val FULL_SCREEN_FLAG = View.SYSTEM_UI_FLAG_LAYOUT_STABLE
            .or(View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)
            .or(View.SYSTEM_UI_FLAG_HIDE_NAVIGATION)
            .or(View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY)
            .or(View.SYSTEM_UI_FLAG_FULLSCREEN)
        window!!.decorView.systemUiVisibility = FULL_SCREEN_FLAG

        dialogView.measure(
            View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
            View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
        )

        window!!.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
    }

    override fun show() {
        window!!.addFlags(WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE)
        super.show()
        window!!.clearFlags(WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE)
    }

    fun showWithLengthLimit() {
        show()
    }

    class Builder(val mContext: Context) {
        var mTitle: CharSequence? = null
            private set
        var mMessage: CharSequence? = null
            private set
        var mPositiveButtonText: CharSequence? = null
            private set
        var mPositiveButtonBackground: Int = 0
            private set
        var mPositiveButtonTextColor: Int = 0
            private set
        var mPositiveButtonListener: DialogInterface.OnClickListener? = null
            private set
        var mNegativeButtonText: CharSequence? = null
            private set
        var mNegativeButtonTextColor: Int = 0
            private set
        var mNegativeButtonBackground: Int = 0
            private set
        var mNegativeButtonListener: DialogInterface.OnClickListener? = null
            private set
        var mCancelable = true
            private set
        var mMaxDialogWidth = 0
            private set
        var mButtonWidth = 0
            private set
        var mOnCancelListener: DialogInterface.OnCancelListener? = null
            private set
        var mOnDismissListener: DialogInterface.OnDismissListener? = null
            private set

        fun setTitle(@StringRes titleId: Int): Builder {
            mTitle = mContext.getString(titleId)
            return this
        }

        fun setTitle(title: CharSequence): Builder {
            mTitle = title
            return this
        }

        fun setMessage(@StringRes messageId: Int): Builder {
            mMessage = mContext.getString(messageId)
            return this
        }

        fun setMessage(message: CharSequence): Builder {
            mMessage = message
            return this
        }

        fun setCancelable(cancelable: Boolean): Builder {
            mCancelable = cancelable
            return this
        }

        fun setPositiveButton(
            @StringRes textId: Int,
            listener: DialogInterface.OnClickListener?
        ): Builder {
            mPositiveButtonText = mContext.getText(textId)
            mPositiveButtonListener = listener
            return this
        }

        fun setPositiveButton(
            text: CharSequence?,
            listener: DialogInterface.OnClickListener?
        ): Builder {
            mPositiveButtonText = text
            mPositiveButtonListener = listener
            return this
        }

        fun setPositiveButtonBackground(@DrawableRes drawableId: Int): Builder {
            mPositiveButtonBackground = drawableId
            return this
        }

        fun setPositiveButtonTextColor(@ColorRes colorInt: Int): Builder {
            mNegativeButtonTextColor = if (Build.VERSION.SDK_INT >= 23) {
                mContext.getColor(colorInt)
            } else {
                mContext.resources.getColor(colorInt)
            }
            return this
        }

        fun setNegativeButton(
            @StringRes textId: Int,
            listener: DialogInterface.OnClickListener?
        ): Builder {
            mNegativeButtonText = mContext.getText(textId)
            mNegativeButtonListener = listener
            return this
        }

        fun setNegativeButton(
            text: CharSequence?,
            listener: DialogInterface.OnClickListener?
        ): Builder {
            mNegativeButtonText = text
            mNegativeButtonListener = listener
            return this
        }

        fun setNegativeButtonBackground(@DrawableRes drawableId: Int): Builder {
            mNegativeButtonBackground = drawableId
            return this
        }

        fun setNegativeButtonTextColor(@ColorRes colorInt: Int): Builder {
            mNegativeButtonTextColor = if (Build.VERSION.SDK_INT >= 23) {
                mContext.getColor(colorInt)
            } else {
                mContext.resources.getColor(colorInt)
            }
            return this
        }

        fun setButtonWidth(widthInDp: Int): Builder {
            mButtonWidth = widthInDp
            return this
        }

        fun setOnCancelListener(onCancelListener: DialogInterface.OnCancelListener?): Builder {
            mOnCancelListener = onCancelListener
            return this
        }

        fun setOnDismissListener(onDismissListener: DialogInterface.OnDismissListener?): Builder {
            mOnDismissListener = onDismissListener
            return this
        }

        fun setMaxDialogWidth(widthInDp: Int): Builder {
            mMaxDialogWidth = widthInDp
            return this
        }

        fun create(): ZegoDialog {
            return ZegoDialog(this)
        }

        fun show(): ZegoDialog {
            return create().also {
                it.show()
            }
        }
    }
}