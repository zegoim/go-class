//
//  ZegoViewAnimator.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/1.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoViewAnimator : NSObject

+ (void)showHUDText:(NSString *)text;
+ (void)dismissHUD;
+ (void)dismiss;
+ (void)showView:(UIView *)view fromRightSideInView:(UIView *)container;
+ (void)hideToRightForView:(nullable UIView *)view;
+ (void)hideToRight;

+ (void)popUpView:(UIView *)view onTopOfView:(UIView *)bottomView;
+ (void)popUpView:(UIView *)view onTopOfView:(UIView *)bottomView backColorAlpha:(CGFloat)alpha;
+ (void)toggleView:(UIView *)view inView:(UIView *)container autoHide:(BOOL)autoHide;
+ (void)fadeInView:(UIView *)view inView:(UIView *)container backViewColor:(UIColor *)backViewColor;
+ (void)fadeInView:(UIView *)view inView:(UIView *)container;
+ (void)fadeInView:(UIView *)view onLeftOfView:(UIView *)rightView;

/// @param offset view 的右上角相对于 rightView 的左上角的 offset
+ (void)fadeInView:(UIView *)view onLeftOfView:(UIView *)rightView offset:(CGPoint)offset;
+ (void)fadeView:(nullable UIView *)view completion:(void (^ __nullable)(BOOL finished))completion;
+ (void)fadeView:(nullable UIView *)view animated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion;
@end

NS_ASSUME_NONNULL_END
