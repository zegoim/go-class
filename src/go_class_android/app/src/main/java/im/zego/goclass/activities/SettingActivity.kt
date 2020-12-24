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
