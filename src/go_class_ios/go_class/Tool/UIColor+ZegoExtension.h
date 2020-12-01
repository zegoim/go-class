//
//  UIColor+ZegoExtension.h
//  ZegoEducation
//
//  Created by zego on 2019/12/3.
//  Copyright © 2019 Shenzhen Zego Technology Company Limited. All rights reserved.
//
#import <UIKit/UIKit.h>

#ifndef UIColorHex
#define UIColorHex(_hex_) [UIColor colorWithRGB:((__bridge NSString *)CFSTR(#_hex_))]
#endif

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (ZegoExtension)

//建议使用UIColor类别。
+ (UIColor *)colorWithRGB:(NSString *)hexColor;
//建议使用UIColor类别。
+ (UIColor *)colorWithRGB:(NSString *)hexColor alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
