//
//  NSString+ZegoExtension.h
//  go_class
//
//  Created by MartinNie on 2021/1/11.
//  Copyright © 2021 zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSString (ZegoExtension)
- (NSString *)stringForContainerWidth:(CGFloat)width font:(UIFont *)font;
- (CGSize)sizeForFont:(UIFont *)font;

+ (NSString *)zego_localizedString:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
