package im.zego.goclass.activities

import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import im.zego.goclass.dp2px
import im.zego.goclass.getRoundRectDrawable
import im.zego.goclass.sdk.ZegoSDKManager
import im.zego.goclass.*
import im.zego.goclass.network.ZegoApiConstants
import im.zego.goclass.tool.SharedPreferencesUtil.Companion.getLastAppLanguageSetting
import im.zego.goclass.tool.ToastUtils
import im.zego.goclass.widget.SelectLanguagePopWindow
import im.zego.zegodocs.ZegoDocsViewManager
import im.zego.zegowhiteboard.ZegoWhiteboardManager
import kotlinx.android.synthetic.main.activity_join.*
import kotlinx.android.synthetic.main.activity_setting.*
import java.util.*

class SettingActivity : BaseActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_setting)

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
        // 设置版本号
        val lastIndexOf = BuildConfig.VERSION_NAME.lastIndexOf(".")
        val version = if (lastIndexOf != -1) {
            BuildConfig.VERSION_NAME.substring(0, lastIndexOf)
        } else {
            BuildConfig.VERSION_NAME
        }
        app_version.text = "App: $version"

        abi.text = BuildConfig.abi_Filters

        var roomSDKMessage = ZegoSDKManager.getInstance().roomSDKMessage()
        roomSDKMessage =
            if (roomSDKMessage.length > 22) roomSDKMessage.substring(0, 22) else roomSDKMessage
        video_version.text = "RTC: $roomSDKMessage"

        docs_version.text = "ZegoDocsView SDK: ${ZegoDocsViewManager.getInstance().version}"
        whiteboard_version.text =
            "ZegoWhiteboardView SDK: ${ZegoWhiteboardManager.getInstance().version}"
    }
}
