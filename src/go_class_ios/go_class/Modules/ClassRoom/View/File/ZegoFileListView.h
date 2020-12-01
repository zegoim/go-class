//
//  ZegoFileListView.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/1.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef IS_WHITE_BOARD_VIEW_SOURCE_CODE
#import "ZegoWhiteboardView.h"
#else
#import <ZegoWhiteboardView/ZegoWhiteboardView.h>
#endif


NS_ASSUME_NONNULL_BEGIN
@class ZegoFileListView;
@protocol ZegoFileListViewDelegate <NSObject>

- (void)zegoFileListView:(ZegoFileListView *)listView didSelectFile:(ZegoFileInfoModel *)fileModel;

@end

@interface ZegoFileListView : UIView

@property(weak, nonatomic) id<ZegoFileListViewDelegate> delegate;

- (void)updateWithFiles:(NSArray<ZegoFileInfoModel *> *)files;

@end

NS_ASSUME_NONNULL_END
