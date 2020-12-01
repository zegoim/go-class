//
//  ZegoChatTable.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/11/4.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZegoChatTableDelegate <NSObject>

- (void)chatTableClickTextView;

@end

@interface ZegoChatTable : UIView

@property (nonatomic,weak)id<ZegoChatTableDelegate>delegate;

- (void)reloadData:(NSArray *)dataArray;

//@property (nonatomic, strong) ZegoRoomMemberInfoModel *currentUserModel;//当前登录用户模型

- (void)onScrollToBottom;

@end

NS_ASSUME_NONNULL_END
