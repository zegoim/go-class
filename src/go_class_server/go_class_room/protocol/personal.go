package protocol

import "go_class_server/go_class_room/model"

func isStateValid(state int8) bool {
	return 0 == state || NEGATIVE == state || POSITIVE == state
}

type PersonalStateSetableParams struct {
	Camera   int8 `json:"camera"`
	Mic      int8 `json:"mic"`
	CanShare int8 `json:"can_share"`
}

func (this PersonalStateSetableParams) IsValid() bool {
	return isStateValid(this.Camera) && isStateValid(this.Mic) && isStateValid(this.CanShare)
}

func (this PersonalStateSetableParams) ChangeAnyState() bool {
	return 0 != this.Camera || 0 != this.Mic || 0 != this.CanShare
}

func (this PersonalStateSetableParams) RequestJoinLive() bool {
	return this.Camera == POSITIVE || this.Mic == POSITIVE
}

type PersonalBasic struct {
	UID      int64  `json:"uid"`
	NickName string `json:"nick_name"`
	Role     int32  `json:"role"`
}

type PersonalState struct {
	PersonalBasic

	LoginTime    int64 `json:"login_time,omitempty"`
	JoinLiveTime int64 `json:"join_live_time,omitempty"`

	PersonalStateSetableParams
}

func (this *PersonalState) RequestJoinLive() bool {
	return this.PersonalStateSetableParams.RequestJoinLive() || this.Role == int32(model.RoleTeacher)
}

type GetUserInfoReq struct {
	CommonData CommonData `json:"common_data"`
	RoomId     string     `json:"room_id"`
	RoomType   int8       `json:"room_type"`
	Uid        int64      `json:"uid"`
	TargetUid  int64      `json:"target_uid"`
}

type GetUserInfoResp struct {
	Ret  CommonResult  `json:"ret"`
	Data PersonalState `json:"data"`
}

type SetUserInfoReq struct {
	CommonData CommonData `json:"common_data"`
	RoomId     string     `json:"room_id"`
	RoomType   int8       `json:"room_type"`
	Uid        int64      `json:"uid"`
	TargetUid  int64      `json:"target_uid"`
	PersonalStateSetableParams
}

type SetUserInfoResp struct {
	Ret CommonResult `json:"ret"`
}

type HeartbeatReq struct {
	CommonData CommonData `json:"common_data"`
	RoomId     string     `json:"room_id"`
	RoomType   int8       `json:"room_type"`
	Uid        int64      `json:"uid"`
}

type HeartbeatSeqs struct {
	AttendeeListSeq int64 `json:"attendee_list_seq"`
	JoinLiveListSeq int64 `json:"join_live_list_seq"`
}

type HeartbeatResp struct {
	Ret  CommonResult `json:"ret"`
	Data struct {
		Interval int32 `json:"interval"`
		HeartbeatSeqs
	} `json:"data"`
}
