package model

import (
	"fmt"
	"go_class_server/utils/stringUtil"
	"strings"
)

const (
	EDU_ROOM_LIST_KEY               = "edu_room:room_list"       // 在线房间列表
	EDU_ROOM_STATE_KEY_PRE          = "edu_room:room_state:"     // 房间状态信息
	EDU_ROOM_ATTENDEE_LIST_KEY_PRE  = "edu_room:attendee_list:"  // 参会成员列表
	EDU_ROOM_PERSONAL_STATE_KEY_PRE = "edu_room:personal_state:" // 参会成员状态信息
	EDU_ROOM_JOIN_LIVE_LIST_KEY_PRE = "edu_room:join_live_list:" // 连麦成员列表

	EDU_ROOM_ONLINE_LIST_KEY         = "edu_room:online:list"      // 在线用户列表
	EDU_ROOM_ONLINE_PERSONAL_KEY_PRE = "edu_room:online:personal:" // 在线用户状态信息

	EDU_ROOM_ATTENDEE_LIST_SEQ_KEY_PRE  = "edu_room:attendee_list:seq:"  // 参会成员列表seq
	EDU_ROOM_JOIN_LIVE_LIST_SEQ_KEY_PRE = "edu_room:join_live_list:seq:" // 连麦成员列表seq

	EDU_ROOM_TO_BE_DESTROYED_LIST = "edu_room:tobe_destroyed_list" // 待销毁房间列表
)

// 房间列表KEY
func GetRoomListKey() string {
	return EDU_ROOM_LIST_KEY
}

// 房间状态KEY
func GetRoomStateKey(roomId string) string {
	return EDU_ROOM_STATE_KEY_PRE + roomId
}

// 参会成员列表KEY
func GetAttendeeListKey(roomId string) string {
	return EDU_ROOM_ATTENDEE_LIST_KEY_PRE + roomId
}

// 连麦成员列表KEY
func GetJoinLiveListKey(roomId string) string {
	return EDU_ROOM_JOIN_LIVE_LIST_KEY_PRE + roomId
}

// 参会成员状态KEY
func GetPersonalStateKey(roomId string, uid int64) string {
	return fmt.Sprintf("%s%s:%d", EDU_ROOM_PERSONAL_STATE_KEY_PRE, roomId, uid)
}

func GetPersonalStateKeyPre(roomId string) string {
	return fmt.Sprintf("%s%s:", EDU_ROOM_PERSONAL_STATE_KEY_PRE, roomId)
}

// 在线用户列表
func GetOnlineListKey() string {
	return EDU_ROOM_ONLINE_LIST_KEY
}

// 在线用户状态信息
func GetOnlinePersonKey(roomId string, uid int64) string {
	return fmt.Sprintf("%s%s:%d", EDU_ROOM_ONLINE_PERSONAL_KEY_PRE, roomId, uid)
}

// 参会成员列表seq KEY
func GetAttendeeListSeqKey(roomId string) string {
	return EDU_ROOM_ATTENDEE_LIST_SEQ_KEY_PRE + roomId
}

// 连麦成员列表seq KEY
func GetJoinLiveListSeqKey(roomId string) string {
	return EDU_ROOM_JOIN_LIVE_LIST_SEQ_KEY_PRE + roomId
}

// 待销毁房间列表
func GetTobeDestroyedRoomListKey() string {
	return EDU_ROOM_TO_BE_DESTROYED_LIST
}

// 创建 uniq roomid
func CreateUniqRoomId(roomId string, roomType int8) string {
	switch RoomTypeEnum(roomType) {
	case LargeRoom:
		return fmt.Sprintf("%d-%s", roomType, roomId)
	default: // 默认返回原房间id，兼容老版本客户端
		return roomId
	}
}

// 获取roomid 和 room_type
func GetRoomIdAndTypeByUniq(uniqRoomId string) (roomId string, roomType int8) {
	idx := strings.Index(uniqRoomId, "-")
	if -1 == idx {
		return uniqRoomId, int8(SmallRoom)
	}

	return uniqRoomId[idx+1:], int8(stringUtil.StringToInt(uniqRoomId[:idx]))
}
