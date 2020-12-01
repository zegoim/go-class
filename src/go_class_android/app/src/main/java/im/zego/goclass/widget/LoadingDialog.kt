package im.zego.goclass.widget

import android.app.Dialog
import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ProgressBar
import android.widget.TextView
import androidx.annotation.StringRes
import im.zego.goclass.R

class LoadingDialog(context: Context, dimBackground: Float) : Dialog(context) {
    private var content: TextView

    init {
        val view: View = LayoutInflater.from(context).inflate(R.layout.dialog_loading_layout, null)
        val progressBar = view.findViewById<ProgressBar>(R.id.progress)
        content = view.findViewById(R.id.content)
        progressBar.visibility = View.VISIBLE
        setCanceledOnTouchOutside(false)
        setCancelable(false)
        setContentView(view)

        window!!.setDimAmount(dimBackground)
    }

    fun updateText(text: String) {
        content.text = text
        if (text.isEmpty()) {
            content.visibility = View.GONE
        } else {
            content.visibility = View.VISIBLE
        }
    }

    fun updateText(@StringRes text: Int) {
        content.setText(text)
        if (content.text.isEmpty()) {
            content.visibility = View.GONE
        } else {
            content.visibility = View.VISIBLE
        }
    }
}