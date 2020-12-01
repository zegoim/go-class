package im.zego.goclass.network


class ZegoApiErrorCode {
    companion object {
        const val NETWORK_ERROR = -1
        const val NETWORK_UNCONNECTED = -2
        const val NETWORK_TIMEOUT = -3

        private const val EXCEPTION = 1
        private const val DUPLICATE_REQUEST = 2
        private const val SYSTEM_ERROR = 3
        private const val ERROR_PARAM = 4
        private const val TEACHER_EXISTED = 10001
        private const val CLASS_FULL = 10002
        private const val UN_AUTHORIZED = 10003
        private const val TARGET_NOT_EXISTED = 10004
        const val NEED_LOGIN = 10005
        private const val CLASS_NOT_EXISTED = 10006
        private const val JOIN_LIVE_LIMIT = 10007
        private const val USER_SHAREING = 10008
        private const val USER_NOT_SHAREING = 10009
        private const val USER_NOT_TEACHER = 10010
        private const val SYNC_ERROR = 10011

        fun getPublicMsgFromCode(code: Int): String {
            return when (code) {
                0 -> "succeed"
                NETWORK_ERROR -> "网络请求错误"
                NETWORK_TIMEOUT -> "网络连接超时"
                NETWORK_UNCONNECTED -> "网络异常，请检查网络后重试"
                EXCEPTION -> "异常"
                DUPLICATE_REQUEST -> "重复请求"
                SYSTEM_ERROR -> "系统错误"
                ERROR_PARAM -> "错误的参数"
                TEACHER_EXISTED -> "课堂已有其他老师，不能加入"
                CLASS_FULL -> "课堂人数已满，不能加入"
                UN_AUTHORIZED -> "用户没有权限修改"
                TARGET_NOT_EXISTED -> "目标用户不在教室"
                NEED_LOGIN -> "需要先登陆房间"
                CLASS_NOT_EXISTED -> "房间不存在"
                JOIN_LIVE_LIMIT -> "演示课堂最多开启3路学生音视频"
                USER_SHAREING -> "用户正在共享"
                USER_NOT_SHAREING -> "用户没有共享"
                USER_NOT_TEACHER -> "用户不是老师"
                SYNC_ERROR -> "同步消息错误"
                else -> "unknown error"
            }
        }
    }
}