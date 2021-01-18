//
//  ZegoWhiteBoardService.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/9/17.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoWhiteBoardService.h"
#import "ZegoToast.h"
#import "ZegoHUD.h"
#import "ZegoAlertView.h"
#import "ZegoViewAnimator.h"
#import "ZegoUIConstant.h"

#import "ZegoWhiteBoardViewContainerModel.h"
#import "ZegoBoardContainer.h"
#import "NSString+ZegoExtension.h"
typedef void(^ZegoCompleteBlock)(NSInteger errorCode);

@interface ZegoWhiteBoardService ()

@property (nonatomic, assign) id<ZegoWhiteBoardServiceDelegate> delegate;

@property (nonatomic, assign) BOOL currentContainerEnable;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong, readwrite) ZegoBoardContainer *currentContainer;       //当前选中BoardContainer;
@property (nonatomic, strong) NSMutableArray<ZegoBoardContainer *> *boardContainers;        //BoardContainer数组
//排序，整理好的ZegoWhiteBoardViewContainerModel数组，供显示白板列表使用
@property (nonatomic, strong, readwrite) NSArray<ZegoWhiteBoardViewContainerModel *> *orderedBoardModelContainers;        //BoardContainerModel数组
@property (nonatomic, assign) ZegoWhiteboardID changeWhiteBoardID; //标记获取白板列表之前的当前白板id，使用后清除

@end

@implementation ZegoWhiteBoardService

- (instancetype)initWithUser:(ZegoRoomMemberInfoModel *)user roomId:(NSString *)roomId delegate:(id<ZegoWhiteBoardServiceDelegate>)delegate {
    if (self = [super init]) {
        self.currentUserModel = user;
        self.currentContainerEnable = YES;
        self.delegate = delegate;
        self.roomId = roomId;
    }
    return  self;
}

- (void)reset {
    for (ZegoBoardContainer *view in self.boardContainers) {
        [view.docsView unloadFile];
        [view removeFromSuperview];
    }
    [self.boardContainers removeAllObjects];
    self.orderedBoardModelContainers = nil;
    [self updateOrderedBoardContainers];
    [self changeWhiteBoardWithBoardContainer:nil];
}

- (void)createContainersWithWhiteBoardList:(NSArray<ZegoWhiteboardView *> *)whiteBoardList {
    NSArray<ZegoWhiteboardView *> *orderedWhiteBoardList = [whiteBoardList sortedArrayUsingComparator:^NSComparisonResult(ZegoWhiteboardView * _Nonnull obj1, ZegoWhiteboardView * _Nonnull obj2) {
        return obj1.whiteboardModel.createTime > obj2.whiteboardModel.createTime;
    }];
    
    for (ZegoWhiteboardView *whiteBoardView in orderedWhiteBoardList) {
        [self addWhiteBoardWithWhiteBoardView:whiteBoardView ];
    }
    [self changeWhiteBoardWithID:self.changeWhiteBoardID];
    self.changeWhiteBoardID = 0;
}

- (void)addWhiteboard {
    NSMutableArray<ZegoBoardContainer *> *whiteBoardArray = [NSMutableArray array];
    [self.boardContainers enumerateObjectsUsingBlock:^(ZegoBoardContainer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.docsView && obj.whiteboardView) {
            [whiteBoardArray addObject:obj];
        }
    }];
    if(whiteBoardArray.count < 10) {
        ZegoBoardContainer *container = [self getOneBoardContainer];
        [self addBoardContainerView:container];
        @weakify(self);
        [container createWhiteboardViewWithUserName:self.currentUserModel.userName block:^(ZegoWhiteboardViewError errorCode) {
            @strongify(self);
            if (errorCode == 0) {
                [self updateOrderedBoardContainers];
                [self changeWhiteBoardWithBoardContainer:container];
            } else {
                [self removeLocalWhiteBoardContainer:container];
                [self showNetworkError];
            }
        }];
    } else {
        [ZegoToast showText:[NSString zego_localizedString:@"wb_tip_exceed_max_number_wb"]];
        [self.activityIndicator stopAnimating];
    }
}

- (void)addWhiteBoardWithWhiteBoardView:(ZegoWhiteboardView *)whiteboardView {
    ZegoBoardContainer *container = [self getOneBoardContainer];
    ZegoBoardContainer *strongContainer = container;
    [self addBoardContainerView:strongContainer];
    @weakify(self);
    self.currentContainer = strongContainer;
    [container addWhiteboarView:whiteboardView complete:^(ZegoWhiteboardViewError errorCode) {
        @strongify(self);
        if(errorCode == 0) {
            [self updateOrderedBoardContainers];
        } else {
          [self showNetworkError];
        }
    }];

}

//点击文件列表创建文件
- (void)addDocBoardWithInfo:(ZegoFileInfoModel *)fileInfo whiteBoardName:(NSString *)whiteBoardName sheetIndex:(int)sheetIndex createSheets:(BOOL)ifCreateSheets complete:(ZegoCreateViewBlock)complete {
    if (self.activityIndicator.animating) {
        [ZegoToast showText:@"加载中，请耐心等待！"];
        return;
    }
    NSMutableArray<ZegoBoardContainer *> *docBoardArray = [NSMutableArray array];
    [self.orderedBoardModelContainers enumerateObjectsUsingBlock:^(ZegoWhiteBoardViewContainerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.selectedBoardContainer.docsView) {
            [docBoardArray addObject:obj.selectedBoardContainer];
        }
    }];
    //一个房间内最多只能创建10个文件
    if(docBoardArray.count < 10) {
        ZegoBoardContainer *boardContainer = [self getOneBoardContainer];
        boardContainer.sheetIndex = sheetIndex;
        [self addBoardContainerView:boardContainer];
        [self.activityIndicator startAnimating];
        @weakify(self);
        //创建文件类型的白板
        [boardContainer buildDocWhiteBoardContainerWithFileInfo:fileInfo
                                                 whiteBoardName:whiteBoardName
                                                     sheetIndex:sheetIndex
                                                       complete:^(ZegoWhiteboardViewError errorCode) {
            @strongify(self);
            [self.activityIndicator stopAnimating];
            if (errorCode == 0) {
                if (complete) {
                    complete(errorCode);
                }
                [self updateOrderedBoardContainers];
                [self changeWhiteBoardWithBoardContainer:boardContainer];
                //如果文件是excel，那么需要创建该excel下所有sheet的白板
                if (ifCreateSheets) {
                    [self createDocSheetBoardsWithContainerView:boardContainer];
                }
            } else {
                [self.boardContainers removeObject:boardContainer];
                [self showNetworkError];
            }
        }];
    } else {
        [ZegoToast showText:[NSString zego_localizedString:@"wb_tip_exceed_max_number_file"]];
    }
}

- (void)changeWhiteBoardWithID:(ZegoWhiteboardID )whiteboardID {
    //切换白板后关闭键盘输入
    [[UIApplication sharedApplication].keyWindow endEditing: YES];
    ZegoBoardContainer *container;
    for (ZegoBoardContainer *boardContainer in self.boardContainers) {
        if (boardContainer.whiteboardID == whiteboardID) {
            container = boardContainer;
            break;
        }
    }
    if (container) {
        if ([container isEqual:self.currentContainer]) {
            return;
        }
        self.currentContainer = container;
    } else {
        self.changeWhiteBoardID = whiteboardID;
    }
}

- (void)changeWhiteBoardWithBoardContainer:(ZegoBoardContainer * _Nullable )boardContainer {
    //切换白板后移除激光笔
    [self.currentContainer.whiteboardView removeLaser];
    @weakify(self);
    [self syncCurrentWhiteBoardID:boardContainer.whiteboardID complete:^(NSInteger errorCode) {
        @strongify(self);
        if (errorCode == 0) {
            self.currentContainer = boardContainer;
            
        } else {
//            [ZegoToast showText:@"切换失败，请重试！"];
        }
    }];
    if (!boardContainer) {
        self.currentContainer = nil;
    }
    
}

- (void)removeWhiteBoardWithWhiteBoardViewContainerModel:(ZegoWhiteBoardViewContainerModel *)whiteBoardViewContainerModel {
    if (whiteBoardViewContainerModel.selectedBoardContainer.isExcel) {
        //删除一个excel sheet的白板时，应该把该excel的所有sheet对应的白板删除
        [self removeExcellSheetWhiteBoardListForFileID:whiteBoardViewContainerModel.selectedBoardContainer.fileInfo.fileID];
    } else {
        @weakify(self);
        [[ZegoWhiteboardManager sharedInstance] destroyWhiteboardID:whiteBoardViewContainerModel.selectedBoardContainer.whiteboardID
                                                      completeBlock:^(ZegoWhiteboardViewError errorCode, ZegoWhiteboardID whiteboardID) {
            @strongify(self);
            if (errorCode == 0) {
               [self removeWhiteBoardWithWhiteboardID:whiteboardID syncMessage:YES];
            } else {
               [self showNetworkError];
            }
        }];
    }
}
- (void)removeWhiteBoardWithWhiteboardID:(ZegoWhiteboardID)whiteboardID syncMessage:(BOOL)shouldSync {
    ZegoBoardContainer *fileView = nil;
    for (ZegoBoardContainer *view in self.boardContainers) {
        if (view.whiteboardID == whiteboardID) {
            fileView = view;
            break;
        }
    }
    if (fileView == nil && shouldSync) {
        if (shouldSync) {
            [self syncCurrentWhiteBoardIDToServer];
        }
    }
    if (fileView) {
        [self.boardContainers removeObject:fileView];
    }
    [self updateOrderedBoardContainers];
    
    if (self.currentContainer.whiteboardID == whiteboardID) {
        self.currentContainer = self.orderedBoardModelContainers.firstObject.selectedBoardContainer;
        if (shouldSync) {
            [self syncCurrentWhiteBoardIDToServer];
        }
    } else {
        if (self.boardContainers.count <= 0) {
            self.currentContainer = nil;
        }
    }
}

- (void)zegoFileListViewDidSelectFile:(ZegoFileInfoModel *)model {
    ZegoBoardContainer *existContainer;
    for (ZegoWhiteBoardViewContainerModel *containerModel in self.orderedBoardModelContainers) {
        if (containerModel.selectedBoardContainer.docsView && [containerModel.selectedBoardContainer.fileInfo.fileID isEqualToString:model.fileID]) {
            existContainer = containerModel.selectedBoardContainer;
            break;
        }
    }
    if (existContainer) {
        [self changeWhiteBoardWithBoardContainer:existContainer];
    } else {
        
        [self addDocBoardWithInfo:model whiteBoardName: model.fileName sheetIndex:0 createSheets:YES complete:^(ZegoWhiteboardViewError errorCode) {
            
        }];
    }
    [ZegoViewAnimator hideToRight];
}

- (void)zegoExcelSheetListDidSelectSheet:(NSString *)sheetName index:(int)index {
    ZegoBoardContainer *existContainer;
    for (ZegoBoardContainer *container in self.boardContainers) {
        if (container.isExcel && [container.fileInfo.fileName isEqualToString:sheetName] && [container.fileInfo.fileID isEqualToString:self.currentContainer.fileInfo.fileID]) {
            existContainer = container;
            break;
        }
    }
    if (existContainer) {
        [self changeWhiteBoardWithBoardContainer:existContainer];
    } else {
        ZegoFileInfoModel *infoModel = [[ZegoFileInfoModel alloc] init];
        infoModel.authKey = self.currentContainer.fileInfo.authKey;
        infoModel.fileID = self.currentContainer.fileInfo.fileID;
        infoModel.fileType = self.currentContainer.fileInfo.fileType;
        infoModel.fileName = sheetName;
        [self addDocBoardWithInfo:infoModel whiteBoardName:self.currentContainer.whiteboardView.whiteboardModel.name sheetIndex:index createSheets: NO complete:^(ZegoWhiteboardViewError errorCode) {
        }];
    }
    [ZegoViewAnimator hideToRight];
}

- (void)animateDynamicPPTWithAnimationInfo:(NSString *)animationInfo {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        DLog(@"-[ZegoDocsView stopPlayAnimation] app在后台, 不播放音视频");
        [self.currentContainer.docsView stopPlay:0];
        return;
    }
    DLog(@"-[ZegoDocsView playAnimation] app在前台, 继续播放音视频");
    [self.currentContainer.docsView playAnimation:animationInfo];
}

- (void)stopDynamicPPTAnimation {
    [self.currentContainer.docsView stopPlay:0];
}

- (void)enableCurrentContainer:(BOOL)isEnable {
    self.currentContainerEnable = isEnable;
    [self.currentContainer setupWhiteboardOperationMode:isEnable?(ZegoWhiteboardOperationModeDraw|ZegoWhiteboardOperationModeZoom):ZegoWhiteboardOperationModeZoom];
}

- (void)deleteSelectedGraphics {
    [self.currentContainer.whiteboardView deleteSelectedGraphics];
}

#pragma mark - Private File

//创建一个Excel白板时同时创建该Excel下所有sheet的白板
- (void)createDocSheetBoardsWithContainerView:(ZegoBoardContainer *)container {
    
    for (int i = 0; i<container.docsView.sheetNameList.count; i++) {
        if (i == 0) {
            //第一个sheet默认已经创建
            continue;
        }
        ZegoBoardContainer *boardContainer = [self getOneBoardContainer];
        boardContainer.sheetIndex = i;
        [self.boardContainers addObject:boardContainer];
        @weakify(self);
        [boardContainer buildDocWhiteBoardContainerWithFileInfo:container.fileInfo whiteBoardName:container.whiteboardView.whiteboardModel.name sheetIndex: i complete:^(ZegoWhiteboardViewError errorCode) {
            @strongify(self);
            if (errorCode) {
                [ZegoToast showText:[NSString stringWithFormat:@"创建sheet白板问题%ld", (long)errorCode]];
            } else {
                [self updateOrderedBoardContainers];
            }
        }];
    }
    
}

- (ZegoBoardContainer *)getOneBoardContainer {
    ZegoBoardContainer *boardContainer = [[ZegoBoardContainer alloc] initWithFrame:self.whiteBoardContentView.bounds];
    @weakify(self);
    boardContainer.onTapWhiteBoard = ^{
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(onTapWhiteBoard)]) {
            [self.delegate onTapWhiteBoard];
        }
    };
    return boardContainer;
}

//根据白板列表(self.boardContainers)整理出最终用来显示的ZegoWhiteBoardViewContainerModel列表(用于展示白板和文件列表)，此处逻辑较复杂，待优化
- (void)updateOrderedBoardContainers {
    [[UIApplication sharedApplication].keyWindow endEditing: YES];
    NSMutableArray<ZegoWhiteBoardViewContainerModel *> *uniqueBoardContainerArray = [NSMutableArray array];
    for (ZegoBoardContainer *container in self.boardContainers) {
        if (!container.whiteboardView) {
            //如果还没创建完白板，则忽略
            continue;
        }
        ZegoWhiteBoardViewContainerModel *addedModel =[self containerModelWithFileID:container.fileInfo.fileID inBoardContainerList:self.orderedBoardModelContainers];
        
        ZegoWhiteBoardViewContainerModel *existModel = [self containerModelWithFileID:container.fileInfo.fileID inBoardContainerList:uniqueBoardContainerArray];
        
        if (!existModel) {
            existModel = [[ZegoWhiteBoardViewContainerModel alloc] initWithContainer:container];
            [uniqueBoardContainerArray addObject:existModel];
            if (container.isExcel) {
                [existModel addSheetContainer:container];
            }
        } else {
            if (container.isExcel && [container.fileInfo.fileID isEqualToString:existModel.selectedBoardContainer.fileInfo.fileID]) {
                [existModel addSheetContainer:container];
            }
        }
        
        if (addedModel && addedModel.selectedBoardContainer.isExcel && [existModel.selectedBoardContainer.fileInfo.fileID isEqualToString:addedModel.selectedBoardContainer.fileInfo.fileID]) {
            existModel.selectedBoardContainer = addedModel.selectedBoardContainer;
        }
        
    }
    NSMutableArray<ZegoWhiteBoardViewContainerModel *> *finalArray = [NSMutableArray array];
    [uniqueBoardContainerArray enumerateObjectsUsingBlock:^(ZegoWhiteBoardViewContainerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isExcel) {
            if (obj.isValidExcel) {
                [finalArray addObject:obj];
            }
        } else {
            [finalArray addObject:obj];
        }
    }];
    self.orderedBoardModelContainers = finalArray;
    if ([self.delegate respondsToSelector:@selector(onChangedOrderedBoardContainerModels:)]) {
        [self.delegate onChangedOrderedBoardContainerModels:self.orderedBoardModelContainers];
    }
}

//由fileID找出对应的ZegoWhiteBoardViewContainerModel
- (ZegoWhiteBoardViewContainerModel *)containerModelWithFileID:(NSString *)fileID inBoardContainerList:(NSArray<ZegoWhiteBoardViewContainerModel *> *)boardContainerList {
    for (ZegoWhiteBoardViewContainerModel *temp in boardContainerList) {
        if ([temp.selectedBoardContainer.fileInfo.fileID isEqualToString:fileID]) {
            return temp;
        }
    }
    return nil;
}

- (NSMutableArray *)boardContainers {
    if (!_boardContainers) {
        _boardContainers = [[NSMutableArray alloc] init];
    }
    return _boardContainers;
}

- (void)setCurrentContainer:(ZegoBoardContainer *)container {
    if ([_currentContainer isEqual:container]) {
        return;
    }
    //停止播放当前白板的音视频
    if ([self.currentContainer isDynamicPPT]) {
        DLog(@"-[ZegoDocsView stopPlay:] 切换白板,停止当前动态ppt音视频播放!!!!!");
        [self stopDynamicPPTAnimation];
    }
    //切换白板时 清除之前的激光笔
    [_currentContainer.whiteboardView removeLaser];
    [_currentContainer removeFromSuperview];
    _currentContainer = container;
    
    [self.whiteBoardContentView addSubview:container];
    if (self.delegate) {
        [self.delegate onWhiteboardContainerChanged:container];
    }
    if (_currentContainer.isExcel) {
        [_currentContainer.docsView switchSheet:(int)_currentContainer.sheetIndex];
        //加载完文件后，白板的contentSize要调整到和文件的contentSize一致（因为加载excell时，不同sheet对应的contenSize会不同）
        _currentContainer.whiteboardView.contentSize = _currentContainer.docsView.contentSize;
    }
    
    ZegoWhiteBoardViewContainerModel *currentContainerModel = [self currentContainerModel];
    //设置当前ZegoWhiteBoardViewContainerModel选中的ZegoBoardContainer
    currentContainerModel.selectedBoardContainer = _currentContainer;
//    self.whiteBoardContentView.userInteractionEnabled = _currentContainer != nil;
//    self.whiteBoardContentView.userInteractionEnabled = self.currentContainerEnable;
}

- (void)syncCurrentWhiteBoardID:(ZegoWhiteboardID)whiteboardID complete:(ZegoCompleteBlock)complete {
    if (!whiteboardID) {
        return;
    }
    [ZegoLiveCenter syncCurrentWhiteboardWithRoomID:self.roomId whiteBoardID:@(whiteboardID).stringValue compelte:^(int errorCode) {

        if (complete) {
            complete(errorCode);
        }
    }];
}

- (void)syncCurrentWhiteBoardIDToServer {
    [self syncCurrentWhiteBoardID:self.currentContainer.whiteboardID complete:nil];
}

- (void)removeLocalWhiteBoardContainer:(ZegoBoardContainer *)container {
    [self.boardContainers removeObject:container];
    [self updateOrderedBoardContainers];
    if (self.boardContainers.count <= 0) {
        [self changeWhiteBoardWithBoardContainer:nil];
    }
}

//获取当前选中的BoardContainer对应的ZegoWhiteBoardViewContainerModel
- (ZegoWhiteBoardViewContainerModel *)currentContainerModel {
    ZegoWhiteBoardViewContainerModel *existContainer;
    for (ZegoWhiteBoardViewContainerModel *container in self.orderedBoardModelContainers) {
        if (container.isExcel) {
            if ([container.selectedBoardContainer.fileInfo.fileID isEqualToString:self.currentContainer.fileInfo.fileID]) {
                existContainer = container;
                break;
            }
        } else {
            if (self.currentContainer.whiteboardID == container.selectedBoardContainer.whiteboardID) {
                existContainer = container;
                break;
            }
        }
    }
    return existContainer;
}

//删除一个excel sheet的白板时，应该把该excel的所有sheet对应的白板删除
- (void)removeExcellSheetWhiteBoardListForFileID:(NSString *)fileID {
    NSArray *boardContainers = [self.boardContainers copy];
    NSMutableArray *sameFileBoardContainers = [NSMutableArray array];
    for (ZegoBoardContainer *container in boardContainers) {
        if ([container.fileInfo.fileID isEqualToString:fileID]) {
            [sameFileBoardContainers addObject:container];
        }
    }
    
    for (ZegoBoardContainer *container in boardContainers) {
        if ([container.fileInfo.fileID isEqualToString:fileID]) {
            @weakify(self);
            [[ZegoWhiteboardManager sharedInstance] destroyWhiteboardID:container.whiteboardID
                                                          completeBlock:^(ZegoWhiteboardViewError errorCode, ZegoWhiteboardID whiteboardID) {
                @strongify(self);
                if (errorCode == 0) {
                    [self.boardContainers removeObject:container];
                    [sameFileBoardContainers removeObject:container];
                    
                    [self updateOrderedBoardContainers];
                    self.currentContainer = self.orderedBoardModelContainers.firstObject.selectedBoardContainer;
                    [self syncCurrentWhiteBoardIDToServer];
                    
                } else {
                    [self showNetworkError];
                }
            }];
        }
        
    }
    
}

- (void)addBoardContainerView:(ZegoBoardContainer *)containerView {
    [self.boardContainers insertObject:containerView atIndex:0];
}

#pragma mark UI

- (void)showNetworkError {
    [self.activityIndicator stopAnimating];
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        _activityIndicator.hidesWhenStopped = YES;
    }
    return _activityIndicator;
}

#pragma mark Getter

- (UIView *)whiteBoardContentView {
    if (!_whiteBoardContentView) {
        CGFloat x = 0;
        CGFloat y = 44;
        CGFloat rawW = kScreenWidth - kStreamCellWidth;
        CGFloat rawH = kScreenHeight - 44 - 49;
        CGFloat aspect = 16.0/9.0;
        
        CGFloat finalW;
        CGFloat finalH;
        
        if ((rawW / rawH) < aspect) {
            finalW = rawW;
            finalH = rawW / aspect;
            y = (rawH - finalH) / 2 + (44 + 49) / 2;
        } else {
            finalH = rawH;
            finalW = rawH * aspect;
            x = (rawW - finalW) / 2;
        }
        
        CGRect rect = CGRectMake(x, y, finalW, finalH);
        _whiteBoardContentView = [[UIView alloc] initWithFrame:rect];
    }
    return _whiteBoardContentView;
}

@end
