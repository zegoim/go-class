//
//  ZegoFilePreviewCollectionViewCell.m
//  ZegoWhiteboardVideoDemo
//
//  Created by MartinNie on 2020/8/19.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoFilePreviewCollectionViewCell.h"
#import "ZegoUIConstant.h"
#import "UIColor+ZegoExtension.h"
@implementation ZegoFilePreviewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    self.pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 22, 12)];
    [self.contentView addSubview:self.pageLabel];
    self.pageLabel.textColor = [UIColor colorWithRGB:@"#585c62"];
    self.pageLabel.font = [UIFont systemFontOfSize:11];
    self.pageLabel.textAlignment = NSTextAlignmentCenter;
    self.contentIV = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.pageLabel.frame), 5, self.frame.size.width - (2 * 40), 80)];
    [self.contentView addSubview:self.contentIV];
    self.contentIV.layer.borderWidth = 1;
    self.contentIV.layer.borderColor = [UIColor colorWithRGB:@"#e5e5e5"].CGColor;
    self.contentIV.layer.cornerRadius = 2;
    [self.contentIV setClipsToBounds:YES];
    self.contentIV.contentMode = UIViewContentModeScaleAspectFit;
    self.contentIV.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        self.backgroundColor = [UIColor colorWithRGB:@"#f0f4ff"];;
        self.pageLabel.textColor = kThemeColorBlue;
        self.contentIV.layer.borderColor = kThemeColorBlue.CGColor;
    } else {
        self.backgroundColor = [UIColor whiteColor];
        self.pageLabel.textColor = [UIColor colorWithRGB:@"#585c62"];
        self.contentIV.layer.borderColor = [UIColor colorWithRGB:@"#e5e5e5"].CGColor;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.pageLabel.frame = CGRectMake(8, 5, 17, 12);
    self.contentIV.frame = CGRectMake(CGRectGetMaxX(self.pageLabel.frame) + 5, 5, self.frame.size.width - 25 - 22, self.frame.size.height - 10);
}


@end
