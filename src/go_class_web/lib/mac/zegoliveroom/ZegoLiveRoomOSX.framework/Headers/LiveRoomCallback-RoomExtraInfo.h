//
//  LiveRoomCallback_RoomExtraInfo_h
//  zegoliveroom
//
//  Copyright © 2020年 Zego. All rights reserved.
//
//

#ifndef LiveRoomCallback_RoomExtraInfo_h
#define LiveRoomCallback_RoomExtraInfo_h

#include "./LiveRoomDefines.h"

namespace ZEGO
{
    namespace LIVEROOM
    {
        class IRoomExtraInfoCallback
        {
        public:
            
            /**
             更新房间属性的回调值 

             @param errorCode   错误码，0 表示无错误
             @param pszRoomID   房间 ID
             @param sendSeq     发送序号 seq
             @param pszKey  key 值
             */
            virtual void OnSetRoomExtraInfo(int errorCode, const char *pszRoomID, int sendSeq, const char *pszKey) = 0;
            
            /**
             收到房间属性变更, 全量回调当前房间内最新的extrainfo信息(注意回调空列表时，表示所有属性已被删除)
             
             @param pszRoomID       房间 ID
             @param propertyList      变更属性列表
             @param propertyListCount      变更属性个数
             */
            virtual void OnRoomExtraInfoUpdated(const char *pszRoomID, const ROOM::ZegoRoomExtraInfo *pExtraInfoList, unsigned int extraInfoListCount) = 0;
          
            virtual ~IRoomExtraInfoCallback() {}
        };
    }
}
#endif /* LiveRoomCallback_RoomExtraInfo_h */
