//
//  ZegoExcelSheetList.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/9.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class ZegoExcelSheetListView;
@protocol ZegoExcelSheetListViewDelegate <NSObject>

- (void)zegoExcelSheetList:(ZegoExcelSheetListView *)listView didSelectSheet:(NSString *)sheetName index:(int)index;

@end
@interface ZegoExcelSheetListView : UIView

@property (nonatomic, weak) id<ZegoExcelSheetListViewDelegate> delegate;

- (void)updateViewWithSheetNameList:(NSArray <NSString *>*)sheetList selectedSheet:(NSString *)selectedSheetName;

@end

NS_ASSUME_NONNULL_END
