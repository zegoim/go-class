//
//  ZegoErrorMap.h
//  TalkLineSDK
//
//  Created by Larry on 2020/6/17.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoErrorMap : NSObject

+ (NSString *)messageWithCode:(NSInteger)errorCode;

@end

NS_ASSUME_NONNULL_END
