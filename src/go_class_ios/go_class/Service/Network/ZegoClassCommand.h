//
//  ZegoClassCommand.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/9/8.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoGeneralCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZegoClassCommand : ZegoGeneralCommand
/// 登录房间的请求
/// @param userID 本机用户ID
/// @param roomID roomID
/// @param nickName nickName
/// @param role 角色：1:老师     2:学生
/// @param isCameraOn 用户摄像头状态
/// @param isMicOn 用户麦克风状态
+ (instancetype)loginRoomCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID nickName:(NSString *)nickName role:(NSInteger)role classType:(NSInteger)classType isCameraOn:(BOOL)isCameraOn isMicOn:(BOOL)isMicOn;


/// 拉取成员列表
/// @param userID 本机用户ID
/// @param roomID roomID
+ (instancetype)getAttendeeListCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID classType:(NSInteger)classType;


/// 拉取连麦成员列表
/// @param userID 本机用户ID
/// @param roomID roomID
+ (instancetype)getJoinLiveListCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID classType:(NSInteger)classType;


/// 获取用户信息
/// @param userID 本机用户ID
/// @param roomID roomID
/// @param targetUserID 目标用户ID
+ (instancetype)getUserInfoCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID targetUserID:(NSString *)targetUserID classType:(NSInteger)classType;


/// 设置用户信息
/// @param userID 本机用户ID
/// @param roomID roomID
/// @param targetUserID 目标用户ID
/// @param isCameraOn isCameraOn
/// @param isMicOn isMicOn
/// @param canShare canShare
+ (instancetype)setUserInfoCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID targetUserID:(NSInteger)targetUserID  classType:(NSInteger)classType isCameraOn:(NSInteger)isCameraOn isMicOn:(NSInteger)isMicOn canShare:(NSInteger)canShare;


/// 心跳
/// @param userID 本机用户ID
/// @param roomID roomID
+ (instancetype)heartBeatCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID classType:(NSInteger)classType;


/// 开始共享
/// @param userID 本机用户ID
/// @param roomID roomID
+ (instancetype)startShareCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID;


/// 停止共享
/// @param userID 本机用户ID
/// @param roomID roomID
/// @param targetUserID targetUserID
+ (instancetype)stopShareCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID targetUserID:(NSString *)targetUserID;


/// 离开房间
/// @param userID 本机用户ID
/// @param roomID roomID
+ (instancetype)leaveRoomCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID classType:(NSInteger)classType;


/// 停止教学
/// @param userID 本机用户ID
/// @param roomID roomID
+ (instancetype)endTeachingCommandWithUserID:(NSInteger)userID roomID:(NSString *)roomID classType:(NSInteger)classType;

@end

NS_ASSUME_NONNULL_END
