//
//  ZegoRoomMemberListRspModel.m
//  ZegoWhiteboardVideoDemo
//
//  Created by MartinNie on 2020/9/9.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoRoomMemberListRspModel.h"
#import <YYModel/YYModel.h>
@implementation ZegoRoomMemberInfoModel
- (instancetype)initWithUid:(NSInteger)uid userName:(NSString *)userName role:(ZegoUserRoleType)role
{
    if (self = [super init]) {
        _uid = uid;
        _userName = userName;
        _role = role;
        _camera = 1;
        _mic = 1;
        _canShare = (role == ZegoUserRoleTypeTeacher)?2:1;
        _isMyself = NO;
        _delta = 0;
        _loginTimer = 0;
        _joinLiveTime = 0;
        
    }
    return self;
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper
{
    return @{
        @"name"  : @"n",
        @"userName"  : @"nick_name",
        @"canShare":@"can_share",
        @"joinLiveTime":@"join_live_time",
        @"loginTimer":@"login_timer"
    };
}

@end

@implementation ZegoRoomMemberListRspModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper
{
    return @{
        @"attendeeList"  : @"attendee_list",
    
    };
}

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass
{
    return @{@"attendeeList" : [ZegoRoomMemberInfoModel class]};
}

@end

@implementation ZegoJoinLiveListRspModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper
{
    return @{
        @"joinLiveList"  : @"join_live_list",
    };
}

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass
{
    return @{@"joinLiveList" : [ZegoRoomMemberInfoModel class]};
}

@end

@implementation ZegoRoomMemberUpdateRspModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper
{
    return @{
        @"operatorUID"  : @"operator_uid",
        @"operatorName"  : @"operator_name",
    };
}

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass
{
    return @{@"users" : [ZegoRoomMemberInfoModel class]};
}
@end

@implementation ZegoRoomMessageRspModel

@end
