//
//  ZegoDrawToolGeometryView.h
//  ZegoWhiteboardVideoDemo
//
//  Created by Vic on 2020/11/23.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoDrawToolConstants.h"

NS_ASSUME_NONNULL_BEGIN

@class ZegoDrawToolGeometryView;
@protocol ZegoDrawToolGeometryViewDelegate <NSObject>

- (void)geometryView:(ZegoDrawToolGeometryView *)geoView didSelectTool:(ZegoDrawingToolViewItemType)toolType dismissAfterSelection:(BOOL)dismiss;

@end

@interface ZegoDrawToolGeometryView : UIView

@property (nonatomic, weak) id<ZegoDrawToolGeometryViewDelegate> delegate;

- (BOOL)selectItemWithType:(ZegoDrawingToolViewItemType)toolType;

@end

NS_ASSUME_NONNULL_END
