//
//  LiveRoom-IM.h
//  zegoliveroom
//
//  Copyright © 2017年 Zego. All rights reserved.
//
//

#ifndef LiveRoom_IM_h
#define LiveRoom_IM_h

#include "./LiveRoomDefines-IM.h"
#include "./LiveRoomCallback-IM.h"

namespace ZEGO
{
    namespace LIVEROOM
    {
        /**
         设置 IM 信息通知的回调对象

         @param pCB 回调对象指针
         @return true 成功，false 失败
         */
        ZEGO_API bool SetIMCallback(IIMCallback* pCB);
        
        /**
         发送聊天室消息
         
         @param type 消息类型
         @param category 消息分类
         @param messageContent 消息内容, 小于1024 字节
         @return 消息 seq
         */
        ZEGO_API int SendRoomMessageEx(ROOM::ZegoMessageType type, ROOM::ZegoMessageCategory category, const char *messageContent);
        
        /**
         获取聊天室历史消息

         @param priority 消息优先级
         @param ascendOrder 历史消息新旧顺序
         @param messageId 消息ID
         @param messageCount 历史消息条数
         @return 操作是否成功
         */
        ZEGO_API bool GetRoomMessage(ROOM::ZegoMessagePriority priority, bool ascendOrder, unsigned long long messageId, int messageCount);
        /**
         发送不可靠信道消息，主要用于大并发的场景，发送一些非必须到达的消息
         
         @param type 消息类型
         @param category 消息分类
         @param messageContent 消息内容, 小于 1024 字节
         @return 消息 seq
         */
        ZEGO_API int SendBigRoomMessage(ROOM::ZegoMessageType type, ROOM::ZegoMessageCategory category, const char *messageContent);
    }
}

#endif /* LiveRoom_IM_h */
