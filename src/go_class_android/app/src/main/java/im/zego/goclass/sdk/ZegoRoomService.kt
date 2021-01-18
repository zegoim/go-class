package im.zego.goclass.sdk

import com.zego.zegoliveroom.entity.ZegoRoomExtraInfo
import im.zego.goclass.entity.ZegoStream
import im.zego.goclass.tool.Logger
import im.zego.zegowhiteboard.ZegoWhiteboardManager

const val OUTSIDE = 0
const val PENDING_ENTER = 1
const val ENTERED = 2

/**
 * login 业务后台
 * enter 加入课堂
 *
 */
class ZegoRoomService(private var zegoVideoSDKProxy: IZegoVideoSDKProxy) {
    val TAG = "RoomService"
    private var state = OUTSIDE
    private var roomID = ""
    var zegoRoomStateListener: IZegoRoomStateListener? = null
    var customCommandListener: ICustomCommandListener? = null


    private val KEY_WHITEBOARD = "1001"

    var onWhiteboardSelectListener: OnWhiteboardSelectedListener? = null
    var currentWhiteboardID = 0L
        get() {
            Logger.i(TAG, "get currentWhiteboardID value:${field}")
            return field
        }

    private fun registerCallback() {
        zegoVideoSDKProxy.setRoomExtraInfoUpdateListener(object : IRoomExtraInfoUpdateListener {
            override fun onRoomExtraInfoUpdate(
                roomID: String,
                roomExtraInfo: ZegoRoomExtraInfo
            ) {
                Logger.d(
                    TAG,
                    "setRoomExtraInfoUpdateListener,roomID:${roomID},roomExtraInfo:${roomExtraInfo}"
                )
                if (roomExtraInfo.key == KEY_WHITEBOARD) {
                    currentWhiteboardID =
                        if (roomExtraInfo.value.isBlank()) 0L else roomExtraInfo.value.toLong()
                    onWhiteboardSelectListener?.onWhiteboardSelected(currentWhiteboardID)
                }
            }
        })

        zegoVideoSDKProxy.setZegoRoomCallback(object : IZegoRoomStateListener {
            override fun onConnected(errorCode: Int, roomID: String) {
                Logger.d(TAG, "onReconnect:errorCode:${errorCode}")
                zegoRoomStateListener?.onConnected(errorCode, roomID)
            }

            override fun onDisconnect(errorCode: Int, roomID: String) {
                Logger.d(TAG, "onDisconnect:errorCode:${errorCode}")
                zegoRoomStateListener?.onDisconnect(errorCode, roomID)
            }

            override fun connecting(errorCode: Int, roomID: String) {
                Logger.d(TAG, "onTempBroken:errorCode:${errorCode}")
                zegoRoomStateListener?.connecting(errorCode, roomID)
            }

        }, object : IKickOutListener {
            override fun onKickOut(reason: Int, roomID: String, customReason: String) {
                Logger.d(TAG, "onKickOut:reason:${reason}")
            }

        }, object : IStreamCountListener {
            override fun onStreamAdd(zegostream: ZegoStream) {
                Logger.d(TAG, "onStreamAdd:zegostream:${zegostream}")
                val streamService = ZegoSDKManager.getInstance().getStreamService()
                streamService.onStreamAdd(zegostream)
            }

            override fun onStreamRemove(zegostream: ZegoStream) {
                Logger.d(TAG, "onStreamRemove:zegostream:${zegostream}")
                val streamService = ZegoSDKManager.getInstance().getStreamService()
                streamService.onStreamRemove(zegostream)
            }

        })

        zegoVideoSDKProxy.setCustomCommandListener(customCommandListener)
    }

    fun unRegisterCallback() {
        zegoVideoSDKProxy.setRoomExtraInfoUpdateListener(null)
        zegoVideoSDKProxy.setZegoRoomCallback(null, null, null)
        zegoVideoSDKProxy.setCustomCommandListener(null)
    }

    private fun clearRoomData() {
        currentWhiteboardID = 0L
    }

    fun clearAll() {
        unRegisterCallback()
        clearRoomData()
    }

    /**
     * 注意这里设置成功了也不代表当前白板就是你设置的那个白板ID，需要比较 latestSeq
     * 如果有多人同时设置，那么要用最大的seq所携带的白板ID为当前白板ID
     */
    fun sendCurrentWhiteboardID(whiteboardID: Long, callback: (Int) -> Unit) {
        Logger.i(
            TAG,
            "sendCurrentWhiteboardID, whiteboardID:${whiteboardID}"
        )
        zegoVideoSDKProxy.setRoomExtraInfo(
            roomID,
            KEY_WHITEBOARD,
            whiteboardID.toString(),
            object : IZegoSetExtraInfoCallback {
                override fun onSetRoomExtraInfo(errorCode: Int) {
                    Logger.i(
                        TAG,
                        "onSendCurrent,errorCode:${errorCode}，KEY_WHITEBOARD:${KEY_WHITEBOARD},whiteboardID:${whiteboardID}"
                    )
                    if (errorCode == 0) {
                        currentWhiteboardID = whiteboardID
                        callback.invoke(errorCode)
                    } else {
                        // 失败了重新获取再试一次
                        zegoVideoSDKProxy.setRoomExtraInfo(
                            roomID,
                            KEY_WHITEBOARD,
                            whiteboardID.toString(), object : IZegoSetExtraInfoCallback {
                                override fun onSetRoomExtraInfo(errorCode: Int) {
                                    Logger.i(
                                        TAG,
                                        "sendCurrentWhiteboardID2,errorCode:${errorCode}，whiteboardID:${whiteboardID}"
                                    )
                                    if (errorCode == 0) {
                                        currentWhiteboardID = whiteboardID
                                    }
                                    callback.invoke(errorCode)
                                }
                            })
                    }
                }
            })
    }

    fun loginRoom(
        userID: String,
        userName: String,
        roomID: String,
        function: (Int) -> Unit
    ) {
        Logger.i(
            TAG,
            "enterRoom() called with: userID = [$userID], userName = [$userName], roomID = [$roomID] state = $state"
        )
        if (state != OUTSIDE) {
            return
        }
        registerCallback()
        ZegoSDKManager.getInstance().getDeviceService().registerCallback()

        state = PENDING_ENTER
        zegoVideoSDKProxy.loginRoom(userID, userName, roomID)
        { errorCode: Int ->
            Logger.i(TAG, "loginRoom:$errorCode")
            if (errorCode == 0) {
                this.roomID = roomID
                state = ENTERED
                onRoomEntered()
            } else {
                state = OUTSIDE
                exitRoom()
            }
            function.invoke(errorCode)
        }
    }

    private fun onRoomEntered() {
        val deviceService = ZegoSDKManager.getInstance().getDeviceService()
        deviceService.setFrontCamera(true)
        zegoVideoSDKProxy.setVideoConfig(640, 360, 600 * 1000, 15)
        zegoVideoSDKProxy.requireHardwareDecoder(true)
        zegoVideoSDKProxy.requireHardwareEncoder(true)
        deviceService.enableSpeaker(true)
    }

    fun exitRoom() {
        ZegoWhiteboardManager.getInstance().clear()
        ZegoSDKManager.getInstance().getStreamService().clearAll()
        ZegoSDKManager.getInstance().getDeviceService().clearAll()
        zegoVideoSDKProxy.logoutRoom(roomID)
        state = OUTSIDE
        zegoRoomStateListener = null
        this.roomID = ""
        clearAll()
    }

    fun isInRoom() = state == ENTERED
}

interface OnWhiteboardSelectedListener {
    fun onWhiteboardSelected(whiteboardID: Long)
}