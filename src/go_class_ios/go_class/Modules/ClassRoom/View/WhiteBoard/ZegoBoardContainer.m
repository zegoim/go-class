//
//  ZegoFileView.m
//  ZegoWhiteboardViewDemo
//
//  Created by zego on 2020/4/28.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoBoardContainer.h"
#import "ZegoAuthConstants.h"
#import "ZegoUIConstant.h"
#import "UIColor+ZegoExtension.h"


@interface ZegoBoardContainer()<UIScrollViewDelegate, ZegoDocsViewDelegate, ZegoWhiteboardViewDelegate>

@end

@implementation ZegoBoardContainer

static int nameIndex = 0;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        self.backgroundColor = [UIColor colorWithRGB:@"#f4f5f8"];
//        self.hidden = YES;
//        self.backgroundColor = UIColor.redColor;
    }
    return self;
}

+ (instancetype)defaultBoardContainer {
    CGFloat x = 0;
    CGFloat y = 44;
    CGFloat rawW = kScreenWidth - kStreamCellWidth;
    CGFloat rawH = kScreenHeight - 44 * 2;
    CGFloat aspect = 16.0/9.0;
    
    CGFloat finalW;
    CGFloat finalH;
    
    if ((rawW / rawH) < aspect) {
        finalW = rawW;
        finalH = rawW / aspect;
        y = (rawH - finalH) / 2 + 44;
    } else {
        finalH = rawH;
        finalW = rawH * aspect;
        x = (rawW - finalW) / 2;
    }
    
    ZegoBoardContainer *boardContainer = [[ZegoBoardContainer alloc] initWithFrame:CGRectMake(x, y, finalW, finalH)];
    return boardContainer;
}

- (NSString *)currentSheetName {
    if (!self.isExcel) {
        return nil;
    }
    if (self.sheetIndex < self.docsView.sheetNameList.count) {
        return self.docsView.sheetNameList[self.sheetIndex];
    }
    return nil;
}

- (NSString *)whiteBoardName {
    return self.whiteboardView.whiteboardModel.name;
}

- (BOOL)isFile {
    return self.whiteboardView.whiteboardModel.fileInfo.fileID != NULL;
}

- (BOOL)isExcel {
    return self.whiteboardView.whiteboardModel.fileInfo && self.whiteboardView.whiteboardModel.fileInfo.fileType == ZegoDocsViewFileTypeELS;
}

- (BOOL)isDynamicPPT {
    return self.whiteboardView.whiteboardModel.fileInfo && self.whiteboardView.whiteboardModel.fileInfo.fileType == ZegoDocsViewFileTypeDynamicPPTH5;
}

- (ZegoFileInfoModel *)fileInfo {
    return self.whiteboardView.whiteboardModel.fileInfo;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[ZegoBoardContainer class]]) {
        return NO;
    }
    return [self isEqualToZegoFileView:(ZegoBoardContainer *)object];
}

- (BOOL)isEqualToZegoFileView:(ZegoBoardContainer *)fileView {
    if (!fileView) {
        return NO;
    }
    return fileView.whiteboardID == self.whiteboardID;
}

- (void)createWhiteboardViewWithUserName:(NSString *)userName block:(ZegoCreateViewBlock)block
{
    ZegoWhiteboardViewModel *model = [[ZegoWhiteboardViewModel alloc] init];
    model.aspectWidth = 16.0 * 5;
    model.aspectHeight = 9.0;
    model.pageCount = 5;
    model.name = [NSString stringWithFormat:@"%@创建的白板%d",userName, ++nameIndex];
    @weakify(self);
    [[ZegoWhiteboardManager sharedInstance] createWhiteboardView:model
                                                   completeBlock:^(ZegoWhiteboardViewError errorCode, ZegoWhiteboardView *whiteboardView) {
        @strongify(self);
        self.whiteboardView = whiteboardView;
        [self buildWithWhiteboardView:whiteboardView docView:nil];
        if (block) {
            block(errorCode);
        }
    }];
}

- (void)buildDocWhiteBoardContainerWithFileInfo:(ZegoFileInfoModel *)fileInfo whiteBoardName:(NSString *)whiteBoardName sheetIndex:(int)sheetIndex complete:(ZegoCreateViewBlock)complete
{
    ZegoDocsView * docView = [[ZegoDocsView alloc] initWithFrame:self.bounds];
    docView.backgroundColor = UIColor.whiteColor;
    DLog(@"开始加载文件");
    @weakify(self);
    [docView loadFileWithFileID:fileInfo.fileID
                        authKey:fileInfo.authKey completionBlock:^(ZegoDocsViewError errorCode) {
        @strongify(self);
        docView.backgroundColor = UIColor.whiteColor;
        if (errorCode == ZegoDocsViewSuccess) {
            DLog(@"成功加载文件");
            [self createFileWhiteboardWithDocView:docView whiteBoardName:whiteBoardName sheetIndex:sheetIndex completeBlock:complete ];
        } else {
            DLog(@"创建文件失败 %ld",(long)errorCode);
            if (complete) {
                complete((ZegoWhiteboardViewError)errorCode);
            }
        }
    }];
}


- (void)addWhiteboarView:(ZegoWhiteboardView *)whiteboardView complete:(ZegoCreateViewBlock)complete
{
    self.whiteboardID = whiteboardView.whiteboardModel.whiteboardID;
    self.whiteboardView = whiteboardView;
    
    if (whiteboardView.whiteboardModel.fileInfo.fileID.length == 0) {
        [self buildWithWhiteboardView:whiteboardView docView:nil];
        if (complete) {
            complete(ZegoWhiteboardViewSuccess);
        }
    } else {
        ZegoDocsView * docView = [[ZegoDocsView alloc] initWithFrame:self.bounds];
        DLog(@"加载文件中");
        @weakify(self);
        [docView loadFileWithFileID:whiteboardView.whiteboardModel.fileInfo.fileID
                            authKey:nil
                    completionBlock:^(ZegoDocsViewError errorCode) {
            @strongify(self);
            if (errorCode == ZegoDocsViewSuccess) {
                DLog(@"加载文件成功 %ld page:%ld",errorCode, (long)docView.currentPage);
                [self buildWithWhiteboardView:whiteboardView docView:docView];
                if (complete) {
                    complete((ZegoWhiteboardViewError)errorCode);
                }
            } else {
                DLog(@"加载文件失败 %ld",errorCode);
            }
        }];
    }
}

- (void)setDraggable:(BOOL)draggable {
    self.whiteboardView.canDraw = !draggable;
}

- (void)nextPage {
    [self nextPageCompletionBlock:nil];
}

- (void)prePage {
    [self prePageCompletionBlock:nil];
}

- (void)nextPPTStepCompletionBlock:(ZegoDocsViewScrollCompleteBlock _Nullable)completionBlock {
    if (!self.isDynamicPPT) return;
    DLog(@"___推之前的PAGE: %ld, STEP: %ld", (long)self.docsView.currentPage, (long)self.docsView.currentStep);
    @weakify(self);
    [self.docsView nextStepWithCompletionBlock:^(BOOL isScrollSuccess) {
        @strongify(self);
        if (isScrollSuccess) {
            float pageNum = (float)MAX((self.docsView.currentPage - 1), 0);
            NSInteger step = self.docsView.currentStep;
            
            DLog(@"___推出去的PAGE: %ld, STEP: %ld", (long)self.docsView.currentPage, step);
            
            [self.whiteboardView scrollToHorizontalPercent:0 verticalPercent: pageNum/ (float)self.docsView.pageCount pptStep:step completionBlock:^(ZegoWhiteboardViewError error_code, float horizontalPercent, float verticalPercent, unsigned int pptStep) {
                if (completionBlock) {
                    completionBlock(error_code == 0);
                    
                }
                [self reupdateDocWithVerticalPercent:verticalPercent pptStep:pptStep shouldReFlipDocsView:error_code != 0 completionBlock:completionBlock];
                DLog(@"主动滚动白板结果 %@",error_code ? @"失败" : @"成功");
            }];
        } else {
            if (completionBlock) {
                completionBlock(isScrollSuccess);
            }
        }
    }];
}

- (void)prePPTStepCompletionBlock:(ZegoDocsViewScrollCompleteBlock _Nullable)completionBlock {
    if (!self.isDynamicPPT) return;
    @weakify(self);
    [self.docsView previousStepWithCompletionBlock:^(BOOL isScrollSuccess) {
        if (isScrollSuccess) {
            @strongify(self);
            float pageNum = (float)MAX((self.docsView.currentPage - 1), 0);
            NSInteger step = self.docsView.currentStep;
            
            DLog(@"___推出去的PAGE: %ld, STEP: %ld", (long)self.docsView.currentPage, step);

            [self.whiteboardView scrollToHorizontalPercent:0 verticalPercent: pageNum/ (float)self.docsView.pageCount pptStep:step completionBlock:^(ZegoWhiteboardViewError error_code, float horizontalPercent, float verticalPercent, unsigned int pptStep) {
                if (completionBlock) {
                    completionBlock(error_code == 0);
                }
                [self reupdateDocWithVerticalPercent:verticalPercent pptStep:pptStep shouldReFlipDocsView:error_code != 0 completionBlock:completionBlock];
                DLog(@"主动滚动白板结果 %@",error_code ? @"失败" : @"成功");
            }];
        } else {
            if (completionBlock) {
                completionBlock(isScrollSuccess);
            }
        }
    }];
}

- (void)nextPageCompletionBlock:(ZegoDocsViewScrollCompleteBlock _Nullable)completionBlock {
    CGFloat xPercent = self.whiteboardView.whiteboardModel.horizontalScrollPercent;
    float pagePercent;
    if (self.docsView) {
        if (self.docsView.currentPage + 1 <= self.docsView.pageCount) {
            [self scrollToPage:self.docsView.currentPage + 1 pptStep:1 completionBlock: completionBlock];
        }
    }else {
        pagePercent = round(xPercent * 100)/100  + 0.2;
        int page = round(pagePercent * 10 / 2);
        //白板最多5页
        if (page > 4) {
            return;
        }
        [self.whiteboardView scrollToHorizontalPercent:pagePercent verticalPercent:0 pptStep: 0 completionBlock:^(ZegoWhiteboardViewError error_code, float horizontalPercent, float verticalPercent, unsigned int step) {
            if (completionBlock) {
                completionBlock(YES);
            }
        }];
    }
}

- (void)prePageCompletionBlock:(ZegoDocsViewScrollCompleteBlock _Nullable)completionBlock {
    CGFloat xPercent = self.whiteboardView.whiteboardModel.horizontalScrollPercent;
    if (self.docsView) {
        if (self.docsView.currentPage - 1 >= 1) {
            [self scrollToPage:self.docsView.currentPage - 1 pptStep:1 completionBlock: completionBlock];
        }
    } else {
        CGFloat pageNo = xPercent  - 0.2;
        pageNo = MAX(pageNo, 0);
        [self.whiteboardView scrollToHorizontalPercent:pageNo verticalPercent:0 pptStep:0  completionBlock:^(ZegoWhiteboardViewError error_code, float horizontalPercent, float verticalPercent, unsigned int pptStep) {
            if (completionBlock) {
                completionBlock(YES);
            }
        }];
    }
}

- (void)scrollToPage:(NSInteger)page pptStep:(NSInteger)step completionBlock:(ZegoDocsViewScrollCompleteBlock _Nullable)completionBlock {
    if (self.docsView) {
        DLog(@"_________@@FlipToPage主动: %ld Step: %d", (long)page, step);
        @weakify(self);
        [self.docsView flipPage:page step:step completionBlock:^(BOOL isScrollSuccess) {
            @strongify(self);
            if (completionBlock) {
                completionBlock(isScrollSuccess);
            }
            float pageNum = (float)MAX((self.docsView.currentPage - 1), 0);
            [self.whiteboardView scrollToHorizontalPercent:0
                                           verticalPercent: pageNum/ (float)self.docsView.pageCount
                                                   pptStep:self.docsView.currentStep
                                           completionBlock:^(ZegoWhiteboardViewError error_code, float horizontalPercent, float verticalPercent, unsigned int pptStep) {
                if (completionBlock) {
                    completionBlock(error_code == 0);
                }
                [self reupdateDocWithVerticalPercent:verticalPercent pptStep:pptStep shouldReFlipDocsView:error_code != 0 completionBlock:completionBlock];
            }];
        }];
    } else {
        float pageNum = (float)MAX((self.docsView.currentPage - 1), 0);
        [self.whiteboardView scrollToHorizontalPercent:0
                                       verticalPercent:pageNum / (float)self.docsView.pageCount
                                               pptStep:step
                                       completionBlock:^(ZegoWhiteboardViewError error_code, float horizontalPercent, float verticalPercent, unsigned int pptStep) {
            if (completionBlock) {
                completionBlock(error_code == 0);
            }
        }];
    }
    
}

- (void)reupdateDocWithVerticalPercent:(float)verticalPercent pptStep:(unsigned int)pptStep shouldReFlipDocsView:(BOOL)shouldReFlipDocsView completionBlock:(ZegoDocsViewScrollCompleteBlock _Nullable)completionBlock {
    if(!shouldReFlipDocsView) {
        return;
    }
    NSInteger pageNumFianel = round(verticalPercent * self.docsView.pageCount) + 1;
    DLog(@"_________@@STEP 主动同步滚动成功收到回调Page: %ld Step: %d verticalPercent: %f 当前page: %ld step:%ld", (long)pageNumFianel, pptStep, verticalPercent,(long)self.docsView.currentPage, (long)self.docsView.currentStep);

    if (pageNumFianel == self.docsView.currentPage && pptStep == self.docsView.currentStep) {
        DLog(@"_________@@FlipToPage主动成功，没变化，不翻页 Page: %ld Step: %d", (long)pageNumFianel, pptStep);
        return;
    }
    DLog(@"_________@@STEP FlipToPage主动成功再Flip: %ld Step: %d", (long)pageNumFianel, pptStep);

    [self.docsView flipPage:pageNumFianel step:pptStep completionBlock:^(BOOL isScrollSuccess) {
        DLog(@"_________@@STEP FlipToPage主动成功再Flip回调结果 %@", isScrollSuccess ? @"成功": @"失败");
        if (completionBlock) {
            completionBlock(YES);
        }
    }];
}

- (void)unloadDoc {
    if (self.isDynamicPPT) {
        [self.docsView unloadFile];
    }
}

#pragma mark - ZegoDocsViewDelegate
- (void)onStepChange {
    DLog(@"___ONStepChange PAGE: %ld, STEP: %ld", (long)self.docsView.currentPage, (long)self.docsView.currentStep);
    if (self.whiteboardViewUIDelegate && [self.whiteboardViewUIDelegate respondsToSelector:@selector(onScaleChangedWithScaleFactor:scaleOffsetX:scaleOffsetY:whiteboardView:)]) {
        [self.whiteboardViewUIDelegate onScaleChangedWithScaleFactor:0 scaleOffsetX:0 scaleOffsetY:0 whiteboardView:self.whiteboardView];
    }
}

// docsView 的回调, 需要调用白板 -playAnimation: 方法
- (void)onPlayAnimation:(NSString *)animationInfo {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        DLog(@"-[ZegoDocsView onPlayAnimation] 不调用白板同步方法");
        return;
    }
    DLog(@"-[ZegoDocsView onPlayAnimation] 调用白板同步方法!!!!");
    [self.whiteboardView playAnimation:animationInfo];
}

- (void)onStepChangeForClick {
    /*
     每次动态 ppt 动画成功回调后:
     1. 需要查看页数是否需要更新
     2. 页数更新后, 需要移动白板 view 的 offset
     */
    if (!self.isDynamicPPT) return;
    if (self.docsView.currentPage <= self.docsView.pageCount) {
        NSInteger pageNum = MAX((self.docsView.currentPage - 1), 0);
        CGFloat verticalPercent = (CGFloat)pageNum / self.docsView.pageCount;
        DLog(@"onStepChangeForClick _________@@主动同步滚动成功收到回调PageNum: %ld    verticalPercent:%f", pageNum, verticalPercent);
        [self.whiteboardView scrollToHorizontalPercent:0
                                       verticalPercent: verticalPercent
                                               pptStep:self.docsView.currentStep
                                       completionBlock:^(ZegoWhiteboardViewError error_code, float horizontalPercent, float verticalPercent, unsigned int pptStep) {
            
            double round1 = round(verticalPercent * self.docsView.pageCount);
            NSInteger pageNumFinal = round1 + 1;
            if (error_code == 0) {
                DLog(@"onStepChangeForClick _________@@主动同步滚动成功收到回调round: %f pageCount: %ld",round1,(long)self.docsView.pageCount);
                DLog(@"onStepChangeForClick _________@@主动同步滚动成功收到回调Page: %ld Step: %d verticalPercent: %f 当前page: %ld step:%ld", (long)pageNumFinal, pptStep, verticalPercent,(long)self.docsView.currentPage, (long)self.docsView.currentStep);
            } else {
                if (pageNumFinal == self.docsView.currentPage && pptStep == self.docsView.currentStep) {
                    DLog(@"onStepChangeForClick _________@@FlipToPage主动成功，没变化，不翻页 Page: %ld Step: %d", (long)pageNumFinal, pptStep);
                    return;
                }
                DLog(@"onStepChangeForClick _________@@FlipToPage主动成功再Flip: %ld Step: %d", (long)pageNumFinal, pptStep);
                [self.docsView flipPage:pageNumFinal step:pptStep completionBlock:nil];
            }
        }];
    }
    if ([self.docsViewUIDelegate respondsToSelector:@selector(onStepChangeForClick)]) {
        [self.docsViewUIDelegate onStepChangeForClick];
    }
}

#pragma mark - ZegoWhiteboardViewUIDelegate

- (void)onScaleChangedWithScaleFactor:(CGFloat)scaleFactor scaleOffsetX:(CGFloat)scaleOffsetX scaleOffsetY:(CGFloat)scaleOffsetY whiteboardView:(ZegoWhiteboardView *)whiteboardView {
   [self.docsView scaleDocsViewWithScaleFactor:scaleFactor scaleOffsetX:scaleOffsetX scaleOffsetY:scaleOffsetY];
    if (self.whiteboardViewUIDelegate && [self.whiteboardViewUIDelegate respondsToSelector:@selector(onScaleChangedWithScaleFactor:scaleOffsetX:scaleOffsetY:whiteboardView:)]) {
        [self.whiteboardViewUIDelegate onScaleChangedWithScaleFactor:scaleFactor scaleOffsetX:scaleOffsetX scaleOffsetY:scaleOffsetY whiteboardView:whiteboardView];
    }
}

- (void)onScrollWithHorizontalPercent:(CGFloat)horizontalPercent verticalPercent:(CGFloat)verticalPercent whiteboardView:(ZegoWhiteboardView *)whiteboardView {
    void (^action)(void) = ^void() {
        if (self.whiteboardViewUIDelegate && [self.whiteboardViewUIDelegate respondsToSelector:@selector(onScrollWithHorizontalPercent:verticalPercent:whiteboardView:)]) {
            [self.whiteboardViewUIDelegate onScrollWithHorizontalPercent:horizontalPercent verticalPercent:verticalPercent whiteboardView:whiteboardView];
        }
    };
    
    if (self.docsView) {
        if (self.isDynamicPPT) {
            if (self.whiteboardView.whiteboardModel.pptStep < 1) {
                return;
            }
            CGFloat yPercent = self.whiteboardView.contentOffset.y / self.whiteboardView.contentSize.height;
            NSInteger pageNo = round(yPercent * self.docsView.pageCount) + 1;
            DLog(@"_________@@FlipToPage被动: %d Step: %d", pageNo, MAX(self.whiteboardView.whiteboardModel.pptStep, 1));
            [self.docsView flipPage:pageNo step:MAX(self.whiteboardView.whiteboardModel.pptStep, 1) completionBlock:^(BOOL isScrollSuccess) {
                action();
            }];
        } else {
            [self.docsView scrollTo:self.whiteboardView.contentOffset.y/self.whiteboardView.contentSize.height completionBlock:^(BOOL isScrollSuccess) {
                action();
            }];
        }
         
    } else {
        action();
    }
}

#pragma mark - ZegoDocsViewDelegate


#pragma mark - ZegoWhiteboardViewDelegate

- (void)onError:(ZegoWhiteboardViewError)error whiteboardView:(ZegoWhiteboardView *)whiboardView
{
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.docsView) {
        [self.docsView scrollTo:scrollView.contentOffset.y/scrollView.contentSize.height completionBlock:^(BOOL isScrollSuccess) {}];
    }
}
#pragma mark - private method

- (void)buildWithWhiteboardView:(ZegoWhiteboardView *)whiteboardView
                        docView:(ZegoDocsView *)docsView
{
    whiteboardView.canDraw = YES;
    whiteboardView.whiteboardViewDelegate = self;
    [docsView setDelegate:self];
    self.whiteboardID = whiteboardView.whiteboardModel.whiteboardID;
    self.whiteboardView = whiteboardView;
    self.docsView = docsView;
    self.docsView.delegate = self;
    if (self.isExcel) {
        self.sheetIndex = [self.docsView.sheetNameList indexOfObject:self.fileInfo.fileName];
    }
    [self addSubview:docsView];
    [self addSubview:whiteboardView];
    
    if (docsView && docsView.pageCount > 0) {
        CGSize visibleSize = docsView.visibleSize;
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        
        CGRect frame = CGRectMake((width - visibleSize.width) / 2.0, (height - visibleSize.height) / 2.0, visibleSize.width, visibleSize.height);
        whiteboardView.frame = frame;
        whiteboardView.contentSize = docsView.contentSize;
        whiteboardView.backgroundColor = [UIColor clearColor];
    } else {
        ZegoWhiteboardViewModel *data = whiteboardView.whiteboardModel;
        whiteboardView.backgroundColor = [UIColor colorWithRGB:@"#f4f5f8"];
        whiteboardView.frame = [self aspectToFitScreen:data.aspectWidth * 1.0 / data.aspectHeight];
    }
    
    //如果登陆房间存在ppt同步信息需要执行同步动画方法
    if (docsView && whiteboardView.whiteboardModel.h5_extra) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [docsView playAnimation:whiteboardView.whiteboardModel.h5_extra];
        });
    }
    
    UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWhiteBoard)];
    [self addGestureRecognizer:tg];
}

- (void)tapWhiteBoard {
    if (self.onTapWhiteBoard) {
        self.onTapWhiteBoard();
    }
}

- (CGRect)aspectToFitScreen:(CGFloat)aspect {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    if (width / height > 16 / 9.0) {
        CGFloat viewWidth = 16 * height / 9.0;
        return CGRectMake((width - viewWidth) * 0.5, 0, viewWidth, height);
    } else {
        CGFloat viewHeight = 9 * width / 16.0;
        return  CGRectMake(0, (height - viewHeight) * 0.5, width, viewHeight);
    }
}

//创建白板与文件
- (void)createFileWhiteboardWithDocView:(ZegoDocsView *)docView whiteBoardName:(NSString *)whiteBoardName sheetIndex:(int)sheetIndex
                          completeBlock:(ZegoCreateViewBlock)completeBlock
{
    ZegoWhiteboardViewModel *model = [[ZegoWhiteboardViewModel alloc] init];
    model.aspectWidth = docView.contentSize.width;
    model.aspectHeight = docView.contentSize.height;
    model.name = whiteBoardName;
    model.roomID = kZegoRoomId;
    model.fileInfo.fileType = docView.fileType;
    model.fileInfo.fileID = docView.fileID;
    model.fileInfo.fileName = docView.sheetNameList[sheetIndex];
    @weakify(self);
    [[ZegoWhiteboardManager sharedInstance] createWhiteboardView:model
                                                   completeBlock:^(ZegoWhiteboardViewError errorCode, ZegoWhiteboardView *whiteboardView) {
        @strongify(self);
        if (errorCode == 0) {
            [self buildWithWhiteboardView:whiteboardView docView:docView];
        }
        if (completeBlock) {
            completeBlock(errorCode);
        }
    }];
}

@end
