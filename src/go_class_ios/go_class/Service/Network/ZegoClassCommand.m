//
//  ZegoClassCommand.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/9/8.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoClassCommand.h"

@implementation ZegoClassCommand
+ (instancetype)loginRoomCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID nickName:(NSString *)nickName role:(NSInteger)role classType:(NSInteger)classType isCameraOn:(BOOL)isCameraOn isMicOn:(BOOL)isMicOn {
    ZegoClassCommand *cmd = [ZegoClassCommand new];
    cmd.path = @"/edu_room/login_room";
    cmd.paramDic = [NSMutableDictionary dictionaryWithDictionary:@{
        @"uid": @(userID),
        @"room_id": roomID,
        @"nick_name": nickName,
        @"role": @(role),
        @"room_type":@(classType),
        @"camera": @(isCameraOn ? 2 : 1),
        @"mic": @(isMicOn ? 2 : 1),
    }];
    return cmd;
}

+ (instancetype)getAttendeeListCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID classType:(NSInteger)classType {
    ZegoClassCommand *cmd = [ZegoClassCommand new];
    cmd.path = @"/edu_room/get_attendee_list";
    cmd.paramDic = [NSMutableDictionary dictionaryWithDictionary:@{
        @"uid": @(userID),
        @"room_id": roomID,
        @"room_type":@(classType),
    }];
    return cmd;
}

+ (instancetype)getJoinLiveListCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID classType:(NSInteger)classType {
    ZegoClassCommand *cmd = [ZegoClassCommand new];
    cmd.path = @"/edu_room/get_join_live_list";
    cmd.paramDic = [NSMutableDictionary dictionaryWithDictionary:@{
        @"uid": @(userID),
        @"room_id": roomID,
        @"room_type":@(classType),
    }];
    return cmd;
}

+ (instancetype)getUserInfoCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID targetUserID:(NSString *)targetUserID classType:(NSInteger)classType{
    ZegoClassCommand *cmd = [ZegoClassCommand new];
    cmd.path = @"/edu_room/get_user_info";
    cmd.paramDic = [NSMutableDictionary dictionaryWithDictionary:@{
        @"uid": @(userID),
        @"room_id": roomID,
        @"target_uid": @(targetUserID.integerValue),
        @"room_type":@(classType),
    }];
    return cmd;
}

+ (instancetype)setUserInfoCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID targetUserID:(NSInteger)targetUserID classType:(NSInteger)classType isCameraOn:(NSInteger)isCameraOn isMicOn:(NSInteger)isMicOn canShare:(NSInteger)canShare {
    ZegoClassCommand *cmd = [ZegoClassCommand new];
    cmd.path = @"/edu_room/set_user_info";
    cmd.paramDic = [NSMutableDictionary dictionaryWithDictionary:@{
        @"uid": @(userID),
        @"room_id": roomID,
        @"target_uid": @(targetUserID),
        @"room_type":@(classType),
        @"camera": @(isCameraOn ),
        @"mic": @(isMicOn ),
        @"can_share": @(canShare),
    }];
    return cmd;
}

+ (instancetype)heartBeatCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID classType:(NSInteger)classType{
    ZegoClassCommand *cmd = [ZegoClassCommand new];
    cmd.path = @"/edu_room/heartbeat";
    cmd.paramDic = [NSMutableDictionary dictionaryWithDictionary:@{
        @"uid": @(userID),
        @"room_id": roomID,
        @"room_type":@(classType),
    }];
    return cmd;
}

+ (instancetype)startShareCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID {
    ZegoClassCommand *cmd = [ZegoClassCommand new];
    cmd.path = @"/edu_room/start_share";
    cmd.paramDic = [NSMutableDictionary dictionaryWithDictionary:@{
        @"uid": @(userID),
        @"room_id": roomID,
    }];
    return cmd;
}

+ (instancetype)stopShareCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID targetUserID:(NSString *)targetUserID {
    ZegoClassCommand *cmd = [ZegoClassCommand new];
    cmd.path = @"/edu_room/stop_share";
    cmd.paramDic = [NSMutableDictionary dictionaryWithDictionary:@{
        @"uid": @(userID),
        @"room_id": roomID,
        @"target_uid": @(targetUserID.integerValue),
    }];
    return cmd;
}

+ (instancetype)leaveRoomCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID classType:(NSInteger)classType {
    ZegoClassCommand *cmd = [ZegoClassCommand new];
    cmd.path = @"/edu_room/leave_room";
    cmd.paramDic = [NSMutableDictionary dictionaryWithDictionary:@{
        @"uid": @(userID),
        @"room_id": roomID,
        @"room_type":@(classType),
    }];
    return cmd;
}

+ (instancetype)endTeachingCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID classType:(NSInteger)classType {
    ZegoClassCommand *cmd = [ZegoClassCommand new];
    cmd.path = @"/edu_room/end_teaching";
    cmd.paramDic = [NSMutableDictionary dictionaryWithDictionary:@{
        @"uid": @(userID),
        @"room_id": roomID,
        @"room_type":@(classType),
    }];
    return cmd;
}




@end
