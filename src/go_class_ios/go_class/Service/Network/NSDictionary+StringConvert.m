//
//  NSDictionary+StringConvert.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/9/8.
//  Copyright © 2020 zego. All rights reserved.
//

#import "NSDictionary+StringConvert.h"

@implementation NSDictionary (StringConvert)

- (NSString *)jsonStringEncoded {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:0];
    NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return dataStr;
}

- (BOOL)containsObjectForKey:(NSString *)key {
    return  self[key] != nil;
}


@end
