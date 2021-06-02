package im.zego.goclass.widget

import android.annotation.SuppressLint
import android.content.Context
import android.util.AttributeSet
import android.webkit.WebChromeClient
import android.webkit.WebSettings
import android.webkit.WebView

/**
 * Created by rocket_wang on 2021/5/27.
 */
class CommonWebView : WebView {
    constructor(context: Context) : this(context, null)
    constructor(context: Context, attrs: AttributeSet?) : this(context, attrs, 0)
    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    ) {
        initWebViewSettings()
    }

    private var listener: ICommonWebViewListener? = null

    private fun initWebViewSettings() {
        // 支持JavaScript交互
        settings.javaScriptEnabled = true

        // 设置自适应屏幕
        settings.useWideViewPort = true
        settings.loadWithOverviewMode = true

        // 缩放操作
        settings.setSupportZoom(true) //支持缩放，默认为true。是下面那个的前提。
        settings.builtInZoomControls = true //设置内置的缩放控件。若为false，则该WebView不可缩放
        settings.displayZoomControls = false //隐藏原生的缩放控件

        //其他细节操作

        settings.allowFileAccess = true //设置可以访问文件
        settings.javaScriptCanOpenWindowsAutomatically = true //支持通过JS打开新窗口
        settings.loadsImagesAutomatically = true //支持自动加载图片
        settings.defaultTextEncodingName = "utf-8" //设置编码格式
        /**
         *
        缓存模式如下：
        webSettings.cacheMode = WebSettings.LOAD_CACHE_ELSE_NETWORK //关闭webview中缓存
            //LOAD_CACHE_ONLY: 不使用网络，只读取本地缓存数据
            //LOAD_DEFAULT: （默认）根据cache-control决定是否从网络上取数据。
            //LOAD_NO_CACHE: 不使用缓存，只从网络获取数据.
            //LOAD_CACHE_ELSE_NETWORK，只要本地有，无论是否过期，或者no-cache，都使用缓存中的数据

        //不使用缓存
        webSettings.cacheMode = WebSettings.LOAD_NO_CACHE
         */
        settings.cacheMode = WebSettings.LOAD_DEFAULT

        // 设置webViewClient
//        webViewClient = mWebViewClient

        // 设置webChromeClient
        webChromeClient = mWebChromeClient
    }

    private val mWebChromeClient = object : WebChromeClient() {

        override fun onProgressChanged(view: WebView?, newProgress: Int) {
            listener?.onProgressChanged(newProgress)
        }

        override fun onReceivedTitle(view: WebView?, title: String?) {
            listener?.onReceivedTitle(title)
        }
    }

    @SuppressLint("JavascriptInterface")
    fun registerJavascriptInterface(obj: Any, interfaceName: String) {
        this.addJavascriptInterface(obj, interfaceName)
    }

    fun setListener(listener: ICommonWebViewListener) {
        this.listener = listener
    }

    interface ICommonWebViewListener {
        fun onProgressChanged(newProgress: Int)
        fun onReceivedTitle(title: String?)
    }
}