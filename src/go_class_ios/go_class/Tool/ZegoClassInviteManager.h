//
//  ZegoClassInviteManager.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/11.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^shareLinksCompletion)(int errorCode, NSString *link);
@interface ZegoClassInviteManager : NSObject
+ (void)pastInviteContentWithUserName:(NSString *)userName roomID:(NSString *)roomID isEnvAbroad:(BOOL)isAbroad;
@end

NS_ASSUME_NONNULL_END
