package im.zego.goclass.entity

import android.view.TextureView
import im.zego.goclass.sdk.DeviceStatus
import im.zego.goclass.sdk.IStreamActiveCallback
import im.zego.goclass.sdk.ZegoSDKManager


abstract class ZegoStream(var userID: String, var userName: String, var streamID: String) {
    val TAG = "ZegoStream"
    val STREAM_INIT = 1
    val STREAM_PENDING_START = 2
    val STREAM_START = 3
    var extraInfo = ""
    var cameraState = DeviceStatus.DEVICE_STATUS_CLOSE
    var micPhoneState = DeviceStatus.DEVICE_STATUS_CLOSE
    val streamService = ZegoSDKManager.getInstance().streamService
    var steamStatus = STREAM_INIT

    fun isCameraOpen() = cameraState == DeviceStatus.DEVICE_STATUS_OPEN

    fun isMicPhoneOpen() = micPhoneState == DeviceStatus.DEVICE_STATUS_OPEN

    fun setCameraStatus(open: Boolean) {
        cameraState = if (open)
            DeviceStatus.DEVICE_STATUS_OPEN else
            DeviceStatus.DEVICE_STATUS_CLOSE
    }

    fun setMicPhoneStatus(open: Boolean) {
        micPhoneState = if (open)
            DeviceStatus.DEVICE_STATUS_OPEN else
            DeviceStatus.DEVICE_STATUS_CLOSE
    }

    fun isStreamActive() = steamStatus == STREAM_START

    fun setStreamActive(success: Boolean) {
        steamStatus = if (success) STREAM_START else STREAM_INIT
    }

    abstract fun enableVideo(enable: Boolean)

    abstract fun enableAudio(enable: Boolean)

    abstract fun activeStream(view: TextureView, activeResult: IStreamActiveCallback)

    abstract fun inActiveStream()

    override fun toString(): String {
        return "ZegoStream(userID='$userID', userName='$userName', streamID='$streamID',  extraInfo='$extraInfo', cameraState=$cameraState, micPhoneState=$micPhoneState, streamService=$streamService, steamStatus=$steamStatus)"
    }


}