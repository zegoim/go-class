//
//  ZegoErrorMap.m
//  TalkLineSDK
//
//  Created by Larry on 2020/6/17.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoErrorMap.h"
#import "NSString+ZegoExtension.h"
@interface ZegoErrorMap()

@property (nonatomic, strong) NSDictionary *errorMessageDic;

@end

@implementation ZegoErrorMap

+ (ZegoErrorMap *)sharedInstance
{
    __strong static ZegoErrorMap * _sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[ZegoErrorMap alloc] init];
    });
    
    return _sharedObject;
}

#pragma mark - class method
+ (NSString *)messageWithCode:(NSInteger)errorCode
{
    NSString *message = [self sharedInstance].errorMessageDic[@(errorCode)];
    if (message.length < 1) {
        message = [NSString stringWithFormat:@"errorCode:%ld",(long)errorCode];
    }
    return message;
}

#pragma mark - get
- (NSDictionary *)errorMessageDic
{
    if (!_errorMessageDic) {
        _errorMessageDic = @{
            @10001: [NSString zego_localizedString:@"login_other_teacher_in_the_class"],
            @10002: [NSString zego_localizedString:@"login_class_is_full"],
            @10003: @"用户没有权限修改",
            @10004: @"目标用户不在教室",
            
            @-90000: [NSString zego_localizedString:@"login_network_exception"],
            @-90001: @"API与key不匹配",
            @-90002: @"重复请求",
            @-90003: [NSString zego_localizedString:@"room_tip_fail_quit_try_again"],
            
            @-1001: [NSString zego_localizedString:@"login_fail_join_class"],
            @1001: [NSString zego_localizedString:@"login_class_is_full"],
            
            @52001104: [NSString zego_localizedString:@"login_class_is_full"],
            @52001105: [NSString zego_localizedString:@"login_class_is_full"],
        };
    }
    return _errorMessageDic;
}

@end
