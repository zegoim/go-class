package jobs

import (
	"context"
	"github.com/astaxie/beego"
	"github.com/astaxie/beego/logs"
	"go_class_server/go_class_room/model"
	"go_class_server/utils/stringUtil"
	"go_class_server/utils/timeUtil"
	"time"
)

// 定时随机抽取房间进行检查 防止资源泄露
type roomMgr struct {
}

func (this *roomMgr) Run() {
	checkInterval := beego.AppConfig.DefaultInt("RoomCheckInterval", 10)
	checkNum := beego.AppConfig.DefaultInt("RoomCheckNumOnce", 5)
	ticker := time.NewTicker(time.Second * time.Duration(checkInterval))
	for {
		select {
		case <-ticker.C:
			this.check(context.Background(), checkNum)
		}
	}
}

func (this *roomMgr) check(ctx context.Context, count int) {
	roomIds, err := model.RandomGetRooms(ctx, count)
	if nil != err {
		logs.Error("RandomGetRooms Failed:%v", err.Error())
		return
	}

	for _, roomId := range roomIds {
		this.checkOneRoom(ctx, roomId)
	}
}

func (this *roomMgr) checkOneRoom(ctx context.Context, roomId string) {
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
