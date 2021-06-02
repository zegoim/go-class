package im.zego.goclass.activities

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.KeyEvent
import android.view.View
import android.webkit.JavascriptInterface
import androidx.appcompat.app.AppCompatActivity
import im.zego.goclass.R
import im.zego.goclass.sdk.ZegoSDKManager
import im.zego.goclass.tool.Logger
import im.zego.goclass.widget.CommonWebView
import kotlinx.android.synthetic.main.activity_webview.*

class WebViewActivity : AppCompatActivity() {
    companion object {
        const val TAG = "WebViewActivity"
        const val KEY_URL = "url"

        @JvmStatic
        fun start(context: Context, url: String) {
            val intent = Intent(context, WebViewActivity::class.java)
            intent.putExtra(KEY_URL, url)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)
        }
    }

    private var mUrl: String? = null

    override fun onDestroy() {
        super.onDestroy()
        mWebView.destroy()
    }

    override fun onPause() {
        super.onPause()
        mWebView.onPause()
    }

    override fun onResume() {
        super.onResume()
        mWebView.onResume()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_webview)

        mBackIv.setOnClickListener {
            if (mWebView.canGoBack()) {
                mWebView.goBack()
            }
            finish()
        }

        mWebView.registerJavascriptInterface(JsCallback(), "feedback")
        mWebView.setListener(object : CommonWebView.ICommonWebViewListener {
            override fun onProgressChanged(newProgress: Int) {
                if (newProgress == 100) {
                    mProgressBar.progress = 100
                    mProgressBar.visibility = View.GONE
                } else {
                    mProgressBar.visibility = View.VISIBLE
                    mProgressBar.progress = newProgress
                }
            }

            override fun onReceivedTitle(title: String?) {
                if (title != null) {
                    if (title.length > 17) {
                        mTitleTv.text = title.subSequence(0, 15).toString() + "..."
                    } else {
                        mTitleTv.text = title
                    }
                }
            }
        })

        parseUrl()
    }

    private fun parseUrl() {
        mUrl = intent.getStringExtra(KEY_URL)
        if (mUrl == null) {
            return
        }

        Logger.i(TAG, "loadUrl=$mUrl")
        mWebView.loadUrl(mUrl)
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_BACK && mWebView.canGoBack()) {
            mWebView.goBack()
            return true
        }

        return super.onKeyDown(keyCode, event)
    }

    inner class JsCallback {
        @JavascriptInterface
        fun uploadLog() {
            Logger.i(TAG, "JsCallback - uploadLog")
            ZegoSDKManager.getInstance().uploadLog()
        }

        @JavascriptInterface
        fun callback(result: String) {
            Logger.i(TAG, "JsCallback - callback:$result")
        }
    }
}
