//
//  NSBundle+ZegoExtension.m
//  ZegoEducation
//
//  Created by zego on 2019/12/5.
//  Copyright © 2019 Shenzhen Zego Technology Company Limited. All rights reserved.
//

#import "NSBundle+ZegoExtension.h"

#import <objc/runtime.h>

#pragma mark - 语言设置

static const char _bundle = 0;

@interface ZegoBundle : NSBundle

@end

@implementation ZegoBundle

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
    NSBundle *bundle = objc_getAssociatedObject(self, &_bundle);
    return bundle ? [bundle localizedStringForKey:key value:value table:tableName] : [super localizedStringForKey:key value:value table:tableName];
}

@end


@implementation NSBundle (ZegoExtension)

+ (void)zego_setLanguage:(NSString *)language
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle mainBundle], [ZegoBundle class]);
    });
    [[NSUserDefaults standardUserDefaults] setValue:@[language] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    objc_setAssociatedObject([NSBundle mainBundle], &_bundle, language ? [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]] : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

