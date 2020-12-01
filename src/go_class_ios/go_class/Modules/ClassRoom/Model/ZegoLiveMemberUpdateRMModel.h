//
//  ZegoLiveMemberUpdateRMModel.h
//  ZegoWhiteboardVideoDemo
//
//  Created by MartinNie on 2020/9/9.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// 业务消息：房间连麦人员变更数据模型
@interface ZegoLiveMemberUpdateRMModel : NSObject
@property (nonatomic, assign) NSInteger seq;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger delta;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, copy) NSString *nick_name;
@end

NS_ASSUME_NONNULL_END
