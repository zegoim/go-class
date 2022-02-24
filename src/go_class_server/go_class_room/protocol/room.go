package protocol

type LoginRoomReq struct {
	CommonData CommonData `json:"common_data"`
	RoomId     string     `json:"room_id"`
	RoomType   int8       `json:"room_type"`
	PersonalBasic
}

type RoomState struct {
	RoomID             string `json:"room_id"`
	DefaultCameraState int8   `json:"default_camera_state,omitempty"` // 默认摄像头设置
	DefaultMicState    int8   `json:"default_mic_state,omitempty"`    // 默认麦克风设置
	AllowTurnOnCamera  int8   `json:"allow_turn_on_camera,omitempty"` // 允许成员自行开麦
	AllowTurnOnMic     int8   `json:"allow_turn_on_mic,omitempty"`    // 允许成员自行打开视频
	SharingUid         int64  `json:"sharing_uid,omitempty"`          // 正在共享的uid
}

type LoginRoomResp struct {
	Ret  CommonResult `json:"ret"`
	Data struct {
		MaxJoinLiveNum int32 `json:"max_join_live_num"`
		RoomState
		PersonalState
		AppToken string `json:"app_token,omitempty"`
	} `json:"data"`
}

type GetAttendeeListReq struct {
	CommonData CommonData `json:"common_data"`
	RoomId     string     `json:"room_id"`
	RoomType   int8       `json:"room_type"`
	Uid        int64      `json:"uid"`
}

type GetAttendeeListResp struct {
	Ret  CommonResult `json:"ret"`
	Data struct {
		Users  []PersonalState `json:"attendee_list"`
		Seq    int64           `json:"seq"`
		RoomId string          `json:"room_id"`
	} `json:"data"`
}

type GetJoinLiveListReq struct {
	CommonData CommonData `json:"common_data"`
	RoomId     string     `json:"room_id"`
	RoomType   int8       `json:"room_type"`
	Uid        int64      `json:"uid"`
}

type GetJoinLiveListResp struct {
	Ret  CommonResult `json:"ret"`
	Data struct {
		Users  []PersonalState `json:"join_live_list"`
		Seq    int64           `json:"seq"`
		RoomId string          `json:"room_id"`
	} `json:"data"`
}

type LeaveRoomReq struct {
	CommonData CommonData `json:"common_data"`
	RoomId     string     `json:"room_id"`
	RoomType   int8       `json:"room_type"`
	Uid        int64      `json:"uid"`
}

type LeaveRoomResp struct {
	Ret CommonResult `json:"ret"`
}

type EndTeachingReq struct {
	CommonData CommonData `json:"common_data"`
	RoomId     string     `json:"room_id"`
	RoomType   int8       `json:"room_type"`
	Uid        int64      `json:"uid"`
}

type EndTeachingResp struct {
	Ret CommonResult `json:"ret"`
}
