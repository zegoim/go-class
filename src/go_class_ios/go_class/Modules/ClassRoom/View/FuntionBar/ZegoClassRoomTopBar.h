//
//  ZegoClassRoomTopFunctionView.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/1.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZegoClassRoomTopActionType) {
    ZegoClassRoomTopActionTypeBoardList,
    ZegoClassRoomTopActionTypeSheetList,
    ZegoClassRoomTopActionTypePreBoard,
    ZegoClassRoomTopActionTypeNextBoard,
    ZegoClassRoomTopActionTypePreview
};
@class ZegoClassRoomTopBar;
@protocol ZegoClassRoomTopBarDelegate <NSObject>

- (void)topBar:(ZegoClassRoomTopBar *)functionCell didSelectAction:(ZegoClassRoomTopActionType)type;


@end

@interface ZegoClassRoomTopBar : UIView
@property (weak, nonatomic) id<ZegoClassRoomTopBarDelegate> delegate;
@property (nonatomic, assign) BOOL canPreview; //是否支持显示预览，用于控制预览按钮的显示样式
@property (nonatomic, assign) BOOL canShare;


NS_ASSUME_NONNULL_END

- (void)refreshWithTitle:(NSString *_Nonnull)title currentIndex:(NSInteger)index totalCount:(NSUInteger)count sheetName:(NSString *_Nullable)sheetName;
- (void)resetPreviewDisplay:(BOOL)display;


@end


