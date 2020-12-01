//
//  ZegoLoginService.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/9/11.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZegoLiveCenter.h"
#import "ZegoNetworkManager.h"
#import "ZegoClassCommand.h"
#import "ZegoRoomMemberListRspModel.h"
typedef void(^ZegoLoginSuccessBlock)(ZegoRoomMemberInfoModel * _Nonnull userModel,NSString * _Nonnull roomID, ZegoLiveReliableMessage * _Nonnull reliableMessage);

typedef void(^ZegoLoginFailBlock)(ZegoResponseModel * _Nonnull response);

NS_ASSUME_NONNULL_BEGIN

@interface ZegoLoginService : NSObject

- (void)serverloginRoomWithRoomID:(NSString *)roomID userID:(NSInteger)userID userName:(NSString *)userName userRole:(ZegoUserRoleType)userRole classType:(ZegoClassPatternType)classType success:(ZegoLoginSuccessBlock)success failure:(ZegoLoginFailBlock)failure;

+ (NSInteger)randomUserID;
@end

NS_ASSUME_NONNULL_END
