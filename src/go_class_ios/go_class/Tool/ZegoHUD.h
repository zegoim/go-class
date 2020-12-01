//
//  ZegoHUD.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/9/14.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoHUD : NSObject

+ (void)showIndicatorHUDText:(NSString *)text;
+ (void)dismiss;

@end

NS_ASSUME_NONNULL_END
