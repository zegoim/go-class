package im.zego.goclass

import android.content.Context
import android.os.Build
import android.os.LocaleList
import androidx.annotation.StringRes
import im.zego.goclass.tool.Logger
import im.zego.goclass.tool.SharedPreferencesUtil
import java.util.*

object AppLanguage {

    private lateinit var appContext: Context
    private var currentLocale: Locale = Locale.SIMPLIFIED_CHINESE

    @JvmStatic
    fun initLanguageSetting(context: Context) {
        appContext = context
        initLanguageSetting()
    }

    @JvmStatic
    fun getCurrentLanguageLocale() = currentLocale

    fun setCurrentLanguageLocale(context: Context, locale: Locale) {
        currentLocale = locale
        SharedPreferencesUtil.setLastAppLanguageSetting(locale.toLanguageTag()) // languageTag 能区分中文 zh 和繁体中文 zh-tw
    }

    fun createLanguageContext(context: Context): Context {
        val resources = context.resources
        val configuration = resources.configuration

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) { // apply locale
            configuration.setLocale(getCurrentLanguageLocale())
        } else { // updateConfiguration
            configuration.locale = getCurrentLanguageLocale()
            resources.updateConfiguration(configuration, resources.displayMetrics)
        }
        return context.createConfigurationContext(configuration)
    }

    private fun initLanguageSetting() {
        currentLocale = if (SharedPreferencesUtil.hasLastAppLanguageSetting()) {
            val lastLanguage = SharedPreferencesUtil.getLastAppLanguageSetting()
            val langStr = lastLanguage.split('-')

            if (langStr.size > 1) {
                Locale(langStr[0], langStr[1])
            } else {
                Locale(langStr[0])
            }
        } else {
            Logger.i("AppLanguage", "system locale: " + getSystemPreferredLanguageLocale())
            when (getSystemPreferredLanguageLocale().language) {
                Locale.ENGLISH.language -> Locale.ENGLISH
                else -> Locale.CHINESE
            }
        }
        Logger.i("AppLanguage", "initLanguageSetting,currentLocale: $currentLocale")
    }

    private fun getSystemPreferredLanguageLocale(): Locale = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) LocaleList.getDefault()[0] else Locale.getDefault()

    /**
     * 返回传入的参数
     * @param context
     * @param res
     * @return
     */
    @StringRes
    fun transferToSceneString(context: Context, @StringRes res: Int): Int {
        val resourceName = context.resources.getResourceEntryName(res)
        var stringId = context.resources.getIdentifier(resourceName, "string", context.packageName)
        stringId = if (stringId == 0) res else stringId
        return stringId
    }
}