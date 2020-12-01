//
//  ZegoWhiteBoardViewContainerModel.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/10.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoWhiteBoardViewContainerModel.h"

@interface ZegoWhiteBoardViewContainerModel ()

@end

@implementation ZegoWhiteBoardViewContainerModel

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[ZegoWhiteBoardViewContainerModel class]]) {
        return NO;
    }
    return [self isEqualToModel:(ZegoWhiteBoardViewContainerModel *)object];
}

- (BOOL)isEqualToModel:(ZegoWhiteBoardViewContainerModel *)model {
    if (!model) {
        return NO;
    }
    return model.selectedBoardContainer.whiteboardID == self.selectedBoardContainer.whiteboardID;
}

- (instancetype)initWithContainer:(ZegoBoardContainer *)container {
    if (self = [super init]) {
        _selectedBoardContainer = container;
        _sheetContainerList = [NSMutableArray array];
    }
    return self;
}

- (BOOL)isExcel {
    return self.selectedBoardContainer.isExcel;
}

- (BOOL)isValidExcel {
    if (!self.isExcel) {
        return NO;
    }
    if (!self.selectedBoardContainer) {
        return NO;
    }
    if (self.sheetContainerList.count <= 0) {
        return NO;
    }
    return self.selectedBoardContainer.docsView.sheetNameList.count <= self.sheetContainerList.count;
}

- (void)addSheetContainer:(ZegoBoardContainer *)container {
    int index = -1;
    for (int i = 0; i < self.sheetContainerList.count; i++) {
        ZegoBoardContainer *tempContainer = self.sheetContainerList[i];
        if ([container.fileInfo.fileName isEqualToString:tempContainer.fileInfo.fileName]) {
            index = -1;
            break;
        }
    }
    if (index == -1) {
        [self.sheetContainerList addObject:container];
    } else {
        [self.sheetContainerList replaceObjectAtIndex:index withObject:container];
    }
}

- (void)removeSheetContainer:(ZegoBoardContainer *)container {
    [self.sheetContainerList removeObject:container];
}

- (void)removeAllSheetContainer {
    [self.sheetContainerList removeAllObjects];
}

@end
