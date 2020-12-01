package im.zego.goclass.widget

import android.content.Context
import android.graphics.Color
import android.util.AttributeSet
import android.util.Log
import android.view.Gravity
import android.view.TextureView
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import im.zego.goclass.R
import im.zego.goclass.entity.ZegoPublishStream
import im.zego.goclass.entity.ZegoStream
import im.zego.goclass.sdk.IStreamActiveCallback
import im.zego.goclass.sdk.ZegoSDKManager

open class ZegoBaseVideoView : FrameLayout {

    private val TAG: String = "ZegoBaseVideoView"
    private var mTextureView: TextureView = TextureView(context)
    private val textView = TextView(context)

    private var stream: ZegoStream? = null
    private var isPreviewIng = false

    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)
    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    )

    init {
        setBackgroundColor(Color.parseColor("#f3f6ff"))
        val layoutParams = LayoutParams(
            LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT
        )
        layoutParams.gravity = Gravity.CENTER
        textView.setCompoundDrawablesWithIntrinsicBounds(0, R.drawable.seating_camera, 0, 0)
        textView.gravity = Gravity.CENTER
        addView(textView, layoutParams)

        addView(
            mTextureView,
            LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        )
    }

    private fun setRenderViewVisible(visible: Boolean) {
        mTextureView.apply {
            visibility = if (visible) {
                View.VISIBLE
            } else {
                View.INVISIBLE
            }
        }
    }

    open fun getAssociatedStreamID(): String? {
        return stream?.streamID
    }

    open fun getAssociatedUserID(): String? {
        return stream?.userID
    }

    open fun setAssociatedData(stream: ZegoStream) {
        this.stream = stream
        textView.text = stream.userName
    }

    open fun startStream(activeResult: IStreamActiveCallback) {
        Log.i(TAG, "startStream，stream：${stream}")
        stream?.let { stream ->
            setRenderViewVisible(stream.isCameraOpen())
            if (stream is ZegoPublishStream) {
                if (stream.isCameraOpen()) {
                    if (!isPreviewIng) {
                        ZegoSDKManager.getInstance().deviceService.startPreview(mTextureView)
                    }
                    isPreviewIng = true
                } else {
                    ZegoSDKManager.getInstance().deviceService.stopPreview()
                    isPreviewIng = false
                }
            }
            stream.activeStream(mTextureView, activeResult)
            stream.enableVideo(stream.isCameraOpen())
            stream.enableAudio(stream.isMicPhoneOpen())
        }
    }

    open fun stopStream() {
        stream?.let { stream ->
            if (stream is ZegoPublishStream) {
                isPreviewIng = false
                ZegoSDKManager.getInstance().deviceService.stopPreview()
            }
            stream.inActiveStream()
        }
    }

    override fun onDetachedFromWindow() {
        stopStream()
        super.onDetachedFromWindow()
    }

    fun description(): String {
        return "${hashCode()}(${stream})"
    }
}