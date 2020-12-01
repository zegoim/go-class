package service

import (
	"go_class_server/go_class_room/model"
	"go_class_server/go_class_room/protocol"
)

func ConvertModelRoomState2Protocol(state *model.RoomState) protocol.RoomState {
	return protocol.RoomState{
		RoomID:             state.RoomId,
		DefaultCameraState: state.DefaultCameraState,
		DefaultMicState:    state.DefaultMicState,
		AllowTurnOnCamera:  state.AllowTurnOnCamera,
		AllowTurnOnMic:     state.AllowTurnOnMic,
		SharingUid:         state.SharingUid,
	}
}

func ConvertModelPersonalState2Protocol(state *model.PersonalState) protocol.PersonalState {
	return protocol.PersonalState{
		PersonalBasic: protocol.PersonalBasic{
			UID:      state.UID,
			NickName: state.NickName,
			Role:     int32(state.Role),
		},
		LoginTime:    state.LoginTime,
		JoinLiveTime: state.JoinLiveTime,
		PersonalStateSetableParams: protocol.PersonalStateSetableParams{
			Camera:   state.Camera,
			Mic:      state.Mic,
			CanShare: state.CanShare,
		},
	}
}
