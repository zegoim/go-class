//
//  ZegoRoomMemberListRspModel.h
//  ZegoWhiteboardVideoDemo
//
//  Created by MartinNie on 2020/9/9.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//授权类型
typedef NS_ENUM(NSUInteger, ZegoUserAuthorityStatusType) {
    ZegoUserAuthorityStatusTypeCamera,
    ZegoUserAuthorityStatusTypeMic,
    ZegoUserAuthorityStatusTypeFileShare,
    ZegoUserAuthorityStatusTypeOther,
};

//用户角色类型
typedef NS_ENUM(NSUInteger, ZegoUserRoleType) {
    ZegoUserRoleTypeOther = 0,
    ZegoUserRoleTypeTeacher = 1,
    ZegoUserRoleTypeStudent = 2,
};

//课堂类型
typedef NS_ENUM(NSUInteger, ZegoClassPatternType) {
    ZegoClassPatternTypeSmall = 1,
    ZegoClassPatternTypeBig = 2
};

// 房间业务消息类型
typedef NS_ENUM(NSUInteger, ZegoClassBusinessType) {
    ZegoClassBusinessTypeRoomStatusChange = 101,        // 房间默认信息变更
    ZegoClassBusinessTypeRoomMemberStatusChange = 102,  // 房间成员状态变更 （房间成员权限被修改时触发）
    ZegoClassBusinessTypeRoomMemberUpdate = 103,        // 房间成员更新 （成员进出房间时触发）
    ZegoClassBusinessTypeJoinLiveMemberUpdate = 104,    // 房间内连麦成员变更 （成员上下麦时触发）
    ZegoClassBusinessTypeClassOver = 105,               // 结束课程 （老师结束课堂）
    ZegoClassBusinessTypeStartShareFile = 106,          // 成员开始共享文件
    ZegoClassBusinessTypeStopShareFile = 107,           // 成员共享权限被收回
};

@interface ZegoRoomMemberInfoModel : NSObject
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) ZegoUserRoleType role;//用户角色，1：老师，2：学生
@property (nonatomic, assign) NSInteger camera;//摄像头状态： 1：关闭  2：打开
@property (nonatomic, assign) NSInteger mic; //麦克风状态： 1：关闭  2：打开
@property (nonatomic, assign) NSInteger canShare;//是否可以分享 1：关闭  2：打开
@property (nonatomic, assign) NSInteger delta;//删除或增加该用户 1：增加 -1：删除
@property (nonatomic, assign) BOOL isMyself;//是否是当前登录用户
@property (nonatomic, assign) NSTimeInterval joinLiveTime;      //加入连麦时间
@property (nonatomic, assign) NSTimeInterval loginTimer;        //进入房间时间

- (instancetype)initWithUid:(NSInteger)uid userName:(NSString *)userName role:(ZegoUserRoleType)role;
@end

@interface ZegoRoomMemberListRspModel : NSObject
@property (nonatomic, assign) NSInteger seq;
@property (nonatomic, assign) NSInteger roomID;
@property (nonatomic, strong) NSArray <ZegoRoomMemberInfoModel *>*attendeeList;
@end

@interface ZegoJoinLiveListRspModel : NSObject
@property (nonatomic, assign) NSInteger seq;
@property (nonatomic, assign) NSInteger roomID;
@property (nonatomic, strong) NSArray <ZegoRoomMemberInfoModel *>*joinLiveList;
@end

@interface ZegoRoomMessageRspModel : NSObject
@property (nonatomic, assign) NSInteger cmd;    //业务id
@property (nonatomic, strong) NSDictionary *data;
@end

@interface ZegoRoomMemberUpdateRspModel : NSObject
@property (nonatomic, assign) NSInteger type;           //1.role 2:摄像头状态 3:麦克风状态 4.共享权限
@property (nonatomic, assign) NSInteger operatorUID;    //远端操作者userID
@property (nonatomic, copy) NSString *operatorName;     //远端操作者用户名
@property (nonatomic, strong) NSArray <ZegoRoomMemberInfoModel *>*users;
@end


NS_ASSUME_NONNULL_END
