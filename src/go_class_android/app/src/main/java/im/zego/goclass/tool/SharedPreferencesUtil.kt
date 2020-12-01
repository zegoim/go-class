package im.zego.goclass.tool

import android.content.Context
import android.content.SharedPreferences
import im.zego.goclass.AuthConstants

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
        fun setTestEnv(isTestEnv: Boolean) {
            val sharedPreferences = getSharedPreferences(env)
            sharedPreferences.edit().putBoolean("isTestEnv", isTestEnv).apply()
        }

        @JvmStatic
        fun getTestEnv(): Boolean {
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.getBoolean("isTestEnv", true)
        }

        @JvmStatic
        fun setAppID(appID: Long) {
            val sharedPreferences = getSharedPreferences(env)
            sharedPreferences.edit().putLong("appID", appID).apply()
        }

        @JvmStatic
        fun getAppID(): Long {
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.getLong("appID", AuthConstants.APP_ID)
        }

        @JvmStatic
        fun setAppSign(appSign: String) {
            val sharedPreferences = getSharedPreferences(env)
            sharedPreferences.edit().putString("appSign", appSign).apply()
        }

        @JvmStatic
        fun removeAppSign() {
            val sharedPreferences = getSharedPreferences(env)
            sharedPreferences.edit().remove("appSign").apply()
        }

        @JvmStatic
        fun getAppSign(): String {
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.getString("appSign", AuthConstants.APP_SIGN)!!
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
        fun containsGoClassTestEnvSp(): Boolean {
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.contains("go_class_env")
        }

        @JvmStatic
        fun setGoClassTestEnv(isTestEnv: Boolean) {
            val sharedPreferences = getSharedPreferences(env)
            sharedPreferences.edit().putBoolean("go_class_env", isTestEnv).apply()
        }

        @JvmStatic
        fun isGoClassTestEnv(): Boolean {
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.getBoolean("go_class_env", false)
        }

        @JvmStatic
        fun containsVideoSDKTestEnvSp(): Boolean {
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.contains("video_env")
        }

        @JvmStatic
        fun setVideoSDKTestEnv(isTestEnv: Boolean) {
            val sharedPreferences = getSharedPreferences(env)
            sharedPreferences.edit().putBoolean("video_env", isTestEnv).apply()
        }

        @JvmStatic
        fun isVideoSDKTestEnv(): Boolean {
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.getBoolean("video_env", false)
        }

        @JvmStatic
        fun containsDocsViewTestEnvSp(): Boolean {
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.contains("docs_view_env")
        }

        @JvmStatic
        fun setDocsViewTestEnv(isTestEnv: Boolean) {
            val sharedPreferences = getSharedPreferences(env)
            sharedPreferences.edit().putBoolean("docs_view_env", isTestEnv).apply()
        }

        @JvmStatic
        fun isDocsViewTestEnv(): Boolean {
            val sharedPreferences = getSharedPreferences(env)
            return sharedPreferences.getBoolean("docs_view_env", false)
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