package mgr

import (
	"context"
	"crypto/md5"
	"crypto/rand"
	"crypto/tls"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/astaxie/beego/httplib"
	"github.com/astaxie/beego/logs"
	"go_class_server/go_class_room/conf"
	"go_class_server/go_class_room/protocol"
	"go_class_server/go_class_room/resource"
	"go_class_server/utils/encryptUtil"
	"go_class_server/utils/stringUtil"
	"strings"
	"time"

	"go_class_server/utils/common"
)

type LiveRoomMgr struct {
	appId        int64
	appSecret    string
	appSignature string
	appBizType   int
	endpoint     string
}

func LiveRoom(cfgs conf.LiveRoomConfigs) *LiveRoomMgr {
	mgr := &LiveRoomMgr{
		appId:        cfgs.AppId,
		appSecret:    cfgs.AppSecret,
		appSignature: cfgs.AppSignature,
		appBizType:   cfgs.AppBizType,
	}
	mgr.endpoint = getLiveRoomEndPoint(cfgs.AppId, cfgs.AppMode, cfgs.EndPoint)
	return mgr
}

func getLiveRoomEndPoint(appId int64, mode, endpointTpl string) (endpoint string) {
	if strings.Compare(strings.ToLower(mode), "prod") == 0 {
		endpoint = fmt.Sprintf(endpointTpl, appId)
	} else if strings.Compare(strings.ToLower(mode), "test") == 0 {
		endpoint = "https://test2-liveroom-api.zego.im"
	} else {
		endpoint = "https://liveroom-alpha.zego.im"
	}

	return
}

func (this *LiveRoomMgr) getAccessToken() (accessToken string) {
	tReqAccessToken := time.Now().UTC().Unix()

	nonce := make([]byte, 8)
	rand.Read(nonce)

	hexNonce := hex.EncodeToString(nonce)
	expired := tReqAccessToken + 7200*int64(time.Minute.Seconds())

	hash := fmt.Sprintf("%x", md5.Sum([]byte(fmt.Sprintf("%d%s%s%d",
		this.appId, strings.ToLower(this.appSecret), hexNonce, expired))))

	tokenInfo := make(map[string]interface{})
	tokenInfo["ver"] = 1
	tokenInfo["hash"] = hash
	tokenInfo["nonce"] = hexNonce
	tokenInfo["expired"] = expired

	tokenData, _ := json.Marshal(tokenInfo)
	token := base64.StdEncoding.EncodeToString(tokenData)

	body := make(map[string]interface{})
	body["version"] = 1
	body["seq"] = this.appId //随便填一个
	body["app_id"] = this.appId
	body["biz_type"] = this.appBizType
	body["token"] = token

	bodyData, _ := json.Marshal(body)

	queryURL := fmt.Sprintf("%s/cgi/token", this.endpoint)

	req := httplib.Post(queryURL)
	req.SetTLSClientConfig(&tls.Config{InsecureSkipVerify: true})
	req.Body(bodyData)

	var rspJSON map[string]interface{}
	if err := req.ToJSON(&rspJSON); err != nil {
		logs.Error("get live-room svr token failed. rsp err:%s", err)
		return
	}

	retCode, _ := common.Map_GetFloat64(&rspJSON, "code")
	if retCode != 0 {
		logs.Error("get live-room svr token failed. code:%v, rspJSON:%v", retCode, rspJSON)
		return
	}

	retData := rspJSON["data"].(map[string]interface{})
	if retData == nil {
		logs.Error("get live-room svr token failed. no data field, rspJSON:%v", rspJSON)
		return
	}

	accessToken, _ = common.Map_GetString(&retData, "access_token")
	return
}

func (this *LiveRoomMgr) GetAccessToken() string {
	key := fmt.Sprintf("edu_room:live_room:access_token:%d", this.appId)
	accessToken, err := resource.RedisClient().GetString(key)
	if nil != err {
		return this.getAccessToken()
	}
	if "" == accessToken {
		accessToken = this.getAccessToken()
		if "" != accessToken {
			resource.RedisClient().SetStringWithExpire(key, accessToken, 3600)
		}
	}

	return accessToken
}

func (this *LiveRoomMgr) GetAppToken(userId string) string {
	token, _ := encryptUtil.MakeAppToken(uint32(this.appId), this.appSignature, userId, 3600*3)
	return token
}

func (this *LiveRoomMgr) SendMessageToRoomUsers(ctx context.Context, roomId, msg string, uids ...string) (int, error) {
	accessToken := this.GetAccessToken()
	if "" == accessToken {
		return common.ERROR_SYSTEM_ERROR, errors.New("GetAccessToken failed")
	}

	body := make(map[string]interface{})
	body["version"] = 1
	body["seq"] = this.appId
	body["access_token"] = accessToken
	body["room_id"] = roomId
	body["src_user_account"] = "system"
	if len(uids) > 0 {
		body["dst_user_account"] = uids
	}
	body["msg_content"] = msg

	bodyData, _ := json.Marshal(body)
	queryURL := fmt.Sprintf("%s/cgi/sendmsg", this.endpoint)

	req := httplib.Post(queryURL)
	req.SetTLSClientConfig(&tls.Config{InsecureSkipVerify: true})
	req.Body(bodyData)

	var rspJSON map[string]interface{}
	if err := req.ToJSON(&rspJSON); err != nil {
		err_string := fmt.Sprintf("SendMessageToRoom failed, err:%s, appId:%d, roomId:%s", err.Error(), this.appId, roomId)
		logs.Error(err_string)
		return common.ERROR_SEND_MESSAGE_TO_ROOM, errors.New(err_string)
	}

	retCode, _ := common.Map_GetFloat64(&rspJSON, "code")
	if retCode != 0 {
		err_string := fmt.Sprintf("SendMessageToRoom failed, code:%v message:%v, appId:%v, roomId:%v", retCode,
			rspJSON["message"], this.appId, roomId)
		logs.Error(err_string)
		return common.ERROR_SEND_MESSAGE_TO_ROOM, errors.New(err_string)
	}

	return 0, nil
}

func (this *LiveRoomMgr) ClearRoom(ctx context.Context, roomId string) (int, error) {
	accessToken := this.GetAccessToken()
	if "" == accessToken {
		return common.ERROR_SYSTEM_ERROR, errors.New("GetAccessToken failed")
	}

	body := make(map[string]interface{})
	body["version"] = 1
	body["seq"] = this.appId
	body["access_token"] = accessToken
	body["room_id"] = roomId

	queryURL := fmt.Sprintf("%s/cgi/clearroom", this.endpoint)

	req := httplib.Post(queryURL)
	req.SetTLSClientConfig(&tls.Config{InsecureSkipVerify: true})

	bodyData, _ := json.Marshal(body)
	req.Body(bodyData)

	var rspJSON map[string]interface{}

	if err := req.ToJSON(&rspJSON); err != nil {
		err_string := fmt.Sprintf("liveroom clear failed, err:%s, appId:%s, roomId:%s", err.Error(), this.appId, roomId)
		logs.Error(err_string)
		return common.ERROR_CLEAR_ROOM, errors.New(err_string)
	}

	retCode, _ := common.Map_GetFloat64(&rspJSON, "code")
	if retCode != 0 {
		err_string := fmt.Sprintf("liveroom clear failed, code:%v message:%v, appId:%v, roomId:%v", retCode, rspJSON["message"], this.appId, roomId)
		logs.Error(err_string)
		return common.ERROR_CLEAR_ROOM, errors.New(err_string)
	}

	logs.Info("liveroom clear success, roomId:%s", roomId)
	return 0, nil
}

func (this *LiveRoomMgr) SendImMessageToRoom(ctx context.Context, roomId string, uid int64, nickName, message string) (int, error) {
	accessToken := this.GetAccessToken()
	if "" == accessToken {
		return common.ERROR_SYSTEM_ERROR, errors.New("GetAccessToken failed")
	}

	request := &protocol.ImReq{
		AccessToken:    accessToken,
		Version:        1,
		Seq:            this.appId,
		RoomId:         roomId,
		SrcUserAccount: stringUtil.Int64Tostring(uid),
		SrcNickname:    nickName,
		MsgCategory:    2,
		MsgType:        1,
		MsgContent:     message,
		MsgPriority:    3,
	}
	bodyData, _ := json.Marshal(request)

	req := httplib.Post(fmt.Sprintf("%s/cgi/im/chat", this.endpoint))
	req.SetTLSClientConfig(&tls.Config{InsecureSkipVerify: true})
	req.Body(bodyData)

	var rspJSON map[string]interface{}

	if err := req.ToJSON(&rspJSON); err != nil {
		err_string := fmt.Sprintf("SendImMessageToRoom failed, err:%s, appId:%v, roomId:%v",
			err.Error(), this.appId, roomId)
		logs.Error(err_string)
		return common.ERROR_SEND_MESSAGE_TO_ROOM, errors.New(err_string)
	}
	logs.Info("SendMessageBufToRoom :%v", rspJSON)
	retCode, _ := common.Map_GetFloat64(&rspJSON, "code")
	if retCode != 0 {
		err_string := fmt.Sprintf("sendmessagebuftoroom failed, code:%v message:%v, appId:%v, roomId:%v",
			retCode, rspJSON["message"], this.appId, roomId)
		logs.Error(err_string)
		return common.ERROR_SEND_MESSAGE_TO_ROOM, errors.New(err_string)
	}

	return 0, nil
}
