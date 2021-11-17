//
//  ZegoClassViewController.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/1.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZegoLiveReliableMessage;
@class ZegoLiveStream;
@class ZegoRoomMemberInfoModel;

@protocol ZegoClassViewControllerProtocol <NSObject>

- (void)classVCDidDismiss;

@end

@interface ZegoClassViewController : UIViewController

@property (nonatomic, weak) id<ZegoClassViewControllerProtocol> delegate;

/// 根据参数初始化课堂 VC
/// @param roomID 房间 ID
/// @param user 当前用户信息
/// @param classType 大班课 / 小班课
/// @param reliableMessage 消息对象
/// @param streamList 当前虚拟房间内的所有流对象
/// @param isEnvAbroad 环境:中国内地 / 海外
- (instancetype)initWithRoomID:(NSString *)roomID user:(ZegoRoomMemberInfoModel *)user classType:(NSInteger)classType streamList: (NSArray<ZegoLiveStream *> * _Nonnull) streamList isEnvAbroad:(BOOL)isEnvAbroad ;

@end

NS_ASSUME_NONNULL_END
