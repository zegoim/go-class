//
//  ZegoDispath.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/9/24.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoDispath.h"

@interface ZegoDispath ()
@property(assign, nonatomic) BOOL isRunning;
@property(copy, nonatomic) dispatch_block_t block;
@end

@implementation ZegoDispath
static ZegoDispath *sharedInstance = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZegoDispath alloc] init];
    });
    return sharedInstance;
}

- (void)execute:(dispatch_block_t)block after:(NSTimeInterval)seconds {
    NSLog(@"@##开始任务");
    if (self.isRunning) {
        return;
    }
    self.isRunning = YES;
    self.block = block;

    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(act) userInfo:nil repeats:NO];
}

- (void)act {
    if (self.block) {
        self.block();
    }
    self.isRunning = NO;
    NSLog(@"@##结束执行");
}
@end
