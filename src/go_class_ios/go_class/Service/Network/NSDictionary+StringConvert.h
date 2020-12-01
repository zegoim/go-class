//
//  NSDictionary+StringConvert.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/9/8.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (StringConvert)
- (NSString *)jsonStringEncoded;
- (BOOL)containsObjectForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
