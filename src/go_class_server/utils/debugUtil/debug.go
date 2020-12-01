package debugUtil

import (
	"context"
	"github.com/astaxie/beego/logs"
	"runtime"
	"time"
)

func LogFuncTimeCost(ctx context.Context) func() {
	start := time.Now()
	return func() {
		pc, _, _, _ := runtime.Caller(1)
		logs.Debug("[%v] func(%s) cost time:%v", ctx.Value("unique_id"), runtime.FuncForPC(pc).Name(), time.Since(start))
	}
}
