//
//  ZegoLiveCenterParam.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/7/7.
//  Copyright © 2020 zego. All rights reserved.
//

#ifndef ZegoLiveCenterParam_h
#define ZegoLiveCenterParam_h
#import "ZegoLiveCenterModel.h"
#import "ZegoRoomMemberListRspModel.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZegoReliableMessage;
@class ZegoMessageInfo;

/// Update type
typedef NS_ENUM(NSUInteger, ZegoLiveUserUpdateType) {
    /// Add
    ZegoLiveUserUpdateTypeAdd = 0,
    /// Delete
    ZegoLiveUserUpdateTypeDelete = 1
};

/** 流变更类型 */
typedef enum
{
    /** 新增流 */
    ZegoDemoStreamTypeADD     = 2001,
    /** 删除流 */
    ZegoDemoStreamTypeDELETE  = 2002,
} ZegoDemoStreamType;

/** 消息类型 */
typedef enum
{
    /** 文字 */
    ZEGO_ROOM_TEXT = 1,
    /** 图片 */
    ZEGO_ROOM_PICTURE,
    /** 文件 */
    ZEGO_ROOM_FILE,
    /** 其他 */
    ZEGO_ROOM_OTHER_TYPE = 100,
} ZegoRoomMessageType;

/** 消息优先级 */
typedef enum
{
    /** 默认优先级 */
    ZEGO_ROOM_DEFAULT = 2,
    /** 高优先级 */
    ZEGO_ROOM_HIGH = 3,
} ZegoRoomMessagePriority;

/** 消息类别 */
typedef enum
{
    /** 聊天 */
    ZEGO_ROOM_CHAT = 1,
    /** 系统 */
    ZEGO_ROOM_SYSTEM,
    /** 点赞 */
    ZEGO_ROOM_LIKE,
    /** 送礼物 */
    ZEGO_ROOM_GIFT,
    /** 其他 */
    ZEGO_ROOM_OTHER_CATEGORY = 100,
} ZegoRoomMessageCategory;


typedef void(^ZegoLiveCenterCompletionBlock)(int errorCode);

typedef void(^ZegoLiveCenterImBlock)(int errorCode,NSString *roomId,NSString *messageId);


@protocol ZegoLiveCenterDelegate <NSObject>

@optional

- (void)onLogUploadResult:(int)errorCode;

- (void)onKickOut:(int)reason roomID:(NSString *)roomID;

- (void)onKickOut:(int)reason roomID:(NSString *)roomID customReason:(NSString *)customReason;

/**
 与 server 断开通知
 
 @param errorCode 错误码，0 表示无错误
 @param roomID 房间 ID
 @discussion 建议开发者在此通知中进行重新登录、推/拉流、报错、友好性提示等其他恢复逻辑。与 server 断开连接后，SDK 会进行重试，重试失败抛出此错误。请注意，此时 SDK 与服务器的所有连接均会断开
 */
- (void)onDisconnect:(int)errorCode roomID:(NSString *)roomID;

/**
 与 server 重连成功通知
 
 @param errorCode 错误码，0 表示无错误
 @param roomID 房间 ID
 */
- (void)onReconnect:(int)errorCode roomID:(NSString *)roomID;

/**
 与 server 连接中断通知，SDK会尝试自动重连
 
 @param errorCode 错误码，0 表示无错误
 @param roomID 房间 ID
 */
- (void)onTempBroken:(int)errorCode roomID:(NSString *)roomID;

- (void)onStreamUpdated:(int)type streams:(NSArray<ZegoLiveStream *> *)streamList roomID:(NSString *)roomID;

- (void)onStreamExtraInfoUpdated:(NSArray<ZegoLiveStream *> *)streamList roomID:(NSString *)roomID;

- (void)onReceiveCustomCommand:(NSString *)fromUserID userName:(NSString *)fromUserName content:(NSString*)content roomID:(NSString *)roomID;

- (void)onPublishStateUpdate:(int)stateCode streamID:(NSString *)streamID streamInfo:(NSDictionary<NSString *,NSArray<NSString *> *> *)info;

- (void)onUserUpdate:(NSArray<ZegoRoomMemberInfoModel *> *)userList;

- (void)onPlayStateUpdate:(int)stateCode streamID:(NSString *)streamID;

- (void)onRemoteCameraStatusUpdate:(int)status ofStream:(NSString *)streamID reason:(int)reason;

- (void)onRemoteMicStatusUpdate:(int)status ofStream:(NSString *)streamID reason:(int)reason;

- (void)onPlayQualityUpdate:(int)quality stream:(NSString *)streamID videoFPS:(double)fps videoBitrate:(double)kbs;

- (void)onRecvReliableMessage:(ZegoLiveReliableMessage *)message room:(NSString *)roomId;

- (void)onReceiveRoomMessage:(NSArray <ZegoMessageInfo *>*)messageList roomID:(NSString *)roomId;

@end

@protocol ZegoLiveCenterClient <NSObject>

+ (void)setDelegate:(__nullable id<ZegoLiveCenterDelegate>)delegate;

+ (void)setupWithAppID:(unsigned int)appID appSign:(nonnull NSData *)appSign isDocTestEnv:(BOOL)isDocTestEnv isRTCTestEnv:(BOOL)isRTCTestEnv scenario:(NSUInteger)scenario complete:(nonnull ZegoLiveCenterCompletionBlock)complete delegate:(nullable id<ZegoLiveCenterDelegate>)delegate;

+ (BOOL)setUserId:(NSString *)userId userName:(NSString *)userName;

+ (void)loginRoomWithRoomId:(NSString *)roomID userId:(NSString *)userId userName:(NSString *)userName complete:(void (^)(int errorCode))completeAction;

+ (NSMutableArray<ZegoRoomMemberInfoModel *> *)getUsersInRoom;

+ (void)clearUser;

+ (void)uploadLog;

/*
 typedef NS_ENUM(NSUInteger, ZegoWhiteboardViewLogLevel) {
     ZegoWhiteboardViewLogLevelGrievous = 0,
     ZegoWhiteboardViewLogLevelError = 1,
     ZegoWhiteboardViewLogLevelWarning = 2,
     ZegoWhiteboardViewLogLevelGeneric = 3,
     ZegoWhiteboardViewLogLevelDebug = 4,
     
 };
 */
+ (void)writeLog:(int)logLevel
                    content:(NSString *)content;

+ (void)logoutRoom:(NSString *)roomID;

+ (void)logoutRoomInRTC:(NSString *)roomID;

+ (void)setFrontCam:(BOOL)isFront;

+ (void)previewInView:(UIView *)view;

+ (void)stopPreview;

+ (void)publishStream:(NSString *)streamID;

+ (void)stopPublishingStream;

+ (void)muteAudio:(BOOL)isMute;

+ (void)muteVideo:(BOOL)isMute;

+ (bool)playStream:(NSString *)streamID inView:(UIView *)view;

+ (bool)updateStream:(NSString *)streamID inView:(UIView *)view;

+ (void)stopPlayingStream:(NSString *)streamID;

+ (NSArray<ZegoLiveStream *> *)streamList;

+ (void)syncCurrentWhiteboardWithRoomID:(NSString *)roomID whiteBoardID:(NSString *)whiteBoardID seq:(unsigned int)seq compelte:(void (^)(int errorCode, NSString *roomId, NSString *msgType, NSUInteger msgSeq))compelte;

+ (void)requestCurrentWhiteboardWithRoomID:(NSString *)roomID complete:(void (^)(ZegoLiveReliableMessage * _Nullable message))compelte;

+ (void)sendMessage:(NSString *)message roomID:(NSString *)roomID callback:(nullable ZegoLiveCenterImBlock)callback;

@end

NS_ASSUME_NONNULL_END

#endif /* ZegoLiveCenterParam_h */
