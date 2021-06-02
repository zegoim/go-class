package im.zego.goclass.entity

/**
 * 大班课讨论聊天消息
 */
class ChatMsg(
    var id: String,
    var content: String,
    var sendUserId: String,
    var sendUserName: String,
    var status: Int
) : IMsg {

    var seq = -1

    companion object {

        const val STATUS_RECEIVE = 0
        const val STATUS_SENDING = 1
        const val STATUS_SEND_FAILED = 2
        const val STATUS_SEND_SUCCESS = 4

        var sendReq = 0

        fun createSendSeq(): Int {
            return ++sendReq
        }

    }

    /**
     * 我的即为发送的消息，不是我的即为接收到的消息。
     * 用于区分是发送的消息，还是接收到的消息。
     */
    fun isMine(): Boolean {
        return when (status) {
            STATUS_SENDING, STATUS_SEND_FAILED, STATUS_SEND_SUCCESS -> {
                true
            }
            STATUS_RECEIVE -> {
                false
            }
            else -> {
                false
            }
        }
    }


}