package controllers

import (
	"bytes"
	"fmt"
	"github.com/astaxie/beego"
	"go_class_server/utils"
	"net/http/pprof"
)

type ProfController struct {
	beego.Controller
}

func (c *ProfController) Get() {
	switch c.Ctx.Input.Param(":app") {
	default:
		pprof.Index(c.Ctx.ResponseWriter, c.Ctx.Request)
	case "":
		pprof.Index(c.Ctx.ResponseWriter, c.Ctx.Request)
	case "cmdline":
		pprof.Cmdline(c.Ctx.ResponseWriter, c.Ctx.Request)
	case "profile":
		pprof.Profile(c.Ctx.ResponseWriter, c.Ctx.Request)
	case "symbol":
		pprof.Symbol(c.Ctx.ResponseWriter, c.Ctx.Request)
	}
	c.Ctx.ResponseWriter.WriteHeader(200)
	lcoalIp := fmt.Sprintf("本机ip:%v", utils.GlobalLocalIP.String())
	c.Ctx.ResponseWriter.Write(bytes.NewBufferString(lcoalIp).Bytes())
}
