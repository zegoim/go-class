//
//  ZegoBaseCommand.h
//  TalkLineSDK
//
//  Created by Larry on 2020/6/14.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZegoTipsType) {
    ZegoTipsTypeNone = 0,   //不显示错误弹窗，默认状态
    ZegoTipsTypeCenterDark, //深色透明样式，中间显示。房间外使用
    ZegoTipsTypeTopSucceed, //成功样式，顶部显示。房间外使用
    ZegoTipsTypeTopFail,    //失败样式，顶部显示。房间外使用
    ZegoTipsTypeTopSucceedCorner,   //成功，圆角，顶部显示。房间内使用
    ZegoTipsTypeTopFailCorner, //失败，圆角，顶部显示。房间内使用
};

@interface ZegoBaseCommand : NSObject

@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSMutableDictionary *paramDic;


- (NSString *)requestUrl;

- (NSString *)key;

@end

NS_ASSUME_NONNULL_END
