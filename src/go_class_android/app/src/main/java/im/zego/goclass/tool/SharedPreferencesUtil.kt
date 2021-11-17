package im.zego.goclass.tool

import android.content.Context
import android.content.SharedPreferences
import im.zego.goclass.AuthConstants
import java.util.*

class SharedPreferencesUtil {
    companion object {
        private lateinit var context: Context
        const val env = "ENV_SETTING"

        fun setApplicationContext(applicationContext: Context) {
            context = applicationContext
        }

        private fun getSharedPreferences(spFileName: String): SharedPreferences {
            return context.getSharedPreferences(spFileName, Context.MODE_PRIVATE)
        }

        @JvmStatic
        fun setLastJoinName(name: String) {
            val sharedPreferences = getSharedPreferences(env)
            sharedPreferences.edit().putString("lastJoinName", name).apply()
        }

        @JvmStatic
        fun getLastJoinName(): String {
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.getString("lastJoinName", "")!!
        }

        @JvmStatic
        fun setLastJoinID(name: String) {
            val sharedPreferences = getSharedPreferences(env)
            sharedPreferences.edit().putString("lastJoinID", name).apply()
        }

        @JvmStatic
        fun getLastJoinID(): String {
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.getString("lastJoinID", "")!!
        }

        @JvmStatic
        fun getProcessID(): Int {
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.getInt("processID", 0)
        }

        @JvmStatic
        fun setProcessID(processID: Int) {
            val sharedPreferences = getSharedPreferences(env)
            sharedPreferences.edit().putInt("processID", processID).apply()
        }

        @JvmStatic
        fun containsNextStepFlipPageSp(): Boolean {
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.contains("next_step_flip_page")
        }

        @JvmStatic
        fun setNextStepFlipPage(isTestEnv: Boolean) {
            val sharedPreferences = getSharedPreferences(env)
            sharedPreferences.edit().putBoolean("next_step_flip_page", isTestEnv).apply()
        }

        @JvmStatic
        fun isNextStepFlipPage():Boolean{
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.getBoolean("next_step_flip_page", true)
        }

        @JvmStatic
        fun setLastAppLanguageSetting(name: String?) {
            val sharedPreferences = getSharedPreferences(env)
            sharedPreferences.edit().putString("language", name).apply()
        }

        @JvmStatic
        fun getLastAppLanguageSetting(): String {
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.getString("language", Locale.CHINA.language).toString()
        }

        @JvmStatic
        fun hasLastAppLanguageSetting(): Boolean {
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.contains("language")
        }

/*        @JvmStatic
        fun containsMainlandEnvSp(): Boolean {
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.contains("mainland_env")
        }

        @JvmStatic
        fun setMainlandEnv(isTestEnv: Boolean) {
            val sharedPreferences = getSharedPreferences(env)
            sharedPreferences.edit().putBoolean("mainland_env", isTestEnv).apply()
        }

        @JvmStatic
        fun isMainlandEnv(): Boolean {
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.getBoolean("mainland_env", false)
        }*/

    }
}