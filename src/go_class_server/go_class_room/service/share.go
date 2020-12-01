package service

import (
	"go_class_server/go_class_room/model"
	"go_class_server/go_class_room/protocol"
	"go_class_server/utils/common"
	"go_class_server/utils/errorUtil"
)

// 开始共享
func (this *room) StartShare(uid int64) *errorUtil.Error {
	personalState, err := model.GetPersonalState(this.ctx, this.UniqRoomId, uid)
	if nil != err {
		return &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "GetPersonalState Failed",
		}
	}
	if nil == personalState {
		return &errorUtil.Error{
			Code:    common.ERROR_NEED_LOGIN_FIRST,
			Message: "need login first",
		}
	}

	// 检查权限
	if protocol.POSITIVE != personalState.CanShare {
		return &errorUtil.Error{
			Code:    common.ERROR_USER_NO_PERMISSION,
			Message: "no permission",
		}
	}

	roomState, err := model.GetRoomState(this.ctx, this.UniqRoomId)
	if nil != err {
		return &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "GetRoomState Failed",
		}
	}
	if nil == roomState {
		return &errorUtil.Error{
			Code:    common.ERROR_ROOM_NOT_EXIST,
			Message: "room not exist",
		}
	}

	// 检查是否有其他人正在共享
	if 0 < roomState.SharingUid {
		return &errorUtil.Error{
			Code:    common.ERROR_ROOM_SHARING,
			Message: "sharing",
		}
	}

	ok, err := model.SetSharingUid(this.ctx, this.UniqRoomId, 0, uid)
	if nil != err {
		return &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "SetSharingUid Failed",
		}
	}
	if !ok {
		return &errorUtil.Error{
			Code:    common.ERROR_ROOM_SHARING,
			Message: "sharing",
		}
	}

	// 开始共享通知
	this.StartShareNotify(personalState)
	return nil
}

// 结束共享
func (this *room) StopShare(uid, targetUid int64) *errorUtil.Error {
	roomState, err := model.GetRoomState(this.ctx, this.UniqRoomId)
	if nil != err {
		return &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "GetRoomState Failed",
		}
	}
	if nil == roomState {
		return &errorUtil.Error{
			Code:    common.ERROR_ROOM_NOT_EXIST,
			Message: "room not exist",
		}
	}

	// 判断目标用户是否为当前共享用户
	if targetUid != roomState.SharingUid {
		return &errorUtil.Error{
			Code:    common.ERROR_USER_NOT_SHARING,
			Message: "user not sharing",
		}
	}

	// 关闭他人共享
	var operator *protocol.Operator
	if uid != targetUid {
		personalState, err := model.GetPersonalState(this.ctx, this.UniqRoomId, uid)
		if nil != err {
			return &errorUtil.Error{
				Code:    common.ERROR_SYSTEM_ERROR,
				Message: "GetPersonalState Failed",
			}
		}
		if nil == personalState || model.RoleTeacher != personalState.Role {
			return &errorUtil.Error{
				Code:    common.ERROR_USER_NO_PERMISSION,
				Message: "no permission",
			}
		}

		operator = &protocol.Operator{
			OperatorUid:  personalState.UID,
			OperatorName: personalState.NickName,
		}
	}

	ok, err := model.SetSharingUid(this.ctx, this.UniqRoomId, targetUid, 0)
	if nil != err {
		return &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "SetRoomState Failed",
		}
	}
	if !ok {
		return &errorUtil.Error{
			Code:    common.ERROR_USER_NOT_SHARING,
			Message: "not sharing",
		}
	}

	// 结束共享通知
	targetPersonalState, _ := model.GetPersonalState(this.ctx, this.UniqRoomId, targetUid)
	this.StopShareNotify(operator, targetPersonalState)
	return nil
}

func (this *room) stopShareBySetCanShare(operator *protocol.Operator, targetPersonalState *model.PersonalState) error {
	_, err := model.SetSharingUid(this.ctx, this.UniqRoomId, targetPersonalState.UID, 0)
	if nil != err {
		return err
	}

	this.StopShareNotify(operator, targetPersonalState)
	return nil
}
