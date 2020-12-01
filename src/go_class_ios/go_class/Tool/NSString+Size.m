//
//  NSString+Size.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/7/8.
//  Copyright © 2020 zego. All rights reserved.
//

#import "NSString+Size.h"


@implementation NSString (Size)

- (NSString *)stringForContainerWidth:(CGFloat)width font:(UIFont *)font {
    NSString *displayString = [self copy];
    if ([self sizeForFont:[UIFont systemFontOfSize:12]].width > width - 4) {
        if (self.length >= 10) {
            NSString *pre = [self substringToIndex:3];
            NSString *last = [self substringFromIndex:self.length - 5];
            displayString = [NSString stringWithFormat:@"%@...%@", pre, last];
        }
        
    }
    return displayString;
}
- (CGSize)sizeForFont:(UIFont *)font {
    return [self boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
}
@end
