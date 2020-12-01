package jobs

import (
	"context"
	"github.com/astaxie/beego"
	"github.com/astaxie/beego/logs"
	"go_class_server/go_class_room/model"
	"go_class_server/go_class_room/service"
	"go_class_server/utils/stringUtil"
	"go_class_server/utils/timeUtil"
	"time"
)

type onlineMgr struct {
	heartbeatInterval int64
	checkRoomNumOnce  int
	checkUsersTimes   int
}

func (this *onlineMgr) Run() {
	this.heartbeatInterval = beego.AppConfig.DefaultInt64("HeartbeatInterval", 30)
	this.checkRoomNumOnce = beego.AppConfig.DefaultInt("RoomCheckNumOnce", 5)

	checkInterval := beego.AppConfig.DefaultInt("OnlineCheckInterval", 2)
	ticker := time.NewTicker(time.Second * time.Duration(checkInterval))
	for {
		select {
		case <-ticker.C:
			this.offlineUsers(context.Background())
		}
	}
}

func (this *onlineMgr) offlineUsers(ctx context.Context) {
	// 计算心跳失效的时间
	tm := timeUtil.MilliSecond() - (this.heartbeatInterval<<1+2)*1000
	users, err := model.GetOfflineUsers(ctx, tm)
	if nil != err {
		logs.Error("GetOfflineUsers Failed:%v", err.Error())
		return
	}

	for _, user := range users {
		e := service.Room(ctx, user.RoomId, user.RoomType).LeaveRoom(user.Uid)
		if nil != e {
			logs.Error("LeaveRoom Failed RoomId(%s) Uid(%d) Err(%s)", user.RoomId, user.Uid, e.Message)
		}
	}

	this.checkUsersTimes++
	if this.checkUsersTimes%5 == 0 {
		this.checkRooms(ctx, this.checkRoomNumOnce)
	}
}

func (this *onlineMgr) checkRooms(ctx context.Context, count int) {
	roomIds, err := model.RandomGetRooms(ctx, count)
	if nil != err {
		logs.Error("RandomGetRooms Failed:%v", err.Error())
		return
	}

	for _, roomId := range roomIds {
		this.checkOneRoom(ctx, roomId)
	}
}

func (this *onlineMgr) checkOneRoom(ctx context.Context, roomId string) {
	attendeeNum, _ := model.GetAttendeeListCount(ctx, roomId)
	if 0 >= attendeeNum {
		tobeDestroy, _ := model.IsRoomTobeDestroy(ctx, roomId)
		if !tobeDestroy {
			model.Add2TobeDestroyList(ctx, roomId, timeUtil.MilliSecond()+
				beego.AppConfig.DefaultInt64("DestroyBufferTime", 900)*1000)
		}
	} else {
		attendeeList, _ := model.GetAttendeeUidList(ctx, roomId)
		for _, uidStr := range attendeeList {
			isHeartbeat, _ := model.IsHeartbeat(ctx, roomId, uidStr)
			if !isHeartbeat {
				model.SetHeartbeatTime(ctx, roomId, stringUtil.StringToInt64(uidStr))
			}
		}
	}
}
