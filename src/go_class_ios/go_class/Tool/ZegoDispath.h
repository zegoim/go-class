//
//  ZegoDispath.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/9/24.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoDispath : NSObject

+ (instancetype)sharedInstance;

- (void)execute:(dispatch_block_t)block after:(NSTimeInterval)seconds;

@end

NS_ASSUME_NONNULL_END
