package im.zego.goclass.debug

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.preference.Preference
import androidx.preference.PreferenceFragmentCompat
import androidx.preference.SwitchPreferenceCompat
import im.zego.goclass.R
import im.zego.goclass.activities.JoinActivity
import im.zego.goclass.tool.SharedPreferencesUtil
import im.zego.goclass.tool.ToastUtils
import im.zego.goclass.tool.ZegoUtil
import kotlinx.android.synthetic.main.activity_app_env.*

class AppEnvActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_app_env)

        supportFragmentManager
            .beginTransaction()
            .replace(R.id.fragment_container_view, SettingsFragment())
            .commit()

        // 保存 （会重启）
        setting_save.setOnClickListener {
            val time = 2
            setting_save.postDelayed({
                ZegoUtil.killSelfAndRestart(this, JoinActivity::class.java)
            }, time * 1000L)
            ToastUtils.showCenterToast("${time}秒后重启应用")
        }
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