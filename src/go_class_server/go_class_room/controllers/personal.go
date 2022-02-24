package controllers

import (
	"github.com/astaxie/beego"
	"go_class_server/go_class_room/controllers/base"
	"go_class_server/go_class_room/protocol"
	"go_class_server/go_class_room/service"
	"go_class_server/utils/common"
	"go_class_server/utils/errorUtil"
)

type PersonalController struct {
	base.BaseController
}

// 获取用户属性
func (c *PersonalController) GetUserInfo() {
	defer c.PrintPanicLog()

	var req protocol.GetUserInfoReq
	c.GetRequest(&req)

	if "" == req.RoomId || 0 >= req.Uid || 0 >= req.TargetUid || !service.IsRoomTypeValid(req.RoomType) {
		c.Error(&errorUtil.Error{
			Code:    common.ERROR_INVALID_PARAMTEER,
			Message: "invalid parameter",
		})
	}

	c.LogField["uid"] = req.Uid
	c.LogField["room_id"] = req.RoomId
	c.LogField["target_uid"] = req.TargetUid

	personalState, e := service.Room(c.Ctx.Request.Context(), req.RoomId, req.RoomType).GetPersonalState(req.Uid, req.TargetUid)
	if nil != e {
		c.Error(e)
	}

	c.Succeed(protocol.GetUserInfoResp{
		Ret: protocol.CommonResult{
			Code:    0,
			Message: "succeed",
		},
		Data: service.ConvertModelPersonalState2Protocol(personalState),
	})
}

// 设置用户属性
func (c *PersonalController) SetUserInfo() {
	defer c.PrintPanicLog()

	var req protocol.SetUserInfoReq
	c.GetRequest(&req)
	if "" == req.RoomId || 0 >= req.Uid || 0 >= req.TargetUid || !req.PersonalStateSetableParams.IsValid() ||
		!service.IsRoomTypeValid(req.RoomType) {
		c.Error(&errorUtil.Error{
			Code:    common.ERROR_INVALID_PARAMTEER,
			Message: "invalid parameter",
		})
	}

	// 如果没有更改任何数据 直接返回
	if !req.PersonalStateSetableParams.ChangeAnyState() {
		c.Succeed(protocol.SetUserInfoResp{Ret: protocol.CommonResult{
			Code:    0,
			Message: "succeed",
		}})
	}

	c.LogField["uid"] = req.Uid
	c.LogField["room_id"] = req.RoomId
	c.LogField["target_uid"] = req.TargetUid

	e := service.Room(c.Ctx.Request.Context(), req.RoomId, req.RoomType).SetPersonalState(req.Uid, req.TargetUid, &req.PersonalStateSetableParams)
	if nil != e {
		c.Error(e)
	}

	c.Succeed(protocol.SetUserInfoResp{Ret: protocol.CommonResult{
		Code:    0,
		Message: "succeed",
	}})
}

// 心跳
func (c *PersonalController) Heartbeat() {
	defer c.PrintPanicLog()

	var req protocol.HeartbeatReq
	c.GetRequest(&req)

	if 0 >= req.Uid || "" == req.RoomId || !service.IsRoomTypeValid(req.RoomType) {
		c.Error(&errorUtil.Error{
			Code:    common.ERROR_INVALID_PARAMTEER,
			Message: "invalid parameter",
		})
	}

	c.LogField["uid"] = req.Uid
	c.LogField["room_id"] = req.RoomId

	seqs, e := service.Room(c.Ctx.Request.Context(), req.RoomId, req.RoomType).Heartbeat(req.Uid)
	if nil != e {
		c.Error(e)
	}

	c.Succeed(protocol.HeartbeatResp{
		Ret: protocol.CommonResult{
			Code:    0,
			Message: "succeed",
		},
		Data: struct {
			Interval int32 `json:"interval"`
			protocol.HeartbeatSeqs
		}{
			Interval:      int32(beego.AppConfig.DefaultInt("HeartbeatInterval", 30)),
			HeartbeatSeqs: seqs,
		},
	})
}
