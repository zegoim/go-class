package routers

import (
	"github.com/astaxie/beego"
	"github.com/astaxie/beego/context"
	"github.com/astaxie/beego/plugins/cors"
	"go_class_server/go_class_room/controllers"
)

func Init() {
	nsEduRoom := beego.NewNamespace("/edu_room",
		beego.NSNamespace("/edu_room", beego.NSInclude(&controllers.RoomController{}, &controllers.PersonalController{},
			&controllers.ShareController{}, &controllers.ImController{})),

		beego.NSRouter("/login_room", &controllers.RoomController{}, "post:LoginRoom"),               // 登录房间
		beego.NSRouter("/get_attendee_list", &controllers.RoomController{}, "post:GetAttendeeList"),  // 获取参会成员列表
		beego.NSRouter("/get_join_live_list", &controllers.RoomController{}, "post:GetJoinLiveList"), // 获取连麦成员列表
		beego.NSRouter("/leave_room", &controllers.RoomController{}, "post:LeaveRoom"),               // 离开房间
		beego.NSRouter("/end_teaching", &controllers.RoomController{}, "post:EndTeaching"),           // 结束教学

		beego.NSRouter("/get_user_info", &controllers.PersonalController{}, "post:GetUserInfo"), // 获取用户状态
		beego.NSRouter("/set_user_info", &controllers.PersonalController{}, "post:SetUserInfo"), // 设置用户状态
		beego.NSRouter("/heartbeat", &controllers.PersonalController{}, "post:Heartbeat"),       // 心跳

		beego.NSRouter("/start_share", &controllers.ShareController{}, "post:StartShare"), // 开始共享
		beego.NSRouter("/stop_share", &controllers.ShareController{}, "post:StopShare"),   // 结束共享

		beego.NSRouter("/send_message", &controllers.ImController{}, "post:SendMessage"), // 发送聊天消息
	)
	beego.AddNamespace(nsEduRoom)

	beego.Router("/debug/pprof", &controllers.ProfController{})
	beego.Router("/debug/pprof/:app([\\w]+)", &controllers.ProfController{})
	beego.Router("/debug/pprof/goroutine*", &controllers.ProfController{})

	// slb健康检查
	beego.Head("/", func(ctx *context.Context) {
		ctx.Output.Body([]byte(""))
	})

	beego.Get("/health", func(ctx *context.Context) {
		ctx.Output.Body([]byte(""))
	})
}

func init() {
	beego.InsertFilter("*", beego.BeforeRouter, cors.Allow(&cors.Options{
		AllowAllOrigins:  true,
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD"},
		AllowHeaders:     []string{"Origin", "Authorization", "Access-Control-Allow-Origin", "Access-Control-Allow-Headers", "Content-Type"},
		ExposeHeaders:    []string{"Content-Length", "Access-Control-Allow-Origin", "Access-Control-Allow-Headers", "Content-Type"},
		AllowCredentials: true,
	}))
}
