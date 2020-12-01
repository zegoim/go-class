//
//  ZegoHttpHeartbeat.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/9/9.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoHttpHeartbeat.h"
#import "ZegoNetworkManager.h"
#import "ZegoClassCommand.h"
#import <NSObject+YYModel.h>

@interface ZegoHttpHeartbeat ()

@property (strong, nonatomic) ZegoHttpHeartbeatResponse *lastHeartbeatResponse;

@property (assign, nonatomic) BOOL isStart;

@property (assign, nonatomic) NSInteger userID;

@property (copy, nonatomic) NSString *roomID;

@property (nonatomic,strong) dispatch_source_t timer;

@property (assign, nonatomic) NSTimeInterval heartBeatTimestamp;

@end

@implementation ZegoHttpHeartbeat

#pragma mark - Public

+ (instancetype)sharedInstance {
    static ZegoHttpHeartbeat *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)startBeatWithUserID:(NSInteger)userID roomID:(NSString *)roomID classType:(NSInteger)classType delegate:(id<ZegoHttpHeartbeatDelegate>)delegate {
    ZegoHttpHeartbeat *instance = [self sharedInstance];
    instance.delegate = delegate;
    instance.userID = userID;
    instance.roomID = roomID;
    [instance beatWithUserID:userID roomID:roomID classType:classType];
}

+ (void)stop {
    ZegoHttpHeartbeat *instance = [self sharedInstance];
    [instance stop];
}

#pragma mark - Private

- (void)repeatedlySendHeartBeatWithInterval:(NSTimeInterval)heartBeatWithInterval startTime:(NSTimeInterval)startTime classType:(NSInteger)classType{
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(startTime*NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(heartBeatWithInterval*NSEC_PER_SEC);
    dispatch_source_set_timer(self.timer, start, interval, 0);
    
    @weakify(self);
    dispatch_source_set_event_handler(self.timer, ^{
        @strongify(self);
        [self beatWithUserID:self.userID roomID:self.roomID classType:classType];
    });
    dispatch_resume(self.timer);
    
}

- (void)beatWithUserID:(NSInteger)userID roomID:(NSString *)roomID classType:(NSInteger)classType {
    [ZegoNetworkManager requestWithCommand:[ZegoClassCommand heartBeatCommandWithUserID:userID roomID:roomID classType:classType] success:^(ZegoResponseModel *response) {
        ZegoHttpHeartbeatResponse *res = [ZegoHttpHeartbeatResponse yy_modelWithJSON:response.data];
        if(!res.interval) {
            res.interval = 30;
        }
        NSTimeInterval heartBeatTimestamp = [[NSDate date] timeIntervalSince1970];
        if ([self isHeartBeatDeadWithCurrentTime:heartBeatTimestamp interval:res.interval]) {
            [self heartbeatInactivateAction];
            return;
        }
        if (!self.isStart) {
            [self repeatedlySendHeartBeatWithInterval:res.interval startTime:self.lastHeartbeatResponse.interval classType:classType];
        } else {
            if (res.interval != self.lastHeartbeatResponse.interval && res.interval > 0) {
                [self repeatedlySendHeartBeatWithInterval:res.interval startTime:0 classType:classType];
            }
        }
        if (response.code == 0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(httpHeartbeatDidReceived:needUpdateAttendeeList:needUpdateJoinLiveList:)]) {
                [self.delegate httpHeartbeatDidReceived:res needUpdateAttendeeList:res.attendeeListSeq > self.lastHeartbeatResponse.attendeeListSeq needUpdateJoinLiveList:res.joinLiveListSeq > self.lastHeartbeatResponse.joinLiveListSeq];
            }
            self.lastHeartbeatResponse = res;
            self.heartBeatTimestamp = heartBeatTimestamp;
            self.isStart = YES;
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(httpHeartbeatDidReceived:needUpdateAttendeeList:needUpdateJoinLiveList:)]) {
                [self.delegate httpHeartbeatDidReceived:nil needUpdateAttendeeList:NO needUpdateJoinLiveList:NO];
            }
        }
        self.appEnterBackgroundTime = 0;
    } failure:^(ZegoResponseModel *response) {
        if (self.lastHeartbeatResponse) {
            NSTimeInterval heartBeatTimestamp = [[NSDate date] timeIntervalSince1970];
            if ([self isHeartBeatDeadWithCurrentTime:heartBeatTimestamp interval:self.lastHeartbeatResponse.interval]) {
                [self heartbeatInactivateAction];
            }
        }
        self.appEnterBackgroundTime = 0;
    }];
}

- (void)stop {
    self.isStart = NO;
    self.lastHeartbeatResponse = nil;
    self.appEnterBackgroundTime = 0;
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
}

- (void)heartbeatInactivateAction {
    [self stop];
    if (self.delegate && [self.delegate respondsToSelector:@selector(httpHeartbeatDidInactivate)]) {
        [self.delegate httpHeartbeatDidInactivate];
    }
}

- (BOOL)isHeartBeatDeadWithCurrentTime:(NSTimeInterval)currentTime interval:(NSInteger)interval {
    NSInteger deadInterval = interval * 2 + 1;
    if ((currentTime - self.appEnterBackgroundTime > deadInterval) && self.isStart && self.appEnterBackgroundTime > 0) {
        return YES;
    }
    BOOL result = currentTime - self.heartBeatTimestamp - self.appEnterBackgroundTime > deadInterval && self.isStart;
    return  result;
}

- (ZegoHttpHeartbeatResponse *)lastHeartbeatResponse {
    if (!_lastHeartbeatResponse) {
        _lastHeartbeatResponse = [ZegoHttpHeartbeatResponse new];
    }
    return _lastHeartbeatResponse;
}

@end

@implementation ZegoHttpHeartbeatResponse

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"attendeeListSeq"  : @"attendee_list_seq",
        @"joinLiveListSeq"  : @"join_live_list_seq",
        @"interval":@"interval"
    };
}

@end
