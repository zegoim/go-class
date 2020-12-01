//
//  ZegoLiveCenterModel.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/5/29.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <ZegoExpressEngine/ZegoExpressEngine.h>
//#import <ZegoLiveRoom/ZegoLiveRoomApiDefines.h>
//#import <ZegoLiveRoom/ZegoLiveRoomApiDefines-IM.h>
#import "ZegoRoomMemberListRspModel.h"
NS_ASSUME_NONNULL_BEGIN
@class ZegoLiveStream;
typedef enum : NSUInteger {
    ZegoStreamStatusTypeNotFound,   //流信息不存在
    ZegoStreamStatusTypeIdle,       //流还未拉流或推流
    ZegoStreamStatusTypePlaying,    //正在拉流
    ZegoStreamStatusTypePublishing,     //正在推流
} ZegoStreamStatusType;


@interface ZegoStreamWrapper : NSObject

@property (strong, nonatomic) NSIndexPath *indexPath;//列表中的cell的重用
@property (strong, nonatomic) ZegoLiveStream *stream;//流信息详情
@property (strong, nonatomic) ZegoRoomMemberInfoModel *userStatusModel;//流所归属的用户状态
@property (assign, nonatomic) ZegoStreamStatusType streamStatusType;//当前流在本地的状态
 - (instancetype)initWithiStream:(ZegoLiveStream * _Nullable)stream ;
 @end


@interface ZegoLiveCenterModel : NSObject

@end

@interface ZegoLiveReliableMessage : NSObject
/** 消息类型 */
@property (nonatomic, copy) NSString    *type;
/** 消息序号 */
@property (nonatomic, assign) unsigned int  latestSeq;
/** 消息内容 */
@property (nonatomic, copy) NSString    *content;
/** 发消息用户的ID */
@property (nonatomic, copy) NSString    *fromUserId;
/** 发消息用户的名字 */
@property (nonatomic, copy) NSString    *fromUserName;
/** 发送时间 */
@property (nonatomic, assign) unsigned long long  sendTime;
+ (instancetype)reliableMessage:(NSString *)type latestSeq:(unsigned int)latestSeq content:(NSString *)content fromUserId:(NSString *)fromUserId fromUserName:(NSString *)fromUserName sendTime:(unsigned long long)sendTime;
@end

@interface ZegoLiveStream : NSObject
/** 用户 ID */
@property (nonatomic, copy) NSString *userID;
/** 用户名 */
@property (nonatomic, copy) NSString *userName;
/** 流 ID */
@property (nonatomic, copy) NSString *streamID;
/** 流附加信息 */
@property (nonatomic, copy) NSString *extraInfo;
/** 流在房间中的序号 */
@property (nonatomic, assign) int streamNID;

+ (instancetype)streamWithUserID:(NSString *)userID userName:(NSString *)userName streamID:(NSString *)streamID extraInfo:(NSString *)extraInfo streamNID:(int)streamNID;

@end


NS_ASSUME_NONNULL_END
