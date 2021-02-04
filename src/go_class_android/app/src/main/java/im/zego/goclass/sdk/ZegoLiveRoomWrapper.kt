package im.zego.goclass.sdk


import android.app.Application
import android.util.Log
import android.view.TextureView
import com.zego.zegoliveroom.ZegoLiveRoom
import com.zego.zegoliveroom.ZegoLiveRoom.SDKContextEx
import com.zego.zegoliveroom.ZegoLiveRoomExtraInfo
import com.zego.zegoliveroom.callback.*
import com.zego.zegoliveroom.callback.im.IZegoIMCallback
import com.zego.zegoliveroom.constants.ZegoAvConfig
import com.zego.zegoliveroom.constants.ZegoConstants
import com.zego.zegoliveroom.constants.ZegoIM
import com.zego.zegoliveroom.constants.ZegoVideoViewMode
import com.zego.zegoliveroom.entity.*
import im.zego.goclass.AppConstants
import im.zego.goclass.entity.ChatMsg
import im.zego.goclass.entity.ZegoClassUser
import im.zego.goclass.entity.ZegoPlayStream
import im.zego.goclass.tool.ZegoUtil
import java.io.File
import java.util.*

class ZegoLiveRoomWrapper : IZegoVideoSDKProxy {
    private val TAG = "ZegoLiveRoomWrapper"
    private var zegoLiveRoomSDK: ZegoLiveRoom = ZegoLiveRoom()
    private var publishResultMap = mutableMapOf<String, IStreamPublishCallback>()
    private var playResultMap = mutableMapOf<String, IStreamPlayCallback>()

    private var userListener: IClassUserListener? = null
    private var zegoRoomStateListener: IZegoRoomStateListener? = null
    private var kickOutListener: IKickOutListener? = null
    private var streamCountListener: IStreamCountListener? = null
    private var remoteDeviceStateListener: IRemoteDeviceStateListener? = null
    private var localDeviceErrorListener: ILocalDeviceErrorListener? = null
    private var roomExtraInfoUpdateListener: IRoomExtraInfoUpdateListener? = null
    private var customCommandListener: ICustomCommandListener? = null
    private var zegoBigRoomMsgListener: IZegoMsgListener? = null
    private var zegoMsgListener: IZegoMsgListener? = null

    override fun initSDK(
        application: Application,
        appID: Long, appSign: String,
        testEnv: Boolean,
        initCallback: ZegoSDKManager.InitResult,
    ) {
        ZegoLiveRoom.setSDKContext(object : SDKContextEx {
            override fun getLogFileSize(): Long {
                return AppConstants.LOG_SIZE
            }

            override fun getSubLogFolder(): String? {
                return AppConstants.LOG_SUBFOLDER
            }

            override fun getLogHookCallback(): IZegoLogHookCallback? {
                return null
            }

            override fun getSoFullPath(): String? {
                return null
            }

            override fun getLogPath(): String? {
                return application.getExternalFilesDir(null)!!.absolutePath + File.separator
            }

            override fun getAppContext(): Application {
                return application
            }
        })

        ZegoLiveRoom.setConfig("room_retry_time=60")
        if (testEnv) {
            ZegoLiveRoom.setTestEnv(true)
        }

        val result: Boolean = zegoLiveRoomSDK.initSDK(
            appID, ZegoUtil.parseSignKeyFromString(appSign)
        ) { errorCode: Int ->
            initCallback.initResult(errorCode == 0)
            if (errorCode == 0) {
                initSDKCallbacks()
            }
        }
        if (!result) {
            initCallback.initResult(false)
        }
    }

    override fun unInitSDK() {
        zegoLiveRoomSDK.unInitSDK()
    }

    override fun isLiveRoom() = true

    override fun rtcSDKName() = "LiveRoom"

    override fun startPublishing(
        streamID: String,
        userName: String,
        callback: IStreamPublishCallback,
    ) {
        val result = zegoLiveRoomSDK.startPublishing(
            streamID,
            userName,
            ZegoConstants.PublishFlag.JoinPublish
        )
        if (result) {
            publishResultMap[streamID] = callback
        } else {
            callback.onPublishStateUpdate(-1, streamID)
        }
    }

    override fun muteVideoPublish(mute: Boolean) {
        zegoLiveRoomSDK.muteVideoPublish(mute)
    }

    override fun muteAudioPublish(mute: Boolean) {
        zegoLiveRoomSDK.muteAudioPublish(mute)
    }

    override fun stopPublishing() {
        zegoLiveRoomSDK.stopPublishing()
    }

    override fun activateVideoPlayStream(streamID: String, enable: Boolean) {
        zegoLiveRoomSDK.activateVideoPlayStream(streamID, enable)
    }

    override fun activateAudioPlayStream(streamID: String, enable: Boolean) {
        zegoLiveRoomSDK.activateAudioPlayStream(streamID, enable)
    }

    override fun startPlayingStream(
        streamID: String,
        view: TextureView,
        playResult: IStreamPlayCallback,
    ) {
        zegoLiveRoomSDK.setViewMode(ZegoVideoViewMode.ScaleAspectFill, streamID)
        val result = zegoLiveRoomSDK.startPlayingStream(streamID, view)
        if (result) {
            playResultMap[streamID] = playResult
            updatePlayView(streamID, view)
        } else {
            playResult.onPlayStateUpdate(-1, streamID)
        }
    }

    override fun updatePlayView(streamID: String, view: TextureView?) {
        zegoLiveRoomSDK.updatePlayView(streamID, view)
    }

    override fun stopPlayingStream(streamID: String) {
        zegoLiveRoomSDK.stopPlayingStream(streamID)
    }

    override fun enableCamera(enable: Boolean) {
        zegoLiveRoomSDK.enableCamera(enable)
    }

    override fun setFrontCam(front: Boolean) {
        zegoLiveRoomSDK.setFrontCam(front)
    }

    override fun enableMic(enable: Boolean) {
        zegoLiveRoomSDK.enableMic(enable)
    }

    override fun enableSpeaker(enable: Boolean) {
        zegoLiveRoomSDK.enableSpeaker(enable)
    }

    override fun setAppOrientation(rotation: Int) {
        zegoLiveRoomSDK.setAppOrientation(rotation)
    }

    override fun startPreview(view: TextureView) {
        zegoLiveRoomSDK.setPreviewViewMode(ZegoVideoViewMode.ScaleAspectFill)
        zegoLiveRoomSDK.setPreviewView(view)
        zegoLiveRoomSDK.startPreview()
    }

    override fun stopPreview() {
        zegoLiveRoomSDK.stopPreview()
    }

    override fun loginRoom(
        userID: String,
        userName: String,
        roomID: String,
        function: (Int) -> Unit,
    ) {
        zegoLiveRoomSDK.setRoomMaxUserCount(ZegoSDKManager.MAX_USER_COUNT)
        zegoLiveRoomSDK.setRoomConfig(true, true)
        ZegoLiveRoom.setUser(userID, userName)
        val result = zegoLiveRoomSDK.loginRoom(roomID, ZegoConstants.RoomRole.Anchor)
        { errorCode, zegoStreamInfos ->
            function.invoke(errorCode)
            zegoStreamInfos.forEach {
                Log.d(TAG, "loginRoom,stream:${it.userName},${it.userID},${it.streamID}")
                ZegoPlayStream(it.userID, it.userName, it.streamID).let { playStream ->
                    streamCountListener?.onStreamAdd(playStream)
                }
            }
        }
        if (!result) {
            function.invoke(-1)
        }
    }

    override fun setVideoConfig(width: Int, height: Int, bitrate: Int, fps: Int) {
        zegoLiveRoomSDK.setLatencyMode(ZegoConstants.LatencyMode.Low3)
        val zegoAvConfig = ZegoAvConfig(ZegoAvConfig.Level.Generic)
        zegoAvConfig.setVideoEncodeResolution(width, height)
        zegoAvConfig.setVideoCaptureResolution(width, height)
        zegoAvConfig.videoBitrate = bitrate
        zegoAvConfig.videoFPS = fps
        zegoLiveRoomSDK.setAVConfig(zegoAvConfig)
    }

    override fun logoutRoom(roomID: String) {
        zegoLiveRoomSDK.logoutRoom()
    }

    override fun requireHardwareDecoder(require: Boolean) {
        ZegoLiveRoom.requireHardwareDecoder(require)
    }

    override fun requireHardwareEncoder(require: Boolean) {
        ZegoLiveRoom.requireHardwareEncoder(require)
    }

    override fun setRoomExtraInfo(
        roomID: String,
        type: String,
        content: String,
        callback: IZegoSetExtraInfoCallback?,
    ) {
        ZegoLiveRoomExtraInfo.getInstance()
            .setRoomExtraInfo(type, content
            ) { errorCode, roomId, key ->
                Log.d(
                    TAG,
                    "onSetRoomExtraInfo,errorCode:${errorCode},roomId:${roomId},key:${key},"
                )
                callback?.onSetRoomExtraInfo(errorCode)
            }
    }

    override fun setClassUserListener(userListener: IClassUserListener?) {
        this.userListener = userListener
    }

    override fun setZegoRoomCallback(
        zegoRoomStateListener: IZegoRoomStateListener?,
        kickOutListener: IKickOutListener?,
        streamCountListener: IStreamCountListener?,
    ) {
        this.zegoRoomStateListener = zegoRoomStateListener
        this.kickOutListener = kickOutListener
        this.streamCountListener = streamCountListener
    }

    override fun setRemoteDeviceEventCallback(remoteDeviceStateListener: IRemoteDeviceStateListener?) {
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

    private fun initSDKCallbacks() {
        zegoLiveRoomSDK.setZegoIMCallback(object : IZegoIMCallback {
            override fun onRecvRoomMessage(roomID: String, listMsg: Array<out ZegoRoomMessage>?) {
                /** 该渠道接收消息用于小班课 */
                listMsg?.forEach { it ->
                    zegoMsgListener?.onReceive(
                        ChatMsg(
                            it.messageID.toString(),
                            it.content,
                            it.fromUserID,
                            it.fromUserName,
                            ChatMsg.STATUS_RECEIVE
                        )
                    )
                }
            }

            override fun onUpdateOnlineCount(roomID: String, count: Int) {
                Log.d(TAG, "onUpdateOnlineCount:roomID:$roomID,count:$count")
            }

            override fun onRecvBigRoomMessage(
                roomID: String?,
                listMsg: Array<out ZegoBigRoomMessage>?
            ) {
                /** 该渠道接收消息用于大班课，一条一条往外抛 */
                listMsg?.forEach { it ->

                    zegoBigRoomMsgListener?.onReceive(
                        ChatMsg(
                            it.messageID,
                            it.content,
                            it.fromUserID,
                            it.fromUserName,
                            ChatMsg.STATUS_RECEIVE
                        )
                    )
                }
            }

            override fun onUserUpdate(zegoUserStates: Array<ZegoUserState>, updateType: Int) {
                Log.d(
                    TAG,
                    "onUserUpdate zegoUserStates.size:${zegoUserStates.size},updateType:$updateType"
                )
                if (updateType == ZegoIM.UserUpdateType.Increase) {
                    for (zegoUserState in zegoUserStates) {
                        val classUser = ZegoClassUser(
                            zegoUserState.userID,
                            zegoUserState.userName
                        )
                        if (zegoUserState.updateFlag == ZegoIM.UserUpdateFlag.Added) {
                            userListener?.onUserAdd(classUser)
                        } else {
                            userListener?.onUserRemove(classUser)
                        }
                    }
                } else {
                    zegoUserStates.forEach {
                        Log.d(TAG, "onUserUpdate,ALL:userID:${it.userID},userName:${it.userName}")
                        val zegoClassUser = ZegoClassUser(it.userID, it.userName)
                        userListener?.onUserAdd(zegoClassUser)
                    }
                }
            }

        })
        zegoLiveRoomSDK.setZegoLivePublisherCallback(object : IZegoLivePublisherCallback {
            override fun onPublishStateUpdate(
                stateCode: Int,
                streamID: String,
                streamInfoMap: HashMap<String, Any>,
            ) {
                Log.d(
                    TAG,
                    "onPublishStateUpdate:stateCode=$stateCode,streamID=$streamID,streamInfoMap:${streamInfoMap}"
                )
                val streamPublishCallback = publishResultMap[streamID]
                streamPublishCallback?.onPublishStateUpdate(stateCode, streamID)
            }

            override fun onJoinLiveRequest(
                i: Int,
                s: String,
                s1: String,
                s2: String,
            ) {
            }

            override fun onPublishQualityUpdate(
                streamID: String,
                zegoPublishStreamQuality: ZegoPublishStreamQuality,
            ) {
                Log.d(
                    TAG,
                    "onPublishQualityUpdate,streamID=$streamID,vkbps:${zegoPublishStreamQuality.vkbps},akbps:${zegoPublishStreamQuality.akbps}"
                )
            }

            override fun onCaptureVideoSizeChangedTo(i: Int, i1: Int) {}
            override fun onCaptureVideoFirstFrame() {}
            override fun onCaptureAudioFirstFrame() {}
        })

        zegoLiveRoomSDK.setZegoLivePlayerCallback(object : IZegoLivePlayerCallback2 {

            /**
             * 视频解码器错误
             */

            override fun onVideoDecoderError(codecID: Int, errorCode: Int, streamID: String?) {
            }

            override fun onPlayStateUpdate(stateCode: Int, streamID: String) {
                val streamPlayCallback = playResultMap[streamID]
                streamPlayCallback?.onPlayStateUpdate(stateCode, streamID)
            }

            override fun onPlayQualityUpdate(
                streamID: String,
                zegoPlayStreamQuality: ZegoPlayStreamQuality,
            ) {
            }

            /**
             * 收到远端流增加的消息，默认就是摄像头麦克风开启的
             * 比如别人因为打开麦克风而创建流，所以自己会收到远端摄像头关闭的消息
             */
            override fun onRemoteCameraStatusUpdate(streamID: String, status: Int, reason: Int) {
                remoteDeviceStateListener?.onRemoteCameraStatusUpdate(streamID, status)
            }

            override fun onRemoteMicStatusUpdate(streamID: String, status: Int, reason: Int) {
                remoteDeviceStateListener?.onRemoteMicStatusUpdate(streamID, status)
            }

            override fun onRecvRemoteAudioFirstFrame(streamID: String) {
                Log.d(TAG, "onRecvRemoteAudioFirstFrame,streamID=$streamID")
            }

            override fun onInviteJoinLiveRequest(
                i: Int,
                s: String,
                s1: String,
                s2: String,
            ) {
            }

            override fun onRecvEndJoinLiveCommand(
                s: String,
                s1: String,
                s2: String,
            ) {
            }

            override fun onRecvRemoteVideoFirstFrame(streamID: String) {
                Log.d(TAG, "onRecvRemoteVideoFirstFrame:,streamID=$streamID")
            }

            override fun onVideoSizeChangedTo(s: String, i: Int, i1: Int) {

            }

            override fun onRenderRemoteVideoFirstFrame(streamID: String) {
                Log.d(TAG, "onRenderRemoteVideoFirstFrame:streamID=$streamID")
            }

        })

        zegoLiveRoomSDK.setZegoRoomCallback(object : IZegoRoomCallback {

            override fun onStreamExtraInfoUpdated(
                liststream: Array<out ZegoStreamInfo>?,
                roomID: String,
            ) {
            }

            override fun onReconnect(errorCode: Int, roomID: String) {
                Log.d(TAG, "onReconnect:errorCode:${errorCode}")
                zegoRoomStateListener?.onConnected(errorCode, roomID)
            }

            override fun onRoomInfoUpdated(p0: ZegoRoomInfo?, p1: String?) {
                Log.d(TAG, "onRoomInfoUpdated:")
            }

            override fun onKickOut(reason: Int, roomID: String, customReason: String) {
                Log.d(TAG, "onKickOut:reason:${reason}")
                kickOutListener?.onKickOut(reason, roomID, customReason)
            }

            override fun onDisconnect(errorCode: Int, roomID: String) {
                Log.d(TAG, "onDisconnect:errorCode:${errorCode}")
                zegoRoomStateListener?.onDisconnect(errorCode, roomID)
            }

            override fun onTempBroken(errorCode: Int, roomID: String) {
                Log.d(TAG, "onTempBroken:errorCode:${errorCode}")
                zegoRoomStateListener?.connecting(errorCode, roomID)
            }

            override fun onStreamUpdated(
                type: Int,
                liststream: Array<ZegoStreamInfo>,
                roomID: String,
            ) {
                if (type == ZegoConstants.StreamUpdateType.Added) {
                    liststream.forEach {
                        Log.d(TAG, "onStreamAdd,${it.userName},${it.userID},${it.streamID}")
                        ZegoPlayStream(it.userID, it.userName, it.streamID).let { playStream ->
                            streamCountListener?.onStreamAdd(playStream)
                        }
                    }
                } else {
                    liststream.forEach { it ->
                        Log.d(TAG, "onStreamRemove,${it.userName},${it.userID},${it.streamID}")
                        ZegoPlayStream(it.userID, it.userName, it.streamID).let { playStream ->
                            streamCountListener?.onStreamRemove(playStream)
                        }
                    }
                }
            }

            override fun onRecvCustomCommand(
                userID: String,
                userName: String,
                content: String,
                roomID: String,
            ) {
                customCommandListener?.onRecvCustomCommand(userID, userName, content, roomID)
            }

        })

        zegoLiveRoomSDK.setZegoDeviceEventCallback { deviceName, errorCode ->
            localDeviceErrorListener?.onDeviceError(
                errorCode, deviceName
            )
        }

        // 设置房间额外信息的回调 登录房间前调用
        ZegoLiveRoomExtraInfo.getInstance().setRoomExtraInfoCallback { roomId, extraInfoArray ->
            Log.d(
                TAG,
                "onRoomExtraInfoUpdated,roomId:${roomId}，extraInfoArray:${extraInfoArray}"
            )
            if (extraInfoArray.isNotEmpty()) {
                roomExtraInfoUpdateListener?.onRoomExtraInfoUpdate(roomId, extraInfoArray[0])
            }
        }

        zegoLiveRoomSDK.setZegoLogInfoCallback(object : IZegoLogInfoCallback {
            override fun onLogWillOverwrite() {
                Log.d(TAG, "onLogWillOverwrite() called")
            }

            override fun onLogUploadResult(p0: Int) {
                Log.d(TAG, "onLogUploadResult() called with: p0 = $p0")
            }

        })
    }

    override fun version(): String {
        return ZegoLiveRoom.version()
    }

    override fun uploadLog() {
        Log.d(TAG, "uploadLog() called")
        ZegoLiveRoom.uploadLog()
    }

    override fun sendLargeClassMsg(content: String, callback: IZegoSendMsgCallback) {
        var result = zegoLiveRoomSDK.sendBigRoomMessage(
            ZegoIM.MessageType.Text, ZegoIM.MessageCategory.Chat, content
        ) { errorCode, roomID, messageID ->
            callback.onSend(errorCode, messageID)
        }
        if (result.not()) {
            callback.onSend(-1, "")
        }
    }

    override fun setLargeClassMsgListener(listener: IZegoMsgListener) {
        zegoBigRoomMsgListener = listener
    }

    override fun sendRoomMsg(content: String, callback: IZegoSendMsgCallback) {
        var result =zegoLiveRoomSDK.sendRoomMessage(
            ZegoIM.MessageType.Text,
            ZegoIM.MessageCategory.Chat,
            content
        ) { errorCode, roomID, messageID ->
            callback.onSend(errorCode, messageID.toString())
        }
        if (result.not()) {
            callback.onSend(-1, "")
        }
    }

    override fun setMsgListener(listener: IZegoMsgListener) {
        zegoMsgListener = listener
    }
}

