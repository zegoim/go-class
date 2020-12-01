//
//  ZegoResponseModel.m
//  TalkLineSDK
//
//  Created by Larry on 2020/6/14.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoResponseModel.h"

@implementation ZegoResponseModel

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{@"code" : @"ret.code",
             @"message" : @"ret.message",
             @"timestamp" : @"ret.timestamp",
    };
}

@end
