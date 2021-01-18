//
//  AppDelegate.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/5/27.
//  Copyright © 2020 zego. All rights reserved.
//

#import "AppDelegate.h"
#import "ZegoLiveCenter.h"
#import "ZGAppSignHelper.h"
#import "ZegoAuthConstants.h"
#import "ZegoHttpHeartbeat.h"
#import "ZegoRotationManager.h"
#import "ZegoDocsViewDependency.h"
#import "ZGAppSignHelper.h"
#import "NSBundle+ZegoExtension.h"
#import "ZegoClassEnvManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary *dict = @{
        kIsTestEnvKey:@YES,
        kAppIDKey: @(kZegoAppID),
#ifdef IS_USE_LIVEROOM
        kAppSignKey: [ZGAppSignHelper convertAppSignToStringFromChars:kZegoSign],
#else
        kAppSignKey: [ZGAppSignHelper convertAppSignStringFromString:kZegoSign],
#endif
    };
    
    BOOL enLanguage = !([ZegoClassEnvManager shareManager].isChinese);
    [NSBundle zego_setLanguage:enLanguage?ZEGOLanguageEnglish:ZEGOLanguageChinese];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
//    [self redirectNSlogToDocumentFolder];
    return YES;
}
#pragma mark - 日志收集
- (void)redirectNSlogToDocumentFolder
{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc]init];
    [dateformat setDateFormat:@"HH:mm:ss"];
    NSString *fileName = [NSString stringWithFormat:@"LOG-%@.txt",[dateformat stringFromDate:[NSDate date]]];
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    // 先删除已经存在的文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:logFilePath error:nil];
    
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [ZegoLiveCenter logoutRoom:@""];
    [ZegoLiveCenter stopPublishingStream];
    [ZegoLiveCenter stopPreview];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kZegoAPPTeminalNotification object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [ZegoHttpHeartbeat sharedInstance].appEnterBackgroundTime = [NSDate date].timeIntervalSince1970;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    ZegoHttpHeartbeat *hb = [ZegoHttpHeartbeat sharedInstance];
    if (hb.appEnterBackgroundTime) {
        hb.appEnterBackgroundTime = [NSDate date].timeIntervalSince1970 - hb.appEnterBackgroundTime;
    }
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return [ZegoRotationManager defaultManager].interfaceOrientationMask;
}


@end
