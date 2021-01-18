package im.zego.goclass.activities

import android.content.Context
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import android.os.PersistableBundle
import androidx.appcompat.app.AppCompatActivity
import im.zego.goclass.AppLanguage.createLanguageContext
import im.zego.goclass.AppLanguage.getCurrentLanguageLocale
import im.zego.goclass.sdk.ZegoSDKManager
import im.zego.goclass.tool.SharedPreferencesUtil
import im.zego.goclass.tool.ZegoUtil
import java.util.*

open class BaseActivity : AppCompatActivity() {

    private var mLocale: Locale? = null

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
        // 如果 app 后台被系统杀掉了，则重启
        if (SharedPreferencesUtil.getProcessID() != android.os.Process.myPid()) {
            ZegoUtil.killSelfAndRestart(this, JoinActivity::class.java)
        }
    }

    override fun onResume() {
        super.onResume()
        val appLocale = getCurrentLanguageLocale()
        if (mLocale!!.language != appLocale.language) {
            mLocale = appLocale
            recreate()
            // 切换语言需要重新初始化
            ZegoSDKManager.getInstance().changeLanguage { _ ->

            }
        }
    }


    override fun attachBaseContext(newBase: Context) {
        val languageContext: Context = createLanguageContext(newBase)
        super.attachBaseContext(languageContext)
        val configuration: Configuration = languageContext.resources.configuration
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            mLocale = configuration.locales.get(0)
        } else {
            mLocale = configuration.locale
        }
    }
}