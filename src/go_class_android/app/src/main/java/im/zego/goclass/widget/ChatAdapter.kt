package im.zego.goclass.widget

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import im.zego.goclass.entity.IMsg
import im.zego.goclass.entity.SystemMsg
import im.zego.goclass.entity.ChatMsg
import im.zego.goclass.R

class ChatAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private var msgList = mutableListOf<IMsg>()

    var resendListener: (ChatMsg) -> Unit = {}

    companion object {
        const val TYPE_SYSTEM = 1
        const val TYPE_CHAT_SEND = 2
        const val TYPE_CHAT_RECEIVE = 3
    }

    fun addMessage(msg: IMsg) {
        msgList.add(msg)
        notifyDataSetChanged()
    }

    fun updateSendMsgStatus(seq: Int, status: Int) {
        for (i in 0..msgList.size) {
            val iMsg = msgList[i]
            if (iMsg is ChatMsg) {
                if (iMsg.seq == seq) {
                    iMsg.status = status
                    notifyItemChanged(i)
                    return
                }
            }

        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val itemView: View = when (viewType) {
            TYPE_CHAT_SEND -> {
                LayoutInflater.from(parent.context).inflate(
                    R.layout.item_send_msg_chat, parent, false)
            }
            TYPE_CHAT_RECEIVE -> {
                LayoutInflater.from(parent.context).inflate(
                    R.layout.item_receive_msg_chat, parent, false)
            }
            TYPE_SYSTEM -> {
                LayoutInflater.from(parent.context).inflate(
                    R.layout.item_msg_system, parent, false)
            }
            else -> {
                LayoutInflater.from(parent.context).inflate(
                    R.layout.item_msg_system, parent, false)
            }
        }
        return object : RecyclerView.ViewHolder(itemView) {

        }
    }

    override fun getItemViewType(position: Int): Int {
        return when (val msg = msgList[position]) {
            is ChatMsg -> {
                if (msg.isMine()) {
                    TYPE_CHAT_SEND
                } else {
                    TYPE_CHAT_RECEIVE
                }
            }
            is SystemMsg -> {
                TYPE_SYSTEM
            }
            else -> {
                TYPE_SYSTEM
            }
        }
    }


    override fun getItemCount(): Int {
        return msgList.size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (val msg = msgList[position]) {
            is ChatMsg -> {
                val sendUser = holder.itemView.findViewById<TextView>(R.id.msg_owner)
                val msgTextView = holder.itemView.findViewById<TextView>(R.id.msg)
                msgTextView.text = msg.content
                sendUser.text = msg.sendUserName

                if (isSameUserFirstMsg(position)) {
                    if (msg.isMine()) {
                        sendUser.visibility = View.INVISIBLE
                    } else {
                        sendUser.visibility = View.VISIBLE
                        sendUser.text = msg.sendUserName
                    }
                } else {
                    sendUser.visibility = View.GONE
                }

                if (getItemViewType(position) == TYPE_CHAT_SEND) {
                    val sendFailed = holder.itemView.findViewById<ImageView>(R.id.send_failed)
                    val sending = holder.itemView.findViewById<ProgressBar>(R.id.sending)
                    when (msg.status) {
                        ChatMsg.STATUS_SENDING -> {
                            sending.visibility = View.VISIBLE
                            sendFailed.visibility = View.GONE
                        }
                        ChatMsg.STATUS_SEND_FAILED -> {
                            sending.visibility = View.GONE
                            sendFailed.visibility = View.VISIBLE
                            sendFailed.setOnClickListener {
                                resendListener?.invoke(msg)
                            }
                        }
                        ChatMsg.STATUS_SEND_SUCCESS -> {
                            sending.visibility = View.GONE
                            sendFailed.visibility = View.GONE
                        }
                        else -> {
                            sending.visibility = View.GONE
                            sendFailed.visibility = View.GONE
                        }
                    }

                }
            }
            is SystemMsg -> {
                val itemView = holder.itemView
                if (itemView is TextView) {
                    itemView.text = msg.content
                }
            }
            else -> {

            }
        }
    }

    /**
     * 是否为用户连续发送多条消息中的第一条消息
     * 如果是，显示用户名。
     * 如果不是，不显示用户名。
     */
    private fun isSameUserFirstMsg(position: Int): Boolean {
        val msg = msgList[position]
        if (msg is ChatMsg) {
            return if ((position == 1)) {
                true
            } else {
                val preMsg = msgList[position - 1]
                if (preMsg is ChatMsg) {
                    preMsg.sendUserName != msg.sendUserName
                } else {
                    true
                }
            }
        }
        return false
    }

}