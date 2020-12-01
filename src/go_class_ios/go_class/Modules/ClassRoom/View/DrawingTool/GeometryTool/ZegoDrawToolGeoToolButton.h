//
//  ZegoDrawToolGeoToolButton.h
//  ZegoWhiteboardVideoDemo
//
//  Created by Vic on 2020/11/23.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoDrawingToolModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZegoDrawToolGeoToolButton : UIButton

@property (nonatomic, strong) ZegoDrawingToolModel *toolModel;

- (instancetype)initWithToolModel:(ZegoDrawingToolModel *)model;

@end

NS_ASSUME_NONNULL_END
