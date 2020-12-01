//
//  ZegoWhiteBoardListCell.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/15.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoWhiteBoardListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (copy, nonatomic) void (^onTapCloseButton)(void);

@end

NS_ASSUME_NONNULL_END
