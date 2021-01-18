package im.zego.goclass.network

import android.content.Context
import im.zego.goclass.R

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

        fun getPublicMsgFromCode(code: Int, context: Context?): String {
            if (context != null) {
                return when (code) {
                    0 -> "succeed"
                    NETWORK_ERROR -> context.getString(R.string.network_request_error)
                    NETWORK_TIMEOUT -> context.getString(R.string.network_connection_timeout)
                    NETWORK_UNCONNECTED -> context.getString(R.string.login_network_exception_try_again)
                    EXCEPTION -> context.getString(R.string.abnormal)
                    DUPLICATE_REQUEST -> context.getString(R.string.repeated_requests)
                    SYSTEM_ERROR -> context.getString(R.string.system_error)
                    ERROR_PARAM -> context.getString(R.string.parameters_error)
                    TEACHER_EXISTED -> context.getString(R.string.login_other_teacher_in_the_class)
                    CLASS_FULL -> context.getString(R.string.login_class_is_full)
                    UN_AUTHORIZED -> context.getString(R.string.users_do_not_have_permission_to_modify)
                    TARGET_NOT_EXISTED -> context.getString(R.string.target_not_in_the_classroom)
                    NEED_LOGIN -> context.getString(R.string.need_login_first)
                    CLASS_NOT_EXISTED -> context.getString(R.string.login_room_not_exist)
                    JOIN_LIVE_LIMIT -> context.getString(R.string.room_tip_channels)
                    USER_SHAREING -> context.getString(R.string.users_are_sharing)
                    USER_NOT_SHAREING -> context.getString(R.string.users_do_not_have_to_share)
                    USER_NOT_TEACHER -> context.getString(R.string.user_is_not_a_teacher)
                    SYNC_ERROR -> context.getString(R.string.sync_message_error)
                    else -> "unknown error"
                }
            } else {
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
}