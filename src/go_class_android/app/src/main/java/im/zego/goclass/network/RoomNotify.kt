package im.zego.goclass.network

import com.google.gson.annotations.SerializedName


data class RoomNotify(
    @SerializedName("cmd")
    val cmd: Int,
    @SerializedName("data")
    var data: String
) {
    companion object {
        const val CMD_ROOM_STATE_CHANGED = 101
        const val CMD_USER_CHANGED = 102
        const val CMD_USER_LIST_CHANGED = 103
        const val CMD_JOIN_LIVE_USER_LIST_CHANGED = 104
        const val CMD_END_TEACH = 105
        const val CMD_START_SHARE = 106
        const val CMD_END_SHARE = 107

        const val CHANGED_TYPE_ROLE = 1
        const val CHANGED_TYPE_CAMERA = 2
        const val CHANGED_TYPE_MIC = 3
        const val CHANGED_TYPE_SHARE = 4

        const val USER_ENTER = 1
        const val USER_LEAVE = -1
    }

}

data class ConfigChange(
    @SerializedName("allow_turn_on_camera")
    val allowTurnOnCamera: Int,
    @SerializedName("allow_turn_on_mic")
    val allowTurnOnMic: Int,
    @SerializedName("default_camera_state")
    val defaultCameraState: Int,
    @SerializedName("default_mic_state")
    val defaultMicState: Int,
    @SerializedName("operator_name")
    val operatorName: String,
    @SerializedName("operator_uid")
    val operatorUid: Long,
    @SerializedName("sharing_uid")
    val sharingUid: Long,
    @SerializedName("type")
    val type: Int
)

data class UserStateChange(
    @SerializedName("operator_name")
    val operatorName: String,
    @SerializedName("operator_uid")
    val operatorUid: Long,
    @SerializedName("type")
    val type: Int,
    @SerializedName("users")
    val users: List<GetUserInfoRspData>
)

data class UserCountChange(
    @SerializedName("camera")
    val camera: Int,
    @SerializedName("can_share")
    val canShare: Int,
    /**
     * 1增加 -1 减少
     */
    @SerializedName("delta")
    val delta: Int,
    @SerializedName("mic")
    val mic: Int,
    @SerializedName("nick_name")
    val nickName: String,
    @SerializedName("role")
    val role: Int,
    @SerializedName("seq")
    val seq: Int,
    @SerializedName("type")
    val type: Int,
    @SerializedName("uid")
    val uid: Long,
    @SerializedName("login_time")
    val loginTime: Long,
    @SerializedName("join_live_time")
    val joinLiveTime: Long
)

data class JoinLiveCountChange(
    @SerializedName("delta")
    val delta: Int,
    @SerializedName("nick_name")
    val nickName: String,
    @SerializedName("seq")
    val seq: Int,
    @SerializedName("type")
    val type: Int,
    @SerializedName("uid")
    val uid: Long,
    @SerializedName("camera")
    val camera: Int,
    @SerializedName("can_share")
    val canShare: Int,
    @SerializedName("mic")
    val mic: Int,
    @SerializedName("role")
    val role: Int,
    @SerializedName("login_time")
    val loginTime: Long,
    @SerializedName("join_live_time")
    val joinLiveTime: Long
) {
    fun isAdd(): Boolean {
        return delta == 1
    }

    fun teacherJoin(): Boolean {
        return type == 1
    }

    fun teacherLeave(): Boolean {
        return type == 3
    }

    fun stuJoin(): Boolean {
        return type == 2
    }

    fun stuLeave(): Boolean {
        return type == 4
    }
}

data class EndTeaching(
    @SerializedName("operator_name")
    val operatorName: String,
    @SerializedName("operator_uid")
    val operatorUid: Long
)

data class StartShare(
    @SerializedName("sharing_name")
    val sharingName: String,
    @SerializedName("sharing_uid")
    val sharingUid: Long
)

data class StopShare(
    @SerializedName("operator_name")
    val operatorName: String,
    @SerializedName("operator_uid")
    val operatorUid: Long,
    @SerializedName("target_name")
    val targetName: String,
    @SerializedName("target_uid")
    val targetUid: Long
)