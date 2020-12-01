//
//  ZegoTextField.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/1.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoDemoRoundTextField.h"
#import "UIColor+ZegoExtension.h"
#import "ZegoUIConstant.h"

@implementation ZegoDemoRoundTextField

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor colorWithRGB:@"#f4f5f8"];
    self.textColor = kTextColor1;
    self.font = [UIFont systemFontOfSize:14];
}

// 重写此方法
-(void)drawPlaceholderInRect:(CGRect)rect {
    // 计算占位文字的 Size
    CGSize placeholderSize = [self.placeholder sizeWithAttributes:
                              @{NSFontAttributeName : self.font}];

    [self.placeholder drawInRect:CGRectMake(0, (rect.size.height - placeholderSize.height)/2, rect.size.width, rect.size.height) withAttributes:
    @{NSForegroundColorAttributeName : [UIColor colorWithRGB:@"#b1b4bd"],
                 NSFontAttributeName : self.font}];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.bounds.size.height / 2;
    self.layer.masksToBounds = YES;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    bounds.origin.x += 24;
    return bounds;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    bounds.origin.x += 24;
    return bounds;
}

@end
