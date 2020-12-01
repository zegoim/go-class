package model

import (
	"context"
	"github.com/astaxie/beego/logs"
	"github.com/garyburd/redigo/redis"
	"go_class_server/go_class_room/resource"
)

type RoomTypeEnum int8

const (
	SmallRoom RoomTypeEnum = 1
	LargeRoom RoomTypeEnum = 2
)

type RoomState struct {
	RoomId             string `redis:"room_id"`
	RoomType           int8   `redis:"room_type"`
	DefaultCameraState int8   `redis:"default_camera_state"` // 默认摄像头设置
	DefaultMicState    int8   `redis:"default_mic_state"`    // 默认麦克风设置
	AllowTurnOnCamera  int8   `redis:"allow_turn_on_camera"` // 允许成员自行开麦
	AllowTurnOnMic     int8   `redis:"allow_turn_on_mic"`    // 允许成员自行打开视频
	SharingUid         int64  `redis:"sharing_uid"`          // 正在共享的uid
	TeacherUid         int64  `redis:"teacher_uid"`          // 老师uid
	RoomCreateTime     int64  `redis:"room_create_time"`     // 房间建立时间
}

func GetRoomState(ctx context.Context, roomId string) (roomState *RoomState, err error) {
	roomState = &RoomState{}
	err = resource.RedisClient().GetHashStruct(GetRoomStateKey(roomId), roomState)
	if nil != err {
		if redis.ErrNil == err {
			return nil, nil
		}
		logs.Error("GetRoomState failed:%s, roomId:%s", err.Error(), roomId)
	}

	return
}

func SetRoomState(ctx context.Context, roomId string, roomState *RoomState) error {
	fields, values := encode2Fields(*roomState)
	if 0 == len(fields) {
		return nil
	}

	_, err := resource.RedisClient().PipeLineHset(GetRoomStateKey(roomId), fields, values)
	if nil != err {
		logs.Error("SetRoomState failed:%s, roomId:%s", err.Error(), roomId)
	}

	return err
}

func GetRoomSharingUid(ctx context.Context, roomId string) (int64, error) {
	return resource.RedisClient().GetHashInt64(GetRoomStateKey(roomId), "sharing_uid")
}

func GetRoomTeacherUid(ctx context.Context, roomId string) (int64, error) {
	return resource.RedisClient().GetHashInt64(GetRoomStateKey(roomId), "teacher_uid")
}

func ExistsRoomState(ctx context.Context, roomId string) bool {
	return resource.RedisClient().Exists(GetRoomStateKey(roomId))
}

// 设置共享uid
func SetSharingUid(ctx context.Context, roomId string, oldVal, newVal int64) (bool, error) {
	script := `
    local key = KEYS[1]
    local oldVal = tonumber(ARGV[1])
	local newVal = tonumber(ARGV[2])

	local sharingUid = 0
	if redis.call("HEXISTS", key, "sharing_uid") == 1 then
		sharingUid = tonumber(redis.call("HGET", key, "sharing_uid"))
	end

	if sharingUid == oldVal then 
		redis.call("HSET", key, "sharing_uid", newVal)
		return 1
	end

	return 0`

	ret, err := redis.Int(resource.RedisClient().EvalLuaScript(script, []string{GetRoomStateKey(roomId)}, oldVal, newVal))
	if err != nil {
		logs.Error("execute SetSharingUid redis lua failed, err:%s", err.Error())
		return false, err
	}

	return ret == 1, nil
}

// 设置老师id
func SetTeacherUid(ctx context.Context, roomId string, oldVal, newVal int64) (bool, error) {
	script := `
    local key = KEYS[1]
    local oldVal = tonumber(ARGV[1])
	local newVal = tonumber(ARGV[2])

	local sharingUid = 0
	if redis.call("HEXISTS", key, "teacher_uid") == 1 then
		sharingUid = tonumber(redis.call("HGET", key, "teacher_uid"))
	end

	if sharingUid == oldVal then 
		redis.call("HSET", key, "teacher_uid", newVal)
		return 1
	end

	return 0`

	ret, err := redis.Int(resource.RedisClient().EvalLuaScript(script, []string{GetRoomStateKey(roomId)}, oldVal, newVal))
	if err != nil {
		logs.Error("execute SetTeacherUid redis lua failed, err:%s", err.Error())
		return false, err
	}

	return ret == 1, nil
}
