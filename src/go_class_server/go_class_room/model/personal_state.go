package model

import (
	"context"
	"github.com/astaxie/beego/logs"
	"github.com/garyburd/redigo/redis"
	"go_class_server/go_class_room/resource"
)

type RoleEnum int8

const (
	RoleTeacher RoleEnum = 1
	RoleStudent RoleEnum = 2
)

type PersonalState struct {
	UID          int64    `redis:"uid"`
	NickName     string   `redis:"nick_name"`
	Role         RoleEnum `redis:"role"`
	Camera       int8     `redis:"camera"`
	Mic          int8     `redis:"mic"`
	CanShare     int8     `redis:"can_share"`
	LoginTime    int64    `redis:"login_time"`
	JoinLiveTime int64    `redis:"join_live_time"`
}

// 是否存在用户状态
func ExistsPersonalState(ctx context.Context, roomId string, uid int64) bool {
	return resource.RedisClient().Exists(GetPersonalStateKey(roomId, uid))
}

func GetPersonalState(ctx context.Context, roomId string, uid int64) (personalState *PersonalState, err error) {
	personalState = &PersonalState{}
	err = resource.RedisClient().GetHashStruct(GetPersonalStateKey(roomId, uid), personalState)
	if nil != err {
		if redis.ErrNil == err {
			return nil, nil
		}
		logs.Error("GetPersonalState failed:%s, roomId:%s, uid:%d", err.Error(), roomId, uid)
	}

	return
}

func SetPersonalState(ctx context.Context, roomId string, uid int64, personalState *PersonalState) error {
	fields, values := encode2Fields(*personalState)
	if 0 == len(fields) {
		return nil
	}

	_, err := resource.RedisClient().PipeLineHset(GetPersonalStateKey(roomId, uid), fields, values)
	if nil != err {
		logs.Error("SetPersonalState failed:%s, roomId:%s, uid:%d", err.Error(), roomId, uid)
	}

	return err
}
