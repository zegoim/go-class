//
//  ZegoDrawToolFormatModel.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/5.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoDrawToolFormatModel.h"

@implementation ZegoDrawToolBrush
- (instancetype)initWithBrushWidth:(CGFloat)brushWidth isSelected:(BOOL)isSelected {
    if (self = [super init]) {
        _brushWidth = brushWidth;
        _isSelected = isSelected;
    }
    return self;
}
@end

@implementation ZegoDrawToolColor
- (instancetype)initWithColor:(UIColor *)color isSelected:(BOOL)isSelected {
    if (self = [super init]) {
        _color = color;
        _isSelected = isSelected;
    }
    return self;
}
@end

@implementation ZegoDrawToolFont
- (instancetype)initWithFont:(UIFont *)font isSelected:(BOOL)isSelected {
    if (self = [super init]) {
        _font = font;
        _isSelected = isSelected;
    }
    return self;
}
@end

@implementation ZegoDrawToolFormat
- (instancetype)initWithBrush:(ZegoDrawToolBrush *)brush color:(ZegoDrawToolColor *)color font:(ZegoDrawToolFont *)font textFormats:(NSArray <ZegoTextFormat *> *)textFormats {

    if (self = [super init]) {
        _font = font;
        _color = color;
        _brush = brush;
        _textFormats = textFormats;

    }
    return self;
}
@end

@implementation ZegoTextFormat
- (instancetype)initWithTextFormatId:(NSInteger)formatId textFormatType:(ZegoTextFormatType )textFormatType normalImageName:(NSString *)normalImageName selectedImageName:(NSString *)selectedImageName isSelected:(BOOL)isSelected
{
    if (self = [super init]) {
        _formatId = formatId;
        _isSelected = isSelected;
        _textFormatType = textFormatType;

        _normalImageName = normalImageName;
        _selectedImageName = selectedImageName;
    }
    return self;
}
@end

