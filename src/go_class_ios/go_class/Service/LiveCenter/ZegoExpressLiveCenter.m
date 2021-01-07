//
//  ZegoExpressLiveCenter.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/7/7.
//  Copyright © 2020 zego. All rights reserved.
//
#ifndef IS_USE_LIVEROOM

#import "ZegoExpressLiveCenter.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import "ZegoAuthConstants.h"
#import "ZegoDocsViewDependency.h"
#import <ZegoWhiteboardView/ZegoWhiteboardManager.h>
#import "ZGAppSignHelper.h"
#import "ZegoClassEnvManager.h"
#import "ZegoChatModel.h"

@interface ZegoExpressLiveCenter ()<ZegoEventHandler>

@property (weak, nonatomic) id<ZegoLiveCenterDelegate> delegate;

@property (strong, nonatomic) ZegoExpressEngine *api;

@property (strong, nonatomic, readwrite) NSMutableArray *liveUsers;
@property (strong, nonatomic) NSArray<ZegoLiveStream *> *streamList;

@property (copy, nonatomic) void (^loginCompleteAction)(int errorCode);

@property (assign, nonatomic) ZegoRoomState roomState;
@property (copy, nonatomic) NSString *roomID;


@end


@implementation ZegoExpressLiveCenter

static ZegoExpressLiveCenter *sharedInstance = nil;

- (ZegoExpressEngine *)api {
    return [ZegoExpressEngine sharedEngine];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZegoExpressLiveCenter alloc] init];
        sharedInstance.liveUsers = [NSMutableArray array];
        sharedInstance.roomState = ZegoRoomStateDisconnected;
    });
    return sharedInstance;
}

+ (void)setDelegate:(id<ZegoLiveCenterDelegate>)delegate {
    [ZegoExpressLiveCenter sharedInstance].delegate = delegate;
}

+ (nonnull NSMutableArray<ZegoRoomMemberInfoModel *> *)getUsersInRoom {
    return [ZegoExpressLiveCenter sharedInstance].liveUsers;
}

#pragma mark - API - LiveRoom
 
+ (void)setupWithAppID:(unsigned int)appID appSign:(nonnull NSData *)appSign isDocTestEnv:(BOOL)isDocTestEnv isRTCTestEnv:(BOOL)isRTCTestEnv scenario:(NSUInteger)scenario complete:(nonnull ZegoLiveCenterCompletionBlock)complete delegate:(nullable id<ZegoLiveCenterDelegate>)delegate {
    ZegoExpressLiveCenter *center = [ZegoExpressLiveCenter sharedInstance];
    [ZegoExpressEngine destroyEngine:nil];
    [ZegoExpressEngine createEngineWithAppID:appID appSign:[ZGAppSignHelper convertAppSignToExpressString:appSign] isTestEnv:isRTCTestEnv scenario:scenario eventHandler:center];

    center.delegate = delegate;
    
    ZegoEngineConfig *config = [[ZegoEngineConfig alloc] init];
    config.advancedConfig = @{
        @"room_retry_time": @300,
        @"play_clear_last_frame": @YES,
        @"preview_clear_last_frame": @YES
    };
    ZegoLogConfig *logConfig = [[ZegoLogConfig alloc] init];
    logConfig.logPath = kZegoLogPath;
    config.logConfig = logConfig;
    

    [ZegoExpressEngine setEngineConfig:config];
    
    
    ZegoExpressEngine *engine = [ZegoExpressEngine sharedEngine];
    ZegoVideoConfig *videoConfig = [[ZegoVideoConfig alloc] init];
    videoConfig.captureResolution = CGSizeMake(640, 360);
    videoConfig.encodeResolution = CGSizeMake(640, 360);
    [engine setVideoConfig:videoConfig];
    [engine setAppOrientation:UIInterfaceOrientationLandscapeRight];
 
     //文档初始化
     ZegoDocsViewConfig * docsViewConfig = [ZegoDocsViewConfig new];
     docsViewConfig.isTestEnv = isDocTestEnv;
    
    //文档sdk没有海外环境，统一用国内环境初始化
//    docsViewConfig.appSign = [ZGAppSignHelper convertAppSignToStringFromChars:kZegoSign];
//    docsViewConfig.appID = (unsigned int)kZegoAppID;
    docsViewConfig.appSign = [ZGAppSignHelper convertAppSignStringFromString:kZegoSign];
    docsViewConfig.appID = kZegoAppID;
    
//     docsViewConfig.appSign = [ZGAppSignHelper convertAppSignToString:appSign];
//     docsViewConfig.appID = appID;
     docsViewConfig.dataFolder = kZegoDocsDataPath;
     docsViewConfig.logFolder = kZegoLogPath;
     docsViewConfig.cacheFolder = kZegoDocsDataPath;
//    [[ZegoDocsViewManager sharedInstance] uninit];
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

#pragma mark - 引擎启动后才设置 ，这是sdk的bug
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //WhiteBoardView 初始化
        ZegoWhiteboardConfig *configw = [ZegoWhiteboardConfig new];
        configw.logPath = kZegoLogPath;
        [[ZegoWhiteboardManager sharedInstance] setConfig:configw];
        if (complete) {
            complete(0);
        }
    });
 }
 
 + (void)loginRoomWithRoomId:(NSString *)roomID userId:(NSString *)userId userName:(NSString *)userName complete:(void (^)(int errorCode))completeAction {
     [ZegoExpressLiveCenter sharedInstance].streamList = nil;
     ZegoUser *user = [[ZegoUser alloc] init];
     [ZegoExpressLiveCenter sharedInstance].loginCompleteAction = completeAction;
     user.userID = userId;
     user.userName = userName;
     
     ZegoRoomConfig *config = [ZegoRoomConfig defaultConfig];
     config.maxMemberCount = 10;
     config.isUserStatusNotify = YES;
     
     [[ZegoExpressLiveCenter sharedInstance].api loginRoom:roomID user:user config:config];
     
     if ([ZegoExpressLiveCenter sharedInstance].roomState == ZegoRoomStateConnected) {
         [[ZegoExpressLiveCenter sharedInstance] onRoomStateUpdate:ZegoRoomStateConnected errorCode:0 extendedData:nil roomID:[ZegoExpressLiveCenter sharedInstance].roomID];
     }
 }
 
+ (void)uploadLog {
    [[ZegoExpressEngine sharedEngine] uploadLog];
}

 + (BOOL)setUserId:(NSString *)userId userName:(NSString *)userName {
     return YES;
 }

+ (void)clearUser {
    [[ZegoExpressLiveCenter sharedInstance].liveUsers removeAllObjects];
}

+ (void)writeLog:(int)logLevel
         content:(NSString *)content {
    //[ZegoEduLogger writeLog:logLevel content:content];
}
 
+ (void)logoutRoomInRTC:(NSString *)roomID {
    [[ZegoExpressLiveCenter sharedInstance].api logoutRoom:roomID];
    [self clearUser];
    [ZegoExpressLiveCenter sharedInstance].streamList = nil;
}

+ (void)logoutRoom:(NSString *)roomID{
    [[ZegoExpressLiveCenter sharedInstance].api logoutRoom:roomID];
    [ZegoExpressLiveCenter sharedInstance].delegate = nil;
    [ZegoExpressLiveCenter sharedInstance].loginCompleteAction = nil;
    [self clearUser];
    [ZegoExpressLiveCenter sharedInstance].streamList = nil;
}

+ (void)previewInView:(UIView *)view {
    ZegoCanvas *canvas = [ZegoCanvas canvasWithView:view];
    canvas.viewMode = ZegoViewModeAspectFill;
    [[ZegoExpressLiveCenter sharedInstance].api startPreview:[ZegoCanvas canvasWithView:view]];
}

+ (void)stopPreview {
    [[ZegoExpressLiveCenter sharedInstance].api stopPreview];
}

+ (void)setFrontCam:(BOOL)isFront {
    [[ZegoExpressLiveCenter sharedInstance].api useFrontCamera:isFront];
}


+ (void)publishStream:(NSString *)streamID {
    [[ZegoExpressLiveCenter sharedInstance].api startPublishingStream:streamID];
}


+ (void)stopPublishingStream {
    [[ZegoExpressLiveCenter sharedInstance].api stopPublishingStream];
}

+ (void)muteAudio:(BOOL)isMute {
    [[ZegoExpressLiveCenter sharedInstance].api enableAudioCaptureDevice:!isMute];
}

+ (void)muteVideo:(BOOL)isMute {
    [[ZegoExpressLiveCenter sharedInstance].api enableCamera: !isMute];
//    [[ZegoExpressLiveCenter sharedInstance].api muteVideoPublish:isMute];
}

+ (bool)playStream:(NSString *)streamID inView:(UIView *)view {
    ZegoCanvas *canvas = [ZegoCanvas canvasWithView:view];
    canvas.viewMode = ZegoViewModeAspectFill;
    [[ZegoExpressLiveCenter sharedInstance].api startPlayingStream:streamID canvas:canvas];
    return YES;
}

+ (bool)updateStream:(NSString *)streamID inView:(UIView *)view {
    ZegoCanvas *canvas = [ZegoCanvas canvasWithView:view];
    canvas.viewMode = ZegoViewModeAspectFill;
    [[ZegoExpressLiveCenter sharedInstance].api startPlayingStream:streamID canvas:canvas];
    return YES;
}

+ (void)stopPlayingStream:(NSString *)streamID {
    [[ZegoExpressLiveCenter sharedInstance].api stopPlayingStream:streamID];
}

+ (NSArray<ZegoLiveStream *> *)streamList {
    return [ZegoExpressLiveCenter sharedInstance].streamList;
}

+ (void)syncCurrentWhiteboardWithRoomID:(NSString *)roomID whiteBoardID:(NSString *)whiteBoardID compelte:(void (^)(int errorCode))compelte {
    
    [[ZegoExpressLiveCenter sharedInstance].api setRoomExtraInfo:whiteBoardID forKey:kZegoRoomCurrentWhiteboardKey roomID:roomID callback:^(int errorCode) {
        if (compelte) {
            compelte(errorCode);
        }
    }];
}


+ (void)sendMessage:(NSString *)message roomID:(NSString *)roomID callback:(nullable ZegoLiveCenterImBlock)callback {
    ZegoExpressLiveCenter *instance = [ZegoExpressLiveCenter sharedInstance];
    [instance.api sendBarrageMessage:message roomID:roomID callback:^(int errorCode, NSString * _Nonnull messageID) {
        if (callback) {
            callback(errorCode,roomID,messageID);
        }
    }];
}

#pragma mark - Delegate


- (void)onRemoteCameraStateUpdate:(ZegoRemoteDeviceState)state streamID:(NSString *)streamID {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onRemoteMicStatusUpdate:ofStream:reason:)]) {
            [self.delegate onRemoteCameraStatusUpdate:(int)state ofStream:streamID reason:0];
        }
    }
}

- (void)onRemoteMicStateUpdate:(int)status streamID:(NSString *)streamID reason:(int)reason {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onRemoteMicStatusUpdate:ofStream:reason:)]) {
            [self.delegate onRemoteMicStatusUpdate:status ofStream:streamID reason:reason];
        }
    }
}

- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList roomID:(NSString *)roomID {
    ZegoDemoStreamType typeDemo;
    if (updateType == ZegoUpdateTypeAdd) {
        typeDemo = ZegoDemoStreamTypeADD;
    } else {
        typeDemo = ZegoDemoStreamTypeDELETE;
    }
    NSArray *liveStreamArray = [self liveStreamListWithStreamList:streamList];
    if (updateType == ZegoUpdateTypeAdd) {
        self.streamList = liveStreamArray;
    }
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onStreamUpdated:streams:roomID:)]) {
            [self.delegate onStreamUpdated:typeDemo streams:liveStreamArray roomID:roomID];
        }
    }
}


- (void)onPlayerQualityUpdate:(ZegoPlayStreamQuality *)quality streamID:(NSString *)streamID {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayQualityUpdate:stream:videoFPS:videoBitrate:)]) {
        [self.delegate onPlayQualityUpdate:(int)quality.level stream:streamID videoFPS:quality.videoRecvFPS videoBitrate:quality.videoKBPS];
    }
}

- (void)onRoomStreamExtraInfoUpdate:(NSArray<ZegoLiveStream *> *)streamList roomID:(NSString *)roomID {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onStreamExtraInfoUpdated:roomID:)]) {
        [self.delegate onStreamExtraInfoUpdated:streamList roomID:roomID];
    }
}

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPublishStateUpdate:streamID:streamInfo:)]) {
        [self.delegate onPublishStateUpdate:(int)state streamID:streamID streamInfo:extendedData];
    }
}

- (void)onIMRecvCustomCommand:(NSString *)command fromUser:(ZegoUser *)fromUser roomID:(NSString *)roomID {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onReceiveCustomCommand:userName:content:roomID:)]) {
        [self.delegate onReceiveCustomCommand:fromUser.userID userName:fromUser.userName content:command roomID:roomID];
    }
}

- (void)onRoomUserUpdate:(ZegoUpdateType)updateType userList:(NSArray<ZegoUser *> *)userList roomID:(NSString *)roomID {
    [userList enumerateObjectsUsingBlock:^(ZegoUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZegoRoomMemberInfoModel *user = [[ZegoRoomMemberInfoModel alloc] initWithUid:obj.userID.integerValue userName:obj.userName role:0];
        if (updateType == ZegoUpdateTypeAdd) {
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

- (void)onRoomExtraInfoUpdate:(NSArray<ZegoRoomExtraInfo *> *)roomExtraInfoList roomID:(NSString *)roomID {
    ZegoRoomExtraInfo *info = roomExtraInfoList.firstObject;
    if ([self.delegate respondsToSelector:@selector(onRecvWhiteboardChange:)] && [info.key isEqualToString:kZegoRoomCurrentWhiteboardKey]) {
        [self.delegate onRecvWhiteboardChange:[info.value longLongValue]];
    }
}

- (void)onIMRecvBarrageMessage:(NSArray<ZegoBarrageMessageInfo *> *)messageList roomID:(NSString *)roomID {
    NSMutableArray *bigRoomMessageList = [NSMutableArray array];
    for (ZegoBarrageMessageInfo *message in messageList) {
        ZegoMessageInfo *info = [[ZegoMessageInfo alloc]init];
        info.message = message.message;
        info.messageId = message.messageID;
        
        ZegoUserInfo *userInfo = [[ZegoUserInfo alloc]init];
        userInfo.userName = message.fromUser.userName;
        userInfo.uid = message.fromUser.userID;
        info.fromUser = userInfo;
        
        [bigRoomMessageList addObject:info];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(onReceiveRoomMessage:roomID:)]) {
           [self.delegate onReceiveRoomMessage:bigRoomMessageList roomID:roomID];
       }
       
}

- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    self.roomState = state;
    self.roomID = roomID;
    switch (state) {
        case ZegoRoomStateDisconnected:
            self.streamList = nil;
            if (self.loginCompleteAction) {
                self.loginCompleteAction(errorCode);
                self.loginCompleteAction = nil;
            }
            if ([self.delegate respondsToSelector:@selector(onDisconnect:roomID:)]) {
//                [self.delegate onDisconnect:errorCode roomID:roomID];
            }
            
            break;
        case ZegoRoomStateConnecting:
            self.streamList = nil;
            if (!self.loginCompleteAction) {
                if ([self.delegate respondsToSelector:@selector(onTempBroken:roomID:)]) {
                    [self.delegate onTempBroken:errorCode roomID:roomID];
                }
            }
            break;
        case ZegoRoomStateConnected:
            if (self.loginCompleteAction) {
                self.loginCompleteAction(errorCode);
                self.loginCompleteAction = nil;
            } else {
                if ([self.delegate respondsToSelector:@selector(onReconnect:roomID:)]) {
                    [self.delegate onReconnect:errorCode roomID:roomID];
                }
            }
            
            break;
        default:
            break;
    }
}

- (ZegoLiveStream *)liveStreamWithStream:(ZegoStream *)stream {
    return [ZegoLiveStream streamWithUserID:stream.user.userID userName:stream.user.userName streamID:stream.streamID extraInfo:stream.extraInfo streamNID:0];
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
