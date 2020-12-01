package im.zego.goclass.classroom

/**
 * Created by yuxing_zhong on 2020/9/18
 */
interface JoinLiveUserListener {
    fun onJoinLive(classUser: ClassUser)
    fun onLeaveJoinLive(userId:Long)
}