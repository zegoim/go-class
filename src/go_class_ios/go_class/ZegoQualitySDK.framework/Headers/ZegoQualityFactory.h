//
//  ZegoQualityFactory.h
//  go_class
//
//  Created by Vic on 2021/6/12.
//  Copyright © 2021 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZegoQualitySDK/ZegoQualityViewControllerProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoQualityFactory : NSObject

/// 获取用于展示评分页和服务质量报告页的页面控制器
/// @param delegate 控制器的代理对象， 处理控制器视图的生命周期回调等方法，可空
+ (UIViewController *)qualityViewControllerWithDelegate:(nullable id<ZegoQualityViewControllerProtocol>)delegate;

@end

NS_ASSUME_NONNULL_END
