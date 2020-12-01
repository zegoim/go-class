package im.zego.goclass.widget

import android.content.Context
import android.graphics.Point
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.*
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.TextView
import android.widget.TextView.BufferType
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.FragmentManager
import im.zego.goclass.tool.ToastUtils
import im.zego.goclass.R

/**
 * 用于讨论列表的输入对话框
 */
const val MAX_LENGTH = 100
class InputDialog : DialogFragment() {

    var sendListener: (String) -> Unit = {}

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        dialog?.let {
            it.window?.apply {
                attributes.gravity = getGravity()
                val mode = WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE or
                        WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING
                setSoftInputMode(mode)
            }
        }
        return inflater.inflate(R.layout.layout_softinput, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val inputEditText = view.findViewById<EditText>(R.id.softinput_edittext)
        requestInputWindow(inputEditText)
        inputEditText.isSaveFromParentEnabled = false
        inputEditText.addTextChangedListener(MaxLengthWatcher(MAX_LENGTH, inputEditText))
        view.findViewById<TextView>(R.id.input_send).setOnClickListener {
            dismiss()
            if (inputEditText.text.toString().isNotEmpty()) {
                sendListener.invoke(inputEditText.text.toString())
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        view?.let {
            hideInputWindow(it)
        }
    }

    private fun getGravity() = Gravity.BOTTOM

    private fun getDialogSize(): Point {
        return Point(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT
        )
    }

    private fun hideInputWindow(view: View) {
        val imm = view.context
            .getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        val result = imm.hideSoftInputFromWindow(view.windowToken, 0)
    }

    private fun requestInputWindow(view: View) {
        val result = view.requestFocus()
        val imm = view.context
            .getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        var input = false
        if (view.isAttachedToWindow) {
            input = imm.showSoftInput(view, 0)
        }
    }

    // isadd 和 isShowing 判断显示都有问题
    private var showedBySelf = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setStyle(STYLE_NO_TITLE, getDialogStyle())
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        dialog?.apply {
            setCanceledOnTouchOutside(canceledOnTouchOutside())
            setCancelable(cancelable())
        }
    }

    override fun onStart() {
        super.onStart()
        dialog?.apply {
            window?.let {
                val dialogSize: Point = getDialogSize()
                it.setLayout(dialogSize.x, dialogSize.y)
                it.setDimAmount(backgroundDimAmount())
            }
        }
    }

    override fun show(
        manager: FragmentManager,
        tag: String?
    ) {
        if (isAdded) {
            return
        }
        showedBySelf = true
        try {
            super.show(manager, tag)
        } catch (e: Exception) {
            val ft = manager.beginTransaction()
            ft.add(this, tag)
            ft.commitAllowingStateLoss()
        }
    }

    override fun dismiss() {
        if (showedBySelf) {
            dismissAllowingStateLoss()
        }
    }

    private fun canceledOnTouchOutside(): Boolean {
        return true
    }

    private fun cancelable(): Boolean {
        return true
    }

    private fun backgroundDimAmount(): Float {
        return 0.15f
    }

    /**
     * @return 需要特别的动画可以在这里设置style
     */
    private fun getDialogStyle(): Int {
        return R.style.DialogFragmentStyle
    }
}

class MaxLengthWatcher(private var maxLength:Int, var editText: EditText) : TextWatcher {

    override fun afterTextChanged(s: Editable?) {
    }

    override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
    }

    override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
        s?.let {
            val toString = it.toString()
            if (toString.length > maxLength) {
                ToastUtils.showCenterToast("最多输入${maxLength}字符")
                val subSequence = toString.subSequence(0, maxLength)
                editText.setText(subSequence, BufferType.EDITABLE)
                editText.setSelection(subSequence.length)
            }
        }
    }
}
