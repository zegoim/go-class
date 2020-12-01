//
//  ZegoLiveCenterModel.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/5/29.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoLiveCenterModel.h"

@implementation ZegoStreamWrapper

- (instancetype)initWithiStream:(ZegoLiveStream *)stream {
    if (self = [super init]) {
        _stream = stream;
        _streamStatusType = ZegoStreamStatusTypeNotFound;

    }
    return self;
}

- (void)setStream:(ZegoLiveStream *)stream
{
    _stream = stream;
    _streamStatusType = ZegoStreamStatusTypeIdle;
}

@end

@implementation ZegoLiveCenterModel

@end

@implementation ZegoLiveReliableMessage

+ (instancetype)reliableMessage:(NSString *)type latestSeq:(unsigned int)latestSeq content:(NSString *)content fromUserId:(NSString *)fromUserId fromUserName:(NSString *)fromUserName sendTime:(unsigned long long)sendTime{
    ZegoLiveReliableMessage *message = [[ZegoLiveReliableMessage alloc] init];
    message.type = type;
    message.latestSeq = latestSeq;
    message.content = content;
    message.fromUserId = fromUserId;
    message.fromUserName = fromUserName;
    message.sendTime = sendTime;
    return message;
}

@end

@implementation ZegoLiveStream

+ (instancetype)streamWithUserID:(NSString *)userID userName:(NSString *)userName streamID:(NSString *)streamID extraInfo:(NSString *)extraInfo streamNID:(int)streamNID {
    ZegoLiveStream *stream = [[ZegoLiveStream alloc] init];
    stream.userID = userID;
    stream.userName = userName;
    stream.streamID = streamID;
    stream.extraInfo = extraInfo;
    stream.streamNID = streamNID;
    return stream;
}


@end
