package model

import (
	"context"
	"github.com/astaxie/beego/logs"
	"github.com/garyburd/redigo/redis"
	"go_class_server/go_class_room/resource"
)

func Add2TobeDestroyList(ctx context.Context, roomId string, destroyTime int64) error {
	return resource.RedisClient().ZAddNx(GetTobeDestroyedRoomListKey(), destroyTime, roomId)
}

func DelFromTobeDestroyList(ctx context.Context, roomId string) error {
	return resource.RedisClient().ZRem(GetTobeDestroyedRoomListKey(), roomId)
}

func IsRoomTobeDestroy(ctx context.Context, roomId string) (bool, error) {
	_, err := resource.RedisClient().ZScore(GetTobeDestroyedRoomListKey(), roomId)
	if nil != err {
		if redis.ErrNil == err {
			return false, nil
		}
		return false, err
	}

	return true, nil
}

func GetShouldDestroyRoomList(ctx context.Context, time int64) ([]string, error) {
	conn := resource.RedisClient().GetPool().Get()
	defer conn.Close()

	key := GetTobeDestroyedRoomListKey()

	conn.Send("MULTI")
	conn.Send("ZRANGEBYSCORE", key, 0, time)
	conn.Send("ZREMRANGEBYSCORE", key, 0, time)

	replys, err := redis.Values(conn.Do("EXEC"))
	if nil != err || 0 == len(replys) {
		logs.Error("model.GetShouldDestroyRoomList Failed:%v", err.Error())
		return nil, err
	}

	return redis.Strings(replys[0], err)
}
