package service

import (
	"go_class_server/go_class_room/model"
	"go_class_server/utils/common"
	"go_class_server/utils/errorUtil"
)

func (this *room) SendMessage(uid int64, message string) *errorUtil.Error {
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

	code, err := this.SendImMessageToRoom(this.ctx, this.RoomId, uid, personalState.NickName, message)
	if nil != err {
		return &errorUtil.Error{
			Code:    int32(code),
			Message: err.Error(),
		}
	}

	return nil
}
