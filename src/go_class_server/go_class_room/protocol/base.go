package protocol

type BaseRequest struct {
	S          string     `json:"s"`
	Uid        int64      `json:"uid"`
	Token      string     `json:"token"`
	SessionId  string     `json:"session_id"`
	CommonData CommonData `json:"common_data"`
}

type CommonData struct {
	DeviceId         string `json:"device_id"`
	DeviceName       string `json:"device_name"`
	SystemVersion    string `json:"system_version"`
	Platform         int64  `json:"platform"`
	AppVersion       int64  `json:"app_version"`
	AppVersionString string `json:"app_version_string"`
	DistNo           int    `json:"dist_no"`
	Seq              int64  `json:"seq"`
	Uid              int64  `json:"uid"`
	Cid              int64  `json:"cid"`
	GEO              string `json:"geo"`
	IMEI             string `json:"imei"`
	IDFA             string `json:"idfa"`
	AndroidId        string `json:"android_id"`
	OS               string `json:"os"`
	MAC              string `json:"mac"`
	IP               string `json:"ip"`
	UA               string `json:"ua"`
}

type CommonResult struct {
	Code      int    `json:"code"`
	Message   string `json:"message"`
	Seq       int    `json:"seq"`
	Timestamp int64  `json:"timestamp"`
}

type Payload interface{}

type CommonRsp struct {
	Ret     CommonResult `json:"ret"`
	Payload `json:"payload,omitempty"`
}

const (
	NEGATIVE = 1 // 否定
	POSITIVE = 2 // 肯定
)
