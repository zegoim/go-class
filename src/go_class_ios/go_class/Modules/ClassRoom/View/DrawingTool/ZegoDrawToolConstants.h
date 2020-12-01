//
//  ZegoDrawToolConstants.h
//  ZegoWhiteboardVideoDemo
//
//  Created by Vic on 2020/11/23.
//  Copyright © 2020 zego. All rights reserved.
//

#ifndef ZegoDrawToolConstants_h
#define ZegoDrawToolConstants_h


typedef NS_ENUM(NSUInteger, ZegoDrawingToolViewItemType) {
    ZegoDrawingToolViewItemTypePath         = 0x1,      // 涂鸦画笔
    ZegoDrawingToolViewItemTypeText         = 0x2,      // 文本
    ZegoDrawingToolViewItemTypeLine         = 0x4,      // 直线
    ZegoDrawingToolViewItemTypeRect         = 0x8,      // 矩形
    ZegoDrawingToolViewItemTypeEllipse      = 0x10,     // 圆
    ZegoDrawingToolViewItemTypeArrow        = 0x20,     // 选择箭头
    ZegoDrawingToolViewItemTypeEraser       = 0x40,     // 橡皮擦
    ZegoDrawingToolViewItemTypeFormat       = 0x81,     // 颜色
    ZegoDrawingToolViewItemTypeGeometry     = 0x82,     // 图形(里面聚合了 矩形,椭圆,直线)
    ZegoDrawingToolViewItemTypeUndo         = 0x110,    // 撤销
    ZegoDrawingToolViewItemTypeRedo         = 0x200,    // 恢复
    ZegoDrawingToolViewItemTypeClear        = 0x400,    // 清空
    ZegoDrawingToolViewItemTypeDrag         = 0x600,    // 拖拽箭头
    ZegoDrawingToolViewItemTypeLaser        = 0x80,     // 激光笔
    ZegoDrawingToolViewItemTypeClick = 0x100,    // 动态 PPT 点击
    ZegoDrawingToolViewItemTypeSave         = 0x101,    // 白板截图
    
    ZegoDrawingToolViewItemTypeJustTest     = ~0,       // 仅供内部测试
};

#endif /* ZegoDrawToolConstants_h */
