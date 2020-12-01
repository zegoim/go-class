package loader

import (
	"github.com/astaxie/beego"
	"go_class_server/go_class_room/conf"
)

type BeegoLoader struct {
}

func (this *BeegoLoader) Load(c *conf.Configs) error {
	// 小班课配置
	c.SmallRoomCfgs.MaxPeopleNum = beego.AppConfig.DefaultInt("SmallClass::MaxPeopleNum", 10)
	c.SmallRoomCfgs.MaxJoinLiveNum = beego.AppConfig.DefaultInt("SmallClass::MaxJoinLiveNum", 4)
	c.SmallRoomCfgs.RoomTeacherNum = beego.AppConfig.DefaultInt("SmallClass::RoomTeacherNum", 1)
	c.SmallRoomCfgs.RoomStudentNum = beego.AppConfig.DefaultInt("SmallClass::RoomStudentNum", 9)
	c.SmallRoomCfgs.DefaultCameraState = int8(beego.AppConfig.DefaultInt("SmallClass::DefaultCameraState", 1))
	c.SmallRoomCfgs.DefaultMicState = int8(beego.AppConfig.DefaultInt("SmallClass::DefaultMicState", 1))
	c.SmallRoomCfgs.AllowTurnOnCamera = int8(beego.AppConfig.DefaultInt("SmallClass::AllowTurnOnCamera", 2))
	c.SmallRoomCfgs.AllowTurnOnMic = int8(beego.AppConfig.DefaultInt("SmallClass::AllowTurnOnMic", 2))

	var err error
	c.SmallRoomCfgs.AppId, err = beego.AppConfig.Int64("SmallClass::AppId")
	if nil != err {
		panic(err)
	}
	c.SmallRoomCfgs.AppSecret = beego.AppConfig.String("SmallClass::AppSecret")
	c.SmallRoomCfgs.AppBizType = beego.AppConfig.DefaultInt("SmallClass::AppBizType", 1)
	c.SmallRoomCfgs.AppMode = beego.AppConfig.String("SmallClass::LiveRoomMode")
	c.SmallRoomCfgs.EndPoint = beego.AppConfig.String("SmallClass::LiveRoomEndPoint")

	// 大班课配置
	c.LargeRoomCfgs.MaxPeopleNum = beego.AppConfig.DefaultInt("LargeClass::MaxPeopleNum", 10)
	c.LargeRoomCfgs.MaxJoinLiveNum = beego.AppConfig.DefaultInt("LargeClass::MaxJoinLiveNum", 4)
	c.LargeRoomCfgs.RoomTeacherNum = beego.AppConfig.DefaultInt("LargeClass::RoomTeacherNum", 1)
	c.LargeRoomCfgs.RoomStudentNum = beego.AppConfig.DefaultInt("LargeClass::RoomStudentNum", 9)
	c.LargeRoomCfgs.DefaultCameraState = int8(beego.AppConfig.DefaultInt("LargeClass::DefaultCameraState", 1))
	c.LargeRoomCfgs.DefaultMicState = int8(beego.AppConfig.DefaultInt("LargeClass::DefaultMicState", 1))
	c.LargeRoomCfgs.AllowTurnOnCamera = int8(beego.AppConfig.DefaultInt("LargeClass::AllowTurnOnCamera", 2))
	c.LargeRoomCfgs.AllowTurnOnMic = int8(beego.AppConfig.DefaultInt("LargeClass::AllowTurnOnMic", 2))

	c.LargeRoomCfgs.AppId, err = beego.AppConfig.Int64("LargeClass::AppId")
	if nil != err {
		panic(err)
	}
	c.LargeRoomCfgs.AppSecret = beego.AppConfig.String("LargeClass::AppSecret")
	c.LargeRoomCfgs.AppBizType = beego.AppConfig.DefaultInt("LargeClass::AppBizType", 1)
	c.LargeRoomCfgs.AppMode = beego.AppConfig.String("LargeClass::LiveRoomMode")
	c.LargeRoomCfgs.EndPoint = beego.AppConfig.String("LargeClass::LiveRoomEndPoint")

	return nil
}
