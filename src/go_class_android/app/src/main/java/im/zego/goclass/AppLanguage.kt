package im.zego.goclass

import android.content.Context
import android.content.res.Configuration
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
        appContext = context.applicationContext

        currentLocale = if (SharedPreferencesUtil.hasLastAppLanguageSetting()) {
            val lastLanguage = SharedPreferencesUtil.getLastAppLanguageSetting()
            val langStr = lastLanguage.split('-')

            if (langStr.size > 1) {
                Locale(langStr[0], langStr[1])
            } else {
                Locale(langStr[0])
            }
        } else {
            val locale =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
                    LocaleList.getDefault()[0]
                else
                    Locale.getDefault()

            when (locale.language) {
                Locale.CHINESE.language -> Locale.CHINESE
                Locale.TRADITIONAL_CHINESE.language -> Locale.TRADITIONAL_CHINESE
                Locale.ENGLISH.language -> Locale.ENGLISH
                Locale.JAPANESE.language -> Locale.JAPANESE
                Locale.KOREAN.language -> Locale.KOREAN
                else -> Locale.CHINESE
            }
        }
        Logger.i("AppLanguage", "initLanguageSetting,currentLocale: $currentLocale")
    }

    @JvmStatic
    fun getCurrentLanguageLocale() = currentLocale

    @JvmStatic
    fun setCurrentLanguageLocale(locale: Locale) {
        currentLocale = locale
        SharedPreferencesUtil.setLastAppLanguageSetting(locale.toLanguageTag()) // languageTag 能区分中文 zh 和繁体中文 zh-tw
    }
}