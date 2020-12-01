package common

const (
	ERROR_PANIC_ERROR             = 1 // 异常
	ERROR_REQUEST_ALREADY_HANDLED = 2 // 重复请求
	ERROR_SYSTEM_ERROR            = 3 // 系统错误
	ERROR_INVALID_PARAMTEER       = 4 // 错误的参数

	ERROR_TEACHER_ALREADY_IN      = 10001 // 课堂已有老师，不能加入
	ERROR_ROOM_PEOPLE_OVERFLOW    = 10002 // 课堂人数已满，无法加入
	ERROR_USER_NO_PERMISSION      = 10003 // 没有权限
	ERROR_USER_NOT_IN_ROOM        = 10004 // 目标用户不在房间
	ERROR_NEED_LOGIN_FIRST        = 10005 // 需要先登录房间
	ERROR_ROOM_NOT_EXIST          = 10006 // 房间不存在
	ERROR_ROOM_JOIN_LIVE_OVERFLOW = 10007 // 连麦人数已满
	ERROR_ROOM_SHARING            = 10008 // 用户正在共享
	ERROR_USER_NOT_SHARING        = 10009 // 用户没有在共享
	ERROR_USER_NOT_TEACHER        = 10010 // 用户不是老师
	ERROR_SEND_MESSAGE_TO_ROOM    = 10011 // 同步消息错误
	ERROR_CLEAR_ROOM              = 10012 // 清除房间错误
)
