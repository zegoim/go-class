package im.zego.goclass.activities

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Color
import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.view.Window
import android.widget.Toast
import androidx.annotation.StringRes
import androidx.core.view.GravityCompat
import androidx.core.view.children
import androidx.drawerlayout.widget.DrawerLayout
import im.zego.goclass.CONFERENCE_ID
import im.zego.goclass.DemoApplication
import im.zego.goclass.dp2px
import im.zego.goclass.getRoundRectDrawable
import im.zego.goclass.classroom.*
import im.zego.goclass.network.Result
import im.zego.goclass.network.ZegoApiClient
import im.zego.goclass.sdk.*
import im.zego.goclass.tool.*
import im.zego.goclass.tool.Logger
import im.zego.goclass.widget.*
import im.zego.zegodocs.ZegoDocsViewConstants
import im.zego.zegowhiteboard.ZegoWhiteboardView
import im.zego.zegowhiteboard.callback.IZegoWhiteboardManagerListener
import im.zego.goclass.R
import kotlinx.android.synthetic.main.activity_main.*
import kotlinx.android.synthetic.main.layout_main_content.*

/**
 * 定制课堂主界面
 */
class MainActivity : BaseActivity() {
    private val TAG = "MainActivity"

    // 分享 PopWindow
    private lateinit var sharePopWindow: SharePopWindow
    // 摄像头 PopWindow
    private lateinit var cameraPopWindow: CameraPopWindow
    // 加载 Dialog
    private lateinit var loadingDialog: LoadingDialog
    // 重新加入 Dialog
    var reLoginDialog: ZegoDialog? = null

    // 设备服务：摄像头、麦克风
    val deviceService: ZegoDeviceService = ZegoSDKManager.getInstance().deviceService
    // 流服务
    val streamService: ZegoStreamService = ZegoSDKManager.getInstance().streamService
    // 房间服务
    val roomService: ZegoRoomService = ZegoSDKManager.getInstance().roomService

    // 隐藏顶部栏
    private val handler = Handler()
    private val hideTopBarRunnable = Runnable { layout_top_bar.visibility = View.GONE }
    // 白板容器
    private var currentHolder: ZegoWhiteboardViewHolder? = null
    // 获取白板列表是否结束
    var getListFinished = false
    // 刚刚进房间也会有whiteboardAdd，remove消息过来，这时候缓存一下，再和getList里面对比，删掉重复的
    var tempWbList = mutableListOf<ZegoWhiteboardView>()

    // 防止快速点击页面/步数跳转
    var lastClickPageChangeTime = 0L
    var lastClickStepChangeTime = 0L

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        loadingDialog = LoadingDialog(this, 0.8f)
        setContentView(R.layout.activity_main)

        initViews()
        // 请求白板列表，如果为空，则创建一个
        prepareWhiteboard()
        // 根据用户权限决定是否开启摄像头/麦克风
        prepare()
    }

    override fun onResume() {
        super.onResume()

        // 隐藏虚拟按键，并且全屏 tool
        hideBottomUIMenu()
        // 获取推流的流 ID
        val publishStreamID = streamService.generatePublishStreamID(ClassRoomManager.myUserId.toString())
        streamService.getStream(publishStreamID)?.let {
            // 根据权限打开摄像头、麦克风
            if (it.isCameraOpen()) {
                deviceService.enableCamera(true)
            }
            if (it.isMicPhoneOpen()) {
                deviceService.enableMic(true)
            }
        }
        deviceService.enableSpeaker(true)
        // 设置当前所选白板容器
        currentHolder?.let {
            handler.post {
                onWhiteboardHolderSelected(it)
            }
        }
    }

    // 有些手机 onstop 回调顺序会有问题，所以到 onPause 里面去处理
    // 但是需要注意的是，弹出像权限请求这种对话框的时候也会触发 onpause
    override fun onPause() {
        super.onPause()
        deviceService.enableCamera(false)
        deviceService.enableMic(false)
        deviceService.enableSpeaker(false)
    }

    private fun initViews() {
        initTopBar()
        initTopLayout()
        initDrawerRight()
        initBottomLayout()

        // 白板 View 数据监听
        addWhiteboardViewListener()

        // 房间相关的监听
        setRoomListeners()

        // 坐席区 View 初始化
        seat_video_window.initViews()

        // 讨论列表的显示
        if (ClassRoomManager.isSmallClass()) {
            chat_window.visibility = View.GONE
        } else {
            chat_window.visibility = View.VISIBLE
            chat_window.initView()
        }
    }

    /**
     * 准备白板
     * 请求白板列表，如果为空，则创建一个
     */
    private fun prepareWhiteboard() {
        // 先主动获取 roomService 最新的 seq 和 whiteboardID，否则后面 setCurrentWhiteboard 会失败
        roomService.getCurrentWhiteboardID { code: Int, currentWhiteboardID: Long ->
            if (code == 0) {
                // 重新计算白板区域
                container.resize(this)
                // 再获取当前房间的白板列表
                requestWhiteboardList(currentWhiteboardID)
            } else {
                Toast.makeText(
                        this,
                        "获取当前白板失败，errorCode = $code",
                        Toast.LENGTH_SHORT
                ).show()
            }
        }
    }

    /**
     * 进入课堂，准备阶段
     */
    private fun prepare() {
        // 加入课堂老师要开启摄像头/麦克风，学生根据连麦列表来判断要不要开启摄像头/麦克风
        if (ClassRoomManager.canOpenCameraOrMic(ClassRoomManager.myUserId)) {
            if (DemoApplication.isAlpha()) {
                return
            }

            PermissionHelper.onCameraPermissionGranted(this) { grant ->
                ClassRoomManager.setUserCamera(ClassRoomManager.myUserId, grant)
                PermissionHelper.onAudioPermissionGranted(this) { grant ->
                    ClassRoomManager.setUserMic(ClassRoomManager.myUserId, grant)
                }
            }
        }
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            hideBottomUIMenu()
        }
    }

    /**
     * 隐藏虚拟按键，并且全屏 tool
     */
    private fun hideBottomUIMenu() {
        // for new api versions.
        val decorView = window.decorView

        // SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN 配合 SYSTEM_UI_FLAG_FULLSCREEN 一起使用，效果使得状态栏出现的时候不会挤压activity高度
        // SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION 配合 SYSTEM_UI_FLAG_HIDE_NAVIGATION 一起使用，效果使得导航栏出现的时候不会挤压activity高度
        val uiOptions = (View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_FULLSCREEN
                or View.SYSTEM_UI_FLAG_LOW_PROFILE
                or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY)
        decorView.systemUiVisibility = uiOptions
    }
    
    override fun onBackPressed() {
        showExitClassDialog()
    }

    private fun initTopBar() {
        // 设置 Title
        top_bar_title.text = getString(R.string.class_title, CONFERENCE_ID)
        // 退出课堂
        top_bar_exit.setOnClickListener { showExitClassDialog() }
        // 白板区域因为事件被消耗，可能这里无法触发，所以白板那里也要增加点击事件
        handler.postDelayed(hideTopBarRunnable, 5000)
        layout_drawer_content.setOnTouchListener { _, event ->
            if (event.action == MotionEvent.ACTION_DOWN) {
                val isVisible = layout_top_bar.visibility == View.VISIBLE
                layout_top_bar.visibility = if (isVisible) View.GONE else View.VISIBLE
                if (!isVisible) {
                    handler.removeCallbacks(hideTopBarRunnable)
                    handler.postDelayed(hideTopBarRunnable, 5000)
                }
            }
            false
        }
    }

    /**
     * 退出课堂 Dialog
     */
    private fun showExitClassDialog() {
        if (ClassRoomManager.me().isTeacher()) {
            ZegoDialog.Builder(this)
                .setTitle(R.string.exit_class_title)
                .setMessage(R.string.exit_class_message)
                .setPositiveButton(R.string.exit_class_confirm) { dialog, _ ->
                    dialog.dismiss()
                    // 老师需要结束教学
                    ClassRoomManager.endClass(object : ZegoApiClient.RequestCallback<Any> {
                        override fun onResult(result: Result, t: Any?) {
                            if (result.code == 0) {
                                finish()
                            } else {
                                ToastUtils.showCenterToast("结束教学失败 ${result.code}")
                            }
                        }
                    })
                }
                .setNegativeButton(R.string.exit_class_cancel) { dialog, _ ->
                    dialog.dismiss()
                    ClassRoomManager.leaveClass()
                    finish()
                }
                .setNegativeButtonBackground(R.drawable.drawable_dialog_confirm2)
                .setNegativeButtonTextColor(R.color.colorAccent)
                .setButtonWidth(80)
                .setMaxDialogWidth(320)
                .create().showWithLengthLimit()
        } else {
            ZegoDialog.Builder(this)
                .setTitle(R.string.exit_class_title)
                .setMessage(R.string.exit_class_ensure)
                .setPositiveButton(R.string.button_confirm) { dialog, _ ->
                    dialog.dismiss()
                    // 学生离开课堂
                    ClassRoomManager.leaveClass()
                    finish()
                }
                .setNegativeButton(R.string.button_cancel) { dialog, _ ->
                    dialog.dismiss()
                }
                .show()
        }
    }

    private fun initTopLayout() {
        // 白板名称
        main_top_whiteboard_name.setOnClickListener {
            showRightDrawer(drawer_whiteboard_list)
        }
        // 预览按钮
        main_top_preview.visibility = View.GONE
        main_top_preview.setOnClickListener {
            val newSelectedState = !main_top_preview.isSelected
            main_top_preview.isSelected = newSelectedState
            ZegoViewAnimationUtils.startRightViewAnimation(
                docs_preview_list_parent,
                newSelectedState
            )
            if (newSelectedState) {
                if (currentHolder != null) {
                    docs_preview_list.setSelectedPage(currentHolder!!.getCurrentPage() - 1)
                }
            }
        }
        // 预览列表
        docs_preview_list.setSelectedListener { oldPage, newPage ->
            currentHolder?.flipToPage(newPage + 1)
        }
        // 页数
        main_page_index.setOnClickListener {
            // 什么都不做，主要是为了避免误触发顶部栏的显示
        }
        // 上一页
        main_page_prev.setOnClickListener {
            if (System.currentTimeMillis() - lastClickPageChangeTime < 500) {
                return@setOnClickListener
            }
            lastClickPageChangeTime = System.currentTimeMillis()
            currentHolder?.flipToPrevPage()?.let {
            }
        }
        // 下一页
        main_page_next.setOnClickListener {
            if (System.currentTimeMillis() - lastClickPageChangeTime < 500) {
                return@setOnClickListener
            }
            lastClickPageChangeTime = System.currentTimeMillis()
            currentHolder?.flipToNextPage()?.let {
            }
        }
        // 上一步
        main_step_prev.setOnClickListener {
            if (System.currentTimeMillis() - lastClickStepChangeTime < 500) {
                return@setOnClickListener
            }
            lastClickStepChangeTime = System.currentTimeMillis()
            currentHolder?.previousStep()
        }
        // 下一步
        main_step_next.setOnClickListener {
            if (System.currentTimeMillis() - lastClickStepChangeTime < 500) {
                return@setOnClickListener
            }
            lastClickStepChangeTime = System.currentTimeMillis()
            currentHolder?.nextStep()
        }
        // Excel 表格页名称
        main_top_sheet_name.setOnClickListener {
            showRightDrawer(drawer_excel_list)
            currentHolder?.let { holder ->
                drawer_excel_list.updateList(holder.getExcelSheetNameList())
            }
        }
    }

    private fun initDrawerRight() {
        layout_main_drawer.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED)
        layout_main_drawer.addDrawerListener(object : DrawerLayout.DrawerListener {
            override fun onDrawerStateChanged(newState: Int) {
            }

            override fun onDrawerSlide(drawerView: View, slideOffset: Float) {
            }

            override fun onDrawerClosed(drawerView: View) {
                layout_drawer_right.children.forEach {
                    it.visibility = View.GONE
                }
            }

            override fun onDrawerOpened(drawerView: View) {
                layout_top_bar.visibility = View.GONE
            }

        })

        // 已打开白板列表
        drawer_whiteboard_list.let { wbList ->
            wbList.drawerParent = layout_main_drawer
            wbList.setWhiteboardItemSelectedListener {
                // 获取当前所选白板 ID
                val holder = container.getWhiteboardViewHolder(it!!.whiteboardID)
                // 更新当前白板为所选白板
                holder?.let {
                    container.updateCurrentHolderToRoom(holder)
                }
                layout_main_drawer.closeDrawer(GravityCompat.END)
            }
            wbList.setWhiteboardItemDeleteListener {
                container.deleteWhiteboard(it) { errorCode, deleteHolder, IDList ->
                    if (errorCode == 0) {
                        drawer_whiteboard_list.removeWhiteboard(it)
                        if (deleteHolder.visibility == View.VISIBLE) {
                            // 获取下一个白板 ID
                            val nextSelectID = wbList.getNextSelectID(it)
                            val nextHolder = container.getWhiteboardViewHolder(nextSelectID)
                            // 更新当前白板为下一个白板
                            nextHolder?.let {
                                container.updateCurrentHolderToRoom(nextHolder)
                            }
                            // 更新相关视图
                            updatePreviewRelations()
                            main_whiteboard_tools_view.onWhiteboardChanged()
                            updateToolsVisibility()
                        }
                    }
                }
            }
        }

        // 已打开的文件列表
        drawer_file_list.let { fileList ->
            fileList.drawerParent = layout_main_drawer
            fileList.setFileClickedListener {
                // 创建文件白板
                container.createFileWhiteBoardView(it.id) { errorCode, holder ->
                    Logger.i(TAG, "createFileWhiteBoardView errorCode:$errorCode")
                    if (errorCode == 0) {
                        // 创建成功，添加白板
                        drawer_whiteboard_list.addWhiteboard(holder.getCurrentWhiteboardModel())
                    }
                }
            }
        }

        // 已打开的 Excel 文件列表
        drawer_excel_list.setExcelClickedListener {
            currentHolder?.let { holder ->
                layout_main_drawer.closeDrawer(GravityCompat.END)
                holder.selectExcelSheet(it) { errorCode, name ->
                    if (errorCode == 0) {
                        main_top_sheet_name.text = name
                    }
                }
            }
        }

        // 当前在线用户列表
        drawer_user_list.updateAll()
    }

    /**
     * 开始监听房间内的消息
     */
    private fun setRoomListeners() {

        // 房间状态监听
        ClassRoomManager.setRoomStateListener(object : IZegoRoomStateListener {
            override fun onConnected(errorCode: Int, roomID: String) {
                dismissLoadingDialog()
                roomService.getCurrentWhiteboardID { code: Int, currentWhiteboardID: Long ->
                    if (code == 0) {
                        container.selectWhiteboardViewHolder(currentWhiteboardID)
                    }
                }
            }

            override fun onDisconnect(errorCode: Int, roomID: String) {
                dismissLoadingDialog()
                showDisconnectDialog()
            }

            override fun connecting(errorCode: Int, roomID: String) {
                showLoadingDialog(R.string.network_temp_broken_reconnect)
            }
        })

        // 房间用户状态监听
        ClassRoomManager.addUserListener(object : ClassUserListener {
            // 新增房间用户
            override fun onUserEnter(user: ClassUser?) {
                Logger.i(TAG, "onUserEnter()")
                bottom_member_count.text = ClassRoomManager.mRoomUserMap.size.toString()
                user?.run {
                    drawer_user_list.addUser(user)
                }
                seat_video_window.onUserEnter(user)
            }

            // 房间用户退出
            override fun onUserLeave(user: ClassUser?) {
                Logger.i(TAG, "onUserLeave()")
                user?.run {
                    drawer_user_list.removeUser(user)
                }
                bottom_member_count.text = ClassRoomManager.mRoomUserMap.size.toString()
                seat_video_window.onUserLeave(user)
            }

            /**
             * 老师开启麦克风/摄像头，学生收到提示：老师已开启你的麦克风（摄像头）学生的麦克风（摄像头）被打开。
             * 老师关闭麦克风/摄像头，学生收到提示：老师已关闭你的麦克风（摄像头） 学生的麦克风（摄像头）被关闭。
             * 所有麦克风、摄像头、共享权限操作成功后，图标状态会切换
             */
            override fun onUserCameraChanged(userId: Long, on: Boolean, selfChanged: Boolean) {
                Logger.i(TAG, "onUserCameraChanged()")
                val myCameraChanged = userId == ClassRoomManager.myUserId
                drawer_user_list.updateAll()
                // 推拉流和底部工具栏只关心自己的摄像头状态/麦克风状态
                if (myCameraChanged) {
                    if (selfChanged) {
                        main_bottom_camera.isSelected = on
                        seat_video_window.onUserCameraChanged(userId, on, selfChanged)
                    } else {
                        if (on) {
                            PermissionHelper.onCameraPermissionGranted(this@MainActivity) { grant ->
                                if (grant) {
                                    ToastUtils.showCenterToast("老师已开启你的摄像头")
                                    main_bottom_camera.isSelected = on
                                } else {
                                    // 关掉
                                    ClassRoomManager.setUserCamera(ClassRoomManager.myUserId, false)
                                }
                                seat_video_window.onUserCameraChanged(userId, on, selfChanged)
                            }
                        } else {
                            main_bottom_camera.isSelected = false
                            ToastUtils.showCenterToast("老师已关闭你的摄像头")
                            seat_video_window.onUserCameraChanged(userId, on, selfChanged)
                        }
                    }
                } else {
                    seat_video_window.onUserCameraChanged(userId, on, selfChanged)
                }
            }

            // 用户麦克风状态更新
            override fun onUserMicChanged(userId: Long, on: Boolean, selfChanged: Boolean) {
                Logger.i(
                    TAG,
                    "onUserMicChanged() userId: $userId, on: $on, selfChanged: $selfChanged"
                )
                drawer_user_list.updateAll()
                // 判断当前更新通知是否由自己的操作发起的
                val myMicChanged = userId == ClassRoomManager.myUserId
                if (myMicChanged) {
                    if (selfChanged) {
                        main_bottom_mic.isSelected = on
                        seat_video_window.onUserMicChanged(userId, on, selfChanged)
                    } else {
                        if (on) {
                            // 申请权限
                            PermissionHelper.onAudioPermissionGranted(this@MainActivity) { grant ->
                                if (grant) {
                                    ToastUtils.showCenterToast("老师已开启你的麦克风")
                                    main_bottom_mic.isSelected = on
                                } else {
                                    // 关掉
                                    ClassRoomManager.setUserMic(ClassRoomManager.myUserId, false)
                                }
                                seat_video_window.onUserMicChanged(userId, on, selfChanged)
                            }
                        } else {
                            ToastUtils.showCenterToast("老师已关闭你的麦克风")
                            main_bottom_mic.isSelected = false
                            seat_video_window.onUserMicChanged(userId, on, selfChanged)
                        }
                    }
                } else {
                    seat_video_window.onUserMicChanged(userId, on, selfChanged)
                }
            }

            // 共享权限改变通知
            override fun onUserShareChanged(userId: Long, on: Boolean, selfChanged: Boolean) {
                Logger.i(TAG, "onUserShareChanged()")
                drawer_user_list.updateAll()
                if (!selfChanged && userId == ClassRoomManager.myUserId) {
                    if (on) {
                        main_whiteboard_tools_view.initTools()
                        main_whiteboard_tools_view.onWhiteboardChanged()
                        ToastUtils.showCenterToast("老师已允许你使用共享功能")
                    } else {
                        ToastUtils.showCenterToast("老师已收回你的共享权限")
                    }
                    // 若当前用户为学生，且没有共享权限，则隐藏白板文件切换/关闭、翻页、白板工具功能
                    updatePreviewRelations()
                    container.onSelfShareChanged(on)
                    updateToolsVisibility()
                }
                seat_video_window.onUserShareChanged(userId, on, selfChanged)
            }

            // 房间用户更新
            override fun onRoomUserUpdate() {
                // 1、更新成员列表
                drawer_user_list.updateAll()
                val me = ClassRoomManager.me()

                // 2、更新共享权限相关view
                updatePreviewRelations()
                updateToolsVisibility()

                // 3、更新底部栏
                Logger.i(TAG, "onRoomUserUpdate() $me")
                if (me.cameraOn) {
                    PermissionHelper.onCameraPermissionGranted(this@MainActivity) { grant ->
                        if (grant) {
                            main_bottom_camera.isSelected = grant
                        } else {
                            // 关掉
                            ClassRoomManager.setUserCamera(ClassRoomManager.myUserId, false)
                        }
                    }
                } else {
                    main_bottom_camera.isSelected = false
                }

                // 4. 更新选中工具
                main_whiteboard_tools_view.onWhiteboardChanged()

                if (me.micOn) {
                    PermissionHelper.onAudioPermissionGranted(this@MainActivity) { grant ->
                        if (grant) {
                            if (grant) {
                                main_bottom_mic.isSelected = grant
                            } else {
                                // 关掉
                                ClassRoomManager.setUserMic(ClassRoomManager.myUserId, false)
                            }
                        }
                    }
                } else {
                    main_bottom_mic.isSelected = false
                }
                bottom_member_count.text = ClassRoomManager.mRoomUserMap.size.toString()
            }

            // 连麦用户更新
            override fun onJoinLiveUserUpdate() {
                Logger.i(TAG, "onJoinLiveUserUpdate()")
                // 4、更新坐席区
                seat_video_window.onJoinLiveUserUpdate()
            }
        })

        // 房间状态监听(老师已结束教学时，学生端收到的状态监听)
        ClassRoomManager.addRoomStateListener(object : ClassRoomStateListener {
            override fun onEndTeach() {
                ZegoDialog.Builder(this@MainActivity)
                    .setMessage(R.string.end_teach_message)
                    .setPositiveButton(R.string.confirm) { dialog, _ ->
                        dialog.dismiss()
                        finish()
                    }.setCancelable(false)
                    .show()
            }
        })

        // 连麦用户状态监听
        ClassRoomManager.addJoinLiveUserListeners(object : JoinLiveUserListener {
            override fun onJoinLive(classUser: ClassUser) {
                Logger.i(TAG, "onJoinLive() $classUser")
                drawer_user_list.updateAll()
                seat_video_window.onJoinLive(classUser)
            }

            override fun onLeaveJoinLive(userId: Long) {
                Logger.i(TAG, "onLeaveJoinLive() userId: $userId")
                drawer_user_list.updateAll()
                seat_video_window.onLeaveJoinLive(userId)
            }
        })
    }

    /**
     * 更新工具列表的显示
     */
    private fun updateToolsVisibility() {
        val isAuthorized = ClassRoomManager.me().sharable
        Log.d(
            TAG,
            "updateToolsVisibility() ,container.childCount:${container.childCount},isAuthorized:$isAuthorized"
        )
        if (container.childCount > 0 && isAuthorized) {
            main_whiteboard_tools_view.visibility = View.VISIBLE
        } else {
            main_whiteboard_tools_view.visibility = View.GONE
        }
    }

    /**
     * 显示重连 Dialog
     */
    private fun showDisconnectDialog() {
        val title = getString(R.string.network_connect_failed_tips)
        if (reLoginDialog == null) {
            reLoginDialog = ZegoDialog.Builder(this@MainActivity)
                .setMessage(title)
                .setCancelable(false)
                .setPositiveButton(R.string.button_confirm) { dialog, _ ->
                    dialog.dismiss()
                    //这个时候再调用 leaveRoom 会返回"需要先登陆房间" 的提示
                    //通常收到这个消息的时候，http服务那边心跳肯定已经断了被下线了，所以直接exitRoom
                    ClassRoomManager.exitRoom()
                    finish()
                }
                .setNegativeButton(R.string.button_retry) { dialog, _ ->
                    dialog.dismiss()

                    showLoadingDialog(R.string.network_temp_broken_reLogin)
                    ClassRoomManager.reLogin { errorCode ->
                        dismissLoadingDialog()
                        if (errorCode == 0) {
                            container.removeAllViews()
                            seat_video_window.removeAllViews()
                            drawer_whiteboard_list.removeAllWhiteboard()
                            initViews()
                            prepareWhiteboard()
                            prepare()
                        } else {
                            // 重连失败
                            showDisconnectDialog()
                        }

                    }
                }
                .create()
        }
        if (!reLoginDialog!!.isShowing) {
            reLoginDialog!!.show()
        }
    }

    /**
     * 根据共享权限，更新操作相关视图
     */
    private fun updateShareOperationView() {
        if (ClassRoomManager.me().sharable) {
            main_top_layout.visibility = View.VISIBLE
            main_step_layout.visibility =
                if (currentHolder != null && currentHolder!!.isDynamicPPT()) View.VISIBLE else View.GONE
        } else {
            main_top_layout.visibility = View.INVISIBLE
            main_step_layout.visibility = View.GONE
        }
    }

    fun showLoadingDialog(@StringRes stringRes: Int) {
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

    private fun initBottomLayout() {

        // 摄像头
        cameraPopWindow = CameraPopWindow(this).also {
            it.setSwitchClickListener {
                deviceService.switchCamera()
            }
            it.setCloseClickListener {
                main_bottom_camera.isSelected = false
                ClassRoomManager.setUserCamera(ClassRoomManager.myUserId, false)
            }
        }
        main_bottom_camera.setOnClickListener {
            if (it.isSelected) {
                cameraPopWindow.show(it)
            } else {
                if (ClassRoomManager.canOpenCameraOrMic(ClassRoomManager.myUserId)) {
                    PermissionHelper.onCameraPermissionGranted(this) { grant ->
                        if (grant) {
                            // 打开自己的摄像头，需要像业务后台发起请求 在连麦列表通知里面进行推流
                            ClassRoomManager.setUserCamera(ClassRoomManager.myUserId, grant)
                        }
                    }
                } else {
                    Toast.makeText(this, "演示课堂最多开启3路学生音视频", Toast.LENGTH_SHORT).show()
                }

            }
        }
        main_bottom_camera.isSelected = false
        if (ClassRoomManager.me().cameraOn) {
            PermissionHelper.onCameraPermissionGranted(this) { grant ->
                main_bottom_camera.isSelected = grant
                if (grant.not()) {
                    ClassRoomManager.setUserCamera(ClassRoomManager.myUserId, false)
                }
            }
        }

        // 麦克风
        main_bottom_mic.isSelected = false
        if (ClassRoomManager.me().micOn) {
            PermissionHelper.onAudioPermissionGranted(this) { grant ->
                main_bottom_mic.isSelected = grant
                // 加入课堂后，服务器是开的状态，本地未授权，所以又关闭mic
                if (!grant) {
                    ClassRoomManager.setUserMic(ClassRoomManager.myUserId, false)
                }
            }
        }
        main_bottom_mic.setOnClickListener {
            if (it.isSelected) {
                // 关闭自己的麦克风 检查摄像头的状态
                ClassRoomManager.setUserMic(ClassRoomManager.myUserId, false)
            } else {
                if (ClassRoomManager.canOpenCameraOrMic(ClassRoomManager.myUserId)) {
                    PermissionHelper.onAudioPermissionGranted(this) { grant ->
                        if (grant) {
                            // 打开自己的麦克风，需要像业务后台发起请求， 在连麦列表通知里面进行推流
                            ClassRoomManager.setUserMic(ClassRoomManager.myUserId, grant)
                        }
                    }
                } else {
                    Toast.makeText(this, "演示课堂最多开启3路学生音视频", Toast.LENGTH_SHORT).show()
                }
            }
        }
        deviceService.enableMic(false)

        // 分享
        sharePopWindow = SharePopWindow(this).also {
            it.setWhiteboardClickListener {
                container.createPureWhiteboard { errorCode, holder ->
                    if (errorCode == 0) {
                        drawer_whiteboard_list.addWhiteboard(holder.getCurrentWhiteboardModel())
                        holder.visibility = View.GONE
                        container.updateCurrentHolderToRoom(holder)
                    }
                }
            }
            it.setFileClickListener {
                showRightDrawer(drawer_file_list)
            }
        }
        main_bottom_share.setOnClickListener {
            if (ClassRoomManager.me().sharable) {
                sharePopWindow.show(it)
            } else {
                ToastUtils.showCenterToast(getString(R.string.share_disable_tips))
            }
        }

        // 邀请
        main_bottom_invite.setOnClickListener {
            val isMainland = ZegoSDKManager.getInstance().isMainLandEnv
            val natEnv =
                if (isMainland) getString(R.string.mainland_value) else getString(R.string.other_value)
            val testRoomUrl =
                "https://doc-demo-whiteboard-test.zego.im/#/login?roomId=$CONFERENCE_ID&&env=$natEnv"
            val officialRoomUrl =
                "https://goclass.zego.im/#/login?roomId=$CONFERENCE_ID&&env=$natEnv"
            val roomUrl =
                if (SharedPreferencesUtil.isVideoSDKTestEnv()) testRoomUrl else officialRoomUrl
            val nat_env =
                if (isMainland) getString(R.string.mainland) else getString(R.string.other)
            val copyText = getString(R.string.copy_text, roomUrl, CONFERENCE_ID, nat_env)
            val clipboardManager = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            clipboardManager.setPrimaryClip(ClipData.newPlainText("Label", copyText))
            ToastUtils.showCenterToast(R.string.copy_succeed)
        }

        // 成员
        main_bottom_member.setOnClickListener {
            showRightDrawer(drawer_user_list)
        }
        bottom_member_count.text = ClassRoomManager.mRoomUserMap.size.toString()
        bottom_member_count.background =
            getRoundRectDrawable(
                "#585c62",
                dp2px(this, 2f)
            )

        // 如果是大班课学生，底部栏仅显示 邀请、成员按钮
        if (!ClassRoomManager.isSmallClass() && !ClassRoomManager.me().isTeacher()) {
            main_bottom_camera.visibility = View.GONE
            main_bottom_mic.visibility = View.GONE
            main_bottom_share.visibility = View.GONE
        }
    }

    /**
     * 添加白板view的listener
     */
    private fun addWhiteboardViewListener() {
        ZegoSDKManager.getInstance().setWhiteboardCountListener(
            object : IZegoWhiteboardManagerListener {
                override fun onWhiteboardAdded(zegoWhiteboardView: ZegoWhiteboardView) {
                    val model = zegoWhiteboardView.getWhiteboardViewModel()
                    Logger.i(TAG, "onWhiteboardAdded:${model.name}")
                    if (getListFinished) {
                        container.onReceiveWhiteboardView(zegoWhiteboardView) { errorCode, newHolder, holder ->
                            // 不管创建和加载是否成功，都要显示出来
                            updatePreviewRelations()
                            main_whiteboard_tools_view.onWhiteboardChanged()
                            if (newHolder) {
                                drawer_whiteboard_list.addWhiteboard(model)
                            }
                            // 有个问题是收到当前白板的消息了但是还没有加载完所以取到页码是0
                            // 因此在这里，加载完了,检查一下是不是包含当前显示的白板
                            // 断网重连，可能连续收到多个白板，如果获取到当前白板到时候onAdd消息还没来，这时候再检查一遍
                            if (holder.hasWhiteboardID(roomService.currentWhiteboardID)) {
                                holder.visibility = View.VISIBLE
                                container.selectWhiteboardViewHolder(roomService.currentWhiteboardID)
                            }
                        }
                    } else {
                        tempWbList.add(zegoWhiteboardView)
                    }
                }

                override fun onWhiteboardRemoved(whiteboardID: Long) {
                    if (currentHolder?.currentWhiteboardID == whiteboardID) {
                        updatePreviewRelations()
                        main_whiteboard_tools_view.onWhiteboardChanged()
                    }
                    val holder = container.removeWhiteboardViewHolder(whiteboardID)
                    drawer_whiteboard_list.removeWhiteboard(whiteboardID)
                    updateToolsVisibility()
                }

                override fun onError(errorCode: Int) {
                }
            })

        ZegoSDKManager.getInstance().setWhiteboardSelectListener(
            object : OnWhiteboardSelectedListener {
                override fun onWhiteboardSelected(whiteboardID: Long) {
                    container.selectWhiteboardViewHolder(whiteboardID)
                }
            })

        main_whiteboard_container_background.onClickWhiteboard {
            if (ClassRoomManager.me().sharable) {
                container.createPureWhiteboard { errorCode, holder ->
                    if (errorCode == 0) {
                        drawer_whiteboard_list.addWhiteboard(holder.getCurrentWhiteboardModel())
                        holder.visibility = View.GONE
                        container.updateCurrentHolderToRoom(holder)
                    }
                }
            } else {
                ToastUtils.showCenterToast(getString(R.string.share_disable_tips))
            }
        }
        main_whiteboard_container_background.onClickShareFile {
            if (ClassRoomManager.me().sharable) {
                showRightDrawer(drawer_file_list)
            } else {
                ToastUtils.showCenterToast(getString(R.string.share_disable_tips))
            }
        }

        container.backgroundView = main_whiteboard_container_background
        container.toolsView = main_whiteboard_tools_view

        with(container) {
            setChildCountChangedListener { count: Int ->
                if (count == 0) {
                    main_top_whiteboard_name.visibility = View.GONE
                    main_top_page_layout.visibility = View.GONE
                    main_top_sheet_name.visibility = View.GONE
                    main_step_layout.visibility = View.GONE
                    main_top_layout.setBackgroundColor(Color.parseColor("#f4f5f8"))
                    currentHolder = null
                } else {
                    main_top_layout.setBackgroundColor(Color.TRANSPARENT)
                }
            }

            setWhiteboardSelectListener {
                Logger.i(TAG, "container onWhiteboardSelectListener,${it}")
                val holder = container.getWhiteboardViewHolder(it)!!
                onWhiteboardHolderSelected(holder)
                updatePreviewRelations()
                updateToolsVisibility()
            }
            setWhiteboardScrollListener { currentPage: Int, pageCount: Int ->
                Logger.i(
                    TAG,
                    "setWhiteboardScrollListener(),currentPage:${currentPage},pageCount:${pageCount}, ${currentHolder?.getCurrentPage()}"
                )
                main_page_index.text = "%s/%s".format(currentPage.toString(), pageCount.toString())
                docs_preview_list.setSelectedPage(currentPage - 1)
            }
            setWhiteboardClickedListener {
                val isVisible = layout_top_bar.visibility == View.VISIBLE
                layout_top_bar.visibility = if (isVisible) View.GONE else View.VISIBLE
                if (!isVisible) {
                    handler.removeCallbacks(hideTopBarRunnable)
                    handler.postDelayed(hideTopBarRunnable, 5000)
                }
            }
        }

    }

    private fun onWhiteboardHolderSelected(holder: ZegoWhiteboardViewHolder) {
        Logger.i(TAG, "onWhiteboardHolderSelected:${holder.getCurrentWhiteboardMsg()}")
        currentHolder = holder
        main_top_whiteboard_name.text = holder.getCurrentWhiteboardName()

        // currentWhiteboard有可能不等于List里面的白板，所以遍历一下
        holder.getWhiteboardIDList().forEach {
            drawer_whiteboard_list.setSelectedWhiteboard(it)
        }

        if (holder.isPureWhiteboard() || holder.isDocsViewLoadSuccessed()) {
            main_page_index.text = "%s/%s".format(
                holder.getCurrentPage().toString(),
                holder.getPageCount().toString()
            )
        } else {
            main_page_index.text = ""
        }

        Logger.i(TAG, "holder.isExcel():${holder.isExcel()}")
        if (holder.isExcel()) {
            main_top_sheet_name.text = holder.getCurrentWhiteboardModel().fileInfo.fileName
        }

        main_top_whiteboard_name.visibility = View.VISIBLE
        main_top_sheet_name.visibility = if (holder.isExcel()) View.VISIBLE else View.GONE
        main_top_page_layout.visibility = if (holder.isExcel()) View.GONE else View.VISIBLE
        main_step_layout.visibility =
            if (holder.isDynamicPPT() && ClassRoomManager.me().sharable) View.VISIBLE else View.GONE

        main_whiteboard_tools_view.onWhiteboardChanged()
    }

    /**
     * 更新预览相关的 view，调用时机
     * 1、新增白板
     * 2、切换白板
     * 3、删除白板
     */
    private fun updatePreviewRelations() {
        if (currentHolder != null && currentHolder!!.hasThumbUrl() && ClassRoomManager.me().sharable) {
            // 有缩略图，显示预览按钮
            main_top_preview.visibility = View.VISIBLE
            main_top_preview.isSelected = false
            docs_preview_list.setThumbnailUrlList(currentHolder!!.getThumbnailUrlList())
        } else {
            // 没有缩略图,不显示预览按钮
            main_top_preview.visibility = View.GONE
            docs_preview_list.setThumbnailUrlList(ArrayList())
        }
        // 业务需求，隐藏缩略图列表
        docs_preview_list_parent.visibility = View.INVISIBLE

        updateShareOperationView()
    }

    /**
     * 请求白板列表
     */
    private fun requestWhiteboardList(currentWhiteboardID: Long) {
        ZegoSDKManager.getInstance().getWhiteboardViewList { errorCode, whiteboardViewList ->
            Logger.i(
                TAG,
                "requestWhiteboardList:errorCode;$errorCode,whiteboardViewList:${whiteboardViewList.size}"
            )
            if (errorCode == 0) {
                if (whiteboardViewList.isEmpty()) {
                    if (ClassRoomManager.me().sharable) {
                        // 有权限到人才会去创建白板
                        container.createPureWhiteboard { createErrorCode, holder ->
                            if (createErrorCode == 0) {
                                drawer_whiteboard_list.addWhiteboard(holder.getCurrentWhiteboardModel())
                                holder.visibility = View.GONE
                                container.updateCurrentHolderToRoom(holder)
                                getListFinished = true
                            }
                        }
                    } else {
                        getListFinished = true
                    }
                } else {
                    val list = mutableListOf<ZegoWhiteboardView>()
                    list.addAll(whiteboardViewList)
                    Logger.d(TAG, "tempWbList.size:${tempWbList.size}")
                    tempWbList.forEach {
                        val tempWhiteboardID = it.whiteboardViewModel.whiteboardID
                        val firstOrNull = list.firstOrNull { item ->
                            tempWhiteboardID == item.whiteboardViewModel.whiteboardID
                        }
                        if (firstOrNull == null) {
                            list.add(it)
                        } else {
                            Logger.i(TAG, "already added :${it.whiteboardViewModel.name}")
                        }
                    }
                    tempWbList.clear()

                    list.forEach {
                        val model = it.whiteboardViewModel
                        val fileType = model.fileInfo.fileType
                        if (fileType != ZegoDocsViewConstants.ZegoDocsViewFileTypeELS) {
                            drawer_whiteboard_list.addWhiteboard(model)
                        } else {
                            if (!drawer_whiteboard_list.containsFileID(model)) {
                                drawer_whiteboard_list.addWhiteboard(model)
                            }
                        }
                    }
                    drawer_whiteboard_list.setSelectedWhiteboard(roomService.currentWhiteboardID)

                    container.onEnterRoomReceiveWhiteboardList(list) { resultCode ->
                        if (resultCode == 0) {
                            val holderList = container.getWhiteboardViewHolderList()
                            Logger.i(
                                TAG,
                                "process Enter List finished,resultCode = $resultCode,holderList:${holderList.size}"
                            )
                            drawer_whiteboard_list.setSelectedWhiteboard(roomService.currentWhiteboardID)
                        } else {
                            Logger.i(TAG, "process Enter List finished,resultCode = $resultCode")
                        }
                    }
                    getListFinished = true
                }
            } else {
                getListFinished = true
                Toast.makeText(
                    this,
                    "获取白板列表失败，errorCode = $errorCode",
                    Toast.LENGTH_SHORT
                ).show()
            }
        }
    }

    private fun showRightDrawer(drawerChild: View) {
        layout_main_drawer.openDrawer(GravityCompat.END)
        layout_drawer_right.children.forEach {
            it.visibility = if (it == drawerChild) View.VISIBLE else View.GONE
        }
    }
}
