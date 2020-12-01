package resource

import (
	"go_class_server/utils/redisUtil"

	"errors"
	"github.com/astaxie/beego"
	"github.com/astaxie/beego/logs"
	"sync"
)

var (
	redisCli  *redisUtil.RedisClient
	redisOnce sync.Once
)

func RedisClient() *redisUtil.RedisClient {
	redisOnce.Do(func() {
		redisAddr := beego.AppConfig.String("RedisAddr")
		redisPassword := beego.AppConfig.String("RedisPassword")
		redisIndex, _ := beego.AppConfig.Int("RedisIndex")

		redisCli = &redisUtil.RedisClient{}
		if err := redisCli.InitPool(redisAddr, redisPassword, redisIndex); err != nil {
			logs.Error("redisAddr:%s, redisPassword:%s, redisIndex:%d", redisAddr, redisPassword, redisIndex)
			panic(errors.New("Redis InitPool failed"))
		}
		logs.Info("Redis init over")
	})

	return redisCli
}
