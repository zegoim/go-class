package im.zego.goclass.entity

import android.util.Log
import android.view.TextureView
import im.zego.goclass.sdk.IStreamActiveCallback
import im.zego.goclass.sdk.IStreamPlayCallback

class ZegoPlayStream(userID: String, userName: String, streamID: String) :
    ZegoStream(userID, userName, streamID) {

    init {
        setCameraStatus(true)
        setMicPhoneStatus(true)
        setStreamActive(false)
    }

    override fun enableVideo(enable: Boolean) {
        streamService.playWithVideo(streamID, enable)
    }

    override fun enableAudio(enable: Boolean) {
        streamService.playWithAudio(streamID, enable)
    }

    override fun activeStream(view: TextureView, activeResult: IStreamActiveCallback) {
        Log.i(TAG,"activeStream:steamStatus$steamStatus")
        if (steamStatus == STREAM_INIT) {
            streamService.startPlayStream(streamID, view, object : IStreamPlayCallback {
                override fun onPlayStateUpdate(errorCode: Int, streamID: String) {
                    setStreamActive(errorCode == 0)
                    activeResult.onStreamActive(errorCode, streamID)
                }
            })
        }
    }

    override fun inActiveStream() {
        if (steamStatus == STREAM_START) {
            streamService.stopPlayStream(streamID)
        }
        setStreamActive(false)
    }
}