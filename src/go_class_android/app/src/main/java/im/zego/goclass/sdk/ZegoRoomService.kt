package im.zego.goclass.sdk

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
    private var latestWhiteboardSeq: Long = 0
        set(value) {
            field = value
            Logger.i(TAG, "set latestWhiteboardSeq value:${field}")
        }
    var onWhiteboardSelectListener: OnWhiteboardSelectedListener? = null
    var currentWhiteboardID = 0L
        get() {
            Logger.i(TAG, "get currentWhiteboardID value:${field}")
            return field
        }

    fun registerCallback() {
        zegoVideoSDKProxy.setReliableMessageCallback(object : IZegoReliableMsgListener {
            override fun onRecvReliableMessage(
                roomID: String,
                msgType: String,
                content: String,
                latestSeq: Long
            ) {
                Logger.d(
                    TAG,
                    "onRecvReliableMessage,msgType:${msgType},content:${content},latestSeq:${latestSeq}"
                )
                if (msgType == KEY_WHITEBOARD && latestSeq > latestWhiteboardSeq) {
                    latestWhiteboardSeq = latestSeq
                    currentWhiteboardID = if (content.isBlank()) 0L else content.toLong()
                    onWhiteboardSelectListener?.onWhiteboardSelected(currentWhiteboardID)
                }
            }

            override fun onRoomUpdateReliableMessageInfo(
                roomID: String,
                msgType: String,
                latestSeq: Long
            ) {
                Logger.d(
                    TAG,
                    "onRoomUpdateReliableMessageInfo,msgType:${msgType},latestSeq:${latestSeq}"
                )
                if (msgType == KEY_WHITEBOARD && latestSeq > latestWhiteboardSeq) {
                    latestWhiteboardSeq = latestSeq
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
        zegoVideoSDKProxy.setReliableMessageCallback(null)
        zegoVideoSDKProxy.setZegoRoomCallback(null, null, null)
        zegoVideoSDKProxy.setCustomCommandListener(null)
    }

    private fun clearRoomData() {
        latestWhiteboardSeq = 0
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
            "sendCurrentWhiteboardID,latestWhiteboardSeq:${latestWhiteboardSeq},whiteboardID:${whiteboardID}"
        )
        zegoVideoSDKProxy.sendReliableMessage(roomID,
            KEY_WHITEBOARD, whiteboardID.toString(), latestWhiteboardSeq,
            object : IZegoSendReliableMsgCallback {
                override fun onSendReliableMessage(
                    errorCode: Int, roomID: String, type: String, latestSeq: Long
                ) {
                    Logger.i(
                        TAG,
                        "onSendCurrent,errorCode:${errorCode}，latestSeq:${latestSeq},whiteboardID:${whiteboardID}"
                    )
                    if (errorCode == 0) {
                        if (latestSeq > latestWhiteboardSeq) {
                            latestWhiteboardSeq = latestSeq
                            currentWhiteboardID = whiteboardID
                        }
                        callback.invoke(errorCode)
                    } else {
                        // 失败了重新获取再试一次
                        getCurrentWhiteboardID { getResult, _ ->
                            if (getResult == 0) {
                                zegoVideoSDKProxy.sendReliableMessage(roomID,
                                    KEY_WHITEBOARD, whiteboardID.toString(), latestWhiteboardSeq,
                                    object : IZegoSendReliableMsgCallback {
                                        override fun onSendReliableMessage(
                                            errorCode: Int, roomID: String,
                                            type: String, latestSeq: Long
                                        ) {
                                            Logger.i(
                                                TAG,
                                                "sendCurrentWhiteboardID2,errorCode:${errorCode}，whiteboardID:${whiteboardID}"
                                            )
                                            if (errorCode == 0) {
                                                if (latestSeq > latestWhiteboardSeq) {
                                                    latestWhiteboardSeq = latestSeq
                                                    currentWhiteboardID = whiteboardID
                                                }
                                            }
                                            callback.invoke(errorCode)
                                        }

                                    }
                                )
                            }
                        }
                    }
                }

            }
        )
    }

    fun getCurrentWhiteboardID(resultCallback: (Int, Long) -> Unit) {
        Logger.i(TAG, "getCurrentWhiteboardID")
        zegoVideoSDKProxy.getReliableMessage(roomID, KEY_WHITEBOARD,
            object : IZegoGetReliableMsgCallback {
                override fun onGetReliableMessage(
                    errorCode: Int, roomID: String, latestSeq: Long, content: String?
                ) {
                    if (errorCode == 0) {
                        latestWhiteboardSeq = latestSeq
                        currentWhiteboardID = if (content.isNullOrBlank()) 0L else content.toLong()
                        Logger.i(
                            TAG,
                            "getCurrentWhiteboardID,latestSeq:${latestWhiteboardSeq},currentWhiteboardID:$currentWhiteboardID"
                        )
                        resultCallback.invoke(errorCode, currentWhiteboardID)
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