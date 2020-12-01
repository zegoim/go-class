package im.zego.goclass.sdk

import android.util.Log
import im.zego.goclass.entity.ZegoClassUser

/**
 * 小班课中，user使用ZegoApi去获取，不再使用sdk自带的用户管理
 */
@Deprecated("",
    ReplaceWith("GoClassRoom"),
    DeprecationLevel.WARNING
)
private class ZegoUserService(private var zegoVideoSDKProxy: IZegoVideoSDKProxy) {
    private val selfInfo = ZegoClassUser("", "")

    /**
     * 包含自己
     */
    val userList: MutableList<ZegoClassUser> = mutableListOf()
    private val TAG = "ZegoUserService"
    var classUserListener: IClassUserListener? = null

    fun registerCallback() {
        zegoVideoSDKProxy.setClassUserListener(object : IClassUserListener {
            override fun onUserAdd(zegoUser: ZegoClassUser) {
                if (addUser(zegoUser)) {
                    classUserListener?.onUserAdd(zegoUser)
                }
            }

            override fun onUserRemove(zegoUser: ZegoClassUser) {
                val user = removeUserByID(zegoUser.userID)
                if (user != null) {
                    classUserListener?.onUserRemove(user)
                }
            }

        })
    }

    fun clearAll() {
        unRegisterCallback()
        clearRoomData()
    }

    fun clearRoomData() {
        userList.clear()
    }

    fun unRegisterCallback() {
        zegoVideoSDKProxy.setClassUserListener(null)
    }

    fun addUser(classUser: ZegoClassUser): Boolean {
        val firstOrNull = userList.firstOrNull { classUser.userID == it.userID }
        return if (firstOrNull == null) {
            userList.add(classUser)
            true
        } else {
            false
        }
    }

    fun removeUser(user: ZegoClassUser) {
        userList.remove(user)
    }

    fun removeUserByID(userID: String): ZegoClassUser? {
        val firstOrNull = userList.firstOrNull { userID == it.userID }
        userList.remove(firstOrNull)
        return firstOrNull
    }

    fun getUserByID(userID: String) = userList.firstOrNull { it.userID == userID }

    fun addAll(elements: Collection<ZegoClassUser>) {
        userList.add(selfInfo)
        userList.addAll(elements)
    }

    fun setSelfInfo(userID: String, userName: String) {
        selfInfo.userID = userID
        selfInfo.userName = userName
        userList.add(selfInfo)
        Log.i(TAG, "setSelfInfo:userID:${userID},userName:${userName}")
        classUserListener?.onUserAdd(selfInfo)
    }

    fun getSelfInfo() = selfInfo

    fun getUserCount() = userList.size
}

