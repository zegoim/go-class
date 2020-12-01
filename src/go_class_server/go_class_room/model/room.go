package model

import (
	"context"
	"github.com/astaxie/beego/logs"
	"github.com/garyburd/redigo/redis"
	"go_class_server/go_class_room/resource"
)

func Add2RoomList(ctx context.Context, roomId string) error {
	return resource.RedisClient().SAdd(GetRoomListKey(), roomId)
}

// 离开房间
func LeaveRoom(ctx context.Context, roomId string, uid int64, role RoleEnum, hasJoinLive bool) error {
	conn := resource.RedisClient().GetPool().Get()
	defer conn.Close()

	conn.Send("MULTI")
	conn.Send("DEL", GetPersonalStateKey(roomId, uid))
	conn.Send("SREM", GetAttendeeListKey(roomId), uid)
	conn.Send("INCR", GetAttendeeListSeqKey(roomId))
	conn.Send("ZREM", GetOnlineListKey(), getOnlineListValue(roomId, uid))
	if RoleTeacher == role {
		conn.Send("HDEL", GetRoomStateKey(roomId), "teacher_uid")
	}
	if hasJoinLive {
		conn.Send("SREM", GetJoinLiveListKey(roomId), uid)
		conn.Send("INCR", GetJoinLiveListSeqKey(roomId))
	}

	_, err := redis.Values(conn.Do("EXEC"))
	if nil != err {
		logs.Error("model.LeaveRoom Failed:%v", err.Error())
		return err
	}

	return nil
}

// 清除房间
func ClearRoom(ctx context.Context, roomId string) error {
	attendeeList, err := GetAttendeeUidList(ctx, roomId)
	if nil != err {
		return err
	}

	conn := resource.RedisClient().GetPool().Get()
	defer conn.Close()

	conn.Send("MULTI")
	conn.Send("SREM", GetRoomListKey(), roomId)
	conn.Send("DEL", GetRoomStateKey(roomId))
	conn.Send("DEL", GetAttendeeListKey(roomId))
	conn.Send("DEL", GetJoinLiveListKey(roomId))
	conn.Send("DEL", GetAttendeeListSeqKey(roomId))
	conn.Send("DEL", GetJoinLiveListSeqKey(roomId))

	// 删除用户状态信息
	personalKeyPre := GetPersonalStateKeyPre(roomId)
	heartbeatKeys := make([]interface{}, 0, len(attendeeList)+1)
	heartbeatKeys = append(heartbeatKeys, GetOnlineListKey())
	for _, uid := range attendeeList {
		conn.Send("DEL", personalKeyPre+uid)
		heartbeatKeys = append(heartbeatKeys, getOnlineListValueByUidStr(roomId, uid))
	}

	// 删除心跳信息
	if 0 < len(attendeeList) {
		conn.Send("ZREM", heartbeatKeys...)
	}

	_, err = redis.Values(conn.Do("EXEC"))
	if nil != err {
		logs.Error("model.ClearRoom Failed:%v", err.Error())
		return err
	}

	return nil
}

func RandomGetRooms(ctx context.Context, count int) (roomIds []string, err error) {
	return resource.RedisClient().SRandMember(GetRoomListKey(), count)
}
