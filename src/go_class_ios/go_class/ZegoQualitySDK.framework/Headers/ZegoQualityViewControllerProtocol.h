//
//  ZegoQualityViewControllerProtocol.h
//  go_class
//
//  Created by Vic on 2021/6/12.
//  Copyright © 2021 zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZegoQualityViewControllerProtocol <NSObject>

/// 点击 web 页面的关闭按钮时抛出该回调方法
/// @param qualityViewController 质量报告控制器
- (void)viewControllerShouldDismiss:(UIViewController *)qualityViewController;

/// 在控制器执行 `viewWillDisappear` 的时候调用该回调方法
/// @param qualityViewController 质量报告控制器
- (void)viewForQualityViewControllerWillDisappear:(UIViewController *)qualityViewController;

/// 在控制器执行 `viewDidDisappear` 的时候调用该回调方法
/// @param qualityViewController 质量报告控制器
- (void)viewForQualityViewControllerDidDisappear:(UIViewController *)qualityViewController;

@end

NS_ASSUME_NONNULL_END
