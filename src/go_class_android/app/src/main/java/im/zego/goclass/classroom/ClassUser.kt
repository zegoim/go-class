package im.zego.goclass.classroom

import im.zego.goclass.network.GetUserInfoRspData
import im.zego.goclass.network.JoinLiveCountChange
import im.zego.goclass.network.UserCountChange
import im.zego.goclass.network.ZegoApiConstants

/**
 * 业务后台的user类定义
 */
data class ClassUser(
    var userId: Long,
    var userName: String,
    var role: Int,
    var cameraOn: Boolean,
    var micOn: Boolean,
    var sharable: Boolean,
    var loginTime: Long,
    var joinLiveTime: Long,
) {

    fun copyFrom(joinRoomUser: GetUserInfoRspData) {
        userId = joinRoomUser.uid
        userName = joinRoomUser.nickName
        role = joinRoomUser.role
        cameraOn = joinRoomUser.camera == ZegoApiConstants.Status.OPEN
        micOn = joinRoomUser.mic == ZegoApiConstants.Status.OPEN
        sharable = joinRoomUser.canShare == ZegoApiConstants.Status.OPEN
        loginTime = joinRoomUser.loginTime
        joinLiveTime = joinRoomUser.joinLiveTime
    }

    companion object {

        /**
         * 根据 joinRoomUser 生成 GoClassUser
         */
        @JvmStatic
        fun create(joinRoomUser: GetUserInfoRspData): ClassUser {
            return ClassUser(
                joinRoomUser.uid,
                joinRoomUser.nickName,
                joinRoomUser.role,
                joinRoomUser.camera == ZegoApiConstants.Status.OPEN,
                joinRoomUser.mic == ZegoApiConstants.Status.OPEN,
                joinRoomUser.canShare == ZegoApiConstants.Status.OPEN,
                joinRoomUser.loginTime,
                joinRoomUser.joinLiveTime
            )
        }

        @JvmStatic
        fun create(userCountChange: UserCountChange): ClassUser {
            return ClassUser(
                userCountChange.uid,
                userCountChange.nickName,
                userCountChange.role,
                userCountChange.camera == ZegoApiConstants.Status.OPEN,
                userCountChange.mic == ZegoApiConstants.Status.OPEN,
                userCountChange.canShare == ZegoApiConstants.Status.OPEN,
                userCountChange.loginTime,
                userCountChange.joinLiveTime
            )
        }

        @JvmStatic
        fun create(joinLiveCountChange: JoinLiveCountChange): ClassUser {
            return ClassUser(
                joinLiveCountChange.uid,
                joinLiveCountChange.nickName,
                joinLiveCountChange.role,
                joinLiveCountChange.camera == ZegoApiConstants.Status.OPEN,
                joinLiveCountChange.mic == ZegoApiConstants.Status.OPEN,
                joinLiveCountChange.canShare == ZegoApiConstants.Status.OPEN,
                joinLiveCountChange.loginTime,
                joinLiveCountChange.joinLiveTime
            )
        }
    }

    /**
     * 根据 mic 和 camera 的状态来判断，有一个是开启的即是连麦状态
     * @return 是否连麦
     */
    fun isJoinLive(): Boolean {
        return cameraOn || micOn
    }

    fun isTeacher(): Boolean {
        return role == ZegoApiConstants.Role.TEACHER
    }
}