package im.zego.goclass.activities

import android.os.Bundle
import android.os.PersistableBundle
import androidx.appcompat.app.AppCompatActivity
import im.zego.goclass.tool.SharedPreferencesUtil
import im.zego.goclass.tool.ZegoUtil

open class BaseActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
        // 如果 app 后台被系统杀掉了，则重启
        if (SharedPreferencesUtil.getProcessID() != android.os.Process.myPid()) {
            ZegoUtil.killSelfAndRestart(this, JoinActivity::class.java)
        }
    }
}