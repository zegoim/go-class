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

- (void)httpHeartbeatDidReceived:(ZegoHttpHeartbeatResponse *_Nullable)heartBeatResponse needUpdateAttendeeList:(BOOL)needUpdateAttendeeList needUpdateJoinLiveList:(BOOL)needUpdateJoinLiveList;

- (void)httpHeartbeatDidInactivate;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ZegoHttpHeartbeat : NSObject

@property (weak, nonatomic) id<ZegoHttpHeartbeatDelegate> delegate;

@property (assign, nonatomic, readwrite) NSTimeInterval appEnterBackgroundTime;

+ (void)startBeatWithUserID:(NSInteger)userID roomID:(NSString *)roomID classType:(NSInteger)classType delegate:(id<ZegoHttpHeartbeatDelegate>)delegate;

+ (void)stop;

+ (instancetype)sharedInstance;

@end

@interface ZegoHttpHeartbeatResponse : NSObject

@property (assign, nonatomic) NSInteger attendeeListSeq;

@property (assign, nonatomic) NSInteger joinLiveListSeq;

@property (assign, nonatomic) NSInteger interval;

@end

NS_ASSUME_NONNULL_END
