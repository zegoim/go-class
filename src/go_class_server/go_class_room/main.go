package main

import (
	"flag"
	"go_class_server/go_class_room/conf"
	"go_class_server/go_class_room/conf/loader"
	"go_class_server/go_class_room/jobs"
	"go_class_server/go_class_room/routers"
	"go_class_server/utils"
	"go_class_server/utils/logUtils"

	"github.com/astaxie/beego"
	"github.com/astaxie/beego/context"
	"github.com/astaxie/beego/plugins/cors"
)

func redirectHttp(ctx *context.Context) {
	filter := cors.Allow(&cors.Options{AllowAllOrigins: true})
	filter(ctx)
}

func init() {
	flag.Parse()
	conf.Init(&loader.BeegoLoader{})

	utils.InitLocalIP()
	logUtils.InitLogrus()
	logUtils.Init()
}

func main() {
	flag.Parse()

	beego.InsertFilter("/", beego.BeforeRouter, redirectHttp)
	beego.InsertFilter("*", beego.BeforeRouter, redirectHttp)

	routers.Init()
	jobs.Init()
	beego.Run()
}
