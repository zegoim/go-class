//
//  NSBundle+ZegoExtension.h
//  ZegoEducation
//
//  Created by zego on 2019/12/5.
//  Copyright © 2019 Shenzhen Zego Technology Company Limited. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const ZEGOLanguageChinese = @"zh-Hans";
static NSString *const ZEGOLanguageEnglish = @"en";


@interface NSBundle (ZegoExtension)

+ (void)zego_setLanguage:(NSString *)language;

@end

NS_ASSUME_NONNULL_END
