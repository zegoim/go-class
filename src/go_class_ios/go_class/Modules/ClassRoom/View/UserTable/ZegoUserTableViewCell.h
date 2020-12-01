//
//  ZegoUserTableViewCell.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/5/29.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoRoomMemberListRspModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface ZegoUserTableViewCell : UITableViewCell
@property (nonatomic, strong) ZegoRoomMemberInfoModel *model;
//使用权限 点击事件block
@property (nonatomic, copy) void(^didClickAuthorityStatusBlock)(ZegoRoomMemberInfoModel *model);
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelToRight;

//是否隐藏 使用权限状态视图
- (void)hiddenStatusMark:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_END
