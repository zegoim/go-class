package im.zego.goclass.sdk


import android.app.Application
import android.util.Log
import android.view.TextureView
import im.zego.goclass.AppConstants
import im.zego.goclass.classroom.ClassRoomManager
import im.zego.goclass.entity.ChatMsg
import im.zego.goclass.entity.ZegoClassUser
import im.zego.goclass.entity.ZegoPlayStream
import im.zego.zegoexpress.ZegoExpressEngine
import im.zego.zegoexpress.callback.IZegoEventHandler
import im.zego.zegoexpress.constants.*
import im.zego.zegoexpress.entity.*
import im.zego.zegoquality.ZegoQualityManager
import org.json.JSONObject
import java.io.File
import java.util.*

class ZegoExpressWrapper : IZegoVideoSDKProxy {
    private val TAG = "ZegoExpressWrapper"
    private lateinit var expressEngine: ZegoExpressEngine

    private var publishResultMap = mutableMapOf<String, IStreamPublishCallback>()
    private var playResultMap = mutableMapOf<String, IStreamPlayCallback>()

    private var userListener: IClassUserListener? = null
    private var zegoRoomStateListener: IZegoRoomStateListener? = null
    private var kickOutListener: IKickOutListener? = null
    private var streamCountListener: IStreamCountListener? = null
    private var remoteDeviceStateListener: IRemoteDeviceStateListener? = null
    private var localDeviceErrorListener: ILocalDeviceErrorListener? = null
    private var customCommandListener: ICustomCommandListener? = null
    private var roomExtraInfoUpdateListener: IRoomExtraInfoUpdateListener? = null
    private var loginResult: (Int) -> Unit = {}
    private var isLoginRoom = false
    private var zegoBigRoomMsgListener: IZegoMsgListener? = null
    private var zegoMsgListener: IZegoMsgListener? = null

    override fun initSDK(
        application: Application,
        appID: Long,
        appSign: String,
        initCallback: ZegoSDKManager.InitResult
    ) {
        Log.d(TAG, "init ZegoExpressEngine ,version:${ZegoExpressEngine.getVersion()}")
        val zegoLogConfig = ZegoLogConfig()
        zegoLogConfig.logPath = application.getExternalFilesDir(null)!!.absolutePath + File.separator + AppConstants.LOG_SUBFOLDER
        zegoLogConfig.logSize = 5*1024*1024
        val config = ZegoEngineConfig()
        config.advancedConfig["allow_verbose_print_high_frequency_content"] = "true"
        config.advancedConfig["enable_callback_verbose"] = "true"
        config.advancedConfig["use_data_record"] = "true"
        ZegoExpressEngine.setEngineConfig(config)
        ZegoExpressEngine.setLogConfig(zegoLogConfig)
        val profile = ZegoEngineProfile()
        profile.appID = appID
        profile.appSign = appSign
        profile.scenario = ZegoScenario.COMMUNICATION
        profile.application = application
        val engine = ZegoExpressEngine.createEngine(profile,null)
        if (engine == null) {
            initCallback.initResult(false)
            return
        }

        expressEngine = engine
        expressEngine.startPerformanceMonitor(3000)
        expressEngine.setEventHandler(object : IZegoEventHandler() {

            override fun onIMRecvBarrageMessage(
                roomID: String?,
                messageList: ArrayList<ZegoBarrageMessageInfo>?
            ) {
                messageList?.forEach {
                    zegoBigRoomMsgListener?.onReceive(ChatMsg(it.messageID, it.message, it.fromUser.userID, it.fromUser.userName, ChatMsg.STATUS_RECEIVE))
                }
            }

            override fun onIMRecvBroadcastMessage(
                roomID: String?,
                messageList: ArrayList<ZegoBroadcastMessageInfo>?
            ) {
                messageList?.forEach {
                    zegoMsgListener?.onReceive(ChatMsg(it.messageID.toString(), it.message, it.fromUser.userID, it.fromUser.userName, ChatMsg.STATUS_RECEIVE))
                }
            }

            override fun onRoomUserUpdate(
                roomID: String, updateType: ZegoUpdateType, userList: ArrayList<ZegoUser>
            ) {
                Log.d(
                    TAG,
                    "onUserUpdate zegoUserStates.size:${userList.size},updateType:$updateType"
                )
                if (updateType == ZegoUpdateType.ADD) {
                    for (user in userList) {
                        val classUser = ZegoClassUser(user.userID, user.userName)
                        userListener?.onUserAdd(classUser)
                    }
                } else {
                    for (user in userList) {
                        val classUser = ZegoClassUser(user.userID, user.userName)
                        userListener?.onUserRemove(classUser)
                    }
                }
            }

            override fun onRoomStateUpdate(
                roomID: String,
                state: ZegoRoomState,
                errorCode: Int,
                extendedData: JSONObject
            ) {
                Log.d(TAG, "onRoomStateUpdate:state :${state},errorCode:${errorCode},extendedData:${extendedData}")
                when (state) {
                    ZegoRoomState.DISCONNECTED -> {
                        if (isLoginRoom) {
                            loginResult.invoke(errorCode)
                            isLoginRoom = false
                        } else {
                            // extendedData 是可能为空的，且 getString("XX") 为空时会直接抛异常，optString() 这个方法可以在 value 没有数据的时候返回 null 值
                            val msg =
                                if (extendedData != null) {
                                    extendedData.optString("custom_kickout_message")
                                } else {
                                    ""
                                }
                            if (msg == "online_time_limit") {
                                kickOutListener?.onKickOut(0, roomID, msg)
                            } else {
                                zegoRoomStateListener?.onDisconnect(errorCode, roomID)
                            }
                        }
                    }
                    ZegoRoomState.CONNECTED -> {
                        if (isLoginRoom) {
                            ZegoQualityManager.getInstance().setLoginOnFinish()
                            loginResult.invoke(errorCode)
                            isLoginRoom = false
                        } else {
                            zegoRoomStateListener?.onConnected(errorCode, roomID)
                        }
                    }
                    ZegoRoomState.CONNECTING -> {
                        zegoRoomStateListener?.connecting(errorCode, roomID)
                    }
                }
            }

            override fun onRoomStreamUpdate(
                roomID: String,
                updateType: ZegoUpdateType,
                streamList: ArrayList<ZegoStream>
            ) {
                if (updateType == ZegoUpdateType.ADD) {
                    streamList.forEach {
                        Log.d(
                            TAG,
                            "onStreamAdd,${it.user.userName},${it.user.userID},${it.streamID}"
                        )
                        ZegoPlayStream(
                            it.user.userID,
                            it.user.userName,
                            it.streamID
                        ).let { playStream ->
                            streamCountListener?.onStreamAdd(playStream)
                        }
                    }
                } else {
                    streamList.forEach { it ->
                        Log.d(
                            TAG,
                            "onStreamRemove,${it.user.userName},${it.user.userID},${it.streamID}"
                        )
                        ZegoPlayStream(
                            it.user.userID,
                            it.user.userName,
                            it.streamID
                        ).let { playStream ->
                            streamCountListener?.onStreamRemove(playStream)
                        }
                    }
                }
            }

            override fun onPlayerStateUpdate(
                streamID: String,
                state: ZegoPlayerState,
                errorCode: Int,
                extendedData: JSONObject
            ) {
                Log.d(
                    TAG,
                    "onPlayerStateUpdate,streamID:$streamID,errorCode:$errorCode,state:$state"
                )
                if (state == ZegoPlayerState.PLAYING) {
                    val streamPlayCallback = playResultMap.remove(streamID)
                    streamPlayCallback?.onPlayStateUpdate(errorCode, streamID)
                }
            }

            override fun onPublisherStateUpdate(
                streamID: String,
                state: ZegoPublisherState,
                errorCode: Int,
                extendedData: JSONObject
            ) {
                Log.d(
                    TAG,
                    "onPublisherStateUpdate,streamID:$streamID,errorCode:$errorCode,state:$state"
                )
                if (state == ZegoPublisherState.PUBLISHING) {
                    val streamPublishCallback = publishResultMap.remove(streamID)
                    streamPublishCallback?.onPublishStateUpdate(errorCode, streamID)
                }
            }

            override fun onPlayerQualityUpdate(streamID: String, quality: ZegoPlayStreamQuality) {
                Log.d(
                    TAG,
                    "streamID:$streamID,quality:videoKBPS:${quality.videoKBPS},audioKBPS:${quality.audioKBPS}"
                )
                super.onPlayerQualityUpdate(streamID, quality)
            }

            override fun onDeviceError(errorCode: Int, deviceName: String) {
                super.onDeviceError(errorCode, deviceName)
                localDeviceErrorListener?.onDeviceError(errorCode, deviceName)
            }

            override fun onRemoteCameraStateUpdate(
                streamID: String,
                state: ZegoRemoteDeviceState
            ) {
                val status =
                    if (state == ZegoRemoteDeviceState.OPEN) DeviceStatus.DEVICE_STATUS_OPEN
                    else DeviceStatus.DEVICE_STATUS_CLOSE
                remoteDeviceStateListener?.onRemoteCameraStatusUpdate(streamID, status)
            }

            override fun onRemoteMicStateUpdate(streamID: String, state: ZegoRemoteDeviceState?) {
                val status =
                    if (state == ZegoRemoteDeviceState.OPEN) DeviceStatus.DEVICE_STATUS_OPEN
                    else DeviceStatus.DEVICE_STATUS_CLOSE
                remoteDeviceStateListener?.onRemoteMicStatusUpdate(streamID, status)
            }

            override fun onIMRecvCustomCommand(
                roomID: String,
                fromUser: ZegoUser,
                command: String
            ) {
                customCommandListener?.onRecvCustomCommand(
                    fromUser.userID,
                    fromUser.userName,
                    command,
                    roomID
                )
            }

            override fun onPlayerRenderVideoFirstFrame(streamID: String?) {
                super.onPlayerRenderVideoFirstFrame(streamID)
                ZegoQualityManager.getInstance().setPlayerStreamOnFirstFrame(streamID)
            }

            override fun onRecvExperimentalAPI(content: String?) {
                super.onRecvExperimentalAPI(content)
                ZegoQualityManager.getInstance().parsingLog(content)
            }

            override fun onRoomExtraInfoUpdate(
                roomID: String,
                roomExtraInfoList: ArrayList<ZegoRoomExtraInfo>
            ) {
                Log.d(
                    TAG,
                    "onRoomExtraInfoUpdate,roomID:${roomID},roomExtraInfoList:${roomExtraInfoList}"
                )
                if (roomExtraInfoList.isNotEmpty()) {
                    roomExtraInfoUpdateListener?.onRoomExtraInfoUpdate(roomID, roomExtraInfoList[0])
                }
            }
        })

        initCallback.initResult(true)
    }

    override fun unInitSDK() {
        ZegoExpressEngine.destroyEngine(null)
    }

    override fun isLiveRoom() = false

    override fun rtcSDKName() = "Express"

    override fun startPublishing(
        streamID: String,
        userName: String,
        publishResult: IStreamPublishCallback
    ) {
        ZegoQualityManager.getInstance().setPublishStreamID(streamID)
        expressEngine.startPublishingStream(streamID)
        publishResultMap[streamID] = publishResult
    }

    override fun muteVideoPublish(mute: Boolean) {
        expressEngine.mutePublishStreamVideo(mute)
    }

    override fun muteAudioPublish(mute: Boolean) {
        expressEngine.mutePublishStreamAudio(mute)
    }

    override fun stopPublishing() {
        expressEngine.stopPublishingStream()
    }

    override fun activateVideoPlayStream(streamID: String, enable: Boolean) {
        expressEngine.mutePlayStreamVideo(streamID, !enable)
    }

    override fun activateAudioPlayStream(streamID: String, enable: Boolean) {
        expressEngine.mutePlayStreamAudio(streamID, !enable)
    }

    override fun startPlayingStream(
        streamID: String,
        view: TextureView,
        playResult: IStreamPlayCallback
    ) {
        Log.d(TAG, "startPlayingStream")
        val zegoCanvas = ZegoCanvas(view)
        zegoCanvas.viewMode = ZegoViewMode.ASPECT_FILL
        ZegoQualityManager.getInstance().setPlayerStreamOnStart(streamID)
        expressEngine.startPlayingStream(streamID, zegoCanvas)
        playResultMap[streamID] = playResult
    }

    override fun updatePlayView(streamID: String, view: TextureView?) {
        Log.d(TAG, "updatePlayView startPlayingStream")
        expressEngine.startPlayingStream(streamID, ZegoCanvas(view))
    }

    override fun stopPlayingStream(streamID: String) {
        expressEngine.stopPlayingStream(streamID)
    }

    override fun enableCamera(enable: Boolean) {
        expressEngine.enableCamera(enable)
    }

    override fun setFrontCam(front: Boolean) {
        expressEngine.useFrontCamera(front)
    }

    override fun enableMic(enable: Boolean) {
        expressEngine.muteMicrophone(!enable)

    }

    override fun enableSpeaker(enable: Boolean) {
        expressEngine.muteSpeaker(!enable)
    }

    override fun setAppOrientation(rotation: Int) {
        expressEngine.setAppOrientation(ZegoOrientation.getZegoOrientation(rotation))
    }

    override fun startPreview(view: TextureView) {
        val zegoCanvas = ZegoCanvas(view)
        zegoCanvas.viewMode = ZegoViewMode.ASPECT_FILL
        expressEngine.startPreview(zegoCanvas)
    }

    override fun stopPreview() {
        expressEngine.stopPreview()
    }

    override fun loginRoom(
        userID: String,
        userName: String,
        roomID: String,
        function: (Int) -> Unit
    ) {
        val user = ZegoUser(userID, userName)
        val roomConfig = ZegoRoomConfig()
        roomConfig.maxMemberCount = ZegoSDKManager.MAX_USER_COUNT
        roomConfig.isUserStatusNotify = true

        ZegoQualityManager.getInstance().setUserID(userID)
        ZegoQualityManager.getInstance().setUserName(userName)
        ZegoQualityManager.getInstance().setRoomID(roomID)
        ZegoQualityManager.getInstance().setProductName("goclass")
        ZegoQualityManager.getInstance().setLoginOnStart()
        expressEngine.loginRoom(roomID, user, roomConfig)
        this.loginResult = function
        isLoginRoom = true
    }

    override fun logoutRoom(roomID: String) {
        expressEngine.logoutRoom(roomID)
        isLoginRoom = false
    }

    override fun setVideoConfig(width: Int, height: Int, bitrate: Int, fps: Int) {
        val config = ZegoVideoConfig()
        config.setCaptureResolution(width, height)
        config.setEncodeResolution(width, height)
        config.setVideoBitrate(bitrate / 1000)
        config.setVideoFPS(fps)
        expressEngine.videoConfig = config
    }

    override fun requireHardwareDecoder(require: Boolean) {
        expressEngine.enableHardwareDecoder(require)
    }

    override fun requireHardwareEncoder(require: Boolean) {
        expressEngine.enableHardwareEncoder(require)
    }

    override fun setRoomExtraInfo(
        roomID: String,
        type: String,
        content: String,
        callback: IZegoSetExtraInfoCallback?
    ) {
        expressEngine.setRoomExtraInfo(roomID, type, content) { errorCode ->
            Log.d(
                TAG,
                "setRoomExtraInfo,key:${type},content:${content}," + "returned errorCode:${errorCode}"
            )
            callback?.onSetRoomExtraInfo(errorCode)
        }
    }

    override fun setClassUserListener(userListener: IClassUserListener?) {
        this.userListener = userListener
    }

    override fun setZegoRoomCallback(
        zegoRoomStateCallback: IZegoRoomStateListener?,
        kickOutListener: IKickOutListener?,
        streamCountListener: IStreamCountListener?
    ) {
        this.zegoRoomStateListener = zegoRoomStateCallback
        this.kickOutListener = kickOutListener
        this.streamCountListener = streamCountListener
    }

    override fun setRemoteDeviceEventCallback(
        remoteDeviceStateListener: IRemoteDeviceStateListener?
    ) {
        this.remoteDeviceStateListener = remoteDeviceStateListener
    }

    override fun setLocalDeviceEventCallback(deviceEventCallback: ILocalDeviceErrorListener?) {
        this.localDeviceErrorListener = deviceEventCallback
    }

    override fun setCustomCommandListener(listener: ICustomCommandListener?) {
        this.customCommandListener = listener
    }

    override fun setRoomExtraInfoUpdateListener(listener: IRoomExtraInfoUpdateListener?) {
        this.roomExtraInfoUpdateListener = listener
    }

    override fun version(): String {
        return ZegoExpressEngine.getVersion()
    }

    override fun uploadLog() {
        expressEngine.uploadLog()
    }

    override fun sendLargeClassMsg(content: String, callback: IZegoSendMsgCallback) {
        var roomId = ClassRoomManager.getRoomId()
        expressEngine.sendBarrageMessage(roomId, content
        ) { errorCode, messageID -> callback.onSend(errorCode, messageID) }
    }

    override fun setLargeClassMsgListener(listener: IZegoMsgListener) {
        zegoBigRoomMsgListener = listener
    }

    override fun sendRoomMsg(content: String, callback: IZegoSendMsgCallback) {
        var roomId = ClassRoomManager.getRoomId()
        expressEngine.sendBroadcastMessage(
            roomId, content
        ) { errorCode, messageID -> callback.onSend(errorCode, messageID.toString()) }

    }

    override fun setMsgListener(listener: IZegoMsgListener) {
        zegoMsgListener = listener
    }
}

