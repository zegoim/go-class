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

/**
 更新流信息
 
 @param type 类型 用来区分是新增还是删除
 @param streamList 流列表
 @param roomID 房间 ID
 */
- (void)onStreamUpdated:(int)type streams:(NSArray<ZegoLiveStream *> *)streamList roomID:(NSString *)roomID;

/**
 流附加信息更新
 
 @param streamList 附加信息更新的流列表
 @param roomID 房间 ID
 */
- (void)onStreamExtraInfoUpdated:(NSArray<ZegoLiveStream *> *)streamList roomID:(NSString *)roomID;

/**
 收到其他用户发送来的自定义信令
 @param fromUserID 发送信令的用户ID
 @param fromUserName 发送信令的用户名
 @param content 内容
 @param roomID 房间ID
 */
- (void)onReceiveCustomCommand:(NSString *)fromUserID userName:(NSString *)fromUserName content:(NSString*)content roomID:(NSString *)roomID;

/**
 流的状态变更时收到回调
 @param stateCode 转态码
 @param streamID 流ID
 @param info 带有状态更新的扩展信息。
 */
- (void)onPublishStateUpdate:(int)stateCode streamID:(NSString *)streamID streamInfo:(NSDictionary<NSString *,NSArray<NSString *> *> *)info;

/**
 成员更新回调
 @param userList 成员列表
 */
- (void)onUserUpdate:(NSArray<ZegoRoomMemberInfoModel *> *)userList;

/**
 拉流转态回调
 @param stateCode 转态码
 @param streamID 流ID
 */
- (void)onPlayStateUpdate:(int)stateCode streamID:(NSString *)streamID;

/**
 收到摄像头状态更新
 @param status 转态码
 @param streamID 流ID
 @param reason 默认为0
 */
- (void)onRemoteCameraStatusUpdate:(int)status ofStream:(NSString *)streamID reason:(int)reason;

/**
 收到麦克风状态更新
 @param status 转态码
 @param streamID 流ID
 @param reason 默认为0
 */
- (void)onRemoteMicStatusUpdate:(int)status ofStream:(NSString *)streamID reason:(int)reason;

/**
 流播放质量的回调
 @param quality 质量值
 @param streamID 流ID
 @param fps 视频的FPS
 @param kbs 视频的比特率
 */
- (void)onPlayQualityUpdate:(int)quality stream:(NSString *)streamID videoFPS:(double)fps videoBitrate:(double)kbs;

/**
 白板变更消息回调
 @param whiteboardID 变更的白板ID
 */
- (void)onRecvWhiteboardChange:(unsigned long long)whiteboardID;

/**
 房间消息回调 大班课讨论区消息
 @param messageList 消息列表
 @param roomId 房间ID
 */
- (void)onReceiveRoomMessage:(NSArray <ZegoMessageInfo *>*)messageList roomID:(NSString *)roomId;

@end

@protocol ZegoLiveCenterClient <NSObject>

/// 设置代理
/// @param delegate 代理对象
+ (void)setDelegate:(__nullable id<ZegoLiveCenterDelegate>)delegate;

/// 初始化
/// @param appID 申请的appID
/// @param appSign 申请的appSign
/// @param isDocTestEnv 文件转码环境
/// @param isRTCTestEnv RTC服务环境
/// @param scenario 应用场景
/// @param complete 初始化回调
/// @param delegate 代理
+ (void)setupWithAppID:(unsigned int)appID appSign:(nonnull NSData *)appSign isDocTestEnv:(BOOL)isDocTestEnv isRTCTestEnv:(BOOL)isRTCTestEnv scenario:(NSUInteger)scenario complete:(nonnull ZegoLiveCenterCompletionBlock)complete delegate:(nullable id<ZegoLiveCenterDelegate>)delegate;

/// 设置用户ID和用户名
/// @param userId 用户ID
/// @param userName 用户名
+ (BOOL)setUserId:(NSString *)userId userName:(NSString *)userName;


/// 登录房间
/// @param roomID 房间ID
/// @param userId 用户ID
/// @param userName 用户名
/// @param completeAction 完成回调
+ (void)loginRoomWithRoomId:(NSString *)roomID userId:(NSString *)userId userName:(NSString *)userName complete:(void (^)(int errorCode))completeAction;


/// 获取房间内的成员
+ (NSMutableArray<ZegoRoomMemberInfoModel *> *)getUsersInRoom;
// 清空房间内的成员
+ (void)clearUser;
// 上传日志
+ (void)uploadLog;
// 获取版本号
+ (NSString *)getVersion;

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

/// 登出房间
/// @param roomID 房间ID
+ (void)logoutRoom:(NSString *)roomID;

/// 登出房间
/// @param roomID 房间ID
+ (void)logoutRoomInRTC:(NSString *)roomID;

/// 切换前后置摄像头
/// @param isFront 是否使用前置摄像头
+ (void)setFrontCam:(BOOL)isFront;

/// 设置预览视图 用户预览视频流
/// @param view 预览视图
+ (void)previewInView:(UIView *)view;

/// 停止本地的预览
+ (void)stopPreview;

/// 推流 对应的流ID
+ (void)publishStream:(NSString *)streamID;

/// 停止推流
+ (void)stopPublishingStream;

/// 启用或者禁用音频捕获设备
/// @param isMute 是否启用
+ (void)muteAudio:(BOOL)isMute;

/// 启用或者禁用视频捕获设备
/// @param isMute 是否启用
+ (void)muteVideo:(BOOL)isMute;

/// 播放流在对应的视图上
/// @param streamID 流ID
/// @param view 流视图
+ (bool)playStream:(NSString *)streamID inView:(UIView *)view;

/// 更新对应视图的流
/// @param streamID 流ID
/// @param view 需要更新的视图
+ (bool)updateStream:(NSString *)streamID inView:(UIView *)view;

/// 停止播放某条流
/// @param streamID 流ID
+ (void)stopPlayingStream:(NSString *)streamID;

/// 获取流列表
+ (NSArray<ZegoLiveStream *> *)streamList;

/// 同步当前的白板
/// @param roomID 房间ID
/// @param whiteBoardID 白板ID
/// @param compelte 结果回调
+ (void)syncCurrentWhiteboardWithRoomID:(NSString *)roomID whiteBoardID:(NSString *)whiteBoardID compelte:(void (^)(int errorCode))compelte;

/// 发送消息
/// @param message 消息内容
/// @param roomID 房间ID
/// @param callback 结果回调
+ (void)sendMessage:(NSString *)message roomID:(NSString *)roomID callback:(nullable ZegoLiveCenterImBlock)callback;

@end

NS_ASSUME_NONNULL_END

#endif /* ZegoLiveCenterParam_h */
