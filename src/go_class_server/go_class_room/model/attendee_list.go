package model

import (
	"context"
	"github.com/astaxie/beego/logs"
	"github.com/garyburd/redigo/redis"
	"go_class_server/go_class_room/resource"
)

func GetAttendeeUidList(ctx context.Context, roomId string) ([]string, error) {
	return resource.RedisClient().SMembersString(GetAttendeeListKey(roomId))
}

func GetAttendeeListCount(ctx context.Context, roomId string) (int64, error) {
	return resource.RedisClient().Scard(GetAttendeeListKey(roomId))
}

func Add2AttendeeList(ctx context.Context, roomId string, uid int64) error {
	conn := resource.RedisClient().GetPool().Get()
	defer conn.Close()

	conn.Send("MULTI")
	conn.Send("SADD", GetAttendeeListKey(roomId), uid)
	conn.Send("INCR", GetAttendeeListSeqKey(roomId))

	_, err := redis.Values(conn.Do("EXEC"))
	if nil != err {
		logs.Error("model.Add2AttendeeList Failed:%v", err.Error())
		return err
	}
	return nil
}

// 获取成员列表和成员列表序列号
func GetAttendeeList(ctx context.Context, roomId string) (users []PersonalState, seq int64, err error) {
	var uids []string
	uids, err = GetAttendeeUidList(ctx, roomId)
	if nil != err {
		return
	}
	if 0 == len(uids) {
		users = []PersonalState{}
		seq, err = GetAttendeeListSeq(ctx, roomId)
		return
	}

	conn := resource.RedisClient().GetPool().Get()
	defer conn.Close()

	conn.Send("MULTI")
	conn.Send("GET", GetAttendeeListSeqKey(roomId))
	personalKeyPre := GetPersonalStateKeyPre(roomId)
	for _, uid := range uids {
		conn.Send("HGETALL", personalKeyPre+uid)
	}

	var replys []interface{}
	replys, err = redis.Values(conn.Do("EXEC"))
	if nil != err || 0 == len(replys) {
		logs.Error("model.GetAttendeeList Failed:%v", err.Error())
		return
	}

	seq, err = redis.Int64(replys[0], err)
	if nil != err {
		logs.Error("model.GetAttendeeList GetAttendeeListSeqKey Failed:%s", err.Error())
		return
	}

	for i := 1; i < len(replys); i++ {
		var personalState PersonalState
		err = redis.ScanStruct(replys[i].([]interface{}), &personalState)
		if nil != err {
			logs.Error("model.GetAttendeeList scan PersonalState Failed:%s", err.Error())
			continue
		}

		users = append(users, personalState)
	}
	return
}

func GetAttendeeListSeq(ctx context.Context, roomId string) (int64, error) {
	return resource.RedisClient().GetInt64(GetAttendeeListSeqKey(roomId))
}
