package service

import (
	"go_class_server/go_class_room/model"
	"go_class_server/go_class_room/protocol"
	"go_class_server/utils/common"
	"go_class_server/utils/errorUtil"
)

func getPersonalStateChangeEvents(role int8, params *protocol.PersonalStateSetableParams) []int8 {
	var events []int8
	if 0 != role {
		events = append(events, protocol.PERSONAL_STATE_CHANGE_ROLE)
	}
	if nil != params {
		if 0 != params.Camera {
			events = append(events, protocol.PERSONAL_STATE_CHANGE_CAMERA)
		}
		if 0 != params.Mic {
			events = append(events, protocol.PERSONAL_STATE_CHANGE_MIC)
		}
		if 0 != params.CanShare {
			events = append(events, protocol.PERSONAL_STATE_CHANGE_CAN_SHARE)
		}
	}
	return events
}

func (this *room) GetPersonalState(uid, targetUid int64) (personalState *model.PersonalState, e *errorUtil.Error) {
	var err error
	personalState, err = model.GetPersonalState(this.ctx, this.UniqRoomId, targetUid)
	if nil != err {
		e = &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "GetPersonalState Failed",
		}
		return
	} else if nil == personalState {
		e = &errorUtil.Error{
			Code:    common.ERROR_USER_NOT_IN_ROOM,
			Message: "user not in room",
		}
		return
	}

	return
}

func (this *room) SetPersonalState(uid, targetUid int64, params *protocol.PersonalStateSetableParams) *errorUtil.Error {
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

	// 权限检查
	if !this.CheckSetUserInfoPermission(this.ctx, personalState, targetUid) {
		return &errorUtil.Error{
			Code:    common.ERROR_USER_NO_PERMISSION,
			Message: "no permission",
		}
	}

	var targetPersonalState *model.PersonalState
	if uid != targetUid {
		targetPersonalState, err = model.GetPersonalState(this.ctx, this.UniqRoomId, targetUid)
		if nil != err {
			return &errorUtil.Error{
				Code:    common.ERROR_SYSTEM_ERROR,
				Message: "GetPersonalState Failed",
			}
		} else if nil == targetPersonalState {
			return &errorUtil.Error{
				Code:    common.ERROR_USER_NOT_IN_ROOM,
				Message: "user not in room",
			}
		}
	} else {
		targetPersonalState = personalState
		// 学生不允许自己打开共享权限
		if personalState.Role == model.RoleStudent && params.CanShare == protocol.POSITIVE && personalState.CanShare != protocol.POSITIVE {
			return &errorUtil.Error{
				Code:    common.ERROR_USER_NO_PERMISSION,
				Message: "no permission",
			}
		}
	}

	// 忽略没修改的状态
	hasJoinLive := protocol.POSITIVE == targetPersonalState.Camera || protocol.POSITIVE == targetPersonalState.Mic
	if targetPersonalState.Camera == params.Camera {
		params.Camera = 0
	} else if 0 != params.Camera {
		targetPersonalState.Camera = params.Camera
	}
	if targetPersonalState.Mic == params.Mic {
		params.Mic = 0
	} else if 0 != params.Mic {
		targetPersonalState.Mic = params.Mic
	}
	if targetPersonalState.CanShare == params.CanShare {
		params.CanShare = 0
	} else if 0 != params.CanShare {
		targetPersonalState.CanShare = params.CanShare
	}
	if !params.ChangeAnyState() {
		return nil
	}

	// 自动上麦、下麦
	if !hasJoinLive && params.RequestJoinLive() { // 上麦
		e := this.JoinLive(targetPersonalState)
		if nil != e {
			return e
		}
	} else if hasJoinLive && protocol.NEGATIVE == targetPersonalState.Camera && protocol.NEGATIVE == targetPersonalState.Mic { // 下麦
		e := this.QuitJoinLive(targetPersonalState)
		if nil != e {
			return e
		}
	}

	setState := &model.PersonalState{
		Camera:   params.Camera,
		Mic:      params.Mic,
		CanShare: params.CanShare,
	}
	err = model.SetPersonalState(this.ctx, this.UniqRoomId, targetUid, setState)
	if nil != err {
		return &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "SetPersonalState Failed",
		}
	}

	// 推送用户状态变化通知
	targetPersonalState, _ = model.GetPersonalState(this.ctx, this.UniqRoomId, targetUid)
	operator := &protocol.Operator{
		OperatorUid:  personalState.UID,
		OperatorName: personalState.NickName,
	}
	this.PersonalStateChangeNotify(getPersonalStateChangeEvents(0, params), operator, targetPersonalState)

	// 如果关闭用户共享权限，且用户当前正在共享，需要关闭他的共享
	if protocol.NEGATIVE == params.CanShare {
		var sharingUid int64
		sharingUid, err = model.GetRoomSharingUid(this.ctx, this.UniqRoomId)
		if nil == err && sharingUid == targetPersonalState.UID {
			this.stopShareBySetCanShare(operator, targetPersonalState)
		}
	}

	return nil
}

// 心跳
func (this *room) Heartbeat(uid int64) (seqs protocol.HeartbeatSeqs, e *errorUtil.Error) {
	if !model.ExistsPersonalState(this.ctx, this.UniqRoomId, uid) {
		e = &errorUtil.Error{
			Code:    common.ERROR_NEED_LOGIN_FIRST,
			Message: "need login first",
		}
		return
	}

	err := model.SetHeartbeatTime(this.ctx, this.UniqRoomId, uid)
	if nil != err {
		e = &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "Heartbeat Failed",
		}
		return
	}

	seqs.AttendeeListSeq, _ = model.GetAttendeeListSeq(this.ctx, this.UniqRoomId)
	seqs.JoinLiveListSeq, _ = model.GetJoinLiveListSeq(this.ctx, this.UniqRoomId)
	return
}
