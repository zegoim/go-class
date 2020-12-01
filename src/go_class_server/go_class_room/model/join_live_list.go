package model

import (
	"context"
	"github.com/astaxie/beego/logs"
	"github.com/garyburd/redigo/redis"
	"go_class_server/go_class_room/resource"
	"go_class_server/utils/stringUtil"
	"go_class_server/utils/timeUtil"
)

func GetJoinLiveUidList(ctx context.Context, roomId string) ([]string, error) {
	return resource.RedisClient().SMembersString(GetJoinLiveListKey(roomId))
}

func GetJoinLiveListCount(ctx context.Context, roomId string) (int64, error) {
	return resource.RedisClient().Scard(GetJoinLiveListKey(roomId))
}

func IsJoinLive(ctx context.Context, roomId string, uid int64) (bool, error) {
	return resource.RedisClient().SIsMember(GetJoinLiveListKey(roomId), stringUtil.Int64Tostring(uid))
}

func Add2JoinLiveList(ctx context.Context, roomId string, uid int64) error {
	return resource.RedisClient().SAdd(GetJoinLiveListKey(roomId), uid)
}

func DelUidFromJoinLive(ctx context.Context, roomId string, uid int64) error {
	return resource.RedisClient().SRemInt64(GetJoinLiveListKey(roomId), uid)
}

func GetJoinLiveListSeq(ctx context.Context, roomId string) (int64, error) {
	return resource.RedisClient().GetInt64(GetJoinLiveListSeqKey(roomId))
}

func JoinLive(ctx context.Context, roomId string, uid int64) error {
	conn := resource.RedisClient().GetPool().Get()
	defer conn.Close()

	conn.Send("MULTI")
	conn.Send("SADD", GetJoinLiveListKey(roomId), uid)
	conn.Send("HSET", GetPersonalStateKey(roomId, uid), "join_live_time", stringUtil.Int64Tostring(timeUtil.MilliSecond()))
	conn.Send("INCR", GetJoinLiveListSeqKey(roomId))

	_, err := redis.Values(conn.Do("EXEC"))
	if nil != err {
		logs.Error("model.JoinLive Failed:%v", err.Error())
		return err
	}
	return nil
}

func QuitJoinLive(ctx context.Context, roomId string, uid int64) error {
	conn := resource.RedisClient().GetPool().Get()
	defer conn.Close()

	conn.Send("MULTI")
	conn.Send("SREM", GetJoinLiveListKey(roomId), uid)
	conn.Send("HSET", GetPersonalStateKey(roomId, uid), "join_live_time", 0)
	conn.Send("INCR", GetJoinLiveListSeqKey(roomId))

	_, err := redis.Values(conn.Do("EXEC"))
	if nil != err {
		logs.Error("model.QuitJoinLive Failed:%v", err.Error())
		return err
	}
	return nil
}

// 获取连麦成员列表和序列号
func GetJoinLiveList(ctx context.Context, roomId string) (users []PersonalState, seq int64, err error) {
	var uids []string
	uids, err = GetJoinLiveUidList(ctx, roomId)
	if nil != err {
		return
	}
	if 0 == len(uids) {
		users = []PersonalState{}
		seq, err = GetJoinLiveListSeq(ctx, roomId)
		return
	}

	conn := resource.RedisClient().GetPool().Get()
	defer conn.Close()

	conn.Send("MULTI")
	conn.Send("GET", GetJoinLiveListSeqKey(roomId))
	personalKeyPre := GetPersonalStateKeyPre(roomId)
	for _, uid := range uids {
		conn.Send("HGETALL", personalKeyPre+uid)
	}

	var replys []interface{}
	replys, err = redis.Values(conn.Do("EXEC"))
	if nil != err || 0 == len(replys) {
		logs.Error("model.GetJoinLiveList Failed:%v", err.Error())
		return
	}

	seq, err = redis.Int64(replys[0], err)
	if nil != err {
		logs.Error("model.GetJoinLiveList GetAttendeeListSeqKey Failed:%s", err.Error())
		return
	}

	for i := 1; i < len(replys); i++ {
		var personalState PersonalState
		err = redis.ScanStruct(replys[i].([]interface{}), &personalState)
		if nil != err {
			logs.Error("model.GetJoinLiveList scan PersonalState Failed:%s", err.Error())
			continue
		}

		users = append(users, personalState)
	}
	return
}
