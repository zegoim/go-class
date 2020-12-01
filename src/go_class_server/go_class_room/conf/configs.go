package conf

import "sync"

type ConfigsLoader interface {
	Load(*Configs) error
}

type LiveRoomConfigs struct {
	AppId      int64
	AppSecret  string
	AppBizType int
	EndPoint   string
	AppMode    string
}

type RoomConfigs struct {
	MaxPeopleNum       int
	MaxJoinLiveNum     int
	RoomTeacherNum     int
	RoomStudentNum     int
	DefaultCameraState int8
	DefaultMicState    int8
	AllowTurnOnCamera  int8
	AllowTurnOnMic     int8

	LiveRoomConfigs
}

type Configs struct {
	SmallRoomCfgs RoomConfigs
	LargeRoomCfgs RoomConfigs
}

var (
	cfgs Configs
	once sync.Once
)

func Init(loader ConfigsLoader) {
	err := loader.Load(&cfgs)
	if nil != err {
		panic(err)
	}
}

func GetSmallRoomCfgs() RoomConfigs {
	return cfgs.SmallRoomCfgs
}

func GetLargeRoomCfgs() RoomConfigs {
	return cfgs.LargeRoomCfgs
}
