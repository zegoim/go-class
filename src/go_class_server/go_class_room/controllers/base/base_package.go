package base

import (
	"encoding/json"
	"fmt"
	"go_class_server/go_class_room/protocol"
	"go_class_server/utils"
	"go_class_server/utils/common"
	"go_class_server/utils/errorUtil"
	"go_class_server/utils/logUtils"
	"go_class_server/utils/stringUtil"
	"go_class_server/utils/timeUtil"
	"runtime"
	"strconv"

	"github.com/astaxie/beego"
	"github.com/astaxie/beego/logs"
	"github.com/sirupsen/logrus"
)

func (c *BaseController) SendCachedResponese(resp interface{}) {
	c.Data["json"] = resp
	c.ServeJSON()

	c.PrintAccessLog(common.ERROR_REQUEST_ALREADY_HANDLED, "request already handled")

	c.StopRun()
}

func (c *BaseController) Succeed(resp interface{}) {
	c.Data["json"] = c.encrypt.EncryptBaseWithCode(0, "", resp)

	if c.commonData != nil {
		CacheResponse(c.Ctx.Request.RequestURI, c.commonData.DeviceId, c.commonData.Seq, c.Data["json"])
	}
	c.ServeJSON()

	buf, _ := json.Marshal(resp)

	str, uid, userDetails := "", int64(0), ""
	if flag, _ := beego.AppConfig.Bool("dontNeedRespLog"); !flag {
		str = string(buf)
	}

	duration := timeUtil.MilliSecond() - c.beginTime
	url := c.Ctx.Request.RequestURI
	printer := logUtils.ColourLogGreen("[Succeed]") + logUtils.ColourLogGray("Response Message") +
		fmt.Sprintf(`: -url:%v - uid:%v - info : %v - time : %d ms - uidqueId:%s --- resp : %v\n`,
			logUtils.ColourLogCyan(url),
			logUtils.ColourLogGreen(strconv.Itoa(int(uid))),
			userDetails,
			duration,
			c.UniqueId,
			str)
	logs.Info(printer)
	c.PrintAccessLog(0, "succeed", str)

	c.StopRun()
}

func (c *BaseController) Error(e *errorUtil.Error) {
	c.error(int(e.Code), e.Message)
}

func (c *BaseController) error(code int, message string) {
	pc, file, line, _ := runtime.Caller(1)
	frame, _ := runtime.CallersFrames([]uintptr{pc}).Next()
	trace := fmt.Sprintf("[%v:%v] %v", stringUtil.GetFileName(file), line, stringUtil.GetFuncName(frame.Function))

	uid, userDetails := int64(0), ""
	req := string(c.reqBuf)
	errMsg := logUtils.ColourLogRed("[Error]") +
		logUtils.ColourLogGray("Error Message") +
		fmt.Sprintf(`:|url:%v - uid:%v - code : %d - msg :【%v】- trace:%v - info : %v - time : %d ms uidqueId:%s - req : 【%v】\n`,
			logUtils.ColourLogCyan(c.Ctx.Request.RequestURI),
			logUtils.ColourLogGreen(strconv.Itoa(int(uid))),
			code,
			message,
			trace,
			userDetails,
			timeUtil.MilliSecond()-c.beginTime,
			c.UniqueId,
			req,
		)
	logs.Error(errMsg)
	if c.encrypt != nil {
		c.Data["json"] = c.encrypt.EncryptBaseWithCode(int(code), message, nil)
	}
	c.ServeJSON()
	c.PrintAccessLog(int32(code), message, message, req)
	c.StopRun()
}

func (c *BaseController) PrintAccessLog(code int32, msg string, packs ...string) {
	var uid int64

	var device_id, system_version, app_version_string string
	var platform, app_version int64
	var dist_no int
	if c.commonData != nil {
		device_id, system_version, app_version_string = c.commonData.DeviceId, c.commonData.SystemVersion, c.commonData.AppVersionString
		platform, app_version = c.commonData.Platform, c.commonData.AppVersion
		dist_no = c.commonData.DistNo
	}

	logs.Info("|access|uid:%d|device_id:%s|system_version:%s|%d|%d|%d|%d|%s|%d|%s",
		uid, device_id, system_version, platform, app_version, dist_no, timeUtil.MilliSecond(), c.Ctx.Request.RequestURI, code, msg)
	c.LogField["client_ip"] = c.ClientIp
	c.LogField["device_id"] = device_id
	c.LogField["system_version"] = system_version
	c.LogField["platform"] = platform
	c.LogField["app_version"] = app_version
	c.LogField["app_version_string"] = app_version_string
	c.LogField["dist_no"] = dist_no
	c.LogField["log_type"] = "access"
	c.LogField["operate"] = c.Ctx.Request.RequestURI
	c.LogField["code"] = code
	c.LogField["begin_time"] = c.beginTime
	c.LogField["begin_time"] = c.beginTime
	if c.LogField["uid"] == nil {
		c.LogField["uid"] = uid
	}
	c.LogField["unique_id"] = c.UniqueId
	c.LogField["cost_time"] = timeUtil.MilliSecond() - c.beginTime
	c.LogField["server_ip"] = utils.GlobalLocalIP

	if len(packs) > 0 {
		for i, k := range packs {
			if i == 0 {
				c.LogField["user_response"] = k
			}
			if i == 1 {
				c.LogField["user_request"] = k
			}
		}
	}

	logrus.WithFields(c.LogField).Info(msg)
}

func IsDevMode() bool {
	if beego.BConfig.RunMode == "dev" {
		return true
	}
	return false
}

func (c *BaseController) PrintPanicLog() {
	if err := recover(); err != nil {
		if err == beego.ErrAbort {
			return
		}
		var stack string
		for i := 1; ; i++ {
			_, file, line, ok := runtime.Caller(i)
			if !ok {
				break
			}
			stack = stack + fmt.Sprintln(fmt.Sprintf("%s:%d", file, line))
		}
		errMsg := fmt.Sprintf("%v", err)
		req := string(c.reqBuf)
		c.PrintAccessLog(common.ERROR_PANIC_ERROR, stack, errMsg, req)

		//继续上报panic
		panic(err)
	}
}

func (c *BaseController) AddLog(key string, value interface{}) *BaseController {
	if c.LogField == nil {
		c.LogField = make(map[string]interface{})
	}
	c.LogField[key] = value
	return c
}

func (c *BaseController) PrintLog(key string, value interface{}) *BaseController {
	c.AddLog(key, value)
	_, file, line, _ := runtime.Caller(1)
	text := fmt.Sprintf("[%v:%v] ", stringUtil.GetFileName(file), line)
	for k, v := range c.LogField {
		text += fmt.Sprintf("[%v:%v] ", k, v)
	}
	logs.Info(text)
	return c
}

func (c *BaseController) SetCommonData(req *protocol.BaseRequest) {
	c.commonData = &(req.CommonData)
}
