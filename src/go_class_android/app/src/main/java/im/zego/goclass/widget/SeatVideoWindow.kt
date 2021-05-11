package im.zego.goclass.widget

import android.content.Context
import android.util.AttributeSet
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.core.view.children
import im.zego.goclass.dp2px
import im.zego.goclass.entity.ZegoPublishStream
import im.zego.goclass.entity.ZegoStream
import im.zego.goclass.network.ZegoApiConstants
import im.zego.goclass.sdk.IStreamCountListener
import im.zego.goclass.sdk.ZegoSDKManager
import im.zego.goclass.classroom.JoinLiveUserListener
import im.zego.goclass.classroom.ClassRoomManager
import im.zego.goclass.classroom.ClassUser
import im.zego.goclass.classroom.ClassUserListener
import im.zego.goclass.tool.Logger

/**
 * 坐席区的视频窗口列表
 */
class SeatVideoWindow : LinearLayout, ClassUserListener, JoinLiveUserListener {

    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet) : super(context, attrs)
    constructor(context: Context, attrs: AttributeSet, defStyleAttr: Int)
            : super(context, attrs, defStyleAttr)

    private var teacherSeatVideoView: SeatVideoView? = null

    companion object {
        const val TAG = "SeatVideoWindow"
    }

    /**
     * Activity 准备好之后调用
     */
    fun initViews() {
        initSeatVideoViews()
        setListeners()
    }

    private fun setListeners() {
        ZegoSDKManager.getInstance().setStreamCountListener(object : IStreamCountListener {
            override fun onStreamAdd(zegostream: ZegoStream) {
                Logger.d(TAG, "onStreamAdd:${zegostream.streamID}")
                ClassRoomManager.mJoinLiveUserList.firstOrNull {
                    it.userId == zegostream.userID.toLong()
                }?.let {
                    addUserVideoViewOrUpdate(it)
                }
            }

            override fun onStreamRemove(zegostream: ZegoStream) {
                Logger.d(TAG, "onStreamRemove:${zegostream.streamID}")
//                removeUserVideoView(zegostream.userID.toLong())
            }
        })
    }

    override fun onViewAdded(child: View) {
        super.onViewAdded(child)
        Logger.d(TAG, "onViewAdded() called with: child = ${(child as SeatVideoView).getSeatUser()}")
    }

    override fun onViewRemoved(child: View) {
        super.onViewRemoved(child)
        Logger.d(TAG, "onViewRemoved() called with: child = ${(child as SeatVideoView).getSeatUser()}")
    }

    /**
     * 加入课堂，根据业务更新坐席区UI
     */
    private fun initSeatVideoViews() {
        val joinLiveUserList = ClassRoomManager.mJoinLiveUserList
        val allUserList = ClassRoomManager.mRoomUserMap.values

        teacherSeatVideoView = SeatVideoView(context)
        val layoutParams =
            ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dp2px(context, 90f).toInt())
        addView(teacherSeatVideoView, layoutParams)
        // 老师在课堂，没有在连麦列表， 需要把老师的属性更新到view上
        val teacher = allUserList.firstOrNull { it.isTeacher() }
        val teacherNotJoinLive = joinLiveUserList.firstOrNull { it.isTeacher() } == null
        if (teacher != null && teacherNotJoinLive) {
            addUserVideoViewOrUpdate(teacher)
        }

        // 存量连麦成员，渲染到坐席区
        joinLiveUserList.forEach {
            addUserVideoViewOrUpdate(it)
        }
    }

    /**
     * 自己的麦克风和摄像头发生来变化。在mainActivity先处理了权限弹框问题
     * 来自业务后台到通知，用户camera/mic状态发生改变
     */
    private fun updatePublish() {
        val publishStreamID =
            ZegoSDKManager.getInstance().streamService.generatePublishStreamID(ClassRoomManager.myUserId.toString())
        val me = ClassRoomManager.me()
        ZegoSDKManager.getInstance().streamService.getStream(publishStreamID)?.let { stream ->
            val cameraOn = me.cameraOn
            val micOn = me.micOn
            stream.setCameraStatus(cameraOn)
            ZegoSDKManager.getInstance().deviceService.enableCamera(cameraOn)
            stream.setMicPhoneStatus(micOn)
            ZegoSDKManager.getInstance().deviceService.enableMic(micOn)

            if (micOn || cameraOn) {
                addUserVideoViewOrUpdate(me)
            } else {
                removeUserVideoView(ClassRoomManager.myUserId)
            }
        }

    }

    /**
     * 会进行推流的动作
     * @param classUser GoClassUser
     */
    fun addUserVideoViewOrUpdate(classUser: ClassUser) {
        var seatVideoView: SeatVideoView? = children.firstOrNull {
            (it is SeatVideoView && it.getAssociatedUserID() == classUser.userId)
        } as? SeatVideoView

        if (seatVideoView == null) {
            val isTeacher = classUser.role == ZegoApiConstants.Role.TEACHER
            if (isTeacher) {
                // 判断下角色，如果是老师，直接用指定的view
                seatVideoView = teacherSeatVideoView
            } else {
                seatVideoView = SeatVideoView(context)
                val layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    dp2px(context, 90f).toInt()
                )
                Logger.i(TAG, "addUserVideoViewOrUpdate: goClassUser $classUser,  childCount = $childCount")
                addView(seatVideoView, layoutParams)
            }
        }
        seatVideoView!!.setSeatUser(classUser)
    }

    private fun removeUserVideoView(userID: Long) {
        children.forEach {
            if (it is SeatVideoView) {
                if (it.getAssociatedUserID() == userID) {
                    it.stopStream()
                    // 判断下角色，如果当前位置是老师的，保留的view(1、老师在课堂，显示老师的属性；2、老师不在课堂，显示占位符)
                    //           如果不是老师的，删除view
                    if (it.getSeatUser()!!.isTeacher()) {
                        it.setSeatUser(ClassRoomManager.teacher())
                    } else {
                        removeView(it)
                    }
                }
            }
        }
    }

    override fun onUserEnter(user: ClassUser?) {
        Logger.i(TAG, "onUserEnter()")
        if (user!!.role == ZegoApiConstants.Role.TEACHER) {
            addUserVideoViewOrUpdate(user)
        }
    }

    override fun onUserLeave(user: ClassUser?) {
        Logger.i(TAG, "onUserLeave()")
        if (user!!.role == ZegoApiConstants.Role.TEACHER) { // 老师离开了，重置下
            teacherSeatVideoView?.setSeatUser(null)
        }
    }

    override fun onUserCameraChanged(userId: Long, on: Boolean, selfChanged: Boolean) {
        if (isSelf(userId)) {
            updatePublish()
        } else {
            ClassRoomManager.mJoinLiveUserList.firstOrNull { it.userId == userId }
                ?.let { goClassUser ->
                    addUserVideoViewOrUpdate(goClassUser)
                }
        }
    }

    override fun onUserMicChanged(userId: Long, on: Boolean, selfChanged: Boolean) {
        if (isSelf(userId)) {
            updatePublish()
        } else {
            ClassRoomManager.mJoinLiveUserList.firstOrNull { it.userId == userId }
                ?.let { goClassUser ->
                    addUserVideoViewOrUpdate(goClassUser)
                }
        }
    }

    override fun onUserShareChanged(userId: Long, on: Boolean, selfChanged: Boolean) {
        if (isSelf(userId)) {
            updatePublish()
        } else {
            ClassRoomManager.mJoinLiveUserList.firstOrNull { it.userId == userId }
                ?.let { goClassUser ->
                    addUserVideoViewOrUpdate(goClassUser)
                }
        }
    }

    override fun onRoomUserUpdate() {

    }

    /**
     * 获取连麦列表更新会调用到这里
     * 如果拉取连麦列表发现自己在麦序上，要重新设置自己的摄像头麦克风硬件的状态
     */
    override fun onJoinLiveUserUpdate() {
        removeAllViews()

        val firstOrNull = ClassRoomManager.mJoinLiveUserList.firstOrNull { isSelf(it.userId) }
        firstOrNull?.apply {
            val publishStreamID =
                ZegoSDKManager.getInstance().streamService.generatePublishStreamID(userId.toString())
            var zegoStream =
                ZegoSDKManager.getInstance().streamService.getStream(publishStreamID)
            if (zegoStream == null) {
                zegoStream = ZegoPublishStream(userId.toString(), userName, publishStreamID)
                ZegoSDKManager.getInstance().streamService.addStream(zegoStream)
            }

            zegoStream.setCameraStatus(cameraOn)
            ZegoSDKManager.getInstance().deviceService.enableCamera(cameraOn)

            zegoStream.setMicPhoneStatus(micOn)
            ZegoSDKManager.getInstance().deviceService.enableMic(micOn)
        }

        initSeatVideoViews()
    }

    private fun isSelf(userId: Long): Boolean {
        val isSelf = userId == ClassRoomManager.myUserId
        return isSelf
    }

    override fun onJoinLive(classUser: ClassUser) {
        Logger.i(TAG, "onJoinLive() goClassUser: $classUser")
        classUser.apply {
            if (isSelf(classUser.userId)) {
                //自己要进行推流
                val publishStreamID =
                    ZegoSDKManager.getInstance().streamService.generatePublishStreamID(userId.toString())
                var zegoStream =
                    ZegoSDKManager.getInstance().streamService.getStream(publishStreamID)
                if (zegoStream == null) {
                    zegoStream = ZegoPublishStream(userId.toString(), userName, publishStreamID)
                    ZegoSDKManager.getInstance().streamService.addStream(zegoStream)
                }

                zegoStream.setCameraStatus(cameraOn)
                ZegoSDKManager.getInstance().deviceService.enableCamera(cameraOn)

                zegoStream.setMicPhoneStatus(micOn)
                ZegoSDKManager.getInstance().deviceService.enableMic(micOn)
                addUserVideoViewOrUpdate(classUser)
            } else {
                // 拉流由streamService负责
                addUserVideoViewOrUpdate(classUser)
            }
        }
    }

    override fun onLeaveJoinLive(userId: Long) {
        val streamService = ZegoSDKManager.getInstance().streamService
        if (ClassRoomManager.myUserId == userId) {
            val publishStreamID = streamService.generatePublishStreamID(userId.toString())
            streamService.getStream(publishStreamID)?.let { stream ->
                stream.setCameraStatus(false)
                ZegoSDKManager.getInstance().deviceService.enableCamera(false)
            }
        }
        removeUserVideoView(userId)
    }

}


