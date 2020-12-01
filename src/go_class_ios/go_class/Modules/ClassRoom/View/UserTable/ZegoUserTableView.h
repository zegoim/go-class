//
//  ZegoUserTableView.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/5/29.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoLiveCenterModel.h"
#import "ZegoRoomMemberListRspModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZegoUserTableView : UITableView
@property (nonatomic, assign) BOOL showUserStatusOperationButton;
@property (nonatomic, strong) NSMutableArray <ZegoRoomMemberInfoModel *> *roomMemberArray;
//使用权限 点击事件block
@property (nonatomic, copy) void(^didClickAuthorityStatusBlock)(ZegoRoomMemberInfoModel *model);


@end

NS_ASSUME_NONNULL_END
