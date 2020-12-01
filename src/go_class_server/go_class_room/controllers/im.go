package controllers

import (
	"go_class_server/go_class_room/controllers/base"
	"go_class_server/go_class_room/protocol"
	"go_class_server/go_class_room/service"
	"go_class_server/utils/common"
	"go_class_server/utils/errorUtil"
)

type ImController struct {
	base.BaseController
}

// 发送聊天消息
func (c *ImController) SendMessage() {
	defer c.PrintPanicLog()

	var req protocol.SendMessageReq
	c.GetRequest(&req)

	if 0 >= req.Uid || "" == req.RoomId || !service.IsRoomTypeValid(req.RoomType) || "" == req.Message {
		c.Error(&errorUtil.Error{
			Code:    common.ERROR_INVALID_PARAMTEER,
			Message: "invalid parameter",
		})
	}

	e := service.Room(c.Ctx.Request.Context(), req.RoomId, req.RoomType).SendMessage(req.Uid, req.Message)
	if nil != e {
		c.Error(e)
	}

	c.Succeed(protocol.SendMessageResp{Ret: protocol.CommonResult{
		Code:    0,
		Message: "succeed",
	}})
}
