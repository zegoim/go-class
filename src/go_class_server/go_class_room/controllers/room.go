package controllers

import (
	"fmt"
	"go_class_server/go_class_room/controllers/base"
	"go_class_server/go_class_room/protocol"
	"go_class_server/go_class_room/service"
	"go_class_server/utils/common"
	"go_class_server/utils/errorUtil"
)

type RoomController struct {
	base.BaseController
}

// 登录房间
func (c *RoomController) LoginRoom() {
	defer c.PrintPanicLog()

	var req protocol.LoginRoomReq
	c.GetRequest(&req)

	if 0 >= req.UID || "" == req.RoomId || !service.IsRoleValid(req.Role) || !service.IsRoomTypeValid(req.RoomType) {
		c.Error(&errorUtil.Error{
			Code:    common.ERROR_INVALID_PARAMTEER,
			Message: "invalid parameter",
		})
	}

	c.LogField["uid"] = req.UID
	c.LogField["room_id"] = req.RoomId
	c.LogField["role"] = req.Role

	room := service.Room(c.Ctx.Request.Context(), req.RoomId, req.RoomType)
	roomState, personalState, e := room.LoginRoom(&req.PersonalBasic)
	if nil != e {
		c.Error(e)
	}

	var appToken string
	if common.IsNeedAppToken(req.CommonData.Platform) {
		appToken = room.GetAppToken(fmt.Sprintf("%d", req.UID))
	}

	resp := protocol.LoginRoomResp{
		Ret: protocol.CommonResult{
			Code:    0,
			Message: "succeed",
		},
		Data: struct {
			MaxJoinLiveNum int32 `json:"max_join_live_num"`
			protocol.RoomState
			protocol.PersonalState
			AppToken string `json:"app_token,omitempty"`
		}{
			MaxJoinLiveNum: int32(room.GetRoomCfgs(c.Ctx.Request.Context()).MaxJoinLiveNum),
			RoomState:      service.ConvertModelRoomState2Protocol(roomState),
			PersonalState:  service.ConvertModelPersonalState2Protocol(personalState),
			AppToken:       appToken,
		},
	}
	c.Succeed(resp)
}

// 获取参会成员列表
func (c *RoomController) GetAttendeeList() {
	defer c.PrintPanicLog()

	var req protocol.GetAttendeeListReq
	c.GetRequest(&req)

	if 0 >= req.Uid || "" == req.RoomId || !service.IsRoomTypeValid(req.RoomType) {
		c.Error(&errorUtil.Error{
			Code:    common.ERROR_INVALID_PARAMTEER,
			Message: "invalid parameter",
		})
	}

	c.LogField["uid"] = req.Uid
	c.LogField["room_id"] = req.RoomId

	users, seq, e := service.Room(c.Ctx.Request.Context(), req.RoomId, req.RoomType).GetAttendeeList(req.Uid)
	if nil != e {
		c.Error(e)
	}

	protocolUsers := make([]protocol.PersonalState, 0, len(users))
	for _, u := range users {
		protocolUsers = append(protocolUsers, service.ConvertModelPersonalState2Protocol(&u))
	}

	resp := protocol.GetAttendeeListResp{
		Ret: protocol.CommonResult{
			Code:    0,
			Message: "succeed",
		},
		Data: struct {
			Users  []protocol.PersonalState `json:"attendee_list"`
			Seq    int64                    `json:"seq"`
			RoomId string                   `json:"room_id"`
		}{Users: protocolUsers, Seq: seq, RoomId: req.RoomId},
	}
	c.Succeed(resp)
}

// 获取连麦成员列表
func (c *RoomController) GetJoinLiveList() {
	defer c.PrintPanicLog()

	var req protocol.GetJoinLiveListReq
	c.GetRequest(&req)

	if 0 >= req.Uid || "" == req.RoomId || !service.IsRoomTypeValid(req.RoomType) {
		c.Error(&errorUtil.Error{
			Code:    common.ERROR_INVALID_PARAMTEER,
			Message: "invalid parameter",
		})
	}

	c.LogField["uid"] = req.Uid
	c.LogField["room_id"] = req.RoomId

	users, seq, e := service.Room(c.Ctx.Request.Context(), req.RoomId, req.RoomType).GetJoinLiveList(req.Uid)
	if nil != e {
		c.Error(e)
	}

	protocolUsers := make([]protocol.PersonalState, 0, len(users))
	for _, u := range users {
		protocolUsers = append(protocolUsers, service.ConvertModelPersonalState2Protocol(&u))
	}

	resp := protocol.GetJoinLiveListResp{
		Ret: protocol.CommonResult{
			Code:    0,
			Message: "succeed",
		},
		Data: struct {
			Users  []protocol.PersonalState `json:"join_live_list"`
			Seq    int64                    `json:"seq"`
			RoomId string                   `json:"room_id"`
		}{Users: protocolUsers, Seq: seq, RoomId: req.RoomId},
	}
	c.Succeed(resp)
}

// 离开教室
func (c *RoomController) LeaveRoom() {
	defer c.PrintPanicLog()

	var req protocol.LeaveRoomReq
	c.GetRequest(&req)

	if 0 >= req.Uid || "" == req.RoomId || !service.IsRoomTypeValid(req.RoomType) {
		c.Error(&errorUtil.Error{
			Code:    common.ERROR_INVALID_PARAMTEER,
			Message: "invalid parameter",
		})
	}

	c.LogField["uid"] = req.Uid
	c.LogField["room_id"] = req.RoomId

	e := service.Room(c.Ctx.Request.Context(), req.RoomId, req.RoomType).LeaveRoom(req.Uid)
	if nil != e {
		c.Error(e)
	}

	c.Succeed(protocol.LeaveRoomResp{Ret: protocol.CommonResult{
		Code:    0,
		Message: "succeed",
	}})
}

// 结束教学
func (c *RoomController) EndTeaching() {
	defer c.PrintPanicLog()

	var req protocol.EndTeachingReq
	c.GetRequest(&req)

	if 0 >= req.Uid || "" == req.RoomId || !service.IsRoomTypeValid(req.RoomType) {
		c.Error(&errorUtil.Error{
			Code:    common.ERROR_INVALID_PARAMTEER,
			Message: "invalid parameter",
		})
	}

	c.LogField["uid"] = req.Uid
	c.LogField["room_id"] = req.RoomId

	e := service.Room(c.Ctx.Request.Context(), req.RoomId, req.RoomType).EndTeaching(req.Uid)
	if nil != e {
		c.Error(e)
	}

	c.Succeed(protocol.EndTeachingResp{Ret: protocol.CommonResult{
		Code:    0,
		Message: "succeed",
	}})
}
