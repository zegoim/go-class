//
//  ZegoFormatToolService.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/9/14.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoFormatToolService.h"
#import "ZegoBoardContainer.h"

@interface ZegoFormatToolService ()
@property (strong, nonatomic) ZegoBoardContainer *currentContainer;
@end

@implementation ZegoFormatToolService

#pragma mark - ZegoDrawingToolViewDelegate

- (instancetype)initWithBoardContainer:(ZegoBoardContainer *)container {
    if (self = [super init]) {
        _currentContainer = container;
    }
    return self;
}

- (void)refreshBoardContainer:(ZegoBoardContainer *)container {
    self.currentContainer = container;
}

//工具栏上的按钮是否能选中
- (BOOL)itemCanBeSelectedWithType:(ZegoDrawingToolViewItemType)itemType {
    if (itemType == ZegoDrawingToolViewItemTypeFormat ||
        itemType == ZegoDrawingToolViewItemTypeUndo ||
        itemType == ZegoDrawingToolViewItemTypeRedo ||
        itemType == ZegoDrawingToolViewItemTypeClear ||
        (itemType == ZegoDrawingToolViewItemTypeClick && !self.currentContainer.isDynamicPPT) ||
        itemType == ZegoDrawingToolViewItemTypeSave ||
        itemType == ZegoDrawingToolViewItemTypeJustTest){
        return NO;
    }
    return YES;
}

- (void)selectItemType:(ZegoDrawingToolViewItemType)itemType selected:(BOOL)isSelected {
    if (itemType == ZegoDrawingToolViewItemTypeJustTest) {
        if ([self.delegate respondsToSelector:@selector(selectItemType:selected:)]) {
            [self.delegate selectItemType:ZegoDrawingToolViewItemTypeJustTest selected:NO];
        }
        return;
    }
    
    if (itemType == ZegoDrawingToolViewItemTypeSave) {
        if ([self.delegate respondsToSelector:@selector(selectItemType:selected:)]) {
            [self.delegate selectItemType:ZegoDrawingToolViewItemTypeSave selected:NO];
        }
        return;
    }
    
    if (itemType != ZegoDrawingToolViewItemTypeLaser &&
        itemType != ZegoDrawingToolViewItemTypeRedo &&
        itemType != ZegoDrawingToolViewItemTypeUndo &&
        itemType != ZegoDrawingToolViewItemTypeClear &&
        itemType != ZegoDrawingToolViewItemTypeFormat) {
        //选中非以上工具时，手动移除激光笔
        [self.currentContainer.whiteboardView removeLaser];
    }
    
    // 动态ppt 点击时, 需要关掉白板的用户交互, 以响应 sdk H5 的点击事件
    if (itemType == ZegoDrawingToolViewItemTypeClick && self.currentContainer.isDynamicPPT) {
        [ZegoWhiteboardManager sharedInstance].toolType = (ZegoWhiteboardTool)itemType;
        [self.currentContainer.docsView setScaleEnable:NO];
        self.currentContainer.whiteboardView.userInteractionEnabled = NO;
    }else {
        [self.currentContainer.docsView setScaleEnable:YES];
        self.currentContainer.whiteboardView.userInteractionEnabled = YES;
    }
    
    switch (itemType) {
        case ZegoDrawingToolViewItemTypeRect:
        case ZegoDrawingToolViewItemTypeEllipse:
        case ZegoDrawingToolViewItemTypeLine:
        case ZegoDrawingToolViewItemTypePath:
        case ZegoDrawingToolViewItemTypeText:
        case ZegoDrawingToolViewItemTypeArrow:
        case ZegoDrawingToolViewItemTypeLaser:
            [ZegoWhiteboardManager sharedInstance].toolType = (ZegoWhiteboardTool)itemType;
            //选中以上工具时，不允许拖拽
            [self.currentContainer setupWhiteboardOperationMode:(ZegoWhiteboardOperationModeDraw|ZegoWhiteboardOperationModeZoom)];
            break;
            
        case ZegoDrawingToolViewItemTypeEraser:
            if ([self.delegate respondsToSelector:@selector(selectItemType:selected:)]) {
                [self.delegate selectItemType:ZegoDrawingToolViewItemTypeEraser selected:YES];
            }
            [ZegoWhiteboardManager sharedInstance].toolType = (ZegoWhiteboardTool)itemType;
            //选中以上工具时，不允许拖拽
            [self.currentContainer setupWhiteboardOperationMode:(ZegoWhiteboardOperationModeDraw|ZegoWhiteboardOperationModeZoom)];
            break;
        case ZegoDrawingToolViewItemTypeDrag:
            //选中拖拽工具时，允许拖拽
            [self.currentContainer setupWhiteboardOperationMode:(ZegoWhiteboardOperationModeZoom|ZegoWhiteboardOperationModeScroll)];
            break;
        case ZegoDrawingToolViewItemTypeUndo:
            [self.currentContainer.whiteboardView undo];
            break;
        case ZegoDrawingToolViewItemTypeRedo:
            [self.currentContainer.whiteboardView redo];
            break;
        case ZegoDrawingToolViewItemTypeClear:
            [self.currentContainer.whiteboardView clear];
            break;
        default:
            break;
    }
    
    if (itemType == ZegoDrawingToolViewItemTypeText) {
        //选中文字工具时默认添加一个文字
        [self.currentContainer.whiteboardView addTextEdit];
    }
}

- (void)selecteColor:(UIColor *)color {
    [ZegoWhiteboardManager sharedInstance].brushColor = color;
}

- (void)didChangeFormat:(ZegoDrawToolFormat *)format {
    [ZegoWhiteboardManager sharedInstance].brushColor = format.color.color;
    [ZegoWhiteboardManager sharedInstance].brushSize = format.brush.brushWidth;
    [ZegoWhiteboardManager sharedInstance].fontSize = format.font.font.pointSize;
    [self transTextFormatToSDKWithTextFormats:format.textFormats];
}

- (void)transTextFormatToSDKWithTextFormats:(NSArray <ZegoTextFormat *>*)textFormats {
    for (ZegoTextFormat *textFormat in textFormats) {
        if (textFormat.textFormatType == ZegoTextFormatTypeBold) {
            [ZegoWhiteboardManager sharedInstance].isFontBold = textFormat.isSelected;
        } else if (textFormat.textFormatType == ZegoTextFormatTypeItalic) {
            [ZegoWhiteboardManager sharedInstance].isFontItalic = textFormat.isSelected;;
        }
    }
}

- (void)uploadFileWithType:(BOOL)isDynamicFile {
    if ([self.delegate respondsToSelector:@selector(uploadFileWithType:)]) {
        [self.delegate uploadFileWithType:isDynamicFile];
    }
}

@end
