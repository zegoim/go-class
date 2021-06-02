package im.zego.goclass.activities

import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import im.zego.goclass.AppLanguage
import im.zego.goclass.BuildConfig
import im.zego.goclass.DemoApplication
import im.zego.goclass.R
import im.zego.goclass.sdk.ZegoSDKManager
import im.zego.goclass.tool.SharedPreferencesUtil
import im.zego.goclass.tool.SharedPreferencesUtil.Companion.getLastAppLanguageSetting
import im.zego.goclass.widget.SelectLanguagePopWindow
import im.zego.zegodocs.ZegoDocsViewManager
import im.zego.zegowhiteboard.ZegoWhiteboardManager
import kotlinx.android.synthetic.main.activity_setting.*
import java.text.SimpleDateFormat
import java.util.*


/**
 * 设置界面
 */
class SettingActivity : BaseActivity() {

    private val PRODUCT_NAME: String = "goclass"
    private var FEEDBACK_ROOT_URL: String = ""
    private var FEEDBACK_PATH: String = "feedback/$PRODUCT_NAME/index.html"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_setting)

        FEEDBACK_ROOT_URL = if (SharedPreferencesUtil.isVideoSDKTestEnv()) {
            "http://192.168.100.62:4001/$FEEDBACK_PATH"
        } else {
            "https://demo-operation.zego.im/$FEEDBACK_PATH"
        }

        initView()
    }

    private fun initView() {
        // 返回上一页
        setting_back.setOnClickListener {
            onBackPressed()
        }
        when (getLastAppLanguageSetting()) {
            Locale.ENGLISH.language -> tv_language.text = "English"
            else -> tv_language.text = "简体中文"
        }
        // 语言
        setting_language.setOnClickListener {
            val selectLanguagePopWindow =
                SelectLanguagePopWindow(this, tv_language.text.toString())
                    .also {
                        it.setOnConfirmClickListener { str ->
                            tv_language.text = str
                            if (str == "English") {
                                AppLanguage.setCurrentLanguageLocale(Locale.ENGLISH)
                            } else {
                                AppLanguage.setCurrentLanguageLocale(Locale.CHINESE)
                            }
                        }
                    }
            selectLanguagePopWindow.show(setting_language)
        }
        // 清除缓存
        tv_clear_cache.text =
            (ZegoSDKManager.getInstance().calculateCacheSize() / 1024).toString() + "KB"
        setting_clear_cache.setOnClickListener {
            ZegoSDKManager.getInstance().clearDocsViewCache()
            tv_clear_cache.text =
                (ZegoSDKManager.getInstance().calculateCacheSize() / 1024).toString() + "KB"
        }
        setting_feedback.setOnClickListener {
            WebViewActivity.start(this, generateFeedbackUrl())
        }
        // 设置版本号
        val version = BuildConfig.VERSION_NAME
        app_version.text = "v$version"
        video_version.text = ZegoSDKManager.getInstance().rtcSDKName()

    }

    /**
     * http://demo-feedback.zego.im/feedback/goclass/index.html?
     * platform=xx
     * &system_version=xx
     * &app_version=xx
     * &sdk_version=xx
     * &device_id=xx
     */
    private fun generateFeedbackUrl(): String {
        val builder: Uri.Builder = Uri.parse(FEEDBACK_ROOT_URL).buildUpon()
        builder.appendQueryParameter("platform", "8")
        builder.appendQueryParameter("system_version", "android_" + Build.VERSION.RELEASE)
        builder.appendQueryParameter("app_version", BuildConfig.VERSION_NAME)
        builder.appendQueryParameter("client", Build.MODEL)
        builder.appendQueryParameter("sdk_version", getSDKVersion())
        val androidId = getAndroidId(this)
        if (androidId != null) {
            builder.appendQueryParameter("device_id", androidId)
        }
        builder.appendQueryParameter("log_filename", getLogFileName())
        return builder.build().toString()
    }

    /**
     * yyyymmddhhmmss_平台_demo名_demo版本_uid.zip
     */
    private fun getLogFileName(): String {
        val time = SimpleDateFormat("yyyyMMddHHmmss").format(Date())
        return "${time}_${PRODUCT_NAME}_${BuildConfig.VERSION_NAME}_${UUID.randomUUID()}.zip"
    }

    private fun getSDKVersion(): String {
        val splitter = "_"
        val sb = StringBuilder()
        val roomSDKMessage = ZegoSDKManager.getInstance().roomSDKMessage()
        sb.append("(rtc=$roomSDKMessage)")
        sb.append(splitter)
        sb.append("(docs=${ZegoDocsViewManager.getInstance().version})")
        sb.append(splitter)
        sb.append("(whiteboard=${ZegoWhiteboardManager.getInstance().version})")
        return sb.toString()
    }

    /**
     * 获取ANDROID_ID
     *
     * @param context
     * @return
     */
    private fun getAndroidId(context: Context): String? {
        return Settings.System.getString(context.contentResolver, Settings.Secure.ANDROID_ID)
    }

}
