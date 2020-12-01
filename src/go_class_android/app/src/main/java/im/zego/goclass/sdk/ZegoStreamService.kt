package im.zego.goclass.sdk

import android.view.TextureView
import im.zego.goclass.entity.ZegoStream
import im.zego.goclass.CONFERENCE_ID
import im.zego.goclass.tool.Logger

class ZegoStreamService(var zegoVideoSDKProxy: IZegoVideoSDKProxy) {
    val TAG = "ZegoStreamService"

    /**
     * 包含自己的流,
     */
    private val streamList = mutableListOf<ZegoStream>()
    private var generateStreamID: String? = null

    var streamCountListener: IStreamCountListener? = null

    fun generatePublishStreamID(userID: String): String {
        Logger.i(TAG, "generatePublishStreamID()")
        if (generateStreamID == null) {
            generateStreamID = "a_${CONFERENCE_ID}_${userID}"
        }
        return generateStreamID!!
    }

    /**
     * 推流的时候，推流成功就表示流已经激活了
     */
    fun startPublishStream(
        streamID: String, userName: String,
        publishResult: IStreamPublishCallback
    ) {
        Logger.i(TAG, "startPublishStream,streamID:$streamID,userName:$userName")
        zegoVideoSDKProxy.startPublishing(streamID, userName, object : IStreamPublishCallback {
            override fun onPublishStateUpdate(errorCode: Int, streamID: String) {
                publishResult.onPublishStateUpdate(errorCode, streamID)
            }
        })
    }

    fun publishWithVideo(enable: Boolean) {
        Logger.i(TAG, "publishWithVideo:$enable")
        zegoVideoSDKProxy.muteVideoPublish(!enable)
    }

    fun publishWithAudio(enable: Boolean) {
        Logger.i(TAG, "publishWithAudio:$enable")
        zegoVideoSDKProxy.muteAudioPublish(!enable)
    }

    fun stopPublishStream() {
        Logger.i(TAG, "stopPublishStream")
        zegoVideoSDKProxy.stopPublishing()
    }

    fun playWithVideo(streamID: String, enable: Boolean) {
        Logger.i(TAG, "playWithVideo,streamID:$streamID,enable:$enable")
        zegoVideoSDKProxy.activateVideoPlayStream(streamID, enable)
    }

    fun playWithAudio(streamID: String, enable: Boolean) {
        Logger.i(TAG, "playWithAudio,streamID:$streamID,enable:$enable")
        zegoVideoSDKProxy.activateAudioPlayStream(streamID, enable)
    }

    /**
     * 播流的时候，播流成功才表示流已经激活
     */
    fun startPlayStream(
        streamID: String,
        view: TextureView,
        playResult: IStreamPlayCallback
    ) {
        Logger.i(TAG, "startPlayStream:streamID:${streamID}")
        zegoVideoSDKProxy.startPlayingStream(streamID, view, object : IStreamPlayCallback {
            override fun onPlayStateUpdate(errorCode: Int, streamID: String) {
                playResult.onPlayStateUpdate(errorCode, streamID)
            }
        })
//        zegoSDKProxy.updatePlayView(streamID, view)

    }

    fun stopPlayStream(streamID: String) {
        Logger.d(TAG, "stopPlayStream:$streamID")
        zegoVideoSDKProxy.stopPlayingStream(streamID)
    }

    fun addStream(streamInfo: ZegoStream) {
        Logger.i(TAG, "addStream:$streamInfo")
        if (!streamList.contains(streamInfo)) {
            streamList.add(streamInfo)
        }
    }

    fun removeStream(stream: ZegoStream) {
        streamList.remove(stream)
    }

    fun getStream(streamID: String): ZegoStream? {
        Logger.i(TAG, "getStream() $streamList")
        return streamList.firstOrNull { streamID == it.streamID }
    }

    fun getStreamByUser(userID: String): ZegoStream? {
        return streamList.firstOrNull { userID == it.userID }
    }

    fun getStreamList() = streamList

    fun getStreamCount() = streamList.size

    fun clearAll() {
        clearRoomData()
    }

    fun clearRoomData() {
        Logger.i(TAG, "clearRoomData")
        stopPublishStream()
        streamList.clear()
        generateStreamID = null
    }

    fun onStreamAdd(playStream: ZegoStream) {
        Logger.i(TAG, "onStreamAdd:$playStream")
        addStream(playStream)
        playStream.setCameraStatus(true)
        playStream.setMicPhoneStatus(true)
        streamCountListener?.onStreamAdd(playStream)
    }

    fun onStreamRemove(zegostream: ZegoStream) {
        val firstOrNull =
            streamList.firstOrNull { stream -> zegostream.streamID == stream.streamID }
        if (firstOrNull != null) {
            streamCountListener?.onStreamRemove(firstOrNull)
            removeStream(firstOrNull)
        }
    }
}

interface IStreamActiveCallback {
    fun onStreamActive(errorCode: Int, streamID: String)
}