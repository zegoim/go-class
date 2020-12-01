package protocol

const (
	CMD_ROOM_STATE_NOTIFY     = 101
	CMD_PERSONAL_STATE_NOTIFY = 102
	CMD_ATTENDEE_LIST_NOTIFY  = 103
	CMD_JOIN_LIVE_LIST_NOTIFY = 104
	CMD_END_TEACHING          = 105
	CMD_START_SHARE           = 106
	CMD_END_STARE             = 107
)

type CmdNotifyMessage struct {
	Cmd  int         `json:"cmd"`
	Data interface{} `json:"data"`
}

type Operator struct {
	OperatorUid  int64  `json:"operator_uid,omitempty"`
	OperatorName string `json:"operator_name,omitempty"`
}

type RoomStageNotifyData struct {
	Operator
	Type               int8  `json:"type"`
	AllowTurnOnCamera  int8  `json:"allow_turn_on_camera"`
	AllowTurnOnMic     int8  `json:"allow_turn_on_mic"`
	SharingUid         int64 `json:"sharing_uid"`
	DefaultCameraState int8  `json:"default_camera_state"`
	DefaultMicState    int8  `json:"default_mic_state"`
}

const (
	PERSONAL_STATE_CHANGE_ROLE      = 1 // 角色变化
	PERSONAL_STATE_CHANGE_CAMERA    = 2 // 摄像头状态变化
	PERSONAL_STATE_CHANGE_MIC       = 3 // 麦克风状态变化
	PERSONAL_STATE_CHANGE_CAN_SHARE = 4 // 共享权限变化
)

type PersonalStateNotifyData struct {
	Operator
	Type  int8            `json:"type"`
	Users []PersonalState `json:"users"`
}

const (
	ATTENDEE_LIST_CHANGE_TEACHER_LOGIN = 1
	ATTENDEE_LIST_CHANGE_STUDENT_LOGIN = 2
	ATTENDEE_LIST_CHANGE_TEACHER_LEAVE = 3
	ATTENDEE_LIST_CHANGE_STUDENT_LEAVE = 4
)

const (
	DELTA_INC = 1
	DELTA_DEC = -1
)

type AttendeeListNotifyData struct {
	Seq   int64 `json:"seq"`
	Type  int8  `json:"type"`
	Delta int8  `json:"delta"`
	PersonalState
}

const (
	JOIN_LIVE_LIST_CHANGE_TEACHER_JOIN  = 1
	JOIN_LIVE_LIST_CHANGE_STUDENT_JOIN  = 2
	JOIN_LIVE_LIST_CHANGE_TEACHER_LEAVE = 3
	JOIN_LIVE_LIST_CHANGE_STUDENT_LEAVE = 4
)

type JoinLiveListNotifyData struct {
	Seq   int64 `json:"seq"`
	Type  int8  `json:"type"`
	Delta int8  `json:"delta"`
	PersonalState
}

type EndTeachingNotifyData struct {
	Operator
}

type StartShareNotifyData struct {
	SharingUid  int64  `json:"sharing_uid"`
	SharingName string `json:"sharing_name"`
}

type StopShareNotifyData struct {
	Operator
	TargetUid  int64  `json:"target_uid"`
	TargetName string `json:"target_name"`
}
