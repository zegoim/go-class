package im.zego.goclass.activities

import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.InputFilter
import android.text.Spanned
import android.util.Log
import android.view.View
import im.zego.goclass.*
import im.zego.goclass.classroom.ClassRoomManager
import im.zego.goclass.network.ZegoApiConstants
import im.zego.goclass.sdk.ZegoSDKManager
import im.zego.goclass.tool.*
import im.zego.goclass.widget.LoadingDialog
import im.zego.goclass.widget.SelectRolePopWindow
import im.zego.goclass.widget.SelectRoomTypePopWindow
import kotlinx.android.synthetic.main.activity_join.*
import java.util.regex.Pattern


/**
 * 登陆界面
 */
class JoinActivity : BaseActivity() {
    private val TAG = "JoinActivity"
    private lateinit var loadingDialog: LoadingDialog
    private val nameFilter: InputFilter = object : InputFilter.LengthFilter(50) {
        override fun filter(
            source: CharSequence,
            start: Int,
            end: Int,
            dest: Spanned,
            dstart: Int,
            dend: Int,
        ): CharSequence? {
            var charSequence = super.filter(source, start, end, dest, dstart, dend)
            val regex = "^[\\u4E00-\\u9FA5a-z0-9A-Z_]+$"
            val permit = Pattern.matches(regex, source.toString())
            return if (permit) charSequence else ""
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        StatusBarUtils.immersiveNotificationBar(this)
        setContentView(R.layout.activity_join)

        loadingDialog = LoadingDialog(this, 0.1f)
        initView()
    }


    private fun initView() {
        val radius = dp2px(this, 27.5f)
        val app = application as DemoApplication

        // 房间ID RoomId
        CONFERENCE_ID = SharedPreferencesUtil.getLastJoinID()
        if (DemoApplication.isAlpha()) {
            join_room_id.setText(CONFERENCE_ID)
            join_room_id.setSelection(CONFERENCE_ID.length)
        }
        join_room_id.addTextChangedListener(object : SimpleTextWatcher() {
            override fun afterTextChanged(s: Editable) {
                join_entrance_main.isEnabled = s.isNotBlank() && join_room_name.text.isNotBlank()
            }
        })
        join_room_id.background = getRoundRectDrawable("#f4f5f8", radius)
        // 房间名称 RoomName
        if (DemoApplication.isAlpha()) {
            join_room_name.setText(SharedPreferencesUtil.getLastJoinName())
        }
        join_room_name.filters = arrayOf(nameFilter)
        join_room_name.addTextChangedListener(object : SimpleTextWatcher() {
            override fun afterTextChanged(s: Editable) {
                join_entrance_main.isEnabled = s.isNotBlank() && join_room_id.text.isNotBlank()
            }
        })
        join_room_name.background = getRoundRectDrawable("#f4f5f8", radius)
        // 登陆
        join_entrance_main.isEnabled = join_room_id.text.isNotEmpty() && join_room_name.text.isNotEmpty()
        join_entrance_main.background = ZegoUtil.getJoinBtnDrawable(this)
        join_entrance_main.setOnClickListener {
            val videoInitSuccess = ZegoSDKManager.getInstance().isVideoInitSuccess
            val docsInitSuccess = ZegoSDKManager.getInstance().isDocsInitSuccess
            val whiteboardInitSuccess = ZegoSDKManager.getInstance().isWhiteboardInitSuccess
            if (!videoInitSuccess) {
                ToastUtils.showCenterToast(getString(R.string.join_init_video_failed))
            } else if (!docsInitSuccess) {
                ToastUtils.showCenterToast(getString(R.string.join_init_docs_failed))
            } else if (!whiteboardInitSuccess) {
                ToastUtils.showCenterToast(getString(R.string.join_init_wb_failed))
            } else {
                login()
            }
        }
        // 设置
        join_entrance_setting.setOnClickListener {
            val intent = Intent(this, SettingActivity::class.java)
            startActivity(intent)
        }
        // 班课类型
        join_class_type.background = getRoundRectDrawable("#f4f5f8", radius)
        join_class_type.setOnClickListener {
            val selectRoomTypePopWindow =
                SelectRoomTypePopWindow(this, join_class_type.text.toString())
                    .also {
                        it.setOnConfirmClickListener { str ->
                            // 切换大班课/小班课的同时需要切换 appId 和 appSign
                            ZegoSDKManager.getInstance()
                                .setRoomType((getRoomTypeId(str) == ZegoApiConstants.RoomType.SMALL_CLASS))
                                { success ->
                                    Log.i(TAG, "init:$success")
                                    if (!success) {
                                        ToastUtils.showCenterToast(getString(R.string.wb_tip_switch_failed))
                                    } else {
                                        join_class_type.text = str
                                    }
                                }
                        }
                    }
            selectRoomTypePopWindow.show(join_class_type)
        }
        // 选择角色
        join_role.background = getRoundRectDrawable("#f4f5f8", radius)
        join_role.setOnClickListener {
            val selectRolePopWindow =
                SelectRolePopWindow(this, join_role.text.toString())
                    .also {
                        it.setOnConfirmClickListener { str ->
                            join_role.text = str
                        }
                    }
            selectRolePopWindow.show(join_role)
        }
    }

    /**
     * 对所选角色值做一个 ID 转换
     */
    private fun getRoleId(): Int {
        return when (join_role.text.toString()) {
            getString(R.string.login_teacher) -> ZegoApiConstants.Role.TEACHER
            getString(R.string.login_student) -> ZegoApiConstants.Role.STUDENT
            else -> ZegoApiConstants.Role.TEACHER
        }
    }

    /**
     * 对所选课堂类型值做一个 ID 转换
     */
    private fun getRoomTypeId(roomTypeStr: String): Int {
        return when (roomTypeStr) {
            getString(R.string.login_large_class) -> ZegoApiConstants.RoomType.LARGE_CLASS
            getString(R.string.login_small_class) -> ZegoApiConstants.RoomType.SMALL_CLASS
            else -> ZegoApiConstants.RoomType.SMALL_CLASS
        }
    }

    /**
     * 登陆
     */
    private fun login() {
        showLoadingDialog("")
        ClassRoomManager.login(
            join_room_id.text.toString(),
            join_room_name.text.toString(),
            getRoleId(),
            getRoomTypeId(join_class_type.text.toString())
        )
        { stateCode ->
            Log.i(TAG, "login, stateCode:$stateCode")
            if (stateCode == 0) {
                // 登陆成功后保存 RoomID RoomName，然后跳转到主页
                CONFERENCE_ID = join_room_id.text.toString()
                SharedPreferencesUtil.setLastJoinID(join_room_id.text.toString())
                SharedPreferencesUtil.setLastJoinName(join_room_name.text.toString())
                startActivity(Intent(this, MainActivity::class.java))
            } else {
                ToastUtils.showLoginErrorToast(this, stateCode)
            }
            dismissLoadingDialog()
        }
    }

    /**
     * 选择接入环境（内地/海外）
     */
    fun onRadioButtonClicked(view: View) {
        Log.i(TAG, "view.getId():${view.getId()}")
        ZegoSDKManager.getInstance().setMainLandEnv(
            (view.id == R.id.radio_mainland)
        ) {
            Log.i(TAG, "init:$it")
            if (!it) {
                ToastUtils.showCenterToast(getString(R.string.wb_tip_switch_failed))
            }
        }
    }

    fun showLoadingDialog(stringRes: String) {
        if (!loadingDialog.isShowing) {
            loadingDialog.updateText(stringRes)
            loadingDialog.show()
        } else {
            loadingDialog.updateText(stringRes)
        }
    }

    fun dismissLoadingDialog() {
        loadingDialog.dismiss()
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "onDestroy() called")
//        ZegoSDKManager.getInstance().unInitSDKEnvironment()
    }
}
