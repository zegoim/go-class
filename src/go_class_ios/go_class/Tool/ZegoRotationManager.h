//
//  ZegoRotationManager.h
//  ZegoWhiteboardVideoDemo
//
//  Created by Vic on 2020/10/30.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoRotationManager : NSObject

@property (nonatomic, readonly) UIInterfaceOrientationMask interfaceOrientationMask;
@property (nonatomic) UIDeviceOrientation orientation;

+ (instancetype)defaultManager;

@end

NS_ASSUME_NONNULL_END
