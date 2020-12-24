package im.zego.goclass.debug

import android.content.Intent
import android.os.Bundle
import android.provider.MediaStore
import android.text.Editable
import android.webkit.MimeTypeMap
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import im.zego.goclass.AppConstants
import im.zego.goclass.BuildConfig
import im.zego.goclass.R
import im.zego.goclass.sdk.ZegoSDKManager
import im.zego.goclass.tool.SimpleTextWatcher
import im.zego.goclass.widget.FontFamilyPopWindow
import im.zego.zegodocs.ZegoDocsViewManager
import im.zego.zegowhiteboard.ZegoWhiteboardManager
import kotlinx.android.synthetic.main.debug_activity.*

/**
 * Debug 页面，长按登陆页面接入环境进入该页面
 */
class DebugActivity : AppCompatActivity() {

    companion object {
        // 默认思源字体路径
        const val FONT_FAMILY_DEFAULT_PATH = "fonts/SourceHanSansSC-Regular.otf"
        const val FONT_FAMILY_DEFAULT_PATH_BOLD = "fonts/SourceHanSansSC-Bold.otf"

        // 当前所选字体路径
        var FONT_FAMILY_SELECT_PATH = "fonts/SourceHanSansSC-Regular.otf"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.debug_activity)
        initData()
        initView()
    }

    private fun initData() {
        supportActionBar?.setDisplayHomeAsUpEnabled(true)

        var roomSDKMessage = ZegoSDKManager.getInstance().roomSDKMessage()
        roomSDKMessage =
            if (roomSDKMessage.length > 22) roomSDKMessage.substring(0, 22) else roomSDKMessage

        video_version.text = "video: $roomSDKMessage"
        app_version.text = "app: ${BuildConfig.VERSION_NAME}"
        docs_version.text = "docs: ${ZegoDocsViewManager.getInstance().version}"
        whiteboard_version.text = "whiteboard: ${ZegoWhiteboardManager.getInstance().version}"
        abi.text = BuildConfig.abi_Filters
    }

    private fun initView() {
        // 返回上一页
        setting_back.setOnClickListener {
            onBackPressed()
        }
        // 上传文件
        upload.setOnClickListener {
            startActivity(Intent(this, UploadFileActivity::class.java))
        }

        set_app_env.setOnClickListener {
            startActivity(Intent(this, AppEnvActivity::class.java))
        }

        // 设置文本框默认值
        text_default.setText(ZegoWhiteboardManager.getInstance().customText)
        text_default.addTextChangedListener(object : SimpleTextWatcher() {
            override fun afterTextChanged(s: Editable) {
                ZegoWhiteboardManager.getInstance().customText = s.toString()
            }
        })

        setting_upload_log.setOnClickListener {
            ZegoSDKManager.getInstance().uploadLog()
        }

        if (FONT_FAMILY_SELECT_PATH.isEmpty()) {
            setting_font_family.text = getString(R.string.font_system)
        } else {
            setting_font_family.text = getString(R.string.font_sc)
        }
        setting_font_family.setOnClickListener {
            val fontFamilyPopWindow = FontFamilyPopWindow(this).also {
                it.setOnItemClickListener { str ->
                    setting_font_family.text = str
                    if (getString(R.string.font_system).equals(str)) {
                        FONT_FAMILY_SELECT_PATH = ""
                        ZegoWhiteboardManager.getInstance().setCustomFontFromAsset("", "")
                    } else {
                        FONT_FAMILY_SELECT_PATH = FONT_FAMILY_DEFAULT_PATH
                        ZegoWhiteboardManager.getInstance().setCustomFontFromAsset(
                            FONT_FAMILY_DEFAULT_PATH,
                            FONT_FAMILY_DEFAULT_PATH_BOLD
                        )
                    }
                }
            }
            fontFamilyPopWindow.show(setting_font_family)
        }

        upload_pics.setOnClickListener {
            startActivity(Intent(this, UploadPicActivity::class.java))
        }
    }
}