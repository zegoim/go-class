package im.zego.goclass.network

import android.os.Handler
import android.os.HandlerThread
import android.os.Message
import android.util.Log
import im.zego.goclass.classroom.ClassRoomManager
import im.zego.goclass.tool.Logger
import kotlin.math.max

class HeartBeatMonitor(private val uid: Long, private val roomID: String) {
    var TAG = "HeartBeatMonitor"

    private var handler: Handler? = null
    private var handlerThread: HandlerThread? = null

    private var tickRunnable: Runnable
    private var heart_interval = 2000L
    private var attendeeListSeq: Int = 0
    private var joinLiveListSeq: Int = 0
    var seqUpdateListener: SeqUpdateListener? = null
    private var continiousSend = true
    private var lastHeartBeatTime = 0L

    init {
        tickRunnable = Runnable { onEveryTick() }
    }

    private fun onEveryTick() {
        ZegoApiClient.heartBeat(uid, roomID, ClassRoomManager.roomType,
            object : ZegoApiClient.RequestCallback<HeartBeatRspData> {
                override fun onResult(result: Result, data: HeartBeatRspData?) {
                    Logger.i(TAG, "onEveryTick() onResult $result,data:$data")
                    val currentTime = System.currentTimeMillis()
                    val timePassed = currentTime - lastHeartBeatTime
                    Logger.i(TAG, "onEveryTick() timePassed $timePassed}")
                    if (timePassed >= heart_interval * 2) {
                        seqUpdateListener?.onOverTime()
                        lastHeartBeatTime = currentTime
                    } else {
                        lastHeartBeatTime = currentTime
                        if (data != null) {
                            onHeartBeatResult(result, data)
                            heart_interval = data.interval * 1000
                        }
                        if (continiousSend) {
                            handler?.postDelayed(tickRunnable, heart_interval)
                        }
                    }
                }
            })
    }

    fun setAttendeeSeq(attendeeListSeq: Int) {
        this.attendeeListSeq = max(attendeeListSeq, this.attendeeListSeq)
    }

    fun setJoinLiveSeq(joinLiveListSeq: Int) {
        this.joinLiveListSeq = max(joinLiveListSeq, this.joinLiveListSeq)
    }

    private fun onHeartBeatResult(result: Result, data: HeartBeatRspData) {
        if (attendeeListSeq < data.attendeeListSeq) {
            seqUpdateListener?.onUpdateAttendeeSeq(attendeeListSeq)
        }
        if (joinLiveListSeq < data.joinLiveListSeq) {
            seqUpdateListener?.onUpdateJoinLiveSeq(joinLiveListSeq)
        }
        attendeeListSeq = max(data.attendeeListSeq, attendeeListSeq)
        joinLiveListSeq = max(data.joinLiveListSeq, joinLiveListSeq)
    }

    fun start() {
        Logger.i(TAG, "start()")
        exit()
        handlerThread = HandlerThread("heartBeat")
        handlerThread!!.start()
        handler = object : Handler(handlerThread!!.looper) {
            override fun handleMessage(msg: Message) {
            }
        }
        lastHeartBeatTime = System.currentTimeMillis()
        handler!!.post(tickRunnable)
    }

    fun exit() {
        Logger.i(TAG, "exit()")
        pause()
        joinLiveListSeq = 0
        attendeeListSeq = 0
        handlerThread?.quit()
        handlerThread = null
        handler = null
        continiousSend = true
        lastHeartBeatTime = 0L
    }

    fun restart() {
        Log.d(TAG, "restart() called")
        continiousSend = true
        handler?.post(tickRunnable)
    }

    fun pause() {
        Log.d(TAG, "pause() called")
        handler?.removeCallbacks(tickRunnable)
        continiousSend = false
    }

    interface SeqUpdateListener {
        fun onUpdateAttendeeSeq(attendeeListSeq: Int)
        fun onUpdateJoinLiveSeq(joinLiveListSeq: Int)
        fun onOverTime()
    }
}
