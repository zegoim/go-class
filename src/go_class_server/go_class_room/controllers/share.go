package controllers

import (
	"go_class_server/go_class_room/controllers/base"
	"go_class_server/go_class_room/protocol"
	"go_class_server/go_class_room/service"
	"go_class_server/utils/common"
	"go_class_server/utils/errorUtil"
)

type ShareController struct {
	base.BaseController
}

// 开始共享
func (c *ShareController) StartShare() {
	defer c.PrintPanicLog()

	var req protocol.StartShareReq
	c.GetRequest(&req)

	if 0 >= req.Uid || "" == req.RoomId || !service.IsRoomTypeValid(req.RoomType) {
		c.Error(&errorUtil.Error{
			Code:    common.ERROR_INVALID_PARAMTEER,
			Message: "invalid parameter",
		})
	}

	e := service.Room(c.Ctx.Request.Context(), req.RoomId, req.RoomType).StartShare(req.Uid)
	if nil != e {
		c.Error(e)
	}

	c.Succeed(protocol.StartShareResp{Ret: protocol.CommonResult{
		Code:    0,
		Message: "succeed",
	}})
}

// 结束共享
func (c *ShareController) StopShare() {
	defer c.PrintPanicLog()

	var req protocol.StopShareReq
	c.GetRequest(&req)

	if 0 >= req.Uid || "" == req.RoomId || 0 >= req.TargetUid || !service.IsRoomTypeValid(req.RoomType) {
		c.Error(&errorUtil.Error{
			Code:    common.ERROR_INVALID_PARAMTEER,
			Message: "invalid parameter",
		})
	}

	e := service.Room(c.Ctx.Request.Context(), req.RoomId, req.RoomType).StopShare(req.Uid, req.TargetUid)
	if nil != e {
		c.Error(e)
	}

	c.Succeed(protocol.StopShareResp{Ret: protocol.CommonResult{
		Code:    0,
		Message: "succeed",
	}})
}
