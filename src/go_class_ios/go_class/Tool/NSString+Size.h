//
//  NSString+Size.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/7/8.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSString (Size)
- (NSString *)stringForContainerWidth:(CGFloat)width font:(UIFont *)font;
- (CGSize)sizeForFont:(UIFont *)font;
@end

NS_ASSUME_NONNULL_END
