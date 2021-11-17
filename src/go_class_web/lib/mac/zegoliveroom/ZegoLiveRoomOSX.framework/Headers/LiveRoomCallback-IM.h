//
//  LiveRoomCallback-IM.h
//  zegoliveroom
//
//  Copyright © 2017年 Zego. All rights reserved.
//
//

#ifndef LiveRoomCallback_IM_h
#define LiveRoomCallback_IM_h

#include "./LiveRoomDefines-IM.h"

namespace ZEGO
{
    namespace LIVEROOM
    {
        class IIMCallback
        {
        public:
            /**
             用户状态更新

             @param pUserInfo 用户信息
             @param userCount 用户数
             @param type 更新类型
             @note 在登录或者重连成功之后，如果房间中有除自己外的其它用户，将会回调一次全量更新数据,后续用户更新将会回调增量数据。
             */
            virtual void OnUserUpdate(const ZegoUserInfo *pUserInfo, unsigned int userCount, ZegoUserUpdateType type) = 0;
            
            /**
             在线人数更新
             
             @param onlineCount 在线人数
             @param pszRoomID 房间 ID
             */
            virtual void OnUpdateOnlineCount(int onlineCount, const char *pszRoomID) {};
            
            /**
             发送房间消息结果

             @param errorCode 错误码，0 表示无错误
             @param pszRoomID 房间 ID
             @param sendSeq 发送消息 seq
             @param messageId 消息 Id
             */
            virtual void OnSendRoomMessage(int errorCode, const char *pszRoomID, int sendSeq, unsigned long long messageId) {}
     
            /**
             收到房间消息回调

             @param pMessageInfo 消息信息
             @param messageCount 消息个数
             @param pszRoomID 房间 ID
             */
            virtual void OnRecvRoomMessage(ROOM::ZegoRoomMessage *pMessageInfo, unsigned int messageCount, const char *pszRoomID) {}
            
            
            /**
             主动拉取房间历史消息回调

             @param pMessageInfo 消息信息
             @param messageCount 消息个数
             @param pszRoomID 房间ID
             @param haveMore 是否还有更多消息
             */
            virtual void OnGetRoomMessage(int erroCode, ROOM::ZegoRoomMessage *pMessageInfo, unsigned int messageCount, const char *pszRoomID, bool haveMore) {}
            
            /**
             发送不可靠消息结果，这个接口用于大并发情景
             
             @param errorCode 错误码，0 表示无错误
             @param pszRoomID 房间 ID
             @param sendSeq 发送消息 seq
             @param pszmessageID 消息 Id
             */
            virtual void OnSendBigRoomMessage(int errorCode, const char *pszRoomID, int sendSeq, const char *pszmessageID) {}
            
            /**
             收到不可靠消息回调
             
             @param pMessageInfo 消息信息
             @param messageCount 消息个数
             @param pszRoomID 房间 ID
             */
            virtual void OnRecvBigRoomMessage(ROOM::ZegoBigRoomMessage *pMessageInfo, unsigned int messageCount, const char *pszRoomID) {}
            
            virtual ~IIMCallback() {}
        };
    }
}
#endif /* LiveRoomCallback_IM_h */
