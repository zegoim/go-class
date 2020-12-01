//
//  ZegoNetworkManager.m
//  TalkLineSDK
//
//  Created by Larry on 2020/6/14.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoNetworkManager.h"
#import "ZegoGeneralCommand.h"
#import "ZegoErrorMap.h"
#import <YYModel/YYModel.h>
#import "NSDictionary+StringConvert.h"
#import "ZegoAuthConstants.h"
#import "ZegoClassEnvManager.h"

#undef __MODULE__
#define __MODULE__ @"NetworkManager"

@interface ZegoListenerHandler : NSObject

@property (nonatomic, weak) id listener;
@property (nonatomic, strong) ZegoBaseCommand *command;
@property (nonatomic, strong) ZegoRequestBlock response;

@end

@implementation ZegoListenerHandler
@end

@interface ZegoRequestHandler : NSObject

@property (nonatomic, strong) ZegoBaseCommand *command;
@property (nonatomic, strong) ZegoRequestBlock successBlock;
@property (nonatomic, strong) ZegoRequestBlock failureBlock;

@end

@implementation ZegoRequestHandler
@end


@interface ZegoNetworkManager()

@property (nonatomic, strong) NSMutableDictionary *seqDic;
@property (nonatomic, strong) NSMutableDictionary *requestDic;
@property (nonatomic, strong) NSMutableDictionary *listenerDic;

@end

@implementation ZegoNetworkManager

+ (ZegoNetworkManager *)sharedInstance
{
    __strong static ZegoNetworkManager * _sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[ZegoNetworkManager alloc] init];
    });
    
    return _sharedObject;
}

+ (AFHTTPSessionManager *)afnManager {
    static dispatch_once_t onceToken;
    static AFHTTPSessionManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        // 设置超时时间
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 10.0f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    });
    return manager;
}

+ (NSString *)getHostWithEnv{
    if ([ZegoClassEnvManager shareManager].abroadEnv) {
        if ([ZegoClassEnvManager shareManager].businessTestEnv) {
            return kZegoGoClassAbroadServerHostTest;
        } else {
            return kZegoGoClassAbroadServerHost;
        }
    } else {
        if ([ZegoClassEnvManager shareManager].businessTestEnv) {
            return kZegoGoClassHomeServerHostTest;
        } else {
            return kZegoGoClassHomeServerHost;
        }
    }
}

+ (void)requestWithCommand:(ZegoBaseCommand *)command
                   success:(ZegoRequestBlock)success
                   failure:(ZegoRequestBlock)failure {
    command.host = [ZegoNetworkManager getHostWithEnv];
    BOOL addSuccess = [[self sharedInstance] addRequestCommand:command success:success failure:failure];
    if (!addSuccess) {
        [[self sharedInstance] duplicateRequestWithFailure:failure];
        return;
    }
    //发送请求
    NSDictionary *jsonDict = [self parseToDict:command];

    AFHTTPSessionManager *manager = [self afnManager];
    NSString *url = [command requestUrl];
    NSString *key = [command key];
    DLog(@"___START REQUEST URL:%@ PARAM:%@", url, jsonDict);
    [manager POST:url parameters:jsonDict headers:@{
        @"Content-Type":@"application/json"
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            DLog(@"___REQUEST URL:%@ SUCCEED:%@", url, responseObject);
            [[self sharedInstance] onResponse:key api:command.path result:responseObject error:nil];
        } else {
            NSError *error = [NSError errorWithDomain:NSNetServicesErrorDomain code:-10009 userInfo:@{@"message": @"No response"}];
            DLog(@"___REQUEST URL:%@ FAILED:%@", url, error);
            [[self sharedInstance] onResponse:key api:command.path result:nil error:error];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DLog(@"___REQUEST FAILED:%@", error);
        [[self sharedInstance] onResponse:key api:command.path result:nil error:error];
    }];
}

+ (void)regListener:(id)listener
            command:(ZegoBaseCommand *)command
           response:(ZegoRequestBlock)response
{
    if (response == nil ||
        command == nil ||
        listener == nil) {
        return;
    }
    [[self sharedInstance] addListener:listener command:command response:response];
}

+ (void)removeListener:(id)listener
               command:(ZegoBaseCommand *)command
              response:(ZegoRequestBlock)response
{
    if (response == nil || command == nil) {
        return;
    }
    NSString *key = [command key];
    NSMutableArray *array = [self sharedInstance].listenerDic[key];
    if (array.count == 0) return;
    NSMutableArray *tempArray = [array mutableCopy];
    for (ZegoListenerHandler *handler in array) {
        if (handler.listener == listener) {
            [tempArray removeObject:listener];
        }
    }
    [self sharedInstance].listenerDic[key] = tempArray;
}

- (void)onResponse:(NSString *)key api:(NSString *)api result:(id)result error:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        ZegoRequestHandler *handler = self.requestDic[key];
        [self.requestDic removeObjectForKey:key];

        ZegoResponseModel *response = [[ZegoResponseModel alloc] init];
        if (error) {
            //code 为-1001时为网络超时的错误
            if (error.code != -1001) {
                response.code = -90000;
            }
            response.code = error.code;
            response.message = [ZegoErrorMap messageWithCode:response.code];
            handler.failureBlock(response);
            return;
        }
        
        if ([handler.command.path isEqualToString:api]) {
            response = [ZegoResponseModel yy_modelWithJSON:result];
            if (response.code == 0 && handler.successBlock) {
                handler.successBlock(response);
            } else if (response.code != 0 && handler.failureBlock) {
                response.message = [ZegoErrorMap messageWithCode:response.code];
                handler.failureBlock(response);
            }
        } else {
            response.code = -90001;
            response.message = [ZegoErrorMap messageWithCode:response.code];
            handler.failureBlock(response);
        }
    });
}

#pragma mark - private method
+ (NSDictionary *)parseToDict:(ZegoBaseCommand *)command
{
    NSMutableDictionary *dic = nil;
    if ([command isKindOfClass:[ZegoGeneralCommand class]]) {
        ZegoGeneralCommand *generalCommand = (ZegoGeneralCommand *)command;
        dic = [generalCommand.paramDic mutableCopy];
    } else {
        dic = [[command yy_modelToJSONObject] mutableCopy];
        [dic removeObjectForKey:@"path"];
        [dic removeObjectForKey:@"tipsType"];
    }
    
    return dic;
}

- (BOOL)addRequestCommand:(ZegoBaseCommand *)command
                  success:(ZegoRequestBlock)success
                  failure:(ZegoRequestBlock)failure
{
    NSString *key = [command key];
    if ([self.requestDic containsObjectForKey:key]) {
        return NO;
    }
    ZegoRequestHandler *hander = [[ZegoRequestHandler alloc] init];
    hander.command = command;
    hander.successBlock = success;
    hander.failureBlock = failure;
    self.requestDic[key] = hander;
    return YES;
}

- (BOOL)addListener:(id)listener
            command:(ZegoBaseCommand *)command
           response:(ZegoRequestBlock)response
{
    NSString *key = [command key];
    NSMutableArray *array = self.listenerDic[key];
    if (array == nil) {
        array = [[NSMutableArray alloc] init];
    }
    
    for (ZegoListenerHandler *handler in array) {
        if (handler.listener == listener) {
            return NO;
        }
    }
    
    ZegoListenerHandler *handler = [[ZegoListenerHandler alloc] init];
    handler.command = command;
    handler.listener = listener;
    handler.response = response;
    
    [array addObject:handler];
    self.listenerDic[key] = array;
    return YES;
}

- (void)duplicateRequestWithFailure:(ZegoRequestBlock)failure
{
    if (failure) {
        ZegoResponseModel *model = [[ZegoResponseModel alloc] init];
        model.code = -90002;
        model.message = [ZegoErrorMap messageWithCode:model.code];
        dispatch_async(dispatch_get_main_queue(), ^{
            failure(model);
        });
    }
}

#pragma mark - Get Set method

- (NSMutableDictionary *)seqDic
{
    if (!_seqDic) {
        _seqDic = [[NSMutableDictionary alloc] init];
    }
    return _seqDic;
}

- (NSMutableDictionary *)requestDic
{
    if (!_requestDic) {
        _requestDic = [[NSMutableDictionary alloc] init];
    }
    return _requestDic;
}

- (NSMutableDictionary *)listenerDic
{
    if (!_listenerDic) {
        _listenerDic = [[NSMutableDictionary alloc] init];
    }
    return _listenerDic;
}
@end
