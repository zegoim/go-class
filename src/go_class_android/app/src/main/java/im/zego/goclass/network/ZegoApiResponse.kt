package im.zego.goclass.network

import com.google.gson.annotations.SerializedName

data class ZegoApiResponse<T>(
    @SerializedName("ret")
    val ret: Result,
    @SerializedName("data")
    val data: T
)

data class Result(
    val code: Int,
    var message: String
)

data class LoginRspData(
    @SerializedName("allow_turn_on_camera")
    val allowTurnOnCamera: Int,
    @SerializedName("allow_turn_on_mic")
    val allowTurnOnMic: Int,
    @SerializedName("default_camera_state")
    val defaultCameraState: Int,
    @SerializedName("default_mic_state")
    val defaultMicState: Int,
    @SerializedName("role")
    val role: Int,
    @SerializedName("room_id")
    val roomId: String,
    @SerializedName("sharing_uid")
    val sharingUid: Long,
    @SerializedName("camera")
    val camera: Int,
    @SerializedName("mic")
    val mic: Int,
    @SerializedName("can_share")
    val canShare: Int,
    @SerializedName("max_join_live_num")
    val maxJoinLiveNum: Int
)

data class GetAttendeeListRspData(
    @SerializedName("attendee_list")
    val attendeeList: List<GetUserInfoRspData>,
    @SerializedName("room_id")
    val roomId: String,
    @SerializedName("seq")
    val seq: Int
)

data class GetJoinLiveListRspData(
    @SerializedName("join_live_list")
    val joinLiveUserList: List<GetUserInfoRspData>,
    @SerializedName("room_id")
    val roomId: String,
    @SerializedName("seq")
    val seq: Int
)

data class GetUserInfoRspData(
    @SerializedName("uid")
    val uid: Long,
    @SerializedName("camera")
    val camera: Int,
    @SerializedName("can_share")
    val canShare: Int,
    @SerializedName("mic")
    val mic: Int,
    @SerializedName("nick_name")
    val nickName: String,
    @SerializedName("role")
    val role: Int,
    @SerializedName("login_time")
    val loginTime: Long,
    @SerializedName("join_live_time")
    val joinLiveTime: Long
)

data class HeartBeatRspData(
    @SerializedName("attendee_list_seq")
    val attendeeListSeq: Int,
    @SerializedName("interval")
    val interval: Long,
    @SerializedName("join_live_list_seq")
    val joinLiveListSeq: Int
)