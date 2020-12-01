package im.zego.goclass.network

import okhttp3.RequestBody
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.POST

interface ZegoClassApiService {

    @POST("edu_room/login_room")
    fun login(@Body requestBody: RequestBody): Call<ZegoApiResponse<LoginRspData>>

    @POST("edu_room/get_attendee_list")
    fun getAttendeeList(@Body requestBody: RequestBody): Call<ZegoApiResponse<GetAttendeeListRspData>>

    @POST("edu_room/get_join_live_list")
    fun getJoinLiveList(@Body requestBody: RequestBody): Call<ZegoApiResponse<GetJoinLiveListRspData>>

    @POST("edu_room/get_user_info")
    fun getUserInfo(@Body requestBody: RequestBody): Call<ZegoApiResponse<GetUserInfoRspData>>

    @POST("edu_room/set_user_info")
    fun setUserInfo(@Body requestBody: RequestBody): Call<ZegoApiResponse<Any>>

    @POST("edu_room/start_share")
    fun startShare(@Body requestBody: RequestBody): Call<ZegoApiResponse<Any>>

    @POST("edu_room/stop_share")
    fun stopShare(@Body requestBody: RequestBody): Call<ZegoApiResponse<Any>>

    @POST("edu_room/leave_room")
    fun leaveRoom(@Body requestBody: RequestBody): Call<ZegoApiResponse<Any>>

    @POST("edu_room/end_teaching")
    fun endTeaching(@Body requestBody: RequestBody): Call<ZegoApiResponse<Any>>

    @POST("edu_room/heartbeat")
    fun heartBeat(@Body requestBody: RequestBody): Call<ZegoApiResponse<HeartBeatRspData>>
}