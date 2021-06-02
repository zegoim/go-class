package im.zego.goclass.activities

import android.content.Context
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import android.os.LocaleList
import android.os.PersistableBundle
import androidx.appcompat.app.AppCompatActivity
import im.zego.goclass.AppLanguage.getCurrentLanguageLocale
import im.zego.goclass.tool.SharedPreferencesUtil
import im.zego.goclass.tool.ZegoUtil
import java.util.*

/**
 * base类，主要是处理 语言动态切换相关的事情
 */
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
        }
    }


    override fun attachBaseContext(newBase: Context) {
        val currentLanguageLocale = getCurrentLanguageLocale()
        // fix appcompat 1.2.0 bug,create new configuration
        val configuration = Configuration(newBase.resources.configuration)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) { // apply locale
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                val localeList = LocaleList(currentLanguageLocale)
                LocaleList.setDefault(localeList)
                configuration.setLocales(localeList)
            } else {
                configuration.setLocale(currentLanguageLocale)
            }
            val newContext = newBase.createConfigurationContext(configuration)
            super.attachBaseContext(newContext)
        } else {
            configuration.locale = currentLanguageLocale
            val displayMetrics = newBase.resources.displayMetrics
            newBase.resources.updateConfiguration(configuration, displayMetrics)
            super.attachBaseContext(newBase)
        }

        mLocale = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            configuration.locales.get(0)
        } else {
            configuration.locale
        }
    }
}
