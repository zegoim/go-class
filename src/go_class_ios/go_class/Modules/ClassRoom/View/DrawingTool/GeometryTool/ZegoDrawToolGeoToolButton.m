//
//  ZegoDrawToolGeoToolButton.m
//  ZegoWhiteboardVideoDemo
//
//  Created by Vic on 2020/11/23.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoDrawToolGeoToolButton.h"

@implementation ZegoDrawToolGeoToolButton

- (instancetype)initWithToolModel:(ZegoDrawingToolModel *)model {
    self = [super init];
    [self setToolModel:model];
    return self;
}

- (void)setToolModel:(ZegoDrawingToolModel *)model {
    _toolModel = model;
    [self setImage:[UIImage imageNamed:model.normalImage] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:model.selectedImage] forState:UIControlStateSelected];
    [self setSelected:model.isSelected];
    [self setEnabled:model.isEnabled];
}

- (BOOL)isHighlighted {
    return NO;
}

@end
