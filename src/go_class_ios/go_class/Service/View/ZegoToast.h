//
//  ZegoToast.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/3.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoToast : NSObject

+ (void)showText:(NSString *)text;

+ (void)showToastToTopWIndow:(NSString *)text;

+ (void)showStickyWithMessage:(NSString *)text Indicator:(BOOL)indicator;

+ (void)updateStickyMessage:(NSString *)text;

+ (void)dismissStickyAnimation:(BOOL)animation;
@end

NS_ASSUME_NONNULL_END
