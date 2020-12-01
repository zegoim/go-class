//
//  ZegoClassRoomCoverView.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/8.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoClassRoomCoverView : UIView

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *exitButton;

- (instancetype)initWithTitle:(NSString *)title exitButtonTapped:(void (^)(void))exitAction;

@end

NS_ASSUME_NONNULL_END
