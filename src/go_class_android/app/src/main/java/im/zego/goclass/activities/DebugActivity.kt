package im.zego.goclass.activities

import android.content.Intent
import android.os.Bundle
import android.text.Editable
import androidx.appcompat.app.AppCompatActivity
import androidx.preference.Preference
import androidx.preference.PreferenceFragmentCompat
import androidx.preference.SwitchPreferenceCompat
import im.zego.goclass.sdk.ZegoSDKManager
import im.zego.goclass.tool.SharedPreferencesUtil
import im.zego.goclass.tool.SimpleTextWatcher
import im.zego.goclass.tool.ToastUtils
import im.zego.goclass.tool.ZegoUtil
import im.zego.zegodocs.ZegoDocsViewManager
import im.zego.zegowhiteboard.ZegoWhiteboardManager
import im.zego.goclass.BuildConfig
import im.zego.goclass.R
import kotlinx.android.synthetic.main.activity_join.*
import kotlinx.android.synthetic.main.debug_activity.*

/**
 * Debug 页面，长按登陆页面接入环境进入该页面
 */
class DebugActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.debug_activity)

        if (savedInstanceState == null) {
            supportFragmentManager
                .beginTransaction()
                .replace(R.id.settings, SettingsFragment())
                .commit()
        }

        initData()
        initView()
    }

    private fun initData() {
        supportActionBar?.setDisplayHomeAsUpEnabled(true)

        var roomSDKMessage = ZegoSDKManager.getInstance().roomSDKMessage()
        roomSDKMessage = if (roomSDKMessage.length > 22) roomSDKMessage.substring(0, 22) else roomSDKMessage

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
        // 保存 （会重启）
        setting_save.setOnClickListener {
            val time = 2
            setting_save.postDelayed({
                ZegoUtil.killSelfAndRestart(this, JoinActivity::class.java)
            }, time * 1000L)
            ToastUtils.showCenterToast("${time}秒后重启应用")
        }
        // 上传文件
        upload.setOnClickListener {
            startActivity(Intent(this, UploadActivity::class.java))
        }
        // 设置文本框默认值
        text_default.setText(ZegoWhiteboardManager.getInstance().customText)
        text_default.addTextChangedListener(object : SimpleTextWatcher() {
            override fun afterTextChanged(s: Editable) {
                ZegoWhiteboardManager.getInstance().customText = s.toString()
            }
        })
    }

    class SettingsFragment : PreferenceFragmentCompat() {
        override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
            preferenceManager.sharedPreferencesName = SharedPreferencesUtil.env
            setPreferencesFromResource(R.xml.root_preferences, rootKey)
            findPreference<SwitchPreferenceCompat>("go_class_env")?.onPreferenceChangeListener =
                Preference.OnPreferenceChangeListener { preference, newValue ->
                    true
                }
            findPreference<SwitchPreferenceCompat>("live_room_env")?.onPreferenceChangeListener =
                Preference.OnPreferenceChangeListener { preference, newValue ->
                    true
                }
            findPreference<SwitchPreferenceCompat>("docs_view_env")?.onPreferenceChangeListener =
                Preference.OnPreferenceChangeListener { preference, newValue ->
                    true
                }
            findPreference<SwitchPreferenceCompat>("next_step_flip_page")?.onPreferenceChangeListener =
                Preference.OnPreferenceChangeListener { preference, newValue ->
                    true
                }
        }
    }

}