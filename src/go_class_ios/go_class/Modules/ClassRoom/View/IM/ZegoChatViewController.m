//
//  ZegoChatViewController.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/11/4.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoChatViewController.h"
#import "ZegoChatTextInputView.h"
#import "ZegoChatTable.h"
#import "ZegoUIConstant.h"
#import "ZegoChatModel.h"
#import "ZegoRoomMemberListRspModel.h"
#import "ZegoToast.h"
#import "ZegoLiveCenter.h"
#import <Masonry/Masonry.h>
#import "NSString+ZegoExtension.h"
@interface ZegoChatViewController ()<ZegoChatTextInputViewDelegate,ZegoChatTableDelegate>

@property (nonatomic,strong)ZegoChatTextInputView *textInputView;
@property (nonatomic,strong)ZegoChatTable *chatTable;
@property (nonatomic,strong)NSMutableArray *messageList;

@end

@implementation ZegoChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self addNomalMessage];
}

- (void)configUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor redColor];
    self.chatTable = [[ZegoChatTable alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.chatTable.delegate = self;
    [self.view addSubview:self.chatTable];
    [self.chatTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

//添加第一次进房默认消息
- (void)addNomalMessage {
    ZegoChatModel *model = [[ZegoChatModel alloc]init];
    model.senderType = ZegoChatMsgSenderTypeSystem;
    model.msgStatus = kZegoChatSendSuccess;
    
    ZegoMessageInfo *info = [[ZegoMessageInfo alloc]init];
    NSString *message = [NSString stringWithFormat:@"%@ %@",[NSString zego_localizedString:@"room_member_me"],[NSString zego_localizedString:@"room_im_join_class"]];
    info.message = message;
    model.messageInfo = info;
    
    [self.messageList addObject:model];
    [self.chatTable reloadData:self.messageList];
}

#pragma mark -Public
- (void)updateRoomMemberInfo:(ZegoRoomMemberInfoModel *)memberInfoModel {
    ZegoChatModel *model = [[ZegoChatModel alloc]init];
    model.senderType = ZegoChatMsgSenderTypeSystem;
    model.msgStatus = kZegoChatSendSuccess;
    
    ZegoMessageInfo *info = [[ZegoMessageInfo alloc]init];
    NSString *message = @"";
    if (memberInfoModel.delta == 1) {//加入课堂
        message = [NSString stringWithFormat:@"%@ %@",memberInfoModel.isMyself ? [NSString zego_localizedString:@""] :memberInfoModel.userName,[NSString zego_localizedString:@"login_join_class"]];
    } else if (memberInfoModel.delta == -1) {//离开课堂
        message = [NSString stringWithFormat:@"%@ %@",memberInfoModel.isMyself ? [NSString zego_localizedString:@""] :memberInfoModel.userName,[NSString zego_localizedString:@"room_leave_class"]];
    }
    info.message = message;
    model.messageInfo = info;
    
    [self.messageList addObject:model];
    [self.chatTable reloadData:self.messageList];
}

- (void)onReceiveMessage:(NSArray<ZegoMessageInfo *> *)messageList roomID:(NSString *)roomID {
    if ([roomID isEqualToString:self.roomID]) {
        if (messageList) {
            for (ZegoMessageInfo *info in messageList) {
                ZegoChatModel *model = [[ZegoChatModel alloc]init];
                model.senderType = kZegoChatSendSuccess;
                model.senderType = ZegoChatMsgSenderTypeOther;
                model.messageInfo = info;
                [self.messageList addObject:model];
            }
            [self.chatTable reloadData:self.messageList];
            [self.chatTable onScrollToBottom];
        }
    }
}

#pragma mark - ZegoChatTextInputViewDelegate
- (void)sendMsgButtonClick:(NSString *)msg {
    //发送消息
    ZegoChatModel *chatModel = [[ZegoChatModel alloc]init];
    chatModel.msgStatus = kZegoChatSending;
    chatModel.senderType = ZegoChatMsgSenderTypeSelf;
    
    //构建消息体
    ZegoMessageInfo *messageInfo = [[ZegoMessageInfo alloc]init];
    messageInfo.message = msg;
    
    ZegoUserInfo *userInfo = [[ZegoUserInfo alloc]init];
    userInfo.userName = self.currentUserModel.userName;
    userInfo.uid = [NSString stringWithFormat:@"%ld",self.currentUserModel.uid];
    messageInfo.fromUser = userInfo;
    
    chatModel.messageInfo = messageInfo;
    [self.messageList addObject:chatModel];
    [self.chatTable reloadData:self.messageList];
    
    __weak typeof(self) weakSelf = self;
    [ZegoLiveCenter sendMessage:msg roomID:self.roomID callback:^(int errorCode, NSString * _Nonnull roomId, NSString * _Nonnull messageId) {
        if (errorCode == 0) {
            chatModel.msgStatus = kZegoChatSendSuccess;
            chatModel.messageInfo.messageId = messageId;
        } else {
            chatModel.msgStatus = kZegoChatSendFailed;
        }
        [weakSelf.chatTable reloadData:weakSelf.messageList];
        [weakSelf.chatTable onScrollToBottom];
    }];

}

- (void)exceedTextNumber:(NSInteger)length {
    [ZegoToast showToastToTopWIndow:[NSString zego_localizedString:@"room_im_max_characters"]];
}

#pragma marl - ZegoChatTableDelegate
- (void)chatTableClickTextView {
    [self.textInputView beginEdit];
}

#pragma mark - Getter
- (ZegoChatTextInputView *)textInputView {
    if (!_textInputView) {
        _textInputView = [[ZegoChatTextInputView alloc]init];
        _textInputView.delegate = self;
    }
    return _textInputView;
}

- (NSMutableArray *)messageList {
    if (!_messageList) {
        _messageList = [NSMutableArray array];
    }
    return _messageList;
}

@end
