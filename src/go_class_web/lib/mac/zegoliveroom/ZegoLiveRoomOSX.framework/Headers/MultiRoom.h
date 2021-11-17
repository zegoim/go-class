//
//  ChatRoom.h
//  zegoliveroom
//
//  Created by Strong on 2017/2/21.
//
//

#ifndef MultiRoom_h
#define MultiRoom_h

#include "./MultiRoomCallback.h"

namespace ZEGO
{
    namespace LIVEROOM
    {
        /**
         设置第二套房间接口回调
         @param pCB 回调对象指针
         @return true 成功，false 失败
         @note 未设置回调对象，或对象设置错误，可能导致无法正常收到相关回调
         */
        ZEGO_API bool SetMultiRoomCallback(IMultiRoomCallback *pCB);


		/**
		设置第二套房间配置信息
		@param userStateUpdate 用户状态（用户进入、退出房间）是否广播。true 广播，false 不广播。默认 false
		@discussion 在登录房间前调用有效，退出房间后失效
                    userStateUpdate为房间属性而非用户属性，设置的是该房间内是否会进行用户状态的广播。如果需要在房间内用户状态改变时，其他用户能收到通知，请为所有用户设置为true；反之，设置为false。设置为true后，方可从OnUserUpdate回调收到用户状态变更通知
		*/
		ZEGO_API bool SetMultiRoomConfig(bool audienceCreateRoom,bool userStateUpdate);

		/**
		设置自定义token信息

		@param thirdPartyToken 第三方传入的token
		@discussion 使用此函数验证登录时用户的合法性，登录房间前调用，token的生成规则请联系即构。若不需要验证用户合法性，不需要调用此函数
		@discussion 在登录房间前调用有效，退出房间后失效
		*/
		ZEGO_API void SetMultiRoomCustomToken(const char *thirdPartyToken);


		/**
		设置房间最大在线人数

		@param maxCount 最大人数
		@discussion 在登录房间前调用有效，退出房间后失效
		*/
		ZEGO_API void SetMultiRoomMaxUserCount(unsigned int maxCount);

        /**
         登录第二套房间接口

         @return true 成功，false失败，参照对应错误码
         @attention 登录成功后，等待 IMultiRoomCallback::OnLoginMultiRoom 回调
         */
        ZEGO_API bool LoginMultiRoom(const char* pszRoomID, int role, const char* pszRoomName);
        
        /**
         退出第二套房间

         @return true 成功，false 失败，参照对应错误码
         @attention 退出成功后，等待 IMultiRoomCallback::OnLogoutRoom 回调
         */
        ZEGO_API bool LogoutMultiRoom();
		/**
		发送房间消息

		@param type 消息类型
		@param category 消息分类
		@param messageContent 消息内容, 不超过 512 字节
		@return 消息 seq
		*/
		ZEGO_API int SendMultiRoomMessage(ROOM::ZegoMessageType type, ROOM::ZegoMessageCategory category, const char *messageContent);

		/**
		发送房间自定义信令

		@param memberList 信令发送成员列表
		@param memberCount 成员个数
		@param content 信令内容
		@return 消息 seq
		*/
		ZEGO_API int SendMultiRoomCustomCommand(ROOM::ZegoUser *memberList, unsigned int memberCount, const char *content);


		/**
		转发接口

		@param relayType 转发类型
		@param pszRelayData 转发内容
		@return 发送序号 seq
		*/
		ZEGO_API int RelayMultiRoom(ROOM::ZegoRelayType relayType, const char *pszRelayData);

        /**
        更新房间属性

        @param pszKey 房间额外信息key值，不能超过 10字节, 不允许为空字符串, 一个房间内只允许1个消息类型
        @param pszValue 房间属性内容，不能超过 100 字节, 允许为空字符串
        @return 发送序号 seq
        */
        ZEGO_API int SetMultiRoomExtraInfo(const char *pszKey, const char *pszValue);

		/**
		发送不可靠信道消息，主要用于大并发的场景，发送一些非必须到达的消息

		@param type 消息类型
		@param category 消息分类
		@param messageContent 消息内容, 不超过 512 字节
		@return 消息 seq
		*/
		ZEGO_API int SendMultiBigRoomMessage(ROOM::ZegoMessageType type, ROOM::ZegoMessageCategory category, const char *messageContent);
     
    }
}
#endif 
