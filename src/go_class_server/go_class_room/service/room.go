package service

import (
	"context"
	"github.com/astaxie/beego"
	"go_class_server/go_class_room/mgr"
	"go_class_server/go_class_room/model"
	"go_class_server/go_class_room/protocol"
	"go_class_server/utils/common"
	"go_class_server/utils/errorUtil"
	"go_class_server/utils/timeUtil"
)

func IsRoleValid(role int32) bool {
	return int32(model.RoleTeacher) == role || int32(model.RoleStudent) == role
}

func IsRoomTypeValid(roomType int8) bool {
	return 0 == roomType || int8(model.SmallRoom) == roomType || int8(model.LargeRoom) == roomType
}

func canShare(role model.RoleEnum) int8 {
	if model.RoleTeacher == role {
		return protocol.POSITIVE
	}
	return protocol.NEGATIVE
}

type room struct {
	ctx        context.Context
	RoomId     string // 房间id 与liveroom通信需使用此id
	RoomType   int8   // 房间类型
	UniqRoomId string // 唯一房间id redis key 与model交互使用此id
	RoomAdapter
	*mgr.LiveRoomMgr
}

func Room(ctx context.Context, roomId string, roomType int8) *room {
	room := &room{
		ctx:         ctx,
		RoomId:      roomId,
		RoomType:    roomType,
		UniqRoomId:  model.CreateUniqRoomId(roomId, roomType),
		RoomAdapter: GetRoomAdapter(roomType),
	}

	room.LiveRoomMgr = room.RoomAdapter.CreateLiveRoomMgr(ctx)
	return room
}

func (this *room) initRoom() (roomState *model.RoomState, e *errorUtil.Error) {
	roomState = this.CreateRoom(this.ctx, this.RoomId)

	err := model.SetRoomState(this.ctx, this.UniqRoomId, roomState)
	if nil != err {
		e = &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "SetRoomState Failed",
		}
		return
	}

	model.Add2RoomList(this.ctx, this.UniqRoomId)
	return
}

func (this *room) initPersonal(user *protocol.PersonalBasic) (personalState *model.PersonalState, e *errorUtil.Error) {
	personalState = &model.PersonalState{
		UID:       user.UID,
		NickName:  user.NickName,
		Role:      model.RoleEnum(user.Role),
		LoginTime: timeUtil.MilliSecond(),
	}

	hasLogin := model.ExistsPersonalState(this.ctx, this.UniqRoomId, user.UID)
	if !hasLogin {
		personalState.Camera = protocol.NEGATIVE
		personalState.Mic = protocol.NEGATIVE
		personalState.CanShare = canShare(model.RoleEnum(user.Role))
	}

	err := model.SetPersonalState(this.ctx, this.UniqRoomId, user.UID, personalState)
	if nil != err {
		e = &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "SetPersonalState Failed",
		}
		return
	}

	if !hasLogin {
		model.Add2AttendeeList(this.ctx, this.UniqRoomId, user.UID)
		this.AttendeeListChangeNotify(personalState, protocol.DELTA_INC)
	} else {
		personalState, _ = model.GetPersonalState(this.ctx, this.UniqRoomId, user.UID)
		this.PersonalStateChangeNotify(getPersonalStateChangeEvents(int8(user.Role), nil),
			nil, personalState)
	}

	// 启动心跳
	model.SetHeartbeatTime(this.ctx, this.UniqRoomId, user.UID)
	return
}

func (this *room) LoginRoom(user *protocol.PersonalBasic) (roomState *model.RoomState,
	personalState *model.PersonalState, e *errorUtil.Error) {
	roomState, err := model.GetRoomState(this.ctx, this.UniqRoomId)
	if nil != err {
		e = &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "GetRoomState Failed",
		}
		return
	}
	if nil == roomState { // 房间不存在则新建一个房间
		roomState, e = this.initRoom()
		if nil != e {
			return
		}
	}

	// 判断是否已有老师角色
	if 0 != roomState.TeacherUid && user.UID != roomState.TeacherUid && model.RoleEnum(user.Role) == model.RoleTeacher {
		e = &errorUtil.Error{
			Code:    common.ERROR_TEACHER_ALREADY_IN,
			Message: "Teacher Already In Room",
		}
		return
	}

	// 判断是否满员
	if !model.ExistsPersonalState(this.ctx, this.UniqRoomId, user.UID) {
		attendeeNum, err := model.GetAttendeeListCount(this.ctx, this.UniqRoomId)
		if nil != err {
			e = &errorUtil.Error{
				Code:    common.ERROR_SYSTEM_ERROR,
				Message: "GetAttendeeListCount Failed",
			}
			return
		}

		maxPeopleNum := int64(this.GetRoomCfgs(this.ctx).MaxPeopleNum)
		if 0 == roomState.TeacherUid && model.RoleEnum(user.Role) == model.RoleStudent { // 留一个空位给老师
			maxPeopleNum--
		}
		if attendeeNum >= maxPeopleNum {
			e = &errorUtil.Error{
				Code:    common.ERROR_ROOM_PEOPLE_OVERFLOW,
				Message: "people num overflow",
			}
			return
		}
	}

	// 设置老师id
	if model.RoleEnum(user.Role) == model.RoleTeacher {
		ok, _ := model.SetTeacherUid(this.ctx, this.UniqRoomId, roomState.TeacherUid, user.UID)
		if !ok {
			e = &errorUtil.Error{
				Code:    common.ERROR_TEACHER_ALREADY_IN,
				Message: "Teacher Already In Room",
			}
			return
		}
	}

	personalState, e = this.initPersonal(user)
	if nil != e {
		// 登录失败 回退老师id
		if model.RoleEnum(user.Role) == model.RoleTeacher {
			model.SetTeacherUid(this.ctx, this.UniqRoomId, user.UID, 0)
		}
		return
	}

	// 从待销毁列表中移除
	model.DelFromTobeDestroyList(this.ctx, this.UniqRoomId)
	return
}

func (this *room) GetAttendeeList(uid int64) (users []model.PersonalState, seq int64, e *errorUtil.Error) {
	if !model.ExistsRoomState(this.ctx, this.UniqRoomId) {
		e = &errorUtil.Error{
			Code:    common.ERROR_ROOM_NOT_EXIST,
			Message: "room not exist",
		}
		return
	}

	if !model.ExistsPersonalState(this.ctx, this.UniqRoomId, uid) {
		e = &errorUtil.Error{
			Code:    common.ERROR_NEED_LOGIN_FIRST,
			Message: "need login first",
		}
		return
	}

	var err error
	users, seq, err = model.GetAttendeeList(this.ctx, this.UniqRoomId)
	if nil != err {
		e = &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "GetAttendeeList Failed",
		}
	}

	return
}

// 获取连麦成员列表
func (this *room) GetJoinLiveList(uid int64) (users []model.PersonalState, seq int64, e *errorUtil.Error) {
	if !model.ExistsRoomState(this.ctx, this.UniqRoomId) {
		e = &errorUtil.Error{
			Code:    common.ERROR_ROOM_NOT_EXIST,
			Message: "room not exist",
		}
		return
	}

	if !model.ExistsPersonalState(this.ctx, this.UniqRoomId, uid) {
		e = &errorUtil.Error{
			Code:    common.ERROR_NEED_LOGIN_FIRST,
			Message: "need login first",
		}
		return
	}

	var err error
	users, seq, err = model.GetJoinLiveList(this.ctx, this.UniqRoomId)
	if nil != err {
		e = &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "GetJoinLiveList Failed",
		}
	}

	return
}

func (this *room) LeaveRoom(uid int64) *errorUtil.Error {
	roomState, err := model.GetRoomState(this.ctx, this.UniqRoomId)
	if nil != err {
		return &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "GetRoomState Failed",
		}
	} else if nil == roomState {
		return &errorUtil.Error{
			Code:    common.ERROR_ROOM_NOT_EXIST,
			Message: "room not exist",
		}
	}

	personalState, err := model.GetPersonalState(this.ctx, this.UniqRoomId, uid)
	if nil != err {
		return &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "GetPersonalState Failed",
		}
	} else if nil == personalState {
		return &errorUtil.Error{
			Code:    common.ERROR_NEED_LOGIN_FIRST,
			Message: "need login first",
		}
	}

	hasJoinLive := protocol.POSITIVE == personalState.Camera || protocol.POSITIVE == personalState.Mic
	if !hasJoinLive {
		hasJoinLive, _ = model.IsJoinLive(this.ctx, this.UniqRoomId, personalState.UID)
	}
	err = model.LeaveRoom(this.ctx, this.UniqRoomId, uid, personalState.Role, hasJoinLive)
	if nil != err {
		return &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "LeaveRoom Failed",
		}
	}

	// 同步成员列表变更通知
	this.AttendeeListChangeNotify(personalState, protocol.DELTA_DEC)

	// 同步连麦成员列表变更通知
	if hasJoinLive {
		this.JoinLiveListChangeNotify(personalState, protocol.DELTA_DEC)
	}

	// 房间没人时，加入待销毁队列
	num, _ := model.GetAttendeeListCount(this.ctx, this.UniqRoomId)
	if 0 >= num {
		model.Add2TobeDestroyList(this.ctx, this.UniqRoomId, timeUtil.MilliSecond()+
			beego.AppConfig.DefaultInt64("DestroyBufferTime", 900)*1000)
	}

	return nil
}

// 结束教学
func (this *room) EndTeaching(uid int64) *errorUtil.Error {
	roomState, err := model.GetRoomState(this.ctx, this.UniqRoomId)
	if nil != err {
		return &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "GetRoomState Failed",
		}
	} else if nil == roomState {
		return &errorUtil.Error{
			Code:    common.ERROR_ROOM_NOT_EXIST,
			Message: "room not exist",
		}
	}

	// 判断是否为当前老师
	if uid != roomState.TeacherUid {
		return &errorUtil.Error{
			Code:    common.ERROR_USER_NO_PERMISSION,
			Message: "user not teacher",
		}
	}

	personalState, err := model.GetPersonalState(this.ctx, this.UniqRoomId, uid)
	if nil != err {
		return &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "GetPersonalState Failed",
		}
	} else if nil == personalState {
		return &errorUtil.Error{
			Code:    common.ERROR_NEED_LOGIN_FIRST,
			Message: "need login first",
		}
	}
	if model.RoleTeacher != personalState.Role {
		return &errorUtil.Error{
			Code:    common.ERROR_USER_NO_PERMISSION,
			Message: "user not teacher",
		}
	}

	// 提前发结束教学通知
	this.EndTeachingNotify(&protocol.Operator{
		OperatorUid:  personalState.UID,
		OperatorName: personalState.NickName,
	})

	err = model.ClearRoom(this.ctx, this.UniqRoomId)
	if nil != err {
		return &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "ClearRoom Failed",
		}
	}

	this.ClearRoom(this.ctx, this.RoomId)
	return nil
}
