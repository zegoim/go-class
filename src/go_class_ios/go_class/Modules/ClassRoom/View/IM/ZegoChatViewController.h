//
//  ZegoChatViewController.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/11/4.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZegoRoomMemberInfoModel;
@class ZegoMessageInfo;

@interface ZegoChatViewController : UIViewController

@property (nonatomic,copy)NSString *roomID;//房间ID

@property (nonatomic, strong) ZegoRoomMemberInfoModel *currentUserModel;//当前登录用户模型

- (void)updateRoomMemberInfo:(ZegoRoomMemberInfoModel *)memberInfoModel;

- (void)onReceiveMessage:(NSArray <ZegoMessageInfo *>*)messageList roomID:(NSString *)roomID;

@end

NS_ASSUME_NONNULL_END
