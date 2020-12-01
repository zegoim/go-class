package protocol

type StartShareReq struct {
	CommonData CommonData `json:"common_data"`
	RoomId     string     `json:"room_id"`
	RoomType   int8       `json:"room_type"`
	Uid        int64      `json:"uid"`
}

type StartShareResp struct {
	Ret CommonResult `json:"ret"`
}

type StopShareReq struct {
	CommonData CommonData `json:"common_data"`
	RoomId     string     `json:"room_id"`
	RoomType   int8       `json:"room_type"`
	Uid        int64      `json:"uid"`
	TargetUid  int64      `json:"target_uid"`
}

type StopShareResp struct {
	Ret CommonResult `json:"ret"`
}
