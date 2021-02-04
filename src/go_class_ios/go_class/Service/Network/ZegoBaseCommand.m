//
//  ZegoBaseCommand.m
//  TalkLineSDK
//
//  Created by Larry on 2020/6/14.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoBaseCommand.h"

@implementation ZegoBaseCommand

- (instancetype)init {
    if (self = [super init]) {
        _path = @"";
//        _host = @"http://doc-api-system-test.zego.im/mock/331";
//        _host = @"https://backend-alpha.talkline.cn";
//        _host = @"http://192.168.6.75:7779";
        
    }
    return self;
}

- (NSString *)requestUrl {
    NSString *url = [self.host stringByAppendingFormat:@"%@",self.path];
    return url;
}

- (NSString *)key {
    NSString *url = [self.host stringByAppendingPathComponent:self.path];
    NSString *fKey = [url stringByAppendingFormat:@"%@", self.paramDic];
    return fKey;
}

- (NSMutableDictionary *)paramDic {
    if (!_paramDic) {
        _paramDic = [[NSMutableDictionary alloc] init];
    }
    return _paramDic;
}

@end
