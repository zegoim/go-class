//
//  UIButton+Delay.m
//  ButtonDelay
//
//  Created by Vic on 2020/12/3.
//  Copyright © 2020 zego. All rights reserved.
//

#import "UIButton+Delay.h"
#import <objc/runtime.h>

#ifndef BUTTON_UNRESPOND_INTERVAL_THRESHOLD
#define BUTTON_UNRESPOND_INTERVAL_THRESHOLD 1   // 按钮点击间隔时间限制
#endif

@interface UIButton ()
@property (nonatomic, assign) NSTimeInterval lastTriggerTime;
@end

@implementation UIButton (Delay)

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if (![self canTrigger]) {
        return;
    }
    [super sendAction:action to:target forEvent:event];
}

- (BOOL)canTrigger {
    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
    if (!self.lastTriggerTime) {
        self.lastTriggerTime = time;
        return YES;
    }
    NSTimeInterval interval = time - self.lastTriggerTime;
    if (interval > BUTTON_UNRESPOND_INTERVAL_THRESHOLD) {
        self.lastTriggerTime = time;
        return YES;
    }
    return NO;
}

const void * lastTriggerKey = @"lastTriggerKey";
- (void)setLastTriggerTime:(NSTimeInterval)lastTriggerTime {
    objc_setAssociatedObject(self, lastTriggerKey, @(lastTriggerTime), OBJC_ASSOCIATION_RETAIN);
}

- (NSTimeInterval)lastTriggerTime {
    NSNumber *ret = objc_getAssociatedObject(self, lastTriggerKey);
    return ret.doubleValue;
}


@end
