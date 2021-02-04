//
//  ZegoLiveRoomLiveCenter.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/7/7.
//  Copyright © 2020 zego. All rights reserved.
//

#ifdef IS_USE_LIVEROOM

#import "ZegoLiveRoomLiveCenter.h"
#import <ZegoLiveRoom/ZegoLiveRoom.h>
#import <ZegoLiveRoom/ZegoLiveRoomApiDefines-RoomExtraInfo.h>
#import <ZegoLiveRoom/ZegoLiveRoomApiDefines.h>
#import <ZegoLiveRoom/zego-api-logger-oc.h>
#import "ZegoAuthConstants.h"
#import "ZegoDocsViewDependency.h"
#import <ZegoWhiteboardView/ZegoWhiteboardManager.h>
#import "ZGAppSignHelper.h"
#import "ZegoRoomMemberListRspModel.h"
#import "ZegoClassEnvManager.h"
#import "ZegoChatModel.h"
@interface ZegoLiveRoomLiveCenter ()<ZegoRoomDelegate, ZegoLivePublisherDelegate, ZegoIMDelegate, ZegoLivePlayerDelegate,ZegoLiveRoomExtraInfoDelegate>

@property (weak, nonatomic) id<ZegoLiveCenterDelegate> delegate;

@property (strong, nonatomic) ZegoLiveRoomApi *api;

@property (strong, nonatomic, readwrite) NSMutableArray *liveUsers;

@property (strong, nonatomic) NSArray<ZegoLiveStream *> *streamList;

@end

@implementation ZegoLiveRoomLiveCenter
static ZegoLiveRoomLiveCenter *sharedInstance = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZegoLiveRoomLiveCenter alloc] init];
        sharedInstance.liveUsers = [NSMutableArray array];
    });
    return sharedInstance;
}

+ (void)setDelegate:(id<ZegoLiveCenterDelegate>)delegate {
    [ZegoLiveRoomLiveCenter sharedInstance].delegate = delegate;
}

+ (nonnull NSMutableArray<ZegoRoomMemberInfoModel *> *)getUsersInRoom {
    return [ZegoLiveRoomLiveCenter sharedInstance].liveUsers;
}

#pragma mark - API - LiveRoom
 
+ (void)setupWithAppID:(unsigned int)appID appSign:(nonnull NSData *)appSign isDocTestEnv:(BOOL)isDocTestEnv isRTCTestEnv:(BOOL)isRTCTestEnv scenario:(NSUInteger)scenario complete:(nonnull ZegoLiveCenterCompletionBlock)complete delegate:(nullable id<ZegoLiveCenterDelegate>)delegate {
    
     [ZegoLiveRoomApi setUseTestEnv:isRTCTestEnv];
    ZegoLiveRoomApi *api = [[ZegoLiveRoomApi alloc] initWithAppID:appID appSignature: appSign completionBlock:^(int errorCode) {
        if (complete) {
            complete(errorCode);
        }
        //WhiteBoardView 初始化
        ZegoWhiteboardConfig *configw = [[ZegoWhiteboardConfig alloc] init];
        configw.logPath = kZegoLogPath;
        [[ZegoWhiteboardManager sharedInstance] setConfig:configw];
    }];
     ZegoLiveRoomLiveCenter *center = [ZegoLiveRoomLiveCenter sharedInstance];
     center.delegate = delegate;
     center.api = api;
     [ZegoLiveRoomApi setConfig:@"room_retry_time=300"];
     [ZegoLiveRoomApi setConfig:@"preview_clear_last_frame=true"];
     [ZegoLiveRoomApi setConfig:@"play_clear_last_frame=true"];
     [ZegoLiveRoomApi setLogDir:kZegoLogPath size:10*1024*1024 subFolder:nil];
     [api setRoomMaxUserCount:10];
     [ZegoLiveRoomApi setPlayQualityMonitorCycle:500];
     [api setPreviewViewMode:ZegoVideoViewModeScaleAspectFill];
     [api setAppOrientation:UIInterfaceOrientationLandscapeRight];
     ZegoAVConfig *config = [ZegoAVConfig presetConfigOf:ZegoAVConfigPreset_Generic];
     config.videoCaptureResolution = CGSizeMake(640, 360);
     config.videoEncodeResolution = CGSizeMake(640, 360);
     [api setAVConfig: config];
     [api setRoomConfig:YES userStateUpdate:YES];
     [api setRoomDelegate: center];
     [api setPublisherDelegate:center];
     [api setPlayerDelegate:center];
     [api setIMDelegate:center];
     [api setRoomExtraInfoUpdateDelegate:center];
    [api setLatencyMode:ZEGOAPI_LATENCY_MODE_LOW3];
 
     //文档初始化
     ZegoDocsViewConfig * docsViewConfig = [ZegoDocsViewConfig new];
     docsViewConfig.isTestEnv = isDocTestEnv;
    //文档暂时没有国际环境，统一用国内的appID初始化
     docsViewConfig.appSign = [ZGAppSignHelper convertAppSignToStringFromChars:kZegoSign];
     docsViewConfig.appID = kZegoAppID;
     docsViewConfig.dataFolder = kZegoDocsDataPath;
//     docsViewConfig.logFolder = kZegoDocsDataPath;
     docsViewConfig.logFolder = kZegoLogPath;
     docsViewConfig.cacheFolder = kZegoDocsDataPath;
//    if ([ZegoClassEnvManager shareManager].pptStepDefaultMode) {
//        [[ZegoDocsViewManager sharedInstance] setCustomizedConfig:@"1" key:@"pptStepMode"];
//    }else {
//        [[ZegoDocsViewManager sharedInstance] setCustomizedConfig:@"2" key:@"pptStepMode"];
//    }
    
     [[ZegoDocsViewManager sharedInstance] initWithConfig:docsViewConfig completionBlock:^(ZegoDocsViewError errorCode) {
         if (errorCode == 0) {
 //            [[ZegoBase alloc] initWhiteboard];
         }
     }];
 }
 
 + (void)loginRoomWithRoomId:(NSString *)roomID userId:(NSString *)userId userName:(NSString *)userName complete:(void (^)(int errorCode))completeAction {
     [ZegoLiveRoomApi setUserID:userId userName:userName];
     [[ZegoLiveRoomLiveCenter sharedInstance].api setRoomConfig:YES userStateUpdate:YES];
     [[ZegoLiveRoomLiveCenter sharedInstance].api loginRoom:roomID role:ZEGO_ANCHOR withCompletionBlock:^(int errorCode, NSArray<ZegoStream *> *streamList) {
         NSArray *liveStreamList = [[ZegoLiveRoomLiveCenter sharedInstance] liveStreamListWithStreamList:streamList];
         [[ZegoLiveRoomLiveCenter sharedInstance] setStreamList:liveStreamList];
         if (completeAction) {
             completeAction(errorCode);
         }
         if ([ZegoLiveRoomLiveCenter sharedInstance].delegate) {
             if ([[ZegoLiveRoomLiveCenter sharedInstance].delegate respondsToSelector:@selector(onStreamUpdated:streams:roomID:)]) {
                 [[ZegoLiveRoomLiveCenter sharedInstance].delegate onStreamUpdated:2001 streams:liveStreamList roomID:roomID];
             }
         }
     }];
      
 }

+ (void)uploadLog {
    [ZegoLiveRoomApi uploadLog];
}
 
 + (BOOL)setUserId:(NSString *)userId userName:(NSString *)userName {
     return [ZegoLiveRoomApi setUserID:userId userName:userName];
 }

+ (void)clearUser {
    [[ZegoLiveRoomLiveCenter sharedInstance].liveUsers removeAllObjects];
}

+ (void)writeLog:(int)logLevel
         content:(NSString *)content {
    [ZegoEduLogger writeLog:logLevel content:content];
}

+ (void)logoutRoomInRTC:(NSString *)roomID {
    [[ZegoLiveRoomLiveCenter sharedInstance].api logoutRoom];
    [self clearUser];
}
 
+ (void)logoutRoom:(NSString *)roomID{
    [[ZegoLiveRoomLiveCenter sharedInstance].api logoutRoom];
    [self clearUser];
}

+ (void)previewInView:(ZEGOView *)view {
    [[ZegoLiveRoomLiveCenter sharedInstance].api setPreviewView:view];
    [[ZegoLiveRoomLiveCenter sharedInstance].api setPreviewViewMode:ZegoVideoViewModeScaleAspectFill];
    [[ZegoLiveRoomLiveCenter sharedInstance].api startPreview];
}

+ (void)stopPreview {
    [[ZegoLiveRoomLiveCenter sharedInstance].api stopPreview];
    [[ZegoLiveRoomLiveCenter sharedInstance].api setPreviewView:nil];
}

+ (void)setFrontCam:(BOOL)isFront {
    [[ZegoLiveRoomLiveCenter sharedInstance].api setFrontCam:isFront];
}

+ (NSArray<ZegoLiveStream *> *)streamList {
    return [ZegoLiveRoomLiveCenter sharedInstance].streamList;
}

+ (void)publishStream:(NSString *)streamID {
    [[ZegoLiveRoomLiveCenter sharedInstance].api startPublishing:streamID title:nil flag:ZEGOAPI_JOIN_PUBLISH];
}


+ (void)stopPublishingStream {
    [[ZegoLiveRoomLiveCenter sharedInstance].api stopPublishing];
}

+ (void)muteAudio:(BOOL)isMute {
    [[ZegoLiveRoomLiveCenter sharedInstance].api enableMic:!isMute];
//    [[ZegoLiveRoomLiveCenter sharedInstance].api muteAudioPublish:isMute];
}

+ (void)muteVideo:(BOOL)isMute {
    [[ZegoLiveRoomLiveCenter sharedInstance].api enableCamera: !isMute];
//    [[ZegoLiveRoomLiveCenter sharedInstance].api muteVideoPublish:isMute];
}

+ (bool)playStream:(NSString *)streamID inView:(ZEGOView *)view {
    return [[ZegoLiveRoomLiveCenter sharedInstance].api startPlayingStream:streamID inView:view];
}

+ (bool)updateStream:(NSString *)streamID inView:(ZEGOView *)view {
    return [[ZegoLiveRoomLiveCenter sharedInstance].api updatePlayView:view ofStream:streamID];
}

+ (void)stopPlayingStream:(NSString *)streamID {
    [[ZegoLiveRoomLiveCenter sharedInstance].api stopPlayingStream:streamID];
}

+ (void)syncCurrentWhiteboardWithRoomID:(NSString *)roomID whiteBoardID:(NSString *)whiteBoardID compelte:(void (^)(int errorCode))compelte  {
    
    [[ZegoLiveRoomLiveCenter sharedInstance].api setRoomExtraInfo:kZegoRoomCurrentWhiteboardKey value:whiteBoardID completion:^(int errorCode, NSString *roomId, NSString *key) {
        if (compelte) {
            compelte(errorCode);
        }
    }];
}

+ (void)sendMessage:(NSString *)message roomID:(NSString *)roomID callback:(nullable ZegoLiveCenterImBlock)callback {
    ZegoLiveRoomLiveCenter *instance = [ZegoLiveRoomLiveCenter sharedInstance];
    [instance.api sendBigRoomMessage:message type:ZEGO_TEXT category:ZEGO_CHAT completion:^(int errorCode, NSString *roomId, NSString *messageId) {
        if (callback) {
            callback(errorCode,roomId,messageId);
        }
    }];
}

#pragma mark - Delegate

- (void)onPlayStateUpdate:(int)stateCode streamID:(NSString *)streamID {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onPlayStateUpdate:streamID:)]) {
            [self.delegate onPlayStateUpdate:stateCode streamID:streamID];
        }
    }


}

- (void)onRemoteCameraStatusUpdate:(int)status ofStream:(NSString *)streamID reason:(int)reason {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onRemoteCameraStatusUpdate:ofStream:reason:)]) {
            [self.delegate onRemoteCameraStatusUpdate:status ofStream:streamID reason:reason];
        }
    }
}

- (void)onRemoteMicStatusUpdate:(int)status ofStream:(NSString *)streamID reason:(int)reason {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onRemoteMicStatusUpdate:ofStream:reason:)]) {
            [self.delegate onRemoteMicStatusUpdate:status ofStream:streamID reason:reason];
        }
    }
}

- (void)onStreamUpdated:(int)type streams:(NSArray<ZegoStream *> *)streamList roomID:(NSString *)roomID {
    ZegoDemoStreamType typeDemo = type;
    NSArray *liveStreamArray = [self liveStreamListWithStreamList:streamList];
    if (type == 0) {
        self.streamList = liveStreamArray;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(onStreamUpdated:streams:roomID:)]) {
        [self.delegate onStreamUpdated:typeDemo streams:liveStreamArray roomID:roomID];
    }
}

- (void)onPlayQualityUpdate:(int)quality stream:(NSString *)streamID videoFPS:(double)fps videoBitrate:(double)kbs {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayQualityUpdate:stream:videoFPS:videoBitrate:)]) {
        [self.delegate onPlayQualityUpdate:quality stream:streamID videoFPS:fps videoBitrate:kbs];
    }
}

- (void)onStreamExtraInfoUpdated:(NSArray<ZegoStream *> *)streamList roomID:(NSString *)roomID {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onStreamExtraInfoUpdated:roomID:)]) {
        [self.delegate onStreamExtraInfoUpdated:[self liveStreamListWithStreamList:streamList] roomID:roomID];
    }
}

- (void)onPublishStateUpdate:(int)stateCode streamID:(NSString *)streamID streamInfo:(NSDictionary<NSString *,NSArray<NSString *> *> *)info {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPublishStateUpdate:streamID:streamInfo:)]) {
        [self.delegate onPublishStateUpdate:stateCode streamID:streamID streamInfo:info];
    }
}

- (void)onReceiveCustomCommand:(NSString *)fromUserID userName:(NSString *)fromUserName content:(NSString *)content roomID:(NSString *)roomID {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onReceiveCustomCommand:userName:content:roomID:)]) {
        [self.delegate onReceiveCustomCommand:fromUserID userName:fromUserName content:content roomID:roomID];
    }
}

- (void)onUserUpdate:(NSArray<ZegoUserState *> *)userList updateType:(ZegoUserUpdateType)type {
//    NSLog(@"onUserUpdate: type:%@ user1 Name:%@ userID:%ld flag:%d(1增加 2删除)", type == ZEGO_UPDATE_TOTAL ? @"全量更新" : @"增量更新", userList.firstObject.userName,userList.firstObject.userID, userList.firstObject.updateFlag);
    if (type == ZEGO_UPDATE_TOTAL) {
        [self.liveUsers removeAllObjects];
    }
    [userList enumerateObjectsUsingBlock:^(ZegoUserState * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZegoRoomMemberInfoModel *user = [[ZegoRoomMemberInfoModel alloc] initWithUid:obj.userID.integerValue userName:obj.userName role:obj.role];
        
        if (obj.updateFlag == ZEGO_USER_ADD) {
            if ([self.liveUsers containsObject:user]) {
                NSUInteger index = [self.liveUsers indexOfObject:user];
                self.liveUsers[index] = user;
            } else {
                [self.liveUsers addObject:user];
            }
        } else {
            [self.liveUsers removeObject:user];
        }
    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onUserUpdate:)]) {
        [self.delegate onUserUpdate:self.liveUsers];
    }
}

- (void)onRoomExtraInfoUpdated:(NSString *)roomId roomExtraInfoList:(NSArray<ZegoRoomExtraInfo *> *)roomExtraInfoList {
    ZegoRoomExtraInfo *info = roomExtraInfoList.firstObject;
    if ([self.delegate respondsToSelector:@selector(onRecvWhiteboardChange:)] && [info.key isEqualToString:kZegoRoomCurrentWhiteboardKey]) {
        [self.delegate onRecvWhiteboardChange:[info.value longLongValue]];
    }
}

- (void)onRecvBigRoomMessage:(NSString *)roomId messageList:(NSArray<ZegoBigRoomMessage *> *)messageList {
    NSMutableArray *bigRoomMessageList = [NSMutableArray array];
    for (ZegoBigRoomMessage *message in messageList) {
        ZegoMessageInfo *info = [[ZegoMessageInfo alloc]init];
        info.message = message.content;
        info.messageId = message.messageId;
        info.messageType = message.type;
        info.priority = message.priority;
        info.category = message.category;
        
        ZegoUserInfo *userInfo = [[ZegoUserInfo alloc]init];
        userInfo.userName = message.fromUserName;
        userInfo.uid = message.fromUserId;
        
        info.fromUser = userInfo;
        [bigRoomMessageList addObject:info];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onReceiveRoomMessage:roomID:)]) {
        [self.delegate onReceiveRoomMessage:bigRoomMessageList roomID:roomId];
    }
}

- (void)onDisconnect:(int)errorCode roomID:(NSString *)roomID {
    if ([self.delegate respondsToSelector:@selector(onDisconnect:roomID:)]) {
        [self.delegate onDisconnect:errorCode roomID:roomID];
    }
}

- (void)onTempBroken:(int)errorCode roomID:(NSString *)roomID {
    if ([self.delegate respondsToSelector:@selector(onTempBroken:roomID:)]) {
        [self.delegate onTempBroken:errorCode roomID:roomID];
    }
}

- (void)onReconnect:(int)errorCode roomID:(NSString *)roomID {
    if ([self.delegate respondsToSelector:@selector(onReconnect:roomID:)]) {
        [self.delegate onReconnect:errorCode roomID:roomID];
    }
}

- (void)onKickOut:(int)reason roomID:(NSString *)roomID customReason:(NSString *)customReason {
    if ([self.delegate respondsToSelector:@selector(onKickOut:roomID:customReason:)]) {
        [self.delegate onKickOut:reason roomID:roomID customReason:customReason];
    }
}

- (ZegoLiveStream *)liveStreamWithStream:(ZegoStream *)stream {
    return [ZegoLiveStream streamWithUserID:stream.userID userName:stream.userName streamID:stream.streamID extraInfo:stream.extraInfo streamNID:stream.streamNID];
}

- (NSArray<ZegoLiveStream *> *)liveStreamListWithStreamList:(NSArray <ZegoStream *> *)streamList {
    NSMutableArray *array = [NSMutableArray array];
    for (ZegoStream *stream in streamList) {
        ZegoLiveStream *liveStream = [self liveStreamWithStream:stream];
        [array addObject:liveStream];
    }
    return array;
}



@end

#endif
