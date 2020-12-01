//
//  ZegoChatModel.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/11/5.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZegoLiveCenterParam.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZegoChatModelStatus) {
    kZegoChatSendSuccess = 0,//发送成功
    kZegoChatSendFailed = 1,//发送失败
    kZegoChatSending = 2,//发送中
};

typedef NS_ENUM(NSUInteger, ZegoChatMsgSenderType) {
    ZegoChatMsgSenderTypeSystem = 0,//系统消息
    ZegoChatMsgSenderTypeSelf = 1,//我的消息
    ZegoChatMsgSenderTypeOther = 2,//其他人的消息
};

@interface ZegoUserInfo : NSObject

@property (nonatomic,strong)NSString *userName;
@property (nonatomic,strong)NSString *uid;

@end

@interface ZegoMessageInfo : NSObject

@property (nonatomic,strong)NSString *message;
@property (nonatomic,strong)NSString *messageId;
@property (nonatomic,assign)ZegoRoomMessageType messageType;//消息类型
@property (nonatomic,assign)ZegoRoomMessagePriority priority;//优先级
@property (nonatomic,assign)ZegoRoomMessageCategory category;//消息类别
@property (nonatomic,strong)ZegoUserInfo *fromUser;//用户信息

@end

@interface ZegoChatModel : NSObject

@property (nonatomic, strong)ZegoMessageInfo *messageInfo;//消息信息
@property (nonatomic, assign)CGFloat contentHeight;//消息计算得出高度
@property (nonatomic, assign)ZegoChatModelStatus msgStatus;//消息状态
@property (nonatomic, assign)ZegoChatMsgSenderType senderType;//消息发送者类型

@end

NS_ASSUME_NONNULL_END
