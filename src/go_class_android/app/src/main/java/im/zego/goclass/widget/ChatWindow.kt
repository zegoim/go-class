package im.zego.goclass.widget

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.recyclerview.widget.LinearLayoutManager
import im.zego.goclass.activities.MainActivity
import im.zego.goclass.entity.SystemMsg
import im.zego.goclass.entity.ChatMsg
import im.zego.goclass.entity.IMsg
import im.zego.goclass.classroom.ClassRoomManager
import im.zego.goclass.classroom.ClassUser
import im.zego.goclass.classroom.ClassUserListener
import im.zego.goclass.sdk.IZegoMsgListener
import im.zego.goclass.sdk.IZegoSendMsgCallback
import im.zego.goclass.sdk.ZegoSDKManager
import im.zego.goclass.R
import kotlinx.android.synthetic.main.layout_chat_window.view.*

/**
 * Created by yuxing_zhong on 2020/11/6
 * 1、布局
 * 2、发送消息
 * 3、注册监听接收消息
 */
class ChatWindow : ConstraintLayout {
    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)
    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    )

    private var inputDialog = InputDialog()

    init {
        LayoutInflater.from(context).inflate(R.layout.layout_chat_window, this)
    }


    fun initView() {
        input_text.setOnClickListener {
            // 需要弹出输入法
            inputDialog.show((context as MainActivity).supportFragmentManager, "")
        }

        chat_recycler_view.let {
            it.layoutManager = LinearLayoutManager(context)
            val chatAdapter = ChatAdapter()
            val joinMsg = createSystemMsg(context.getString(R.string.me), true)
            chatAdapter.addMessage(joinMsg)
            /*chatAdapter.resendListener = object : (ChatMsg) -> Unit {
                override fun invoke(chatMsg: ChatMsg) {
                    resend(chatMsg)
                }

            }*/
            it.adapter = chatAdapter
        }

        inputDialog.sendListener = object : (String) -> Unit {
            override fun invoke(msg: String) {
                val chatMsg = createChatMsg(msg)
                addMessage(chatMsg)
                sendMessage(chatMsg)
            }

        }

        initMsgListener()
        initGoClassUserListener()
    }

    /**
     * 失败消息进行重新发送
     */
    fun resend(chatMsg: ChatMsg) {
        updateSendMsgStatus(chatMsg.seq, ChatMsg.STATUS_SENDING)
        sendMessage(chatMsg)
    }

    /**
     *  发送消息。
     *  监听发送结果回调，成功/失败更新 adapter 的回调
     */
    fun sendMessage(chatMsg: ChatMsg) {
        ZegoSDKManager.getInstance()
            .sendLargeClassMsg(chatMsg.content, object : IZegoSendMsgCallback {
                override fun onSend(errorCode: Int, messageID: String) {
                    val status =
                        if (errorCode == 0) ChatMsg.STATUS_SEND_SUCCESS else ChatMsg.STATUS_SEND_FAILED
                    updateSendMsgStatus(chatMsg.seq, status)
                }
            })
    }

    private fun addMessage(msg: IMsg) {
        val chatAdapter = chat_recycler_view.adapter as ChatAdapter
        chatAdapter.addMessage(msg)
        chatAdapter.notifyDataSetChanged()
        chat_recycler_view.scrollToPosition(chatAdapter.itemCount - 1)
    }

    private fun updateSendMsgStatus(seq: Int, status: Int) {
        (chat_recycler_view.adapter as ChatAdapter).updateSendMsgStatus(seq, status)
    }

    private fun createChatMsg(content: String): ChatMsg {
        val sendId = ""
        val chatMsg = ChatMsg(
            sendId,
            content,
            ClassRoomManager.myUserId.toString(),
            ClassRoomManager.me().userName,
            ChatMsg.STATUS_SENDING
        )

        val sendSeq = ChatMsg.createSendSeq()
        chatMsg.seq = sendSeq
        return chatMsg
    }

    /**
     * 监听接收聊天消息
     */
    private fun initMsgListener() {
        ZegoSDKManager.getInstance().setLargeClassMsgListener(object : IZegoMsgListener {
            override fun onReceive(chatMsg: ChatMsg) {
                addMessage(chatMsg)
            }
        })
    }

    /**
     * 监听系统消息：即用户进入/退出房间的消息
     *
     */
    private fun initGoClassUserListener() {
        ClassRoomManager.addUserListener(object : ClassUserListener {
            override fun onUserEnter(user: ClassUser?) {
                user?.let {
                    val systemMsg = createSystemMsg(user.userName, true)
                    addMessage(systemMsg)
                }
            }

            override fun onUserLeave(user: ClassUser?) {
                user?.let {
                    val systemMsg = createSystemMsg(user.userName, false)
                    (chat_recycler_view.adapter as ChatAdapter).addMessage(systemMsg)
                }
            }

            override fun onUserCameraChanged(userId: Long, on: Boolean, selfChanged: Boolean) {
            }

            override fun onUserMicChanged(userId: Long, on: Boolean, selfChanged: Boolean) {
            }

            override fun onUserShareChanged(userId: Long, on: Boolean, selfChanged: Boolean) {
            }

            override fun onRoomUserUpdate() {
            }

            override fun onJoinLiveUserUpdate() {
            }
        })

    }

    /**
     * 创建系统消息：
     * 1、xxx 加入课堂
     * 2、xxx 退出课堂
     */
    private fun createSystemMsg(name: String, isJoinIn: Boolean): SystemMsg {
        val action =
            if (isJoinIn) context.getString(R.string.join) else context.getString(R.string.exit)
        return SystemMsg("$name ${action}${context.getString(R.string.go_class)}")
    }

}

