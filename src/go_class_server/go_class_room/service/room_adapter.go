package service

import (
	"context"
	"go_class_server/go_class_room/conf"
	"go_class_server/go_class_room/mgr"
	"go_class_server/go_class_room/model"
	"go_class_server/utils/timeUtil"
)

type RoomAdapter interface {
	GetRoomCfgs(ctx context.Context) conf.RoomConfigs
	CreateLiveRoomMgr(ctx context.Context) *mgr.LiveRoomMgr
	CreateRoom(ctx context.Context, roomId string) *model.RoomState
	CheckSetUserInfoPermission(ctx context.Context, personalState *model.PersonalState, targetUid int64) bool
}

type SmallRoomAdapter struct {
}

func (this *SmallRoomAdapter) GetRoomCfgs(ctx context.Context) conf.RoomConfigs {
	return conf.GetSmallRoomCfgs()
}

func (this *SmallRoomAdapter) CreateLiveRoomMgr(ctx context.Context) *mgr.LiveRoomMgr {
	return mgr.LiveRoom(conf.GetSmallRoomCfgs().LiveRoomConfigs)
}

func (this *SmallRoomAdapter) CreateRoom(ctx context.Context, roomId string) *model.RoomState {
	cfgs := conf.GetSmallRoomCfgs()
	return &model.RoomState{
		RoomId:             roomId,
		RoomType:           int8(model.SmallRoom),
		DefaultCameraState: cfgs.DefaultCameraState,
		DefaultMicState:    cfgs.DefaultMicState,
		AllowTurnOnCamera:  cfgs.AllowTurnOnCamera,
		AllowTurnOnMic:     cfgs.AllowTurnOnMic,
		RoomCreateTime:     timeUtil.MilliSecond(),
	}
}

func (this *SmallRoomAdapter) CheckSetUserInfoPermission(ctx context.Context, personalState *model.PersonalState,
	targetUid int64) bool {
	return personalState.UID == targetUid || personalState.Role == model.RoleTeacher
}

type LargeRoomAdapter struct {
}

func (this *LargeRoomAdapter) GetRoomCfgs(ctx context.Context) conf.RoomConfigs {
	return conf.GetLargeRoomCfgs()
}

func (this *LargeRoomAdapter) CreateLiveRoomMgr(ctx context.Context) *mgr.LiveRoomMgr {
	return mgr.LiveRoom(conf.GetLargeRoomCfgs().LiveRoomConfigs)
}

func (this *LargeRoomAdapter) CreateRoom(ctx context.Context, roomId string) *model.RoomState {
	cfgs := conf.GetLargeRoomCfgs()
	return &model.RoomState{
		RoomId:             roomId,
		RoomType:           int8(model.LargeRoom),
		DefaultCameraState: cfgs.DefaultCameraState,
		DefaultMicState:    cfgs.DefaultMicState,
		AllowTurnOnCamera:  cfgs.AllowTurnOnCamera,
		AllowTurnOnMic:     cfgs.AllowTurnOnMic,
		RoomCreateTime:     timeUtil.MilliSecond(),
	}
}

func (this *LargeRoomAdapter) CheckSetUserInfoPermission(ctx context.Context, personalState *model.PersonalState,
	targetUid int64) bool {
	return personalState.Role == model.RoleTeacher && personalState.UID == targetUid
}

func GetRoomAdapter(roomType int8) RoomAdapter {
	switch model.RoomTypeEnum(roomType) {
	case model.LargeRoom:
		return &LargeRoomAdapter{}
	default:
		return &SmallRoomAdapter{}
	}
}
