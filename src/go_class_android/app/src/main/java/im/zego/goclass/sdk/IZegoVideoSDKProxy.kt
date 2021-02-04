package im.zego.goclass.sdk

import android.app.Application
import android.view.TextureView
import im.zego.zegoexpress.entity.ZegoRoomExtraInfo
import im.zego.goclass.entity.ZegoClassUser
import im.zego.goclass.entity.ChatMsg
import im.zego.goclass.entity.ZegoStream

/**
 * ZegoSDK会有两种实现，liveroom 和 express
 */
interface IZegoVideoSDKProxy {

    fun initSDK(
        application: Application,
        appID: Long,
        appSign: String,
        testEnv: Boolean,
        initCallback: ZegoSDKManager.InitResult
    )

    fun unInitSDK()

    fun isLiveRoom(): Boolean

    fun rtcSDKName(): String

    fun startPublishing(
        streamID: String, userName: String,
        callback: IStreamPublishCallback
    )

    fun muteVideoPublish(mute: Boolean)

    fun muteAudioPublish(mute: Boolean)

    fun stopPublishing()

    fun activateVideoPlayStream(streamID: String, enable: Boolean)

    fun activateAudioPlayStream(streamID: String, enable: Boolean)

    fun startPlayingStream(streamID: String, view: TextureView, playResult: IStreamPlayCallback)

    fun updatePlayView(streamID: String, view: TextureView?)

    fun stopPlayingStream(streamID: String)

    fun enableCamera(enable: Boolean)

    fun setFrontCam(front: Boolean)

    fun enableMic(enable: Boolean)

    fun enableSpeaker(enable: Boolean)

    fun setAppOrientation(rotation: Int)

    fun startPreview(view: TextureView)

    fun stopPreview()

    fun loginRoom(
        userID: String,
        userName: String,
        roomID: String,
        function: (Int) -> Unit
    )

    fun setVideoConfig(width: Int, height: Int, bitrate: Int, fps: Int)

    fun logoutRoom(roomID: String)

    fun requireHardwareDecoder(require: Boolean)

    fun requireHardwareEncoder(require: Boolean)

    fun setRoomExtraInfo(
        roomID: String,
        type: String,
        content: String,
        callback: IZegoSetExtraInfoCallback?
    )

    fun setClassUserListener(userListener: IClassUserListener?)

    fun setZegoRoomCallback(
        zegoRoomStateCallback: IZegoRoomStateListener?,
        kickOutListener: IKickOutListener?,
        streamCountListener: IStreamCountListener?
    )

    fun setRemoteDeviceEventCallback(remoteDeviceStateListener: IRemoteDeviceStateListener?)

    fun setLocalDeviceEventCallback(deviceEventCallback: ILocalDeviceErrorListener?)

    fun setCustomCommandListener(listener: ICustomCommandListener?)

    fun setRoomExtraInfoUpdateListener(listener: IRoomExtraInfoUpdateListener?)

    fun version(): String

    fun uploadLog()

    /**
     * 大班课发送消息。
     */
    fun sendLargeClassMsg(content: String, callback: IZegoSendMsgCallback)

    /**
     * 设置大班课接收消息的监听
     */
    fun setLargeClassMsgListener(listener:IZegoMsgListener)

    /**
     * 小班课发送消息。
     */
    fun sendRoomMsg(content: String, callback: IZegoSendMsgCallback)

    /**
     * 设置小班课接收消息的监听
     */
    fun setMsgListener(listener:IZegoMsgListener)

}

interface IClassUserListener {
    fun onUserAdd(zegoUser: ZegoClassUser)
    fun onUserRemove(zegoUser: ZegoClassUser)
}

interface IStreamCountListener {
    fun onStreamAdd(zegostream: ZegoStream)
    fun onStreamRemove(zegostream: ZegoStream)
}

interface IRemoteDeviceStateListener {
    fun onRemoteCameraStatusUpdate(streamID: String, status: Int)
    fun onRemoteMicStatusUpdate(streamID: String, status: Int)
}

interface ILocalDeviceErrorListener {
    fun onDeviceError(errorCode: Int, deviceName: String)
}

interface ICustomCommandListener {
    fun onRecvCustomCommand(userID: String, userName: String, content: String, roomID: String)
}

interface IRoomExtraInfoUpdateListener {
    fun onRoomExtraInfoUpdate(roomID: String, roomExtraInfo: ZegoRoomExtraInfo)
}

interface IStreamPlayCallback {
    fun onPlayStateUpdate(errorCode: Int, streamID: String)
}

interface IStreamPublishCallback {
    fun onPublishStateUpdate(errorCode: Int, streamID: String)
}

interface IKickOutListener {
    fun onKickOut(reason: Int, roomID: String, customReason: String)
}

interface IZegoRoomStateListener {
    fun onConnected(errorCode: Int, roomID: String)
    fun onDisconnect(errorCode: Int, roomID: String)
    fun connecting(errorCode: Int, roomID: String)
}

interface IZegoSetExtraInfoCallback {
    fun onSetRoomExtraInfo(errorCode: Int)
}

interface IZegoSendMsgCallback {
    fun onSend(errorCode: Int, messageID: String)
}

interface IZegoMsgListener {
    fun onReceive(chatMsg: ChatMsg)
}

object DeviceStatus {
    const val DEVICE_STATUS_OPEN = 0
    const val DEVICE_STATUS_CLOSE = 1
}