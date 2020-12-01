package service

import (
	"go_class_server/go_class_room/model"
	"go_class_server/go_class_room/protocol"
	"go_class_server/utils/common"
	"go_class_server/utils/errorUtil"
)

func (this *room) JoinLive(personalState *model.PersonalState) *errorUtil.Error {
	hasJoinLive, _ := model.IsJoinLive(this.ctx, this.UniqRoomId, personalState.UID)
	if hasJoinLive {
		return nil
	}

	// 判断是否有空闲麦位
	if personalState.Role == model.RoleStudent {
		joinLiveNum, err := model.GetJoinLiveListCount(this.ctx, this.UniqRoomId)
		if nil != err {
			return &errorUtil.Error{
				Code:    common.ERROR_SYSTEM_ERROR,
				Message: "GetJoinLiveListCount Failed",
			}
		}

		maxJoinLiveNum := int64(this.GetRoomCfgs(this.ctx).MaxJoinLiveNum)
		teacherUid, err := model.GetRoomTeacherUid(this.ctx, this.UniqRoomId)
		if nil != err {
			return &errorUtil.Error{
				Code:    common.ERROR_SYSTEM_ERROR,
				Message: "GetRoomTeacherUid Failed",
			}
		}

		// 老师还未上麦 给老师留一个麦位
		if 0 == teacherUid {
			maxJoinLiveNum--
		} else {
			teacherJoinLive, _ := model.IsJoinLive(this.ctx, this.UniqRoomId, teacherUid)
			if !teacherJoinLive {
				maxJoinLiveNum--
			}
		}

		if joinLiveNum >= maxJoinLiveNum {
			return &errorUtil.Error{
				Code:    common.ERROR_ROOM_JOIN_LIVE_OVERFLOW,
				Message: "join live num overflow",
			}
		}
	}

	err := model.JoinLive(this.ctx, this.UniqRoomId, personalState.UID)
	if nil != err {
		return &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "JoinLive Failed",
		}
	}

	this.JoinLiveListChangeNotify(personalState, protocol.DELTA_INC)
	return nil
}

func (this *room) QuitJoinLive(personalState *model.PersonalState) *errorUtil.Error {
	hasJoinLive, err := model.IsJoinLive(this.ctx, this.UniqRoomId, personalState.UID)
	if nil != err {
		return &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "IsJoinLive Failed",
		}
	}

	if !hasJoinLive {
		return nil
	}

	err = model.QuitJoinLive(this.ctx, this.UniqRoomId, personalState.UID)
	if nil != err {
		return &errorUtil.Error{
			Code:    common.ERROR_SYSTEM_ERROR,
			Message: "QuitJoinLive Failed",
		}
	}

	this.JoinLiveListChangeNotify(personalState, protocol.DELTA_DEC)
	return nil
}
