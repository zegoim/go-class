package im.zego.goclass.sdk

import android.view.Surface
import android.view.TextureView
import im.zego.goclass.classroom.ClassRoomManager
import im.zego.goclass.tool.Logger

class ZegoDeviceService(private var zegoVideoSDKProxy: IZegoVideoSDKProxy) {

    private val TAG: String = "ZegoDeviceService"
    var remoteDeviceListener: IRemoteDeviceStateListener? = null

    fun registerCallback() {
        zegoVideoSDKProxy.setLocalDeviceEventCallback(object : ILocalDeviceErrorListener {
            override fun onDeviceError(errorCode: Int, deviceName: String) {
                Logger.d(TAG, "setZegoDeviceEventCallback:name=$deviceName,errorCode=$errorCode")
            }
        })
        zegoVideoSDKProxy.setRemoteDeviceEventCallback(object : IRemoteDeviceStateListener {
            override fun onRemoteCameraStatusUpdate(streamID: String, status: Int) {
                val enable = status == DeviceStatus.DEVICE_STATUS_OPEN
                Logger.d(
                    TAG,
                    "onRemoteCameraStatusUpdate:status:${status},CAMERA OPEN: $enable, streamID=$streamID"
                )
                
                val streamService = ZegoSDKManager.getInstance().getStreamService()
                streamService.getStream(streamID)?.let {

                    it.setCameraStatus(enable)
                    remoteDeviceListener?.onRemoteCameraStatusUpdate(streamID, status)
                }
            }

            override fun onRemoteMicStatusUpdate(streamID: String, status: Int) {
                val enable = status == DeviceStatus.DEVICE_STATUS_OPEN
                Logger.d(TAG, "onRemoteMicStatusUpdate:status:${status},MIC OPEN: $enable, streamID=$streamID")
                val streamService = ZegoSDKManager.getInstance().getStreamService()
                streamService.getStream(streamID)?.let {
                    it.setMicPhoneStatus(enable)
                    remoteDeviceListener?.onRemoteMicStatusUpdate(streamID, status)
                }
            }

        })
    }

    fun clearAll() {
        unRegisterCallback()
        clearRoomData()
    }

    fun clearRoomData() {
        enableMic(false)
        enableCamera(false)
        enableSpeaker(false)
    }

    fun unRegisterCallback() {
        zegoVideoSDKProxy.setLocalDeviceEventCallback(null)
        zegoVideoSDKProxy.setRemoteDeviceEventCallback(null)
    }

    fun enableCamera(enable: Boolean) {
        zegoVideoSDKProxy.enableCamera(enable)
    }

    fun setFrontCamera(front: Boolean) {
        zegoVideoSDKProxy.setFrontCam(front)
    }

    fun switchCamera() {
        ClassRoomManager.frontCamera = !ClassRoomManager.frontCamera
        setFrontCamera(ClassRoomManager.frontCamera)
    }

    fun enableMic(enable: Boolean) {
        zegoVideoSDKProxy.enableMic(enable)
    }

    fun enableSpeaker(enable: Boolean) {
        zegoVideoSDKProxy.enableSpeaker(enable)
    }

    fun startPreview(view: TextureView) {
        zegoVideoSDKProxy.setAppOrientation(Surface.ROTATION_90)
        zegoVideoSDKProxy.startPreview(view)
    }

    fun stopPreview() {
        zegoVideoSDKProxy.stopPreview()
    }
}