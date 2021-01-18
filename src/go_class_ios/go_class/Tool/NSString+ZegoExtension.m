//
//  NSString+ZegoExtension.m
//  go_class
//
//  Created by MartinNie on 2021/1/11.
//  Copyright © 2021 zego. All rights reserved.
//

#import "NSString+ZegoExtension.h"
#import "ZegoClassEnvManager.h"
#import "NSBundle+ZegoExtension.h"
@implementation NSString (ZegoExtension)
- (NSString *)stringForContainerWidth:(CGFloat)width font:(UIFont *)font {
    NSString *displayString = [self copy];
    CGSize size = [self sizeForFont:[UIFont systemFontOfSize:12]];
    if (size.width > width - 4) {
        if (self.length >= 10) {
            NSString *pre = [self substringToIndex:3];
            NSString *last = [self substringFromIndex:self.length - 5];
            displayString = [NSString stringWithFormat:@"%@...%@", pre, last];
        }
        
    }
    return displayString;
}

- (CGSize)sizeForFont:(UIFont *)font {
    CGRect rect = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil];
    CGSize size = CGSizeMake(rect.size.width, rect.size.height);
    return size;
}

+ (NSString *)zego_localizedString:(NSString *)key {
    
    NSBundle *languageBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[ZegoClassEnvManager shareManager].isChinese ?ZEGOLanguageChinese:ZEGOLanguageEnglish ofType:@"lproj"]];
    NSString *result = [languageBundle localizedStringForKey:key value:@"" table:@"Localizeble"];
    return result;
}
@end
