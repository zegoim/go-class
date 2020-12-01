package im.zego.goclass.activities

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import im.zego.goclass.AppConstants
import im.zego.goclass.DemoApplication
import im.zego.goclass.dp2px
import im.zego.goclass.getRoundRectDrawable
import im.zego.goclass.sdk.ZegoSDKManager
import im.zego.goclass.*
import im.zego.goclass.widget.FontFamilyPopWindow
import im.zego.zegowhiteboard.ZegoWhiteboardManager
import kotlinx.android.synthetic.main.activity_setting.*

class SettingActivity : AppCompatActivity() {

    private lateinit var processedAppSign: String

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
        // 清除缓存
        setting_clear_cache.text = getString(
                R.string.clear_cache,
                (ZegoSDKManager.getInstance().calculateCacheSize() / 1024).toString() + "KB"
        )
        setting_clear_cache.background =
                getRoundRectDrawable(
                        "#f4f5f8",
                        dp2px(this, 22f)
                )
        setting_clear_cache.setOnClickListener {
            ZegoSDKManager.getInstance().clearDocsViewCache()
            setting_clear_cache.text = getString(
                    R.string.clear_cache,
                    (ZegoSDKManager.getInstance().calculateCacheSize() / 1024).toString() + "KB"
            )
        }
        // 上传日志
        setting_upload_log.visibility = if (DemoApplication.isFinal()) View.GONE else View.VISIBLE
        setting_upload_log.background =
                getRoundRectDrawable(
                        "#f4f5f8",
                        dp2px(this, 22f)
                )
        setting_upload_log.setOnClickListener {
            ZegoSDKManager.getInstance().uploadLog()
        }
        // 切换系统字体
        setting_font_family.visibility = if (DemoApplication.isFinal()) View.GONE else View.VISIBLE
        setting_font_family.background =
                getRoundRectDrawable(
                        "#f4f5f8",
                        dp2px(this, 22f)
                )
        if (AppConstants.FONT_FAMILY_SELECT_PATH.isEmpty()) {
            setting_font_family.text = getString(R.string.font_system)
        } else {
            setting_font_family.text = getString(R.string.font_sc)
        }
        setting_font_family.setOnClickListener {
            val fontFamilyPopWindow = FontFamilyPopWindow(this).also {
                it.setOnItemClickListener { str ->
                    setting_font_family.text = str
                    if (getString(R.string.font_system).equals(str)) {
                        AppConstants.FONT_FAMILY_SELECT_PATH = ""
                        ZegoWhiteboardManager.getInstance().setCustomFontFromAsset("", "")
                    } else {
                        AppConstants.FONT_FAMILY_SELECT_PATH = AppConstants.FONT_FAMILY_DEFAULT_PATH
                        ZegoWhiteboardManager.getInstance().setCustomFontFromAsset(
                                AppConstants.FONT_FAMILY_DEFAULT_PATH,
                                AppConstants.FONT_FAMILY_DEFAULT_PATH_BOLD
                        )
                    }
                }
            }
            fontFamilyPopWindow.show(setting_font_family)
        }
        // 设置版本号
        val lastIndexOf = BuildConfig.VERSION_NAME.lastIndexOf(".")
        val version = if (lastIndexOf != -1) {
            BuildConfig.VERSION_NAME.substring(0, lastIndexOf)
        } else {
            BuildConfig.VERSION_NAME
        }
        setting_version.text = "v$version"
    }
}
