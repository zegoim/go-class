//
//  ZegoViewCaptor.h
//  ZegoWhiteboardVideoDemo
//
//  Created by Vic on 2020/11/24.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoViewCaptor : NSObject

+ (instancetype)sharedInstance;

- (void)writeToAlbumWithView:(UIView *)view complete:(void(^)(BOOL success, BOOL alert))complete;
- (void)writeToAlbumWithPath:(NSString *)path complete:(void(^)(BOOL success, BOOL alert))complete;

@end

NS_ASSUME_NONNULL_END
