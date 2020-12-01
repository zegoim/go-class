//
//  ZegoClassRoomSharePopView.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/3.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoClassRoomSharePopView : UIView
@property (copy, nonatomic) void (^onTapAction)(NSUInteger type);
@end

NS_ASSUME_NONNULL_END
