//
//  ZegoFilePreviewView.h
//  ZegoWhiteboardVideoDemo
//
//  Created by MartinNie on 2020/8/19.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoFilePreviewView : UIView
@property (nonatomic, strong, readonly) NSArray *dataArray;
@property (nonatomic, assign, readonly) NSInteger currentPage;// 从0开始 -1代表未指定页面
@property (nonatomic, copy) void(^selectedPageBlock)(NSInteger index);// index从0开始

- (void)setDataArray:(NSArray *)dataArray;
- (void)setPreviewPageCount:(NSInteger)pageCount;
- (void)reset;
@end

NS_ASSUME_NONNULL_END
