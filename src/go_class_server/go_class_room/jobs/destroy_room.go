package jobs

import (
	"context"
	"github.com/astaxie/beego"
	"github.com/astaxie/beego/logs"
	"go_class_server/go_class_room/model"
	"go_class_server/go_class_room/service"
	"go_class_server/utils/timeUtil"
	"time"
)

type destroyRoomMgr struct {
}

func (this *destroyRoomMgr) Run() {
	checkInterval := beego.AppConfig.DefaultInt("DestroyRoomCheckInterval", 2)
	ticker := time.NewTicker(time.Second * time.Duration(checkInterval))
	for {
		select {
		case <-ticker.C:
			this.destroyRooms(context.Background())
		}
	}
}

func (this *destroyRoomMgr) destroyRooms(ctx context.Context) {
	roomIds, err := model.GetShouldDestroyRoomList(ctx, timeUtil.MilliSecond())
	if nil != err {
		logs.Error("GetShouldDestroyRoomList Failed:%v", err.Error())
		return
	}

	for _, uniqRoomId := range roomIds {
		num, _ := model.GetAttendeeListCount(ctx, uniqRoomId)
		if num > 0 {
			logs.Error("someone in room:%s", uniqRoomId)
			continue
		}

		err = model.ClearRoom(ctx, uniqRoomId)
		if nil != err {
			logs.Error("destroy room:%s, err:%s", uniqRoomId, err.Error())
			continue
		}

		roomId, roomType := model.GetRoomIdAndTypeByUniq(uniqRoomId)
		service.Room(ctx, roomId, roomType).ClearRoom(ctx, roomId)
	}
}
