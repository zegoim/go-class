package logUtils

import (
	"fmt"
	"github.com/astaxie/beego"
	"github.com/astaxie/beego/logs"
	"github.com/sirupsen/logrus"
	"go_class_server/utils"
	"go_class_server/utils/common"
	"os"
	"runtime"
)

var Log = logrus.New()

var MyLog *logs.BeeLogger

type Logger struct {
	Module string
}

func (this *Logger) Log(uid int64, methon, key, value interface{}) string {
	return fmt.Sprintf("<%v>.%v | act:%v value:%v", this.Module, methon, key, value)
}

func Init() string {
	logLevel := beego.AppConfig.String("LogLevel")
	logFolder := beego.AppConfig.String("LogFolder")
	logFilename := beego.AppConfig.String("LogFilename")
	config := fmt.Sprintf("{\"filename\":\"%v/%v\",\"level\":%v}", logFolder, logFilename, logLevel)
	beego.SetLogger("file", config)
	if isNotDevMode() {
		beego.BeeLogger.DelLogger("console")
	}

	logs.GetBeeLogger().EnableFuncCallDepth(true)
	logs.SetLogFuncCallDepth(3)

	logs.Info("Log Init: ", config)

	return config
}

func InitLogrus() {

	// 设置日志格式为json格式
	logrus.SetFormatter(&logrus.JSONFormatter{})
	logrus.StandardLogger().SetNoLock()

	// 设置将日志输出到标准输出（默认的输出为stderr,标准错误）
	// 日志消息输出可以是任意的io.writer类型
	//logrus.SetOutput(os.Stdout)

	logrus.SetLevel(logrus.DebugLevel)

	jsonLogFilename := beego.AppConfig.String("JsonLogFilename")
	file, err := os.OpenFile(beego.AppConfig.String("LogFolder")+"/"+jsonLogFilename, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
	if err == nil {
		//Log.Out = file
		logrus.SetOutput(file)
	} else {
		logrus.Info("Failed to log to file, using default stderr")
	}
}

func PrintAutoTaskPanicLog(operate string) {
	if err := recover(); err != nil {
		if err == beego.ErrAbort {
			return
		}

		var stack string
		logs.Critical("the request url is ", operate)
		logs.Critical("Handler crashed with error", err)
		for i := 1; ; i++ {
			_, file, line, ok := runtime.Caller(i)
			if !ok {
				break
			}

			logs.Critical(fmt.Sprintf("%s:%d", file, line))
			stack = stack + fmt.Sprintln(fmt.Sprintf("%s:%d", file, line))
		}

		logrus.WithFields(logrus.Fields{"server_ip": utils.GlobalLocalIP, "log_type": "auto", "operate": operate, "code": common.ERROR_PANIC_ERROR}).Info(stack)
	}
}

func isNotDevMode() bool {
	if beego.BConfig.RunMode != "dev" {
		return true
	}
	return false
}

func ColourLogRed(in string) string {
	if isNotDevMode() {
		return fmt.Sprintf("❌ ❌%v", in)
	}
	return fmt.Sprintf("❌ %c[%d;%d;%dm%s%v%c[0m ", 0x1B, 0, 41, 30, "", in, 0x1B)
}

func ColourLogWhite(in string) string {
	if isNotDevMode() {
		return in
	}
	return fmt.Sprintf("%c[%d;%d;%dm%s%v%c[0m ", 0x1B, 0, 40, 34, "", in, 0x1B)
}

func ColourLogGreen(in string) string {
	if isNotDevMode() {
		return fmt.Sprintf("✅%v", in)
	}
	return fmt.Sprintf("%c[%d;%d;%dm%s%v%c[0m ", 0x1B, 0, 42, 30, "", in, 0x1B)
}

func ColourLogCyan(in string) string {
	if isNotDevMode() {
		return fmt.Sprintf("✅%v", in)
	}
	return fmt.Sprintf("%c[%d;%d;%dm%s%v%c[0m ", 0x1B, 0, 46, 30, "", in, 0x1B)
}

func ColourLogGray(in string) string {
	if isNotDevMode() {
		return fmt.Sprintf("📥%v", in)
	}
	return fmt.Sprintf("%c[%d;%d;%dm%s%v%c[0m ", 0x1B, 0, 47, 34, "", in, 0x1B)
}

func ColorLog() {
	for b := 40; b <= 50; b++ { // b
		for f := 30; f <= 37; f++ { // f
			for d := range []int{0, 1, 4, 5, 7, 8} { // p
				fmt.Printf(" %c[%d;%d;%dm%s(f=%d,b=%d,d=%d)%c[0m ", 0x1B, d, b, f, "", f, b, d, 0x1B)
			}
			fmt.Println("")
		}
		fmt.Println("")
	}
}
