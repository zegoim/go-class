package base

import (
	"crypto/md5"
	"encoding/json"
	"fmt"
	"github.com/astaxie/beego"
	"github.com/astaxie/beego/logs"
	"go_class_server/go_class_room/resource"
	"go_class_server/go_class_room/service"
	"go_class_server/utils/logUtils"
	"math/rand"
	"strings"

	"go_class_server/go_class_room/protocol"
	"go_class_server/utils/common"
	"go_class_server/utils/redisUtil"
	"go_class_server/utils/stringUtil"
	"go_class_server/utils/timeUtil"
)

type BaseController struct {
	beego.Controller
	encrypt    *service.Encrypt
	commonData *protocol.CommonData
	beginTime  int64 //开始时间
	LogField   map[string]interface{}
	reqBuf     []byte
	UniqueId   string
	ClientIp   string
}

func (c *BaseController) Prepare() {
	c.LogField = make(map[string]interface{})
	c.SetUniqueId()
	c.SetClientIp()

	c.beginTime = timeUtil.MilliSecond()
	// 获取reqBody
	c.reqBuf = c.Ctx.Input.RequestBody
	c.encrypt = service.NewEncrypter()

	if len(c.reqBuf) == 0 {
		c.error(common.ERROR_INVALID_PARAMTEER, "c.reqBuf == 0")
	}
	var reqStruct protocol.BaseRequest
	err := json.Unmarshal(c.reqBuf, &reqStruct)
	if err != nil {
		logs.Error("[base] Prepare.json.Unmarshal req failed:%v", err.Error())
		c.error(common.ERROR_INVALID_PARAMTEER, err.Error())
	}

	c.encrypt.AESRequestBody = c.reqBuf
	if reqStruct.S != "" {
		if err := c.encrypt.DecryptBase(reqStruct.S, c.Ctx.Request.RequestURI, &reqStruct); err != nil {
			logs.Error("[base] Prepare.Encrypt.DecryptBase failed:%v", err.Error())
			c.error(common.ERROR_INVALID_PARAMTEER, err.Error())
		}
		c.reqBuf = c.encrypt.AESRequestBody
	}

	c.SetCommonData(&reqStruct)

	//处理重复请求
	if isAlreadyHandled, resp := CheckUniqueAndGetCacheResponse(c.Ctx.Request.RequestURI, c.commonData.DeviceId, c.commonData.Seq); isAlreadyHandled && resp != nil {
		c.SendCachedResponese(resp)
	}

	logs.Info(
		logUtils.ColourLogGray("[Recv]")+
			logUtils.ColourLogGray("REQ")+
			`-url:%s - uid: %v - detail : %v - uniqueId : %s - req  : %s`,
		logUtils.ColourLogCyan(c.Ctx.Request.RequestURI),
		c.UniqueId, string(c.reqBuf))
}

// 解压对应结构体
func (c *BaseController) GetRequest(v interface{}) {
	if len(c.reqBuf) != 0 {
		if err := json.Unmarshal(c.encrypt.AESRequestBody, v); err != nil {
			log := fmt.Sprintf("unmarshal to request failed, url:%v err:%v", c.Ctx.Request.RequestURI, err.Error())
			logs.Error(log)
			c.error(common.ERROR_INVALID_PARAMTEER, log)
		}
	}
}

func (c *BaseController) GetUniqueClientId() string {
	m := md5.New()
	_, err := m.Write([]byte(c.ClientIp + c.commonData.DeviceId + c.commonData.AppVersionString))
	if err != nil {
		logs.Error("uniqueId:%v err:%v", c.UniqueId, err.Error())
		c.error(common.ERROR_INVALID_PARAMTEER, err.Error())
	}
	signByte := m.Sum(nil)
	uniqueId := fmt.Sprintf("%x", signByte)
	return uniqueId
}

func (c *BaseController) SetUniqueId() {
	now := timeUtil.MilliSecond()
	rand.Seed(now)
	c.UniqueId = stringUtil.Int64Tostring(now) + stringUtil.Int64Tostring(rand.Int63n(100000))
}

func (c *BaseController) SetClientIp() {
	ips := strings.Split(c.Ctx.Request.Header.Get("X-Forwarded-For"), ",")
	if len(ips) > 0 {
		c.ClientIp = ips[0]
	}
}

func (c *BaseController) getRequestBody() []byte {
	var reqBody []byte
	cType := c.Ctx.Request.Header.Get("Content-Type")
	if strings.HasPrefix(cType, "multipart/form-data;") {
		file, h, err := c.GetFile("req")
		if err != nil {
			logs.Error("[base] unmarshal req failed:", err)
			c.StopRun()
		}
		content := make([]byte, h.Size)
		_, err = file.Read(content)
		if err != nil {
			logs.Error("[base] unmarshal req failed:", err)
			c.StopRun()
		}
		reqBody = content
	} else {
		reqBody = c.Ctx.Input.RequestBody
	}
	if len(reqBody) <= 0 && c.Ctx.Request.Method != "GET" {
		logs.Error("len(reqBody) <= 0")
		c.StopRun()
	}
	return reqBody
}

func GetResponseCacheKey(url string, deviceId string, seq int64) string {
	return url + ":" + deviceId + ":" + stringUtil.Int64Tostring(seq)
}

func CheckUniqueAndGetCacheResponse(url string, deviceId string, seq int64) (isAlreadyHandled bool, resp map[string]interface{}) {
	if deviceId == "" || seq == 0 {
		return false, nil
	}

	key := GetResponseCacheKey(url, deviceId, seq)

	err := resource.RedisClient().GetComplexObject(key, &resp)
	if err != nil {
		logs.Debug("CheckUniqueAndGetCacheResponse err != nil , key:%s, err:%s", key, err.Error())
		return false, resp
	}

	if resp == nil {
		logs.Debug("CheckUniqueAndGetCacheResponse resp == nil , key:%s", key)
		return false, resp
	}

	logs.Debug("get cache resp:%v", resp)

	return true, resp
}

func CacheResponse(url string, deviceId string, seq int64, resp interface{}) {
	if deviceId == "" || seq == 0 {
		return
	}

	key := GetResponseCacheKey(url, deviceId, seq)
	resource.RedisClient().SetComplexObjectExpire(key, resp, redisUtil.MINUTE)
}
