package im.zego.goclass.widget

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import im.zego.goclass.entity.ZegoPublishStream
import im.zego.goclass.entity.ZegoStream
import im.zego.goclass.network.ZegoApiConstants
import im.zego.goclass.sdk.IStreamActiveCallback
import im.zego.goclass.sdk.ZegoSDKManager
import im.zego.goclass.classroom.ClassUser
import im.zego.goclass.tool.Logger
import im.zego.goclass.R
import kotlinx.android.synthetic.main.layout_seat_video_view.view.*

/**
 * 1、分为老师和学生两种视图
 * 2、user为空和user不为空
 * 3、根据user去查找Stream，如果有Stream进行推拉流
 */
open class SeatVideoView : FrameLayout {

    private var mClassUser: ClassUser? = null
    private var stream: ZegoStream? = null
    private var isPreviewIng = false

    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)
    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    )

    companion object {
        const val TAG = "SeatVideoView"
    }

    /**
     * 设置一个user进来
     * 1、根据user去查stream
     */
    fun setSeatUser(joinLiveUser: ClassUser?) {
        Logger.i(TAG, "setUser() joinLiveUser$joinLiveUser")
        mClassUser = joinLiveUser
        stream = null
        joinLiveUser?.let {
            stream = ZegoSDKManager.getInstance().streamService.getStreamByUser(it.userId.toString())
        }
        updateViews()
    }

    fun getSeatUser(): ClassUser? {
        return mClassUser
    }

    private fun updateViews() {
        Logger.i(TAG, "update() stream: $stream")
        if (mClassUser == null) {
            // 显示老师不在课堂的占位符
            setTeacherPlaceHolder()
        } else {
            setSeatUserName(mClassUser!!.userName)
            stream?.let { stream ->
                setRenderViewVisible(mClassUser!!.cameraOn)
                if (stream is ZegoPublishStream) {
                    if (mClassUser!!.cameraOn) {
                        if (!isPreviewIng) {
                            ZegoSDKManager.getInstance().deviceService.startPreview(texture)
                            isPreviewIng = true
                        }
                    } else {
                        ZegoSDKManager.getInstance().deviceService.stopPreview()
                        isPreviewIng = false
                    }
                }
                stream.activeStream(texture, object : IStreamActiveCallback {
                    override fun onStreamActive(errorCode: Int, streamID: String) {
                        Logger.i(TAG, "onStreamActive() streamID: $streamID, err: $errorCode")
                    }
                })

                stream.enableVideo(mClassUser!!.cameraOn)
                stream.enableAudio(mClassUser!!.micOn)
            }

            //更新视图
            camera.visibility = View.VISIBLE
            mic.visibility = View.VISIBLE
            share.visibility = View.VISIBLE
            name.visibility = View.VISIBLE
            wait_text.visibility = View.GONE

            camera.isSelected = mClassUser!!.cameraOn
            mic.isSelected = mClassUser!!.micOn
            share.isSelected = mClassUser!!.sharable
            val teacher = mClassUser!!.role == ZegoApiConstants.Role.TEACHER
            if (teacher) {
                share.visibility = View.GONE
                label.visibility = View.VISIBLE
                mask.setImageResource(R.drawable.teacher)
            } else {
                label.visibility = View.GONE
                mask.setImageResource(R.drawable.student)
            }
            texture.visibility = if (mClassUser!!.cameraOn) VISIBLE else GONE
        }

    }

    init {
        LayoutInflater.from(context).inflate(R.layout.layout_seat_video_view, this)
    }

    /**
     * 老师的流停止了，用成员列表的属性展示。
     */
    private fun setTeacherPlaceHolder() {
        //更新视图
        camera.visibility = View.GONE
        mic.visibility = View.GONE
        share.visibility = View.GONE
        name.visibility = View.GONE
        wait_text.visibility = View.VISIBLE
        isPreviewIng = false
        setRenderViewVisible(false)
        stopStream()
    }

    private fun setRenderViewVisible(visible: Boolean) {
        texture.visibility = if (visible) View.VISIBLE else View.INVISIBLE
    }

    open fun getAssociatedUserID(): Long? {
        return mClassUser?.userId
    }

    private fun setSeatUserName(text: String) {
        var showName = text
        if (text.length > 6) {
            //超过6个字符，显示前6个字符加上"..."
            showName = showName.substring(0, 6)
            showName += "..."
        }
        name.text = showName
        name.visibility = View.VISIBLE
    }

    open fun stopStream() {
        stream?.let { stream ->
            if (stream is ZegoPublishStream) {
                isPreviewIng = false
                ZegoSDKManager.getInstance().deviceService.stopPreview()
            }
            stream.inActiveStream()
            this.stream = null
        }
    }

    override fun onDetachedFromWindow() {
        stopStream()
        super.onDetachedFromWindow()
    }

}