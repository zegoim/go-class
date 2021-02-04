//
//  ZegoToast.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/3.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoToast.h"
#import <UIKit/UIKit.h>
static UIView *stickyView;
static UILabel *titleLabel;
static UIActivityIndicatorView *indicationView;

@implementation ZegoToast

+ (void)showText:(NSString *)text {
    UIWindow *key = [UIApplication sharedApplication].keyWindow;
    CGSize size = key.bounds.size;
    CGFloat textWidth = [self calculateRowWidth:text];
    CGFloat viewWidth = textWidth + 30;
    CGFloat textHeight = 16;
    CGFloat viewHeight = 44;
    
    __block UIView *view = [[UIView alloc] initWithFrame:CGRectMake((size.width-viewWidth)/2, (size.height-viewHeight)/2, viewWidth, viewHeight)];
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, textWidth, textHeight)];
    textLabel.text = text;
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.textColor = [UIColor whiteColor];
    [view addSubview:textLabel];
    
    [key addSubview:view];
    [key bringSubviewToFront:view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.6 animations:^{
            view.alpha = 0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
            view = nil;
        }];
    });
}

+ (void)showToastToTopWIndow:(NSString *)text {
    UIWindow *key = [[[UIApplication sharedApplication] delegate] window];
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (id windowView in windows) {
        key = windowView;
    }
    
    CGSize size = key.bounds.size;
    CGFloat textWidth = [self calculateRowWidth:text];
    CGFloat viewWidth = textWidth + 30;
    CGFloat textHeight = 16;
    CGFloat viewHeight = 44;
    
    __block UIView *view = [[UIView alloc] initWithFrame:CGRectMake((size.width-viewWidth)/2, (size.height-viewHeight)/2, viewWidth, viewHeight)];
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, textWidth, textHeight)];
    textLabel.text = text;
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.textColor = [UIColor whiteColor];
    [view addSubview:textLabel];
    [key addSubview:view];
    [key bringSubviewToFront:view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.6 animations:^{
            view.alpha = 0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
            view = nil;
        }];
    });
}

+ (void)showStickyWithMessage:(NSString *)text Indicator:(BOOL)indicator {
    [ZegoToast dismissStickyAnimation:NO];
    UIWindow *key = [UIApplication sharedApplication].keyWindow;
    CGSize size = key.bounds.size;
    CGFloat textWidth = [ZegoToast calculateRowWidth:text];
    CGFloat textHeight = 16;
    CGFloat viewHeight = 42;
    
    __block UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    stickyView = view;
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    indicatorView.color = [UIColor whiteColor];
    indicatorView.hidesWhenStopped = YES;
    [indicatorView startAnimating];

    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel.text = text;
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.textColor = [UIColor whiteColor];
    titleLabel = textLabel;
    if (indicator) {
        CGFloat indicatorWidth = 20;
        CGFloat viewWidth = textWidth + indicatorWidth + 8 + 30 ;
        view.frame = CGRectMake((size.width-viewWidth)/2, 54, viewWidth, viewHeight);
        indicatorView.frame = CGRectMake(15, (viewHeight - indicatorWidth)/2, indicatorWidth, indicatorWidth);
        textLabel.frame = CGRectMake(CGRectGetMaxX(indicatorView.frame) + 8, (viewHeight - textHeight)/2, textWidth, textHeight);
        indicatorView.hidden = NO;
    } else {
        CGFloat viewWidth = textWidth + 30 ;
        view.frame = CGRectMake((size.width-viewWidth)/2, 54, viewWidth, viewHeight);
        textLabel.frame = CGRectMake(15, (viewHeight - textHeight) /2, textWidth, textHeight);
        indicatorView.hidden = YES;
        [indicatorView stopAnimating];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ZegoToast dismissStickyAnimation:YES];
        });
    }
    [view addSubview:indicatorView];
    [view addSubview:textLabel];
    [key addSubview:view];
    [key bringSubviewToFront:view];
}

+ (void)updateStickyMessage:(NSString *)text {
    titleLabel.text = text;
}

+ (void)dismissStickyAnimation:(BOOL)animation {
    if (stickyView) {
        if (animation) {
            [UIView animateWithDuration:0.6 animations:^{
                stickyView.alpha = 0;
            } completion:^(BOOL finished) {
                [self reset];
            }];
        } else {
            [self reset];
        }
    }
}

+ (void)reset {
    [stickyView removeFromSuperview];
    stickyView = nil;
    titleLabel = nil;
    indicationView = nil;
}

+(CGFloat)calculateRowWidth:(NSString *)string {
    return [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0]} context:nil].size.width + 10;
}


@end
