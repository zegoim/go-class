package im.zego.goclass.classroom


interface ClassUserListener {

    /**
     * 有人加入课堂的通知
     */
    fun onUserEnter(user: ClassUser?)

    /**
     * 有人离开课堂的通知
     */
    fun onUserLeave(user: ClassUser?)
    
    fun onUserCameraChanged(userId: Long, on: Boolean, selfChanged:Boolean)
    fun onUserMicChanged(userId: Long, on: Boolean, selfChanged:Boolean)
    fun onUserShareChanged(userId: Long, on: Boolean, selfChanged:Boolean)

    fun onRoomUserUpdate()

    fun onJoinLiveUserUpdate()
}