#ifndef MULTI_ROOM_CALLABCK
#define MULTI_ROOM_CALLABCK

#include "./LiveRoomDefines.h"
//#include "./RoomDefines.h"

namespace ZEGO
{
    namespace LIVEROOM
    {
        class IMultiRoomCallback
        {
        public:
            /**
             登录第二套房间接口回调
             @param errorCode 错误码，0 表示无错误
			 @param pszRoomID 房间ID
			 @param pStreamInfo 房间流信息
			 @param streamCount 房间流个数
             */
            virtual void OnLoginMultiRoom(int errorCode, const char *pszRoomID, const ZegoStreamInfo *pStreamInfo, unsigned int streamCount) = 0;

            /**
             退出房间回调
             @param errorCode 错误码
			 @param pszRoomID 房间ID
             */
            virtual void OnLogoutMultiRoom(int errorCode, const char *pszRoomID) {}
            
            /**
             被踢出房间
             @param reason 被踢出原因，1 表示该账户多点登录被踢出 2 表示该账户是被手动踢出 3 表示房间会话错误被踢出
             */
            virtual void OnKickOutMultiRoom(int reason, const char *pszRoomID, const char* pszCustomReason="") = 0;
            
			/**
			房间断开链接
			 @param errorCode 错误码
			 @param pszRoomID 房间ID
			*/
			virtual void OnMultiRoomDisconnect(int errorCode, const char *pszRoomID) = 0;


			/**
			房间与 server 重连成功通知

			@param errorCode 错误码，0 表示无错误
			@param pszRoomID 房间 ID
			@attention 可在该回调中处理自动重连成功的下一步处理（例如提示重连成功，恢复正常连接的页面布局等）
			@note 非主动与 server 断开连接后，SDK 会进行重试，重试成功回调该方法。
			*/
			virtual void OnMultiRoomReconnect(int errorCode, const char *pszRoomID) {};

			/**
			与 server 的连接被动断开通知

			@param errorCode 错误码，0 表示无错误
			@param pszRoomID 房间 ID
			@note 由于网络的波动造成连接暂时不可用
			*/
			virtual void OnMultiRoomTempBroken(int errorCode, const char *pszRoomID) {};


            /**
            房间信息更新，登录成功，或者重连成功后，房间信息变化会收到此回调

            @param info 参见ZegoRoomInfo
            @param pszRoomID 房间 ID
            */
            virtual void OnMultiRoomInfoUpdated(const ZegoRoomInfo& info, const char *pszRoomID) {}

			/**
			流信息更新

			@param type 更新类型
			@param pStreamInfo 直播流列表
			@param streamCount 直播流个数
			@param pszRoomID 房间 ID
			@attention 房间内增加流、删除流，均会触发此更新。主播推流，自己不会收到此回调，房间内其他成员会收到。建议对流增加和流删除分别采取不同的处理
			*/
			virtual void OnMultiRoomStreamUpdated(ZegoStreamUpdateType type, ZegoStreamInfo *pStreamInfo, unsigned int streamCount, const char *pszRoomID) = 0;

			/**
			流附加信息更新

			@param pStreamInfo 附加信息更新的流列表
			@param streamCount 流个数
			@param pszRoomID 房间 ID
			*/
			virtual void OnMultiRoomStreamExtraInfoUpdated(ZegoStreamInfo *pStreamInfo, unsigned int streamCount, const char *pszRoomID) = 0;
            
            /**
             发送广播消息结果

             @param errorCode 错误码
             @param sendSeq 发送 seq
             @param messageId server 返回的消息 id
			 @param pszRoomID 房间 ID
             */
            virtual void OnSendMultiRoomMessage(int errorCode, int sendSeq, unsigned long long messageId, const char *pszRoomID) = 0;
            
            /**
             收到广播消息

             @param pMessage 收到的消息指针
             @param messageCount 消息条数
			 @param pszRoomID 房间 ID
             */
            virtual void OnRecvMultiRoomMessage(ROOM::ZegoRoomMessage *pMessage, unsigned int messageCount, const char *pszRoomID) = 0;
            /**
             当前在线用户变化消息

             @param pUserInfo 用户信息
             @param userCount 用户个数
             @param type 更新类型
			 @param pszRoomID 房间 ID
             @note 在登录成功之后，如果房间中有除自己外的其它用户，将会回调一次全量更新数据。之后再退出房间之前都将回调增量数据。
             @note 现在可以直接取此回调中的数据使用，SDK内部维护数据列表，外部不需要再维护相关数据
             */
            virtual void OnMultiRoomUserUpdate(const ZegoUserInfo *pUserInfo, unsigned int userCount, ZegoUserUpdateType type, const char *pszRoomID) = 0;

			/**
			在线人数更新

			@param onlineCount 在线人数
			@param pszRoomID 房间 ID
			*/
			virtual void OnMultiRoomUpdateOnlineCount(int onlineCount, const char *pszRoomID) {};

            /**
            更新房间属性的回调值

            @param errorCode   错误码，0 表示无错误
            @param pszRoomID   房间 ID
            @param sendSeq     发送序号 seq
            @param pszKey  key 值
            */
            virtual void OnSetMultiRoomExtraInfo(int errorCode, const char *pszRoomID, int sendSeq, const char *pszKey) = 0;

            /**
            收到房间属性变更(登录成功之后,收到属性变更，会回调此callback)

            @param pszRoomID       房间 ID
            @param propertyList      变更属性列表
            @param propertyListCount      变更属性个数
            */
            virtual void OnMultiRoomExtraInfoUpdated(const char *pszRoomID, const ROOM::ZegoRoomExtraInfo *pExtraInfoList, unsigned int extraInfoListCount) = 0;

			/**
			发送自定义信令结果

			@param errorCode 错误码，0 表示无错误
			@param requestSeq 请求 seq
			@param pszRoomID 房间 ID
			*/
			virtual void OnSendMultiRoomCustomCommand(int errorCode, int requestSeq, const char *pszRoomID) = 0;

			/**
			收到自定义信令

			@param pszUserId 发送者 UserId
			@param pszUserName 发送者 UserName
			@param pszContent 收到的信令内容
			@param pszRoomID 房间 ID
			*/
			virtual void OnRecvMultiRoomCustomCommand(const char *pszUserId, const char *pszUserName, const char *pszContent, const char *pszRoomID) = 0;

			/**
			发送转发结果

			@param errorCode 错误码，0 表示无错误
			@param pszRoomID 房间 ID
			@param sendSeq 发送序号 seq
			@param type    转发的类型
			@param pszRelayResult 转发的结果
			*/
			virtual void OnMultiRoomRelay(int errorCode, const char *pszRoomID, int sendSeq, ZEGO::ROOM::ZegoRelayType type, const char *pszRelayResult) {}

			/**
			发送不可靠消息结果，这个接口用于大并发情景

			@param errorCode 错误码，0 表示无错误
			@param pszRoomID 房间 ID
			@param sendSeq 发送消息 seq
			@param pszmessageID 消息 Id
			*/
			virtual void OnSendMultiRoomBigRoomMessage(int errorCode, const char *pszRoomID, int sendSeq, const char *pszmessageID) {}

			/**
			收到不可靠消息回调

			@param pMessageInfo 消息信息
			@param messageCount 消息个数
			@param pszRoomID 房间 ID
			*/
			virtual void OnRecvMultiRoomBigRoomMessage(ROOM::ZegoBigRoomMessage *pMessageInfo, unsigned int messageCount, const char *pszRoomID) {}

	


        };
    }
}

#endif 
