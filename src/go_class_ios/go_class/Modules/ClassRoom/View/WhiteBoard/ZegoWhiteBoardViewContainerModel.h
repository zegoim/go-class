//
//  ZegoWhiteBoardViewContainerModel.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/10.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZegoBoardContainer.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZegoWhiteBoardViewContainerModel : NSObject

@property (nonatomic, assign, readonly) BOOL isValidExcel;
@property (nonatomic, assign, readonly) BOOL isExcel;
@property (nonatomic, assign) ZegoBoardContainer *selectedBoardContainer;

/// 如果白板类型是文件，并且文件类型是Excel，那可能包含多个sheet白板
@property (nonatomic, strong) NSMutableArray<ZegoBoardContainer *> *sheetContainerList;

- (instancetype)initWithContainer:(ZegoBoardContainer *)container;
- (void)addSheetContainer:(ZegoBoardContainer *)container;
- (void)removeSheetContainer:(ZegoBoardContainer *)container;
- (void)removeAllSheetContainer;


@end

NS_ASSUME_NONNULL_END
