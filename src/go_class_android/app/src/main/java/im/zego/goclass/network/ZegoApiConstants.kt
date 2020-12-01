package im.zego.goclass.network

object ZegoApiConstants {

    /**
     * 开关的状态
     */
    object Status {
        const val CLOSE: Int = 1
        const val OPEN: Int = 2
    }

    /**
     * 进入课堂的用户的角色
     */
    object Role {
        const val TEACHER: Int = 1
        const val STUDENT: Int = 2
    }

    /**
     * 课程类型：SMALL_CLASS 小班课，LARGE_CLASS 大班课
     */
    object RoomType {
        const val SMALL_CLASS = 1
        const val LARGE_CLASS = 2
    }

}