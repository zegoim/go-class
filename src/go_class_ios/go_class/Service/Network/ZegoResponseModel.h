//
//  ZegoResponseModel.h
//  TalkLineSDK
//
//  Created by Larry on 2020/6/14.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoResponseModel : NSObject

/// 错误码，详细描述见ZegoErrorMap.m
@property (nonatomic, assign) NSInteger code;

/// 错误消息
@property (nonatomic, copy) NSString *message;

/// 返回时间
@property (nonatomic, assign) NSTimeInterval timestamp;

/// 返回数据
@property (nonatomic, strong) NSDictionary *data;

@end

NS_ASSUME_NONNULL_END
