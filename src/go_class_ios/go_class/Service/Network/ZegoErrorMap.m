//
//  ZegoErrorMap.m
//  TalkLineSDK
//
//  Created by Larry on 2020/6/17.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoErrorMap.h"

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
            @10001: @"课堂已有其他老师，不能加入",
            @10002: @"课堂人数已满，不能加入",
            @10003: @"用户没有权限修改",
            @10004: @"目标用户不在教室",
            
            @-90000: @"网络异常，请检查网络后重试",
            @-90001: @"API与key不匹配",
            @-90002: @"重复请求",
            @-90003: @"退出课堂失败，请重试",
            
            @-1001: @"加入课堂失败，请重试",
            @1001: @"加入课堂失败，当前已达到10人的最大人数限制",
            
            @52001104: @"加入课堂失败，当前已达到10人的最大人数限制",
            @52001105: @"加入课堂失败，当前已达到10人的最大人数限制",
        };
    }
    return _errorMessageDic;
}

@end
