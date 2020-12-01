package im.zego.goclass.entity

import android.util.Log
import android.view.TextureView
import im.zego.goclass.sdk.IStreamActiveCallback
import im.zego.goclass.sdk.IStreamPublishCallback


class ZegoPublishStream(userID: String, userName: String, streamID: String) :
    ZegoStream(userID, userName, streamID) {

    override fun enableVideo(enable: Boolean) {
        Log.i(TAG, "publishWithVideo:$enable")
        streamService.publishWithVideo(enable)
    }

    override fun enableAudio(enable: Boolean) {
        Log.i(TAG, "publishWithAudio:$enable")
        streamService.publishWithAudio(enable)
    }

    override fun activeStream(view: TextureView, activeResult: IStreamActiveCallback) {
        Log.d(TAG, "startPublishStream,${steamStatus}")
        // 如果连续点击麦克风和摄像头，会导致创建两个流对象，因此先加进来，失败再移除
        if (steamStatus == STREAM_INIT) {
            steamStatus = STREAM_PENDING_START
            streamService.addStream(this)
            streamService.startPublishStream(streamID, userName, object : IStreamPublishCallback {
                override fun onPublishStateUpdate(errorCode: Int, streamID: String) {
                    setStreamActive(errorCode == 0)
                    if (errorCode == 0) {
                        if (streamService.getStream(streamID) == null) {
                            streamService.addStream(this@ZegoPublishStream)
                        }
                    } else {
                        streamService.removeStream(this@ZegoPublishStream)
                    }
                    activeResult.onStreamActive(errorCode, streamID)
                }
            })
        }
    }

    override fun inActiveStream() {
        Log.d(TAG, "stopPublishStream,${steamStatus}")
        if (steamStatus == STREAM_START) {
            // 成功或者失败都设置为初始状态
            streamService.stopPublishStream()
            streamService.removeStream(this)
        }
        setStreamActive(false)
    }
}