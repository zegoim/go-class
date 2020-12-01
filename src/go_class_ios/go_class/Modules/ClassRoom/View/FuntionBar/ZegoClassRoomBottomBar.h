//
//  ZegoClassRoomBottomBar.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/2.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoClassRoomBottomBarCell.h"
#import "ZegoRoomMemberListRspModel.h"
NS_ASSUME_NONNULL_BEGIN

@class ZegoClassRoomBottomBar;
@protocol ZegoClassRoomBottomBarDelegate <NSObject>

- (void)bottomBarCell:(ZegoClassRoomBottomBarCell *)functionCell didSelectCellModel:(ZegoClassRoomBottomCellModel *)model;

@optional
- (void)bottomBarDidTapBarArea;

@end

@interface ZegoClassRoomBottomBar : UIView
@property (nonatomic, strong) ZegoRoomMemberInfoModel *currentModel;
@property (weak, nonatomic) id<ZegoClassRoomBottomBarDelegate> delegate;

- (void)reloadData;
- (void)refreshUserCount:(NSUInteger)count;
- (BOOL)isCamareOpen;
- (BOOL)isMicOpen;

//items 内的数据必须对应ZegoClassRoomBottomCellType
- (void)hiddenItems:(NSArray *)items;

// 外部控制本地设备开关，react表示是否触发联动，NO只更改UI 样式，YES 触发整个响应链
- (void)setupCameraOpen:(BOOL)open react:(BOOL)react;
- (void)setupMicOpen:(BOOL)open react:(BOOL)react;
@end

NS_ASSUME_NONNULL_END
