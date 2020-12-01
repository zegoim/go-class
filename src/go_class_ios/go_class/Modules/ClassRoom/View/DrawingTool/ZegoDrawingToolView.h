//
//  ZegoDrawingToolView.h
//  ZegoEducation
//
//  Created by MrLQ  on 2018/4/12.
//  Copyright © 2018年 Shenzhen Zego Technology Company Limited. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ZegoDrawToolFormatView.h"
#import "ZegoDrawToolConstants.h"

@class ZegoDrawingToolView;

@protocol ZegoDrawingToolViewDelegate <NSObject>

@optional

- (void)selectItemType:(ZegoDrawingToolViewItemType)itemType selected:(BOOL)isSelected;
- (BOOL)itemCanBeSelectedWithType:(ZegoDrawingToolViewItemType)itemType;
- (void)didChangeFormat:(ZegoDrawToolFormat *)format;
- (void)selecteColor:(UIColor *)color;

@end

@interface ZegoDrawingToolView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<ZegoDrawingToolViewDelegate> delegate;
@property (nonatomic, strong , readonly) UIColor *selectedColor;
@property (nonatomic, assign , readonly) BOOL isDragEnable;

+ (instancetype)defaultInstance;

//重置View到初始状态
- (void)resetDrawingColorView;

- (void)changeToItemType:(ZegoDrawingToolViewItemType)itemType response:(BOOL)response;
- (void)enableItemType:(ZegoDrawingToolViewItemType)itemType isEnabled:(BOOL)isEnabled;

@end
