//
//  StreamTableView.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/5/28.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoLiveCenterModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZegoStreamTableView : UITableView
@property (nonatomic, strong) ZegoRoomMemberInfoModel *currentModel; //当前用户模型
@property (nonatomic, copy) NSString *publishStreamId;  //推流id
@property (nonatomic, strong) ZegoRoomMemberInfoModel *teacherModel;      //是否有老师
//设置列表数据源
- (void)setupStreamDataSources:(NSArray <ZegoStreamWrapper *> *)streamDataSource;

//新增流
- (void)addStream:(ZegoStreamWrapper *)wrapper;

//删除流 （清除UI，并停止拉流）
- (void)removeStream:(ZegoStreamWrapper *)wrapper;

// 执行推拉流后更新流状态
- (void)updateStream:(ZegoStreamWrapper *)streamWrapper;

// 获取列表流信息
- (ZegoStreamWrapper *)getStreamWrapper:(NSString *)streamId;

 @end


NS_ASSUME_NONNULL_END
