package im.zego.goclass.network

import com.google.gson.annotations.SerializedName


data class LoginReqParam(
    @SerializedName("uid")
    val uid: Long,
    @SerializedName("room_id")
    val roomId: String,
    @SerializedName("nick_name")
    val nickName: String,
    @SerializedName("role")
    val role: Int,
    @SerializedName("room_type")
    val roomType:Int
)

data class SetUserInfoReqParam(
    @SerializedName("uid")
    val uid: Long,
    @SerializedName("room_id")
    val roomId: String,
    @SerializedName("target_uid")
    val targetUid: Long,
    @SerializedName("camera")
    val camera: Int?,
    @SerializedName("mic")
    val mic: Int?,
    @SerializedName("can_share")
    val canShare: Int?,
    @SerializedName("room_type")
    val roomType:Int
)