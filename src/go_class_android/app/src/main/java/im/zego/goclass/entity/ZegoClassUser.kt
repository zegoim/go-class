package im.zego.goclass.entity

/**
 *
 * 摄像头，麦克风状态等等，都是属于流的属性
 * 如果要查询一个用户的流的状态，需要去 streamService 里面去查
 */
open class ZegoClassUser(var userID: String, var userName: String) {

    var frontCamera = true

    override fun toString(): String {
        return "ZegoClassUser(userID='$userID', userName='$userName')"
    }
}