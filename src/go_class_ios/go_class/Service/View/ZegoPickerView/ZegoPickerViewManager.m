//
//  CGXPickerViewManager.m
//  CGXPickerView
//
//  Created by CGX on 2018/1/8.
//  Copyright © 2018年 CGX. All rights reserved.
//

#import "ZegoPickerViewManager.h"
#import "UIColor+ZegoExtension.h"
#import "NSString+ZegoExtension.h"
/// RGB颜色(16进制)
#define CGXPickerRGBColor(r,g,b,a) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a];


@interface ZegoPickerViewManager ()

@end
@implementation ZegoPickerViewManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _kPickerViewH = 44 + 44 + 44 + 8;
        _kTopViewH = 49;
        _pickerTitleSize  =15;
        _pickerTitleColor = [UIColor colorWithRGB:@"#4d2d2e"];
        
        _pickerTitleSelectSize  =15;
        _pickerTitleSelectColor = [UIColor colorWithRGB:@"#2d2e32"];
        
        _lineViewColor = [UIColor colorWithRGB:@"#e5e5e5"];
        
        _titleLabelColor = [UIColor colorWithRGB:@"#2d2e32"];
        _titleSize = 15;
        _titleLabelBGColor = [UIColor clearColor];
        _rowHeight = 44;
        _rightBtnTitle = [NSString zego_localizedString:@"wb_determine"];
        _rightBtnBGColor =  [UIColor clearColor];
        _rightBtnTitleSize = 15;
        _rightBtnTitleColor = [UIColor colorWithRGB:@"#0044ff"];
        
        _rightBtnborderColor = CGXPickerRGBColor(252, 96, 134, 1);
        _rightBtnCornerRadius = 6;
        _rightBtnBorderWidth = 0;
        
        _leftBtnTitle = [NSString zego_localizedString:@"wb_cancel"];
        _leftBtnBGColor =  [UIColor clearColor];
        _leftBtnTitleSize = 15;
        _leftBtnTitleColor = [UIColor colorWithRGB:@"#6f7078"];
        
        _leftBtnborderColor = CGXPickerRGBColor(252, 96, 134, 1);
        _leftBtnCornerRadius = 6;
        _leftBtnBorderWidth = 0;
        _isHaveLimit = NO;
        
    }
    return self;
}
@end
