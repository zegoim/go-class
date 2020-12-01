package model

import (
	"context"
	"fmt"
	"github.com/astaxie/beego/logs"
	"github.com/garyburd/redigo/redis"
	"go_class_server/go_class_room/resource"
	"go_class_server/utils/stringUtil"
	"go_class_server/utils/timeUtil"
	"strings"
)

type OfflineUser struct {
	RoomId   string
	RoomType int8
	Uid      int64
}

func getOnlineListValue(roomId string, uid int64) string {
	return fmt.Sprintf("%s:%d", roomId, uid)
}

func getOnlineListValueByUidStr(roomId string, uid string) string {
	return roomId + ":" + uid
}

func SetHeartbeatTime(ctx context.Context, roomId string, uid int64) error {
	return resource.RedisClient().ZAdd(GetOnlineListKey(), timeUtil.MilliSecond(), getOnlineListValue(roomId, uid))
}

func IsHeartbeat(ctx context.Context, roomId, uidStr string) (bool, error) {
	_, err := resource.RedisClient().ZScore(GetOnlineListKey(), getOnlineListValueByUidStr(roomId, uidStr))
	if nil != err {
		if redis.ErrNil == err {
			return false, nil
		}
		return false, err
	}

	return true, nil
}

func GetOfflineUsers(ctx context.Context, time int64) ([]OfflineUser, error) {
	conn := resource.RedisClient().GetPool().Get()
	defer conn.Close()

	key := GetOnlineListKey()

	conn.Send("MULTI")
	conn.Send("ZRANGEBYSCORE", key, 0, time)
	conn.Send("ZREMRANGEBYSCORE", key, 0, time)

	replys, err := redis.Values(conn.Do("EXEC"))
	if nil != err || 0 == len(replys) {
		logs.Error("model.GetOfflineUsers Failed:%v", err.Error())
		return nil, err
	}

	strs, err := redis.Strings(replys[0], err)
	if nil != err {
		logs.Error("model.GetOfflineUsers Convert Strings Failed:%v", err.Error())
		return nil, err
	}

	users := make([]OfflineUser, 0, len(strs))
	for i := 0; i < len(strs); i++ {
		strs := strings.Split(strs[i], ":")
		if len(strs) < 2 {
			continue
		}

		user := OfflineUser{
			Uid: stringUtil.StringToInt64(strs[1]),
		}
		user.RoomId, user.RoomType = GetRoomIdAndTypeByUniq(strs[0])
		users = append(users, user)
	}
	return users, nil
}
