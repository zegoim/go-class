package service

import (
	"encoding/json"
	"github.com/astaxie/beego/logs"
	"go_class_server/go_class_room/model"
	"go_class_server/go_class_room/protocol"
	"go_class_server/utils/common"
)

func (this *room) SendMessageToRoom(cmd int, msg interface{}) (int, error) {
	uids, err := model.GetAttendeeUidList(this.ctx, this.UniqRoomId)
	if nil != err {
		logs.Error("SendMessageToRoom GetAttendeeUidList err:%v", err)
		return common.ERROR_SYSTEM_ERROR, err
	} else if 0 == len(uids) {
		return 0, nil
	}

	message := protocol.CmdNotifyMessage{
		Cmd:  cmd,
		Data: msg,
	}
	messageStr, _ := json.Marshal(message)

	return this.SendMessageToRoomUsers(this.ctx, this.RoomId, string(messageStr), uids...)
}

// 用户状态变更通知
func (this *room) PersonalStateChangeNotify(eventTypes []int8, operator *protocol.Operator, state *model.PersonalState) {
	for _, ev := range eventTypes {
		data := protocol.PersonalStateNotifyData{
			Operator: protocol.Operator{},
			Type:     ev,
			Users:    []protocol.PersonalState{ConvertModelPersonalState2Protocol(state)},
		}
		if nil != operator {
			data.Operator = *operator
		}

		_, err := this.SendMessageToRoom(protocol.CMD_PERSONAL_STATE_NOTIFY, data)
		if nil != err {
			logs.Error("PersonalStateChangeNotify Room(%s) Failed", this.UniqRoomId)
		}
	}

	logs.Info("PersonalStateChangeNotify Room(%s) Data(%v)", this.UniqRoomId, *state)
}

// 成员列表变更通知
func (this *room) AttendeeListChangeNotify(state *model.PersonalState, delta int8) {
	seq, _ := model.GetAttendeeListSeq(this.ctx, this.UniqRoomId)

	// 获取事件类型
	var typ int8
	if protocol.DELTA_INC == delta {
		if model.RoleTeacher == state.Role {
			typ = protocol.ATTENDEE_LIST_CHANGE_TEACHER_LOGIN
		} else {
			typ = protocol.ATTENDEE_LIST_CHANGE_STUDENT_LOGIN
		}
	} else {
		if model.RoleTeacher == state.Role {
			typ = protocol.ATTENDEE_LIST_CHANGE_TEACHER_LEAVE
		} else {
			typ = protocol.ATTENDEE_LIST_CHANGE_STUDENT_LEAVE
		}
	}

	data := protocol.AttendeeListNotifyData{
		Seq:           seq,
		Type:          typ,
		Delta:         delta,
		PersonalState: ConvertModelPersonalState2Protocol(state),
	}
	_, err := this.SendMessageToRoom(protocol.CMD_ATTENDEE_LIST_NOTIFY, data)
	if nil != err {
		logs.Error("AttendeeListChangeNotify Room(%s) Failed", this.UniqRoomId)
	}
}

// 连麦列表变更通知
func (this *room) JoinLiveListChangeNotify(state *model.PersonalState, delta int8) {
	seq, _ := model.GetJoinLiveListSeq(this.ctx, this.UniqRoomId)

	// 获取事件类型
	var typ int8
	if protocol.DELTA_INC == delta {
		if model.RoleTeacher == state.Role {
			typ = protocol.JOIN_LIVE_LIST_CHANGE_TEACHER_JOIN
		} else {
			typ = protocol.JOIN_LIVE_LIST_CHANGE_STUDENT_JOIN
		}
	} else {
		if model.RoleTeacher == state.Role {
			typ = protocol.JOIN_LIVE_LIST_CHANGE_TEACHER_LEAVE
		} else {
			typ = protocol.JOIN_LIVE_LIST_CHANGE_STUDENT_LEAVE
		}
	}

	data := protocol.JoinLiveListNotifyData{
		Seq:           seq,
		Type:          typ,
		Delta:         delta,
		PersonalState: ConvertModelPersonalState2Protocol(state),
	}
	_, err := this.SendMessageToRoom(protocol.CMD_JOIN_LIVE_LIST_NOTIFY, data)
	if nil != err {
		logs.Error("JoinLiveListChangeNotify Room(%s) Failed", this.UniqRoomId)
	}
}

// 结束教学通知
func (this *room) EndTeachingNotify(operator *protocol.Operator) {
	data := protocol.EndTeachingNotifyData{Operator: *operator}

	_, err := this.SendMessageToRoom(protocol.CMD_END_TEACHING, data)
	if nil != err {
		logs.Error("EndTeachingNotify Room(%s) Failed", this.UniqRoomId)
	}
}

// 开始共享通知
func (this *room) StartShareNotify(sharePerson *model.PersonalState) {
	data := protocol.StartShareNotifyData{
		SharingUid:  sharePerson.UID,
		SharingName: sharePerson.NickName,
	}

	_, err := this.SendMessageToRoom(protocol.CMD_START_SHARE, data)
	if nil != err {
		logs.Error("StartShareNotify Room(%s) Failed", this.UniqRoomId)
	}
}

// 结束共享通知
func (this *room) StopShareNotify(operator *protocol.Operator, sharePerson *model.PersonalState) {
	var data protocol.StopShareNotifyData
	if nil != operator {
		data.Operator = *operator
	} else if nil != sharePerson {
		data.OperatorUid = sharePerson.UID
		data.OperatorName = sharePerson.NickName
	}
	if nil != sharePerson {
		data.TargetUid = sharePerson.UID
		data.TargetName = sharePerson.NickName
	}

	_, err := this.SendMessageToRoom(protocol.CMD_END_STARE, data)
	if nil != err {
		logs.Error("StopShareNotify Room(%s) Failed", this.UniqRoomId)
	}
}
