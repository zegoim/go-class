//
//  ZegoLoginService.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/9/11.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoLoginService.h"
#import "ZegoToast.h"
#import "ZegoErrorMap.h"

@interface ZegoLoginService ()

@property (nonatomic, copy) ZegoLoginSuccessBlock success;

@property (nonatomic, copy) ZegoLoginFailBlock failure;

@end

@implementation ZegoLoginService

- (void)loginFailed {
    ZegoResponseModel *model = [[ZegoResponseModel alloc] init];
    model.code = -1001;
    model.message = [ZegoErrorMap messageWithCode:model.code];
    if (self.failure) {
        self.failure(model);
        self.failure = nil;
    }
}

- (void)serverloginRoomWithRoomID:(NSString *)roomID userID:(NSInteger)userID userName:(NSString *)userName userRole:(ZegoUserRoleType)userRole classType:(ZegoClassPatternType)classType success:(ZegoLoginSuccessBlock)success failure:(ZegoLoginFailBlock)failure {
    self.success = success;
    self.failure = failure;
    @weakify(self);
    [ZegoNetworkManager requestWithCommand:[ZegoClassCommand loginRoomCommandWithUserID:userID roomID:roomID nickName:userName role:userRole classType:classType isCameraOn:NO isMicOn:NO] success:^(ZegoResponseModel *response) {
        @strongify(self);
        [self liveRoomloginRoomWithRoomID:roomID userID:userID userName:userName userRole: userRole];
    } failure:^(ZegoResponseModel *response) {
        if (self.failure) {
            self.failure(response);
            self.failure = nil;
        }
    }];
}

- (void)liveRoomloginRoomWithRoomID:(NSString *)roomID userID:(NSInteger)userID userName:(NSString *)userName userRole:(ZegoUserRoleType)userRole {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    ZegoRoomMemberInfoModel *user = [[ZegoRoomMemberInfoModel alloc] initWithUid:userID userName:userName role:userRole];
    [self performSelector:@selector(loginFailed) withObject:self afterDelay:10];
    @weakify(self);
    [ZegoLiveCenter loginRoomWithRoomId:roomID userId:@(userID).stringValue userName:userName complete:^(int errorCode) {
        @strongify(self);
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        if (errorCode == 0) {
            if (self.success) {
                self.success(user, roomID);
                self.success = nil;
            }
        } else {
            ZegoResponseModel *model = [[ZegoResponseModel alloc] init];
            model.code = errorCode;
            model.message = [ZegoErrorMap messageWithCode:model.code];
            if (self.failure) {
                self.failure(model);
                self.failure = nil;
            }
        }
    }];
}

+ (NSInteger)randomUserID {
    NSString *uid = [NSString stringWithFormat:@"%ld", (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000)];
    return uid.integerValue;
}
@end
