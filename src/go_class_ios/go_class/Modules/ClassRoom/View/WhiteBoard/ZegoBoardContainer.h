//
//  ZegoFileView.h
//  ZegoWhiteboardViewDemo
//
//  Created by zego on 2020/4/28.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoDocsViewDependency.h"

#ifdef IS_WHITE_BOARD_VIEW_SOURCE_CODE

#import "ZegoWhiteboardView.h"
#import "ZegoWhiteboardManager.h"

#else

#import <ZegoWhiteboardView/ZegoWhiteboardView.h>
#import <ZegoWhiteboardView/ZegoWhiteboardManager.h>

#endif


NS_ASSUME_NONNULL_BEGIN
//创建白板回调
typedef void(^ZegoCreateViewBlock)(ZegoWhiteboardViewError errorCode);

typedef void(^ZegoWhiteBoardTapBlock)(void);

@interface ZegoBoardContainer : UIView

@property (nonatomic, weak) id<ZegoWhiteboardViewDelegate> whiteboardViewUIDelegate;
@property (nonatomic, weak) id<ZegoDocsViewDelegate> docsViewUIDelegate;

@property (nonatomic, assign) ZegoWhiteboardID whiteboardID;
@property (nonatomic, strong) ZegoWhiteboardView *whiteboardView;
@property (nonatomic, copy, readonly) NSString *whiteBoardName;
@property (nonatomic, copy) ZegoWhiteBoardTapBlock onTapWhiteBoard;

//***仅在文件白板时有意义***
@property (nonatomic, strong) ZegoDocsView *docsView;
@property (nonatomic, strong, readonly) ZegoFileInfoModel *fileInfo;
@property (nonatomic, assign, readonly) BOOL isFile;
@property (nonatomic, assign, readonly) BOOL isExcel;
@property (nonatomic, assign, readonly) BOOL isDynamicPPT;
//仅为Excel文件白板时有意义
@property (nonatomic, assign) NSInteger sheetIndex;
@property (nonatomic, strong, readonly) NSString *currentSheetName;
//***

+ (instancetype)defaultBoardContainer;

- (void)buildDocWhiteBoardContainerWithFileInfo:(ZegoFileInfoModel *)fileInfo whiteBoardName:(NSString *)whiteBoardName sheetIndex:(int)sheetIndex complete:(ZegoCreateViewBlock)complete;

- (void)createWhiteboardViewWithUserName:(NSString *)userName block:(ZegoCreateViewBlock)block;

- (void)addWhiteboarView:(ZegoWhiteboardView *)whiteboardView complete:(ZegoCreateViewBlock)complete;

- (void)setupWhiteboardOperationMode:(ZegoWhiteboardOperationMode)mode;

- (void)nextPage;

- (void)prePage;

- (void)nextPageCompletionBlock:(ZegoDocsViewScrollCompleteBlock _Nullable)completionBlock;

- (void)prePageCompletionBlock:(ZegoDocsViewScrollCompleteBlock _Nullable)completionBlock;

- (void)nextPPTStepCompletionBlock:(ZegoDocsViewScrollCompleteBlock _Nullable)completionBlock;

- (void)prePPTStepCompletionBlock:(ZegoDocsViewScrollCompleteBlock _Nullable)completionBlock;

- (void)scrollToPage:(NSInteger)page pptStep:(NSInteger)step completionBlock:(ZegoDocsViewScrollCompleteBlock _Nullable)completionBlock;
@end

NS_ASSUME_NONNULL_END
