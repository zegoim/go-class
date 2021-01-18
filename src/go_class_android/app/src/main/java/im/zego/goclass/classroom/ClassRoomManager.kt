package im.zego.goclass.classroom

import com.google.gson.Gson
import im.zego.goclass.network.*
import im.zego.goclass.sdk.ICustomCommandListener
import im.zego.goclass.sdk.IZegoRoomStateListener
import im.zego.goclass.sdk.ZegoSDKManager
import im.zego.goclass.tool.Logger
import im.zego.goclass.tool.ToastUtils
import org.json.JSONObject

/**
 * 小班课的主要业务流程管理
 * 对 liveroom/express 信令的补充
 */
object ClassRoomManager {

    private const val TAG = "GoClassRoom"
    private const val JOIN_LIVE_STUDENT_MAX = 3
    private var mGson = Gson()
    var frontCamera = true
    var myUserId = 0L
    private var mRoomId = ""

    // 每次登录的时候会构造该对象，在断网重试的时候可以用到。不要在 clear 中清除掉。
    private lateinit var loginReqParam: LoginReqParam

    // 用于标记这两个数据是否初始完成了
    private var roomUserReady = false
    private var joinLiveUserReady = false

    var mRoomUserMap = mutableMapOf<Long, ClassUser>()
    var mJoinLiveUserList = mutableListOf<ClassUser>()//用于推拉流

    private var mGoClassRoomStateListeners = mutableListOf<ClassRoomStateListener>()
    private var mUserListeners =
        mutableListOf<ClassUserListener>() // camera/mic 的开启，涉及到权限到申请。建议先在activity处理，然后在分发，保证view的一致性
    private var joinLiveUserListeners = mutableListOf<JoinLiveUserListener>()

    // 主要关注一些配置项
    // 1 是否允许开关摄像头/麦克风，
    // 2 加入课堂摄像头/麦克风的初始状态
    private var mLoginRspData: LoginRspData? = null

    // 心跳，定时向服务器发出请求，查看数据是否有更新
    private var heartBeatMonitor: HeartBeatMonitor? = null
    private var roomStatelistener: IZegoRoomStateListener? = null

    var roomType = ZegoApiConstants.RoomType.SMALL_CLASS

    /**
     * 监听结束教学，自己结束和老师结束
     */
    fun addRoomStateListener(listener: ClassRoomStateListener) {
        mGoClassRoomStateListeners.add(listener)
    }

    fun addUserListener(listener: ClassUserListener) {
        mUserListeners.add(listener)
    }

    fun addJoinLiveUserListeners(joinLiveUserListener: JoinLiveUserListener) {
        joinLiveUserListeners.add(joinLiveUserListener)
    }

    /**
     * 从进入课堂开始，自己就应该是存在，userId 也是知道。所以返回不为 null
     */
    fun me(): ClassUser {
        return mRoomUserMap[myUserId]!!
    }

    /**
     * 判断当前课堂类型，是否为小班课
     */
    fun isSmallClass(): Boolean {
        return roomType == ZegoApiConstants.RoomType.SMALL_CLASS
    }

    /**
     * 如果老师没进课堂，返回空
     */
    fun teacher(): ClassUser? = mRoomUserMap.values.firstOrNull {
        it.role == ZegoApiConstants.Role.TEACHER
    }

    private fun clear() {
        Logger.i(TAG, "clear()")
        mUserListeners.clear()
        mRoomUserMap.clear()
        mJoinLiveUserList.clear()
        mGoClassRoomStateListeners.clear()
        joinLiveUserListeners.clear()
        mRoomId = ""
        mLoginRspData = null
        roomUserReady = false
        joinLiveUserReady = false
    }

    /**
     * 1、业务后台，用来校验用户
     */
    fun login(
        roomId: String,
        userName: String,
        role: Int,
        roomType: Int,
        onLogin: (errorCode: Int) -> Unit
    ) {
        Logger.i(TAG, "login() roomId: $roomId,  userName: $userName, role: $role")

        mRoomId = roomId
        myUserId = generateUserId()
        this.roomType = roomType

        // 构建对象，加入map
        mRoomUserMap[myUserId] = ClassUser(
            myUserId, userName, role,
            cameraOn = false,
            micOn = false,
            sharable = false,
            loginTime = 0,
            joinLiveTime = 0
        )
        loginReqParam = LoginReqParam(myUserId, roomId, userName, role, roomType)

        ZegoApiClient.loginRoom(
            loginReqParam,
            object : ZegoApiClient.RequestCallback<LoginRspData> {
                override fun onResult(result: Result, loginRspData: LoginRspData?) {
                    Logger.i(
                        TAG,
                        "onResult() result code:  ${result.code}, msg: ${result.message}, rsp: ${loginRspData?.toString()} "
                    )
                    if (result.code != 0) {
                        // login 失败
                        onLogin(result.code)
                        clear()
                    } else {
                        // save loginRsp
                        mLoginRspData = loginRspData
                        // login 成功，加入课堂
                        enterRoom(myUserId, userName, roomId) { errorCode ->
                            onLogin(errorCode)
                        }
                    }
                }

            })
    }

    /**
     * 课堂内重试
     */
    fun reLogin(onLogin: (errorCode: Int) -> Unit) {
        exitRoom()

        val roomId = loginReqParam.roomId
        val userName = loginReqParam.nickName
        val role = loginReqParam.role
        login(roomId, userName, role, roomType, onLogin)
    }

    fun getRoomId():String {
        return loginReqParam.roomId
    }

    /**
     * @return 返回 userId 由客户端生成，统一规则：毫秒级时间戳。注意：理论上还是会存在冲突的。
     */
    private fun generateUserId(): Long {
        val userId = System.currentTimeMillis()
        Logger.i(TAG, "generateUserId() myUserId: $userId")
        return userId
    }

    /**
     * 2、SDK 的登陆房间操作
     */
    private fun enterRoom(
        userId: Long,
        userName: String,
        roomID: String,
        onLogin: (errorCode: Int) -> Unit
    ) {
        Logger.i(TAG, "enterRoom()")
        // 加入房间之前要监听通知回调
        ZegoSDKManager.getInstance().setCustomCommandListener(object : ICustomCommandListener {
            override fun onRecvCustomCommand(
                userID: String, userName: String, content: String, roomID: String,
            ) {
                Logger.i(
                    TAG,
                    "onRecvCustomCommand() userID: $userID, userName: $userName, content: $content, roomID: $roomID"
                )
                onRecvCustomCommandNotify(userID, userName, content, roomID)
            }
        })

        ZegoSDKManager.getInstance().roomService.loginRoom(
            userId.toString(),
            userName,
            roomID
        ) { stateCode ->
            Logger.i(TAG, "onEnterRoom() stateCode: $stateCode")
            if (stateCode == 0) {
                prepare(onLogin)
            } else {
                // 加入课堂失败，清除数据
                onLogin.invoke(stateCode)
                clear()
            }
        }

    }

    /**
     * 开启/关闭摄像头
     */
    fun setUserCamera(targetUserId: Long, cameraOn: Boolean, onChange: (errorCode: Int) -> Unit) {
        Logger.i(TAG, "setUserCamera() targetUserId : $targetUserId, cameraOn: $cameraOn")
        val camera = if (cameraOn) ZegoApiConstants.Status.OPEN else ZegoApiConstants.Status.CLOSE
        mRoomUserMap[targetUserId]?.let {
            it.cameraOn = cameraOn
            // 发起网络请求， 同时需要通知 UI
            for (listener in mUserListeners) {
                listener.onUserCameraChanged(targetUserId, cameraOn, true)
            }
            val setUserInfoReqParam =
                SetUserInfoReqParam(myUserId, mRoomId, targetUserId, camera, null, null, roomType)
            ZegoApiClient.setUserInfo(
                setUserInfoReqParam,
                object : ZegoApiClient.RequestCallback<Any?> {
                    override fun onResult(result: Result, t: Any?) {
                        Logger.i(TAG, "setUserCamera() onResult  : ${result.code}")
                        if (result.code != 0) {
                            // 失败回滚 加toast
                            it.cameraOn = !cameraOn
                            for (listener in mUserListeners) {
                                listener.onUserCameraChanged(targetUserId, !cameraOn, true)
                            }
                            onChange(result.code)
                        }
                    }
                })
        }
    }

    /**
     * 开启/关闭麦克风
     */
    fun setUserMic(targetUserId: Long, micOn: Boolean, onChange: (errorCode: Int) -> Unit) {
        Logger.i(TAG, "setUserMic() targetUserId : $targetUserId, cameraOn: $micOn")
        val mic = if (micOn) ZegoApiConstants.Status.OPEN else ZegoApiConstants.Status.CLOSE
        mRoomUserMap[targetUserId]?.let {
            it.micOn = micOn
            // 发起网络请求， 同时需要通知UI
            for (listener in mUserListeners) {
                listener.onUserMicChanged(targetUserId, micOn, true)
            }
            val setUserInfoReqParam =
                SetUserInfoReqParam(myUserId, mRoomId, targetUserId, null, mic, null, roomType)
            ZegoApiClient.setUserInfo(
                setUserInfoReqParam,
                object : ZegoApiClient.RequestCallback<Any?> {
                    override fun onResult(result: Result, t: Any?) {
                        Logger.i(TAG, "setUserMic() onResult  : ${result.code}")
                        if (result.code != 0) {
                            // 失败回滚 加 toast
                            it.micOn = !micOn
                            for (listener in mUserListeners) {
                                listener.onUserMicChanged(targetUserId, !micOn, true)
                            }
                            onChange(result.code)
                        }
                    }
                })
        }
    }

    /**
     * 授予/取消权限
     */
    fun setUserShare(targetUserId: Long, shareEnable: Boolean, onChange: (errorCode: Int) -> Unit) {
        val share = if (shareEnable) ZegoApiConstants.Status.OPEN else ZegoApiConstants.Status.CLOSE
        mRoomUserMap[targetUserId]?.let {
            it.sharable = shareEnable
            // 发起网络请求, 同时需要通知 UI
            for (listener in mUserListeners) {
                listener.onUserShareChanged(targetUserId, shareEnable, true)
            }
            val setUserInfoReqParam =
                SetUserInfoReqParam(myUserId, mRoomId, targetUserId, null, null, share, roomType)
            ZegoApiClient.setUserInfo(
                setUserInfoReqParam,
                object : ZegoApiClient.RequestCallback<Any?> {
                    override fun onResult(result: Result, t: Any?) {
                        if (result.code != 0) {
                            // 失败回滚 加 toast
                            it.sharable = !shareEnable
                            for (listener in mUserListeners) {
                                listener.onUserShareChanged(targetUserId, !shareEnable, true)
                            }
                            onChange(result.code)
                        }
                    }
                })
        }
    }


    /**
     * 加入课堂成功，准备数据阶段
     * 1、如果是老师，尝试打开摄像头，麦克风，上麦
     * 2、如果是学生，判断连麦列表人数，如果小于 4，尝试打开摄像头、麦克风，上麦
     */
    private fun prepare(onPrepare: (errorCode: Int) -> Unit) {
        Logger.i(TAG, "prepare()")
        heartBeatMonitor = HeartBeatMonitor(myUserId, mRoomId)
        getAttendeeList { errorCode ->
            if (errorCode == 0) {
                // 成员列表拉取成功
                roomUserReady = true
                checkUserList(onPrepare)
            } else {
                onPrepare.invoke(errorCode)
                exitRoom()
            }
        }

        getJoinLiveList { errorCode ->
            if (errorCode == 0) {
                // 连麦列表拉取成功
                joinLiveUserReady = true
                checkUserList(onPrepare)
            } else {
                onPrepare.invoke(errorCode)
                exitRoom()
            }
        }

    }

    /**
     * 拉取成员列表
     */
    private fun getAttendeeList(onGetList: (errorCode: Int) -> Unit) {
        Logger.i(TAG, "getAttendeeList()")
        ZegoApiClient.getAttendeeList(
            myUserId,
            mRoomId,
            roomType,
            object : ZegoApiClient.RequestCallback<GetAttendeeListRspData> {
                override fun onResult(
                    result: Result,
                    getAttendeeListRspData: GetAttendeeListRspData?,
                ) {
                    Logger.i(
                        TAG,
                        "getAttendeeList() onResult resultCode: ${result.code}, attendees: ${getAttendeeListRspData?.attendeeList.toString()}"
                    )
                    if (result.code == 0) {
                        getAttendeeListRspData?.let {
                            heartBeatMonitor?.setAttendeeSeq(it.seq)
//                            mRoomUserMap.clear()
                            for (joinRoomUser in it.attendeeList) {
                                mRoomUserMap[joinRoomUser.uid] = ClassUser.create(joinRoomUser)
                            }
                        }
                        for (listener in mUserListeners) {
                            listener.onRoomUserUpdate()
                        }
                    }
                    onGetList(result.code)
                }
            })
    }

    /**
     * 拉取连麦列表
     */
    private fun getJoinLiveList(onGetList: (errorCode: Int) -> Unit) {
        Logger.i(TAG, "getJoinLiveList()")
        ZegoApiClient.getJoinLiveList(
            myUserId,
            mRoomId,
            roomType,
            object : ZegoApiClient.RequestCallback<GetJoinLiveListRspData> {
                override fun onResult(
                    result: Result,
                    t: GetJoinLiveListRspData?
                ) {
                    Logger.i(
                        TAG,
                        "getJoinLiveList() onResult resultCode: ${result.code}, joinLiveUserList: ${t?.joinLiveUserList.toString()}"
                    )

                    if (result.code == 0) {
                        t?.let {
                            heartBeatMonitor?.setJoinLiveSeq(it.seq)
                            mJoinLiveUserList.clear()
                            mJoinLiveUserList.addAll(
                                it.joinLiveUserList
                                    .sortedBy { data -> data.joinLiveTime }
                                    .map { userInfo ->
                                        ClassUser.create(userInfo)
                                    }
                            )
                        }
                        for (listener in mUserListeners) {
                            listener.onJoinLiveUserUpdate()
                        }
                    }
                    onGetList(result.code)
                }
            })
    }


    /**
     * 两个列表已经拉取完成了
     */
    private fun checkUserList(onPrepare: (errorCode: Int) -> Unit) {
        Logger.i(
            TAG,
            "onPrepare() roomUserReady: $roomUserReady, joinLiveUserReady: $joinLiveUserReady"
        )
        if (roomUserReady && joinLiveUserReady) {
            heartBeatMonitor?.let {
                it.seqUpdateListener = object : HeartBeatMonitor.SeqUpdateListener {
                    override fun onUpdateAttendeeSeq(attendeeListSeq: Int) {
                        getAttendeeList {}
                    }

                    override fun onUpdateJoinLiveSeq(joinLiveListSeq: Int) {
                        getJoinLiveList {}
                    }

                    override fun onOverTime() {
                        roomStatelistener?.onDisconnect(0, mRoomId)
                    }
                }
                it.start()
            }
            // 数据准备完成
            onPrepare.invoke(0)
        }
    }

    /**
     * 离开课堂，因为离开对别人没有影响，假如断网了，请求失败，也退出房间关闭界面
     * 服务器收不到心跳会对用户进行下线处理
     */
    fun leaveClass(requestCallback: ZegoApiClient.RequestCallback<Any>?) {
        Logger.i(TAG, "leaveClass()")
        ZegoApiClient.leaveRoom(myUserId, mRoomId, roomType, requestCallback)
        exitRoom()
    }

    /**
     * 结束教学, 必须收到成功回调才能结束
     */
    fun endClass(requestCallback: ZegoApiClient.RequestCallback<Any>?) {
        Logger.i(TAG, "endTeaching()")
        ZegoApiClient.endTeaching(
            myUserId,
            mRoomId,
            roomType,
            object : ZegoApiClient.RequestCallback<Any> {
                override fun onResult(result: Result, t: Any?) {
                    if (result.code == 0) {
                        exitRoom()
                    }
                    requestCallback?.onResult(result, t)
                }
            })
    }

    fun exitRoom() {
        ZegoSDKManager.getInstance().roomService.exitRoom()
        clear()
        heartBeatMonitor?.exit()
    }


    /**
     * 接收 liveroom/express 传来的通知
     */
    private fun onRecvCustomCommandNotify(
        userID: String,
        userName: String,
        content: String,
        roomID: String,
    ) {
        Logger.i(TAG, "onRecvCustomCommandNotify() commandCode: $content")
        var jsonObject = JSONObject(content)
        val cmdCode = jsonObject.getInt("cmd")
        val cmdData = jsonObject.getString("data")
        when (cmdCode) {
            // 房间状态变更通知，组播房间所有人，当有用户修改了房间的状态时
            // 后台会主动推送房间状态给房间内的所有用户
            RoomNotify.CMD_ROOM_STATE_CHANGED -> {
                // 暂无实现
//                val configChange = mGson.fromJson(cmdData, ConfigChange::class.java)
            }
            // 成员状态变更通知，组播房间所有人，当用户修改了自己或他人的属性（麦克风、摄像头、共享权限状态）时
            // 后台会将被修改用户的属性同步给所有用户
            RoomNotify.CMD_USER_CHANGED -> {
                val userStateChange = mGson.fromJson(cmdData, UserStateChange::class.java)
                onUserStateChange(userStateChange)
            }
            // 成员列表变更通知，组播房间所有人，当有用户登录/退出房间时，会推送此消息给所有用户
            RoomNotify.CMD_USER_LIST_CHANGED -> {
                val userCountChange = mGson.fromJson(cmdData, UserCountChange::class.java)
                onUserListChanged(userCountChange)
            }
            // 连麦成员列表通知，组播房间所有人，当有用户上麦/下麦时触发，推送给房间内所有用户
            RoomNotify.CMD_JOIN_LIVE_USER_LIST_CHANGED -> {
                val joinLiveCountChange = mGson.fromJson(cmdData, JoinLiveCountChange::class.java)
                onJoinLiveUserChanged(joinLiveCountChange)
            }
            // 结束教学，组播房间所有人，当老师结束教学时触发
            RoomNotify.CMD_END_TEACH -> {
                val endTeaching = mGson.fromJson(cmdData, EndTeaching::class.java)
                if (endTeaching.operatorUid != myUserId) {
                    // 自己结束教学在回调接口处处理
                    for (listener in mGoClassRoomStateListeners) {
                        listener.onEndTeach()
                    }
                    // 直接结束，清掉sdk的回调，这样就不会再接收到onDisconnect消息
                    exitRoom()
                }
            }
            // 开始共享，组播房间所有人，当有用户开始共享时触发，同步给房间内所有用户
            RoomNotify.CMD_START_SHARE -> {
                //暂无实现
//                val startShare = mGson.fromJson(cmdData, StartShare::class.java)
            }
            // 结束共享，组播房间所有人，当用户结束自己的共享或者老师结束学生的共享时触发
            RoomNotify.CMD_END_SHARE -> {
                //暂无实现
//                val stopShare = mGson.fromJson(cmdData, StopShare::class.java)
            }

        }
    }

    /**
     * 连麦列表变更，连麦列表变更可以通过用户 camera 和 mic 的状态来判断
     */
    private fun onJoinLiveUserChanged(joinLiveCountChange: JoinLiveCountChange) {
        Logger.i(TAG, "onJoinLiveUserChanged() joinLiveCountChange: $joinLiveCountChange")
        heartBeatMonitor?.setJoinLiveSeq(joinLiveCountChange.seq)
        if (joinLiveCountChange.isAdd()) {
            ClassUser.create(joinLiveCountChange).let {
                mJoinLiveUserList.add(it)
                for (listener in joinLiveUserListeners) {
                    listener.onJoinLive(it)
                }
            }
        } else {
            mJoinLiveUserList.first { it.userId == joinLiveCountChange.uid }.let {
                mJoinLiveUserList.remove(it)
                for (listener in joinLiveUserListeners) {
                    listener.onLeaveJoinLive(it.userId)
                }
            }
        }
    }

    /**
     * 用户列表变更，新增/减少
     */
    private fun onUserListChanged(userCountChange: UserCountChange) {
        heartBeatMonitor?.setAttendeeSeq(userCountChange.seq)
        when (userCountChange.delta) {
            RoomNotify.USER_ENTER -> {
                val newUser = ClassUser.create(userCountChange)
                mRoomUserMap[newUser.userId] = newUser
                for (listener in mUserListeners) {
                    listener.onUserEnter(newUser)
                }
            }
            RoomNotify.USER_LEAVE -> {
                val leaveUser = mRoomUserMap.remove(userCountChange.uid)
                for (listener in mUserListeners) {
                    listener.onUserLeave(leaveUser)
                }
            }
            else -> {
                Logger.w(TAG, "onUserListChanged() unknownChanged ${userCountChange.delta}")
            }
        }
    }

    /**
     * 用户属性变化，camera/mic/share
     */
    private fun onUserStateChange(userStateChange: UserStateChange) {
        Logger.i(TAG, "onUserStateChange() ${userStateChange.type}")
        // 是否自己修改，提示语
        val isSelfOperation = userStateChange.operatorUid == myUserId

        userStateChange.users.forEach { user ->
            mRoomUserMap[user.uid]?.copyFrom(user)
            mJoinLiveUserList.firstOrNull { it.userId == user.uid }?.copyFrom(user)

            when (userStateChange.type) {
                RoomNotify.CHANGED_TYPE_ROLE -> {
                    // 目前没有处理
                }
                RoomNotify.CHANGED_TYPE_CAMERA -> {
                    val cameraOn = user.camera == ZegoApiConstants.Status.OPEN
                    for (listener in mUserListeners) {
                        listener.onUserCameraChanged(user.uid, cameraOn, isSelfOperation)
                    }
                }
                RoomNotify.CHANGED_TYPE_MIC -> {
                    val micOn = user.mic == ZegoApiConstants.Status.OPEN
                    for (listener in mUserListeners) {
                        listener.onUserMicChanged(user.uid, micOn, isSelfOperation)
                    }
                }
                RoomNotify.CHANGED_TYPE_SHARE -> {
                    val sharable = user.canShare == ZegoApiConstants.Status.OPEN
                    for (listener in mUserListeners) {
                        listener.onUserShareChanged(user.uid, sharable, isSelfOperation)
                    }
                }
                else -> {
                    Logger.e(TAG, "onUserStateChange() unknown type ${userStateChange.type}")
                }
            }
        }

    }

    /**
     * 查看当前连麦列表中，学生的数量。
     */
    private fun calculateJoinLiveStudentCount(): Int {
        var count = 0
        mJoinLiveUserList.forEach { user ->
            if (user.role == ZegoApiConstants.Role.STUDENT) {
                count++
            }
        }
        return count
    }

    /**
     * （可以打开指定 userId 用户的摄像头/麦克风）
     * 1、指定 userId 用户是老师
     * 2、指定 userId 用户已经连麦（摄像头或麦克风已经开了其中一个）(小班课)
     * 3、指定 userId 用户没有连麦，且连麦的学生数量小于3 (小班课)
     */
    fun canOpenCameraOrMic(userId: Long): Boolean {
        return mRoomUserMap[userId]!!.role == ZegoApiConstants.Role.TEACHER
                || (isSmallClass() && (mJoinLiveUserList.find { it.userId == userId } != null))
                || (isSmallClass() && calculateJoinLiveStudentCount() < JOIN_LIVE_STUDENT_MAX)
    }

    fun setRoomStateListener(listener: IZegoRoomStateListener) {
        roomStatelistener = listener
        ZegoSDKManager.getInstance().setRoomStateListener(object : IZegoRoomStateListener {
            override fun onConnected(errorCode: Int, roomID: String) {
                listener.onConnected(errorCode, roomID)
                heartBeatMonitor?.restart()
                getAttendeeList {}
                getJoinLiveList {}
            }

            override fun onDisconnect(errorCode: Int, roomID: String) {
                listener.onDisconnect(errorCode, roomID)
                heartBeatMonitor?.pause()
            }

            override fun connecting(errorCode: Int, roomID: String) {
                listener.connecting(errorCode, roomID)
                heartBeatMonitor?.pause()
            }
        })
    }

}
