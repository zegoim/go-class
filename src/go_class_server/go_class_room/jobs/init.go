package jobs

func Init() {
	onlineMgr := onlineMgr{}
	go onlineMgr.Run()

	destroyRoomMgr := destroyRoomMgr{}
	go destroyRoomMgr.Run()
}
