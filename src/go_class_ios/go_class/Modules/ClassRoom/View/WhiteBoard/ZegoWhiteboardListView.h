//
//  ZegoWhiteboardListView.h
//  ZegoWhiteboardViewDemo
//
//  Created by zego on 2020/4/16.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef IS_WHITE_BOARD_VIEW_SOURCE_CODE
#import "ZegoWhiteboardView.h"
#else
#import <ZegoWhiteboardView/ZegoWhiteboardView.h>
#endif
#import "ZegoBoardContainer.h"
#import "ZegoWhiteBoardViewContainerModel.h"

NS_ASSUME_NONNULL_BEGIN

@class ZegoListItemModel;

@protocol ZegoWhiteboardListViewDelegate <NSObject>

- (void)whiteBoardListDidSelectView:(ZegoWhiteBoardViewContainerModel *)fileView;

- (void)whiteBoardListDidDeleteView:(ZegoWhiteBoardViewContainerModel *)fileView;

@end

@interface ZegoWhiteboardListView : UIView

@property (nonatomic, weak) id<ZegoWhiteboardListViewDelegate> delegate;

- (void)refreshWithBoardContainerModels:(NSArray <ZegoWhiteBoardViewContainerModel *>*)boardContainerModels selected:(ZegoBoardContainer *)selected;

@end

NS_ASSUME_NONNULL_END
