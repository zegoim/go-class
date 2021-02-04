//
//  ZegoViewAnimator.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/1.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoViewAnimator.h"
#import "ZegoUIConstant.h"

typedef NS_ENUM(NSUInteger, ZegoViewAnimatorType) {
    ZegoViewAnimatorTypeFromRight,
    ZegoViewAnimatorTypePop,
    ZegoViewAnimatorTypeFade,
};

@interface ZegoViewAnimator ()

@property (assign, nonatomic) ZegoViewAnimatorType animatorType;
@property (weak, nonatomic) UIView *targetView;
@property (weak, nonatomic) UIView *toggledView;
@property (strong, nonatomic) UIView *backgroundView;

@property (nonatomic, strong) void (^dismissComplementBlock)(void);
@end

@implementation ZegoViewAnimator

typedef void (^ZegoActionBlock)(void);


static ZegoViewAnimator *sharedInstance = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZegoViewAnimator alloc] init];
    });
    return sharedInstance;
}

+ (void)showHUDText:(NSString *)text{
    ZegoViewAnimator *instance = [self sharedInstance];
    [NSObject cancelPreviousPerformRequestsWithTarget:instance];
    [self fadeView:nil animated:NO completion:nil];
    UIWindow *key = [UIApplication sharedApplication].keyWindow;
    CGSize size = key.bounds.size;
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (size.height - 15)/2, size.width, 15)];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.text = text;
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.textColor = [UIColor whiteColor];
    
    [self fadeInView:textLabel inView:key backViewColor:[UIColor colorWithWhite:0 alpha:0.6] tapToDismiss:NO];
}

+ (void)dismissHUD {
    [self dismiss];
}

+ (void)showView:(UIView *)view fromRightSideInView:(UIView *)container {
    ZegoViewAnimator *instance = [self sharedInstance];
    ZegoActionBlock block = ^(){
        instance.animatorType = ZegoViewAnimatorTypeFromRight;
        instance.targetView = view;
        view.alpha = 1;
        UIView *backView = [self getBackViewWithTapTarget:instance container:container];
        [container addSubview:view];
        view.frame = CGRectMake(container.bounds.size.width, 0, view.bounds.size.width, view.bounds.size.height);
        [UIView animateWithDuration:0.35 animations:^{
            backView.backgroundColor = [self defaultBackColor];
            view.frame = CGRectMake(container.bounds.size.width - view.bounds.size.width, 0, view.bounds.size.width, view.bounds.size.height);
        }];
    };
    
    if (instance.targetView) {
        [self fadeView:instance.targetView completion:^(BOOL finished) {
            block();
        }];
    } else {
        block();
    }
    
    
}

+ (void)fadeInView:(UIView *)view inView:(UIView *)container {
    [self fadeInView:view inView:container backViewColor:[self defaultBackColor] tapToDismiss:YES];
}

+ (void)fadeInView:(UIView *)view inView:(UIView *)container backViewColor:(UIColor *)backViewColor {
    [self fadeInView:view inView:container backViewColor:backViewColor tapToDismiss:YES];
}

+ (void)fadeInView:(UIView *)view inView:(UIView *)container backViewColor:(UIColor *)backViewColor tapToDismiss:(BOOL)tapToDismiss {
    ZegoViewAnimator *instance = [self sharedInstance];
    instance.animatorType = ZegoViewAnimatorTypeFade;
    instance.targetView = view;
    view.alpha = 0;
    
    UIView *backView = [[UIView alloc] initWithFrame:container.bounds];
    instance.backgroundView = backView;
    [container addSubview:backView];
    if (tapToDismiss) {
        UIGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:instance action:@selector(onTapBack)];
        [backView addGestureRecognizer:gr];
    }
    backView.backgroundColor = [UIColor clearColor];
    
    [container addSubview:view];
    [container bringSubviewToFront:view];
    [UIView animateWithDuration:0.35 animations:^{
        backView.backgroundColor = backViewColor;
        view.alpha = 1;
    }];
}

+ (void)toggleView:(UIView *)view inView:(UIView *)container autoHide:(BOOL)autoHide {
    ZegoViewAnimator *instance = [self sharedInstance];
    [NSObject cancelPreviousPerformRequestsWithTarget:instance];
    if (instance.toggledView && !instance.toggledView.hidden) {
        [UIView animateWithDuration:0.35 animations:^{
            instance.toggledView.alpha = 0;
        } completion:^(BOOL finished) {
            instance.toggledView.hidden = YES;
        }];
    } else {
        instance.toggledView = view;
        instance.toggledView.hidden = NO;
        view.alpha = 0;
        instance.animatorType = ZegoViewAnimatorTypeFade;
        [container addSubview:view];
        [UIView animateWithDuration:0.35 animations:^{
            view.alpha = 1;
        }];
        if (autoHide) {
            [instance performSelector:@selector(autoHideToggleView:) withObject:view afterDelay:5];
        }
    }
    
}

- (void)autoHideToggleView:(UIView *)view {
    [UIView animateWithDuration:0.35 animations:^{
        self.toggledView.alpha = 0;
    } completion:^(BOOL finished) {
        self.toggledView.hidden = YES;
        [self.toggledView removeFromSuperview];
        self.toggledView = nil;
    }];
}

+ (void)popUpView:(UIView *)view onTopOfView:(UIView *)bottomView backColorAlpha:(CGFloat)alpha {
    ZegoViewAnimator *instance = [self sharedInstance];
    instance.targetView = view;
    instance.animatorType = ZegoViewAnimatorTypePop;
    
    UIView *container = [UIApplication sharedApplication].keyWindow;
    UIView *backView = [self getBackViewWithTapTarget:instance container:container];
    [container addSubview:view];
    
    CGRect bottomViewRect = [bottomView.superview convertRect:bottomView.frame toView:container];
    CGPoint bottomViewOrigin = bottomViewRect.origin;
    
    CGSize bottomViewSize = bottomViewRect.size;
    CGFloat pointX = bottomViewOrigin.x + (bottomViewSize.width)/2 - view.bounds.size.width / 2;
    CGFloat pointY = bottomViewOrigin.y - view.bounds.size.height + 10;

    view.frame = CGRectMake(pointX, pointY, view.bounds.size.width, view.bounds.size.height);
    view.alpha = 1;
    [UIView animateWithDuration:0.35 animations:^{
        backView.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
        view.alpha = 1;
    }];
}

+ (void)popUpView:(UIView *)view onTopOfView:(UIView *)bottomView {
    [self popUpView:view onTopOfView:bottomView backColorAlpha:0.3];
    
}

+ (void)fadeInView:(UIView *)view onLeftOfView:(UIView *)rightView {
//    ZegoViewAnimator *instance = [self sharedInstance];
//    instance.targetView = view;
//    instance.animatorType = ZegoViewAnimatorTypePop;
//
//    UIView *container = [UIApplication sharedApplication].keyWindow;
//    UIView *backView = [self getBackViewWithTapTarget:instance container:container];
//    [container addSubview:view];
//
//    CGRect rightViewRect = [rightView.superview convertRect:rightView.frame toView:container];
//    CGPoint rightViewOrigin = rightViewRect.origin;
//
//    CGFloat pointX = rightViewOrigin.x - view.bounds.size.width - 8;
//    //此处多减去5个像素是因为，topbar 44，bottombar 49 差了5个像素
//    CGFloat pointY = (kScreenHeight - view.bounds.size.height - 5) / 2;
//
//    view.frame = CGRectMake(pointX, pointY, view.bounds.size.width, view.bounds.size.height);
//    view.alpha = 1;
//    [UIView animateWithDuration:0.15 animations:^{
////        backView.backgroundColor = [self defaultBackColor];
//        view.alpha = 1;
//    }];
    [self fadeInView:view onLeftOfView:rightView offset:CGPointMake(-8, 5)];
}

+ (void)fadeInView:(UIView *)view onLeftOfView:(UIView *)rightView offset:(CGPoint)offset {
    ZegoViewAnimator *instance = [self sharedInstance];
    instance.targetView = view;
    instance.animatorType = ZegoViewAnimatorTypePop;
    
    UIView *container = [UIApplication sharedApplication].keyWindow;
    __unused UIView *backView = [self getBackViewWithTapTarget:instance container:container];
    [container addSubview:view];
    
    CGRect rightViewRect = [rightView.superview convertRect:rightView.frame toView:container];
    CGPoint rightViewOrigin = rightViewRect.origin;
    
    CGFloat pointX = rightViewOrigin.x - view.bounds.size.width + offset.x;
    CGFloat pointY = rightViewOrigin.y + offset.y;

    view.frame = CGRectMake(pointX, pointY, view.bounds.size.width, view.bounds.size.height);
    view.alpha = 1;
    [UIView animateWithDuration:0.15 animations:^{
//        backView.backgroundColor = [self defaultBackColor];
        view.alpha = 1;
    }];
}

+ (void)dismiss {
    [self fadeView:nil animated:NO completion:^(BOOL finished) {
        
    }];
}

+ (void)fadeView:(nullable UIView *)view completion:(void (^ __nullable)(BOOL finished))completion {
    [self fadeView:view animated:YES completion:completion];
}

+ (void)fadeView:(nullable UIView *)view animated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion{
    
    ZegoViewAnimator *instance = [self sharedInstance];
    UIView *backView = [instance backgroundView];
    UIView *targetView = view;
    if (!targetView) {
        targetView = instance.targetView;
    }
    if (animated) {
        [UIView animateWithDuration:0.35 animations:^{
            if (backView) {
                backView.backgroundColor = UIColor.clearColor;
            }
            targetView.alpha = 0;
        } completion:^(BOOL finished) {
            [targetView removeFromSuperview];
            backView.backgroundColor = UIColor.clearColor;
            [backView removeFromSuperview];
            instance.backgroundView = nil;
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        targetView.alpha = 0;
        [targetView removeFromSuperview];
        backView.backgroundColor = UIColor.clearColor;
        [backView removeFromSuperview];
        instance.backgroundView = nil;
        if (completion) {
            completion(YES);
        }
    }
    
    
    
}

+ (void)fadeInView:(UIView *)view onLeftOfView:(UIView *)rightView offset:(CGPoint)offset completion:(void (^ __nullable)(BOOL finished))completion dismissCompletion:(void (^ __nullable)(void))dismissCompletion {
    ZegoViewAnimator *instance = [self sharedInstance];
    instance.dismissComplementBlock = dismissCompletion;
    instance.targetView = view;
    instance.animatorType = ZegoViewAnimatorTypePop;
    
    UIView *container = [UIApplication sharedApplication].keyWindow;
    __unused UIView *backView = [self getBackViewWithTapTarget:instance container:container];
    [container addSubview:view];
    
    CGRect rightViewRect = [rightView.superview convertRect:rightView.frame toView:container];
    CGPoint rightViewOrigin = rightViewRect.origin;
    
    CGFloat pointX = rightViewOrigin.x - view.bounds.size.width + offset.x;
    CGFloat pointY = rightViewOrigin.y + offset.y;

    view.frame = CGRectMake(pointX, pointY, view.bounds.size.width, view.bounds.size.height);
    view.alpha = 1;
    [UIView animateWithDuration:0.15 animations:^{
//        backView.backgroundColor = [self defaultBackColor];
        view.alpha = 1;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

+ (void)hideToRightForView:(nullable UIView *)view {
    ZegoViewAnimator *instance = [self sharedInstance];
    UIView *backView = [instance backgroundView];
    UIView *targetView = view;
    if (!targetView) {
        targetView = instance.targetView;
    }
    if (!targetView) {
        return;
    }
    [UIView animateWithDuration:0.35 animations:^{
        if (backView) {
            backView.backgroundColor = UIColor.clearColor;
        }
        CGRect targetViewBounds = targetView.bounds;
        targetView.frame = CGRectMake(targetView.frame.origin.x + targetViewBounds.size.width, 0, targetViewBounds.size.width, targetViewBounds.size.height);
    } completion:^(BOOL finished) {
        [targetView removeFromSuperview];
        instance.backgroundView.backgroundColor = UIColor.clearColor;
        [instance.backgroundView removeFromSuperview];
        instance.backgroundView = nil;
        
    }];
    
}

+ (void)hideToRight {
    [self hideToRightForView:nil];
}

- (void)onTapBack {
    if ([ZegoViewAnimator sharedInstance].animatorType == ZegoViewAnimatorTypeFromRight) {
        [ZegoViewAnimator hideToRight];
        if (self.dismissComplementBlock) {
            self.dismissComplementBlock();
        }
    } else {
        @weakify(self)
        [ZegoViewAnimator fadeView:nil completion:^(BOOL finished) {
            @strongify(self)
            if (self.dismissComplementBlock) {
                self.dismissComplementBlock();
            }
        }];
    }
    
}

+ (UIView *)getBackViewWithTapTarget:(NSObject *)target container:(UIView *)container {
    ZegoViewAnimator *instance = [ZegoViewAnimator sharedInstance];
    if (!instance.backgroundView) {
        UIView *backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        UIGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(onTapBack)];
        [backView addGestureRecognizer:gr];
        backView.backgroundColor = [UIColor clearColor];

        instance.backgroundView = backView;
        [container addSubview:instance.backgroundView];
    } else {
        instance.backgroundView.backgroundColor = [UIColor clearColor];
    }
    
    return instance.backgroundView;
}

+ (UIColor *)defaultBackColor {
    return [UIColor colorWithWhite:0 alpha:0.3];
}
@end
