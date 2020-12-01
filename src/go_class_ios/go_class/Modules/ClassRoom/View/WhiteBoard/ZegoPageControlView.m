//
//  ZegoPageControlView.m
//  ZegoWhiteboardVideoDemo
//
//  Created by MartinNie on 2020/8/5.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoPageControlView.h"
#import "UIColor+ZegoExtension.h"
@interface ZegoPageControlView ()
@property (nonatomic, strong) UIButton *previousPageBtn;
@property (nonatomic, strong) UIButton *nextPageBtn;
@property (nonatomic, strong) UIImageView *previousIV;
@property (nonatomic, strong) UIImageView *nextIV;
@property (nonatomic, strong) UIImageView *lineIV;
@property (nonatomic, assign) BOOL isDelayAction;  //添加延迟标记，翻页操作间隔需要大于500ms
@end
@implementation ZegoPageControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    self.isDelayAction = NO;
    self.backgroundColor = [UIColor whiteColor];
    self.previousPageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.previousPageBtn];
    [self.previousPageBtn addTarget:self action:@selector(didClickPreviousPage) forControlEvents:UIControlEventTouchUpInside];
    self.previousPageBtn.backgroundColor = [UIColor clearColor];
    
    self.previousIV = [[UIImageView alloc] initWithImage:nil];
    [self addSubview:self.previousIV];
    self.previousIV.image = [UIImage imageNamed:@"arrow_left_2"];
    
    self.nextPageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.nextPageBtn];
    [self.nextPageBtn addTarget:self action:@selector(didClickNextPage) forControlEvents:UIControlEventTouchUpInside];
    self.nextPageBtn.backgroundColor = [UIColor clearColor];
    
    self.nextIV = [[UIImageView alloc] initWithImage:nil];
    [self addSubview:self.nextIV];
    self.nextIV.image = [UIImage imageNamed:@"arrow_right_2"];
    
    self.lineIV = [[UIImageView alloc] initWithImage:nil];
    [self addSubview:self.lineIV];
    self.lineIV.backgroundColor = [UIColor colorWithRGB:@"edeff3"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.cornerRadius = self.frame.size.height/2;
    self.layer.masksToBounds = YES;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat margin = 12;
    CGFloat btnWidth = (width-1)/2;
    self.previousPageBtn.frame = CGRectMake(0, 0, btnWidth, height);
    self.previousIV.frame = CGRectMake(margin, 8, margin, margin);
    
    self.lineIV.frame = CGRectMake(CGRectGetMaxX(self.previousPageBtn.frame)  +1, (height - margin)/2, 1, margin);
    self.nextPageBtn.frame = CGRectMake(CGRectGetMaxX(self.lineIV.frame), 0, btnWidth, height);
    self.nextIV.frame = CGRectMake(CGRectGetMaxX(self.lineIV.frame) + 11, 8, margin, margin);
}

- (void)didClickPreviousPage
{
    if ([self.delegate respondsToSelector:@selector(pageControlViewPreviousPage)] && !self.isDelayAction) {
        [self handleDelayActionLogic];
        [self.delegate pageControlViewPreviousPage];
    }
}

- (void)didClickNextPage
{
    if ([self.delegate respondsToSelector:@selector(pageControlViewNextPage)] && !self.isDelayAction) {
        [self handleDelayActionLogic];
        [self.delegate pageControlViewNextPage];
    }
}

- (void)handleDelayActionLogic
{
    self.isDelayAction = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isDelayAction = NO;
    });
}

@end
