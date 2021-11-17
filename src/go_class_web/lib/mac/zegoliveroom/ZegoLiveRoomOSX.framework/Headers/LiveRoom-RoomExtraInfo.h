//
//  LiveRoom-RoomExtraInfo_h
//  zegoliveroom
//
//  Copyright © 2020年 Zego. All rights reserved.
//
//

#ifndef LiveRoom_RoomExtraInfo_h
#define LiveRoom_RoomExtraInfo_h

#include "./LiveRoomDefines.h"
#include "./LiveRoomCallback-RoomExtraInfo.h"

namespace ZEGO
{
    namespace LIVEROOM
    {
        /**
         设置 RoomExtraInfo 通知的回调

         @param pCB 回调对象指针
         @return true 成功，false 失败
         */
        ZEGO_API bool SetRoomExtraInfoCallback(IRoomExtraInfoCallback* pCB);
    
        /**
        更新房间属性 登录房间成功后使用

         @param pszKey 房间额外信息key值，不能超过 10字节, 不允许为空字符串, 一个房间内只允许1个消息类型
         @param pszValue 房间属性内容，不能超过 128 字节, 允许为空字符串
         @return 发送序号 seq
         */
        ZEGO_API int SetRoomExtraInfo(const char *pszKey, const char *pszValue);
    }
}

#endif /* LiveRoom_RoomExtraInfo_h */
