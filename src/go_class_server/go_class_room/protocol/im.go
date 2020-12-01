package protocol

type ImReq struct {
	AccessToken    string `json:"access_token"`
	Version        int    `json:"version"`
	Seq            int64  `json:"seq"`
	RoomId         string `json:"room_id"`
	SrcUserAccount string `json:"src_user_account"`
	SrcNickname    string `json:"src_nickname"`
	MsgCategory    int64  `json:"msg_category"`
	MsgType        int64  `json:"msg_type"`
	MsgContent     string `json:"msg_content"`
	MsgPriority    int64  `json:"msg_priority"`
}

type SendMessageReq struct {
	CommonData CommonData `json:"common_data"`
	RoomId     string     `json:"room_id"`
	RoomType   int8       `json:"room_type"`
	Uid        int64      `json:"uid"`
	Message    string     `json:"message"`
}

type SendMessageResp struct {
	Ret CommonResult `json:"ret"`
}
