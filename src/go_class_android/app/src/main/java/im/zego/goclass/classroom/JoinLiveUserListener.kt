package im.zego.goclass.classroom

interface JoinLiveUserListener {
    fun onJoinLive(classUser: ClassUser)
    fun onLeaveJoinLive(userId:Long)
}