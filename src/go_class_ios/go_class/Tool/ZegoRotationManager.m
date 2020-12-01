//
//  ZegoRotationManager.m
//  ZegoWhiteboardVideoDemo
//
//  Created by Vic on 2020/10/30.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoRotationManager.h"
#import <objc/message.h>

static ZegoRotationManager *_instance = nil;

@interface ZegoRotationManager ()

@property (nonatomic, readwrite) UIInterfaceOrientationMask interfaceOrientationMask;

@end

@implementation ZegoRotationManager

#pragma mark - singleton
+ (instancetype)defaultManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[ZegoRotationManager alloc] init];
        _instance.interfaceOrientationMask = UIInterfaceOrientationMaskPortrait;
    });
    return _instance;
}

#pragma mark - setter methods
- (void)setOrientation:(UIDeviceOrientation)orientation {
    if (_orientation == orientation) return;
    if ([UIDevice currentDevice].orientation == orientation) {
        //强制旋转成与之前不一样的
        [[UIDevice currentDevice] setValue:@(_orientation) forKey:@"orientation"];
    }
    _orientation = orientation;
    UIInterfaceOrientationMask interfaceOrientationMask = UIInterfaceOrientationMaskPortrait;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            interfaceOrientationMask = UIInterfaceOrientationMaskPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            interfaceOrientationMask = UIInterfaceOrientationMaskPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeRight:
            interfaceOrientationMask = UIInterfaceOrientationMaskLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeLeft:
            interfaceOrientationMask = UIInterfaceOrientationMaskLandscapeLeft;
            break;
        default:
            interfaceOrientationMask = UIInterfaceOrientationMaskPortrait;
            break;
    }
    [ZegoRotationManager defaultManager].interfaceOrientationMask = interfaceOrientationMask;
    //强制旋转成全屏
    [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
}
@end
