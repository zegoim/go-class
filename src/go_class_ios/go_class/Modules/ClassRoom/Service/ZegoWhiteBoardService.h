//
//  ZegoWhiteBoardService.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/9/17.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoLiveCenter.h"
#ifdef IS_USE_LIVEROOM
#import <ZegoLiveRoom/ZegoLiveRoomApi.h>
#else
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#endif

#import "ZegoBoardContainer.h"
#import "ZegoWhiteBoardViewContainerModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZegoWhiteBoardServiceDelegate <NSObject>
- (void)onWhiteboardContainerChanged:(ZegoBoardContainer * __nullable)container;
- (void)onChangedOrderedBoardContainerModels:(NSArray<ZegoWhiteBoardViewContainerModel *> *)orderedBoardModelContainers;
@optional
- (void)onTapWhiteBoard;
@end

@interface ZegoWhiteBoardService : NSObject

@property (nonatomic, strong) ZegoRoomMemberInfoModel *currentUserModel;//当前登录用户模型

@property (nonatomic, strong) UIView *whiteBoardContentView;
@property (nonatomic, strong, readonly) ZegoBoardContainer *currentContainer;       //当前选中BoardContainer;
@property (nonatomic, strong, readonly) NSArray<ZegoWhiteBoardViewContainerModel *> *orderedBoardModelContainers;   
@property (nonatomic, copy) NSString *roomId;

- (instancetype)initWithUser:(ZegoRoomMemberInfoModel *)user roomId:(NSString *)roomId delegate:(id<ZegoWhiteBoardServiceDelegate>)delegate;
- (void)reset;

- (void)createContainersWithWhiteBoardList:(NSArray<ZegoWhiteboardView *> *)whiteBoardList;

- (void)addWhiteboard;
- (void)addWhiteBoardWithWhiteBoardView:(ZegoWhiteboardView *)whiteboardView;
- (void)addDocBoardWithInfo:(ZegoFileInfoModel *)fileInfo whiteBoardName:(NSString *)whiteBoardName sheetIndex:(int)sheetIndex createSheets:(BOOL)ifCreateSheets complete:(ZegoCreateViewBlock)complete;

- (void)changeWhiteBoardWithID:(ZegoWhiteboardID)whiteboardID;
- (void)changeWhiteBoardWithBoardContainer:(ZegoBoardContainer * _Nullable)boardContainer;

- (void)removeWhiteBoardWithWhiteBoardViewContainerModel:(ZegoWhiteBoardViewContainerModel *)whiteBoardViewContainerModel;
- (void)removeWhiteBoardWithWhiteboardID:(ZegoWhiteboardID)whiteboardID syncMessage:(BOOL)shouldSync;

- (void)zegoFileListViewDidSelectFile:(ZegoFileInfoModel *)model;
- (void)zegoExcelSheetListDidSelectSheet:(NSString *)sheetName index:(int)index;
- (void)animateDynamicPPTWithAnimationInfo:(NSString *)animationInfo;
- (void)stopDynamicPPTAnimation;

- (void)enableCurrentContainer:(BOOL)isEnable;
- (void)deleteSelectedGraphics;

@end

NS_ASSUME_NONNULL_END
