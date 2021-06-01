//
//  ZegoHttpHeartbeat.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/9/9.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZegoHttpHeartbeatResponse;

@protocol ZegoHttpHeartbeatDelegate <NSObject>

/// 接收到心跳回包
/// @param heartBeatResponse 心跳响应数据
/// @param needUpdateAttendeeList 是否需要更新成员列表
/// @param needUpdateJoinLiveList 是否需要更新连麦列表
- (void)httpHeartbeatDidReceived:(ZegoHttpHeartbeatResponse *_Nullable)heartBeatResponse needUpdateAttendeeList:(BOOL)needUpdateAttendeeList needUpdateJoinLiveList:(BOOL)needUpdateJoinLiveList;

/// 心跳失活
- (void)httpHeartbeatDidInactivate;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ZegoHttpHeartbeat : NSObject

@property (weak, nonatomic) id<ZegoHttpHeartbeatDelegate> delegate;

@property (assign, nonatomic, readwrite) NSTimeInterval appEnterBackgroundTime;

/// 开启心跳
/// @param userID 用户ID
/// @param roomID 房间ID
/// @param classType 房间类型
/// @param delegate 代理对象
+ (void)startBeatWithUserID:(NSInteger)userID roomID:(NSString *)roomID classType:(NSInteger)classType delegate:(id<ZegoHttpHeartbeatDelegate>)delegate;

/// 停止心跳
+ (void)stop;

+ (instancetype)sharedInstance;

@end

@interface ZegoHttpHeartbeatResponse : NSObject

@property (assign, nonatomic) NSInteger attendeeListSeq;

@property (assign, nonatomic) NSInteger joinLiveListSeq;

@property (assign, nonatomic) NSInteger interval;

@end

NS_ASSUME_NONNULL_END
