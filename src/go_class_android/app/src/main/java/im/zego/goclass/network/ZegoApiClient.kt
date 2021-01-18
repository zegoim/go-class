package im.zego.goclass.network

import android.content.Context
import android.util.Log
import android.widget.Toast
import com.google.gson.Gson
import im.zego.goclass.BackendApiConstants
import im.zego.goclass.R
import im.zego.goclass.tool.ToastUtils
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.io.InterruptedIOException
import java.net.SocketTimeoutException
import java.net.UnknownHostException
import java.util.concurrent.TimeUnit

object ZegoApiClient {
    private val TAG = "ZegoApiClient"
    private val gson = Gson()
    private val MEDIA_TYPE_JSON = "application/json; charset=utf-8".toMediaType()

    private lateinit var client: OkHttpClient
    private lateinit var retrofit: Retrofit
    private lateinit var classApi: ZegoClassApiService
    private var context: Context? = null

    @JvmStatic
    fun setAppContext(context: Context?, isTestEnv: Boolean, isMainLandEnv: Boolean) {
        // 仅仅在测试 http 接口的时候才会传一个空值
        if (context != null) {
            this.context = context.applicationContext
        }
        client = OkHttpClient.Builder()
            .connectTimeout(60, TimeUnit.SECONDS)
            .writeTimeout(60, TimeUnit.SECONDS)
            .readTimeout(60, TimeUnit.SECONDS)
            .callTimeout(60, TimeUnit.SECONDS)
            .addInterceptor(HttpLoggingInterceptor().setLevel(HttpLoggingInterceptor.Level.BASIC))
            .build()

        val baseUrl = if (isTestEnv) {
            if (isMainLandEnv) {
                BackendApiConstants.BACKEND_API_URL_TEST
            } else {
                BackendApiConstants.BACKEND_API_URL_TEST_OVERSEAS
            }
        } else {
            if (isMainLandEnv) {
                BackendApiConstants.BACKEND_API_URL
            } else {
                BackendApiConstants.BACKEND_API_URL_OVERSEAS
            }
        }
        retrofit = Retrofit.Builder()
            .baseUrl(baseUrl)
            .addConverterFactory(GsonConverterFactory.create())
            .client(client)
            .build()
        classApi = retrofit.create(ZegoClassApiService::class.java)
    }

    @JvmStatic
    fun loginRoom(
        loginParam: LoginReqParam,
        requestCallback: RequestCallback<LoginRspData>?
    ) {
        val request = classApi.login(gson.toJson(loginParam).toRequestBody(MEDIA_TYPE_JSON))
        sendAsyncCall(request, object : RequestCallback<LoginRspData> {
            override fun onResult(result: Result, t: LoginRspData?) {
                requestCallback?.onResult(result, t)
                Log.d(TAG, "loginRoom onResult() called with: result = $result, t = $t")
            }
        })
    }

    @JvmStatic
    fun getAttendeeList(
        uid: Long,
        roomID: String,
        roomType: Int,
        requestCallback: RequestCallback<GetAttendeeListRspData>?
    ) {
        val map = mapOf<String, Any>("uid" to uid, "room_id" to roomID, "room_type" to roomType)
        val request = classApi.getAttendeeList(gson.toJson(map).toRequestBody(MEDIA_TYPE_JSON))
        sendAsyncCall(request, object : RequestCallback<GetAttendeeListRspData> {
            override fun onResult(result: Result, t: GetAttendeeListRspData?) {
                requestCallback?.onResult(result, t)
            }
        })
    }

    @JvmStatic
    fun getJoinLiveList(
        uid: Long,
        roomID: String,
        roomType: Int,
        requestCallback: RequestCallback<GetJoinLiveListRspData>?
    ) {
        val map = mapOf<String, Any>("uid" to uid, "room_id" to roomID, "room_type" to roomType)
        val request = classApi.getJoinLiveList(gson.toJson(map).toRequestBody(MEDIA_TYPE_JSON))
        sendAsyncCall(request, object : RequestCallback<GetJoinLiveListRspData> {
            override fun onResult(result: Result, t: GetJoinLiveListRspData?) {
                requestCallback?.onResult(result, t)
            }
        })
    }

    @JvmStatic
    fun getUserInfo(
        uid: Long,
        roomID: String,
        targetUID: Long,
        roomType: Int,
        requestCallback: RequestCallback<GetUserInfoRspData>?
    ) {
        val map = mapOf<String, Any>("uid" to uid, "room_id" to roomID, "target_uid" to targetUID, "room_type" to roomType)
        val request = classApi.getUserInfo(gson.toJson(map).toRequestBody(MEDIA_TYPE_JSON))
        sendAsyncCall(request, object : RequestCallback<GetUserInfoRspData> {
            override fun onResult(result: Result, t: GetUserInfoRspData?) {
                requestCallback?.onResult(result, t)
                if (result.code != 0) {
                    ToastUtils.showCenterToast(result.message)
                }
            }
        })
    }

    @JvmStatic
    fun setUserInfo(reqParam: SetUserInfoReqParam, requestCallback: RequestCallback<Any>?) {
        val request = classApi.setUserInfo(gson.toJson(reqParam).toRequestBody(MEDIA_TYPE_JSON))
        sendAsyncCall(request, object : RequestCallback<Any> {
            override fun onResult(result: Result, t: Any?) {
                requestCallback?.onResult(result, t)
            }
        })
    }

    @JvmStatic
    fun startShare(
        uid: Long,
        roomID: String,
        requestCallback: RequestCallback<Any>?
    ) {
        val map = mapOf<String, Any>("uid" to uid, "room_id" to roomID)
        val request = classApi.startShare(gson.toJson(map).toRequestBody(MEDIA_TYPE_JSON))
        sendAsyncCall(request, object : RequestCallback<Any> {
            override fun onResult(result: Result, t: Any?) {
                requestCallback?.onResult(result, t)
                if (result.code != 0) {
                    ToastUtils.showCenterToast(result.message)
                }
            }
        })
    }

    @JvmStatic
    fun stopShare(
        uid: Long,
        roomID: String,
        targetUID: Long,
        requestCallback: RequestCallback<Any>?
    ) {
        val map = mapOf<String, Any>("uid" to uid, "room_id" to roomID, "target_uid" to targetUID)
        val request = classApi.stopShare(gson.toJson(map).toRequestBody(MEDIA_TYPE_JSON))
        sendAsyncCall(request, object : RequestCallback<Any> {
            override fun onResult(result: Result, t: Any?) {
                requestCallback?.onResult(result, t)
                if (result.code != 0) {
                    ToastUtils.showCenterToast(result.message)
                }
            }
        })
    }

    @JvmStatic
    fun leaveRoom(
        uid: Long,
        roomID: String,
        roomType: Int,
        requestCallback: RequestCallback<Any>?
    ) {
        val map = mapOf<String, Any>("uid" to uid, "room_id" to roomID, "room_type" to roomType)
        val request = classApi.leaveRoom(gson.toJson(map).toRequestBody(MEDIA_TYPE_JSON))
        sendAsyncCall(request, object : RequestCallback<Any> {
            override fun onResult(result: Result, t: Any?) {
                requestCallback?.onResult(result, t)
            }
        })
    }

    @JvmStatic
    fun endTeaching(
        uid: Long,
        roomID: String,
        roomType: Int,
        requestCallback: RequestCallback<Any>?
    ) {
        val map = mapOf<String, Any>("uid" to uid, "room_id" to roomID, "room_type" to roomType)
        val request = classApi.endTeaching(gson.toJson(map).toRequestBody(MEDIA_TYPE_JSON))
        sendAsyncCall(request, object : RequestCallback<Any> {
            override fun onResult(result: Result, t: Any?) {
                requestCallback?.onResult(result, t)
            }
        })
    }

    @JvmStatic
    fun heartBeat(
        uid: Long,
        roomID: String,
        roomType: Int,
        requestCallback: RequestCallback<HeartBeatRspData>?
    ) {
        val map = mapOf<String, Any>("uid" to uid, "room_id" to roomID, "room_type" to roomType)
        val request = classApi.heartBeat(gson.toJson(map).toRequestBody(MEDIA_TYPE_JSON))
        sendAsyncCall(request, object : RequestCallback<HeartBeatRspData> {
            override fun onResult(result: Result, t: HeartBeatRspData?) {
                requestCallback?.onResult(result, t)
                if (result.code != 0 && result.code != ZegoApiErrorCode.NEED_LOGIN) {
                    ToastUtils.showCenterToast(result.message)
                }
            }
        })
    }

    private fun <T> sendAsyncCall(
        call: Call<ZegoApiResponse<T>>,
        requestCallback: RequestCallback<T>?,
    ) {
        call.enqueue(object : Callback<ZegoApiResponse<T>> {
            override fun onResponse(
                call: Call<ZegoApiResponse<T>>,
                response: Response<ZegoApiResponse<T>>,
            ) {
                val body = response.body()
                if (body != null) {
                    body.ret.message = ZegoApiErrorCode.getPublicMsgFromCode(body.ret.code, context)
                    requestCallback?.onResult(body.ret, body.data)
                } else {
                    val result = Result(
                        ZegoApiErrorCode.NETWORK_ERROR,
                        ZegoApiErrorCode.getPublicMsgFromCode(ZegoApiErrorCode.NETWORK_ERROR, context)
                    )
                    requestCallback?.onResult(result, null)
                }
            }

            override fun onFailure(call: Call<ZegoApiResponse<T>>, error: Throwable) {
                Log.d(TAG, "onFailure() called with: call = $call, error = $error")
                val result: Result =
                    if (error is UnknownHostException || error is SocketTimeoutException) {
                        Result(
                            ZegoApiErrorCode.NETWORK_UNCONNECTED,
                            ZegoApiErrorCode.getPublicMsgFromCode(ZegoApiErrorCode.NETWORK_UNCONNECTED, context)
                        )
                    } else if (error is InterruptedIOException && error.message == "timeout") {
                        Result(
                            ZegoApiErrorCode.NETWORK_TIMEOUT,
                            ZegoApiErrorCode.getPublicMsgFromCode(ZegoApiErrorCode.NETWORK_ERROR, context)
                        )
                    } else {
                        Result(
                            ZegoApiErrorCode.NETWORK_ERROR,
                            ZegoApiErrorCode.getPublicMsgFromCode(ZegoApiErrorCode.NETWORK_ERROR, context)
                        )
                    }
                requestCallback?.onResult(result, null)
            }
        })
    }

    interface RequestCallback<in T> {
        fun onResult(result: Result, t: T?)
    }
}