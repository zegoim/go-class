//
//  ZegoAlertView.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/11.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoAlertView.h"
#import "ZegoUIConstant.h"
#import "UIColor+ZegoExtension.h"
#import "ZegoViewAnimator.h"

@interface ZegoAlertView ()
@property (nonatomic, copy) void (^firstAction)(void);
@property (nonatomic, copy) void (^secondAction)(void);
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;
@property (weak, nonatomic) UIView *alertView;
@property (assign, nonatomic) ZegoAlertViewThemeStyle themeStyle;
@property (strong, nonatomic) UIView *backgroundView;
@end

@implementation ZegoAlertView
static ZegoAlertView *sharedInstance = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZegoAlertView alloc] init];
    });
    return sharedInstance;
}

+ (void)alertWithTitle:(NSString *)title hasCancelButton:(BOOL)hasCancelButton onTapYes:(void (^)(void))yesAction {
    [self alertWithTitle:title subTitle:nil hasCancelButton:hasCancelButton onTapYes:yesAction onTapSecondButton:nil themeStyle:ZegoAlertViewThemeStyleNormal];
}

+ (void)alertWithTitle:(NSString *)title onTapYes:(void (^)(void))yesAction onTapRetryButton:(void (^)(void))retryAction {
    [self alertWithTitle:title subTitle:nil hasCancelButton:YES onTapYes:yesAction onTapSecondButton:retryAction themeStyle:ZegoAlertViewThemeStyleRetry];
}

+ (void)alertWithTitle:(NSString *)title subTitle:(NSString *)subTitle onTapYes:(void (^)(void))yesAction onTapSecondButton:(void (^)(void))secondAction themeStyle:(ZegoAlertViewThemeStyle)style {
    [self alertWithTitle:title subTitle:subTitle hasCancelButton:NO onTapYes:yesAction onTapSecondButton:secondAction themeStyle:style];
}

+ (void)alertWithTitle:(NSString *)title subTitle:(NSString *)subTitle hasCancelButton:(BOOL)hasCancelButton onTapYes:(void (^)(void))yesAction onTapSecondButton:(void (^)(void))secondAction  themeStyle:(ZegoAlertViewThemeStyle)style {
    [ZegoViewAnimator dismiss];
    [self dismiss];
    ZegoAlertView *alertView = [[ZegoAlertView alloc] initWithTitle:title subTitle:subTitle hasCancelButton:hasCancelButton onTapYes:yesAction onTapSecondButton:secondAction themeStyle:style];
    ZegoAlertView *instance = [self sharedInstance];
    UIView *container = [UIApplication sharedApplication].keyWindow;
    instance.alertView = alertView;
    alertView.alpha = 0;
    
    UIView *backView = [[UIView alloc] initWithFrame:container.bounds];
    UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    if (style == ZegoAlertViewThemeStyleTeacher) {
        [backView addGestureRecognizer:tapG];
    }
    instance.backgroundView = backView;
    [container addSubview:backView];
    backView.backgroundColor = [UIColor clearColor];
    
    [container addSubview:alertView];
    [container bringSubviewToFront:alertView];
    [UIView animateWithDuration:0.35 animations:^{
        backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        alertView.alpha = 1;
    }];
}

+ (void)alertWithTitle:(NSString *)title onTapYes:(void (^)(void))yesAction {
    [self alertWithTitle:title hasCancelButton:YES onTapYes:yesAction];
}

+ (void)dismiss {
    ZegoAlertView *instance = [self sharedInstance];
    [instance.alertView removeFromSuperview];
    [instance.backgroundView removeFromSuperview];
    instance.alertView = nil;
    instance.backgroundView = nil;
}

+ (void)dismissCompletion:(void (^ __nullable)(BOOL finished))completion {
    ZegoAlertView *instance = [self sharedInstance];
    [UIView animateWithDuration:0.35 animations:^{
        instance.backgroundView.backgroundColor = UIColor.clearColor;
        instance.alertView.alpha = 0;
    } completion:^(BOOL finished) {
        [instance.alertView removeFromSuperview];
        [instance.backgroundView removeFromSuperview];
        instance.alertView = nil;
        instance.backgroundView = nil;
        if (completion) {
            completion(finished);
        }
    }];
}

- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle hasCancelButton:(BOOL)hasCancelButton onTapYes:(void (^)(void))yesAction onTapSecondButton:(void (^)(void))secondAction themeStyle:(ZegoAlertViewThemeStyle)style {
    if (self = [super init]) {
        _firstAction = yesAction;
        _secondAction = secondAction;
        _title = title;
        _subTitle = subTitle;
        _themeStyle = style;
        if (subTitle) {
            [self setupSubTitleUI];
        } else {
            [self setupUIWithCancelButton:hasCancelButton];
        }
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title onTapYes:(void (^)(void))yesAction {
    return [self initWithTitle:title subTitle:nil hasCancelButton:YES onTapYes:yesAction onTapSecondButton:^{
        
    } themeStyle:ZegoAlertViewThemeStyleNormal];
}

- (void)setupSubTitleUI {
    UIView *view = [UIApplication sharedApplication].keyWindow;
    CGFloat minWidth = 238;
    CGFloat titleWidth = [self.title boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16 weight:UIFontWeightRegular]} context:nil].size.width;
    CGFloat width = MAX(minWidth, titleWidth + 40);
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5;
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((width - titleWidth) / 2, 24, titleWidth + 5, 15)];
    [self addSubview:titleLabel];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textColor = kTextColor1;
    titleLabel.text = self.title;
    
    CGFloat subTitleHeight = [self.subTitle boundingRectWithSize:CGSizeMake(width - 48, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14 weight:UIFontWeightRegular]} context:nil].size.height;
    CGFloat subTitleY = CGRectGetMaxY(titleLabel.frame) + 16;
    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, subTitleY, width - 48, subTitleHeight)];
    [self addSubview:subTitleLabel];
    subTitleLabel.textAlignment = NSTextAlignmentCenter;
    subTitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    subTitleLabel.textColor = kTextColor1;
    subTitleLabel.text = self.subTitle;
    subTitleLabel.numberOfLines = 0;
    
    CGFloat midGap = 20;
    CGFloat buttonHeight = 24;
    CGFloat buttonWidth = 80;
    CGFloat btn1Y = CGRectGetMaxY(subTitleLabel.frame) + 20;
    
    CGFloat btn1X = (width - buttonWidth * 2 - midGap) / 2;
    CGFloat btn2X = btn1X + midGap + buttonWidth;
    UIButton *noButton = [self buttonIsYes:NO];
    noButton.frame = CGRectMake(btn1X, btn1Y, buttonWidth, buttonHeight);
    [self addSubview:noButton];
    [noButton addTarget:self action:@selector(onTapNo) forControlEvents:UIControlEventTouchUpInside];

    if (self.themeStyle == ZegoAlertViewThemeStyleStudent) {
        [noButton setTitle:@"取消" forState:UIControlStateNormal];
    }else if (self.themeStyle == ZegoAlertViewThemeStyleGalleryAuth) {
        [noButton setTitle:@"知道了" forState:UIControlStateNormal];
        noButton.backgroundColor = [UIColor clearColor];
        [noButton setTitleColor:kThemeColorBlue forState:UIControlStateNormal];
        noButton.layer.borderWidth = 0.5;
        noButton.layer.borderColor = kThemeColorBlue.CGColor;
    }else {
        [noButton setTitle:@"离开课堂" forState:UIControlStateNormal];
        noButton.backgroundColor = [UIColor clearColor];
        [noButton setTitleColor:kThemeColorBlue forState:UIControlStateNormal];
        noButton.layer.borderWidth = 0.5;
        noButton.layer.borderColor = kThemeColorBlue.CGColor;
    }
    
    
    UIButton *yesButton = [self buttonIsYes:YES];
    yesButton.frame = CGRectMake(btn2X, btn1Y, buttonWidth, buttonHeight);
    [self addSubview:yesButton];
    [yesButton addTarget:self action:@selector(onTapYes) forControlEvents:UIControlEventTouchUpInside];
    if (self.themeStyle == ZegoAlertViewThemeStyleStudent) {
        [yesButton setTitle:@"确定" forState:UIControlStateNormal];
    }else if (self.themeStyle == ZegoAlertViewThemeStyleGalleryAuth) {
        [yesButton setTitle:@"去设置" forState:UIControlStateNormal];
    }else {
        [yesButton setTitle:@"结束教学" forState:UIControlStateNormal];
    }
    
    
    CGFloat height = CGRectGetMaxY(yesButton.frame) + 24;
    CGFloat x = (view.bounds.size.width - width)/2;
    CGFloat y = (view.bounds.size.height - height)/2;
    self.frame = CGRectMake(x, y, width, height);
}

- (void)setupUIWithCancelButton:(BOOL)hasCancelButton {
    UIView *view = [UIApplication sharedApplication].keyWindow;
    CGFloat minWidth = 238;
    CGFloat titleWidth = [self calculateRowSize:self.title].width;
    CGFloat width = MAX(minWidth, titleWidth + 40);
    CGFloat height = 105;
    CGFloat x = (view.bounds.size.width - width)/2;
    CGFloat y = (view.bounds.size.height - height)/2;
    self.frame = CGRectMake(x, y, width, height);
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5;
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((width - titleWidth) / 2, 24, titleWidth + 5, 18)];
    [self addSubview:titleLabel];
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    titleLabel.textColor = kTextColor1;
    titleLabel.text = self.title;
    
    CGFloat midGap = 20;
    CGFloat buttonHeight = 24;
    CGFloat buttonWidth = 69;
    CGFloat btn1Y = 60;
    
    if (hasCancelButton) {
        CGFloat btn1X = (width - buttonWidth * 2 - midGap) / 2;
        CGFloat btn2X = btn1X + midGap + buttonWidth;
        UIButton *noButton = [self buttonIsYes:NO];
        noButton.frame = CGRectMake(btn1X, btn1Y, buttonWidth, buttonHeight);
        [self addSubview:noButton];
        [noButton addTarget:self action:@selector(onTapNo) forControlEvents:UIControlEventTouchUpInside];
        if (self.themeStyle == ZegoAlertViewThemeStyleNormal) {
            [noButton setTitle:@"取消" forState:UIControlStateNormal];
        } else {
            [noButton setTitle:@"重试" forState:UIControlStateNormal];
        }
        
        UIButton *yesButton = [self buttonIsYes:YES];
        yesButton.frame = CGRectMake(btn2X, btn1Y, buttonWidth, buttonHeight);
        [self addSubview:yesButton];
        [yesButton addTarget:self action:@selector(onTapYes) forControlEvents:UIControlEventTouchUpInside];
        
    } else {
        CGFloat btn1X = (width - buttonWidth) / 2;
        UIButton *yesButton = [self buttonIsYes:YES];
        yesButton.frame = CGRectMake(btn1X, btn1Y, buttonWidth, buttonHeight);
        [self addSubview:yesButton];
        [yesButton addTarget:self action:@selector(onTapYes) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (UIButton *)buttonIsYes:(BOOL)isYes {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.backgroundColor = isYes ? kThemeColorBlue : [UIColor colorWithRGB:@"#b1b4bd"];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 12;
    [button setTitle:isYes ? @"确定" : @"取消" forState:UIControlStateNormal];
    return button;
}

- (void)onTapYes {
    [ZegoAlertView dismissCompletion:^(BOOL finished) {
        if (self.firstAction) {
            self.firstAction();
            self.firstAction = nil;
        }
    }];
    
}

- (void)onTapNo {
    [ZegoAlertView dismissCompletion:^(BOOL finished) {
        self.firstAction = nil;
        if (self.secondAction) {
            self.secondAction();
            self.secondAction = nil;
        }
    }];
}

- (CGSize)calculateRowSize:(NSString *)string {
    return [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14 weight:UIFontWeightRegular]} context:nil].size;
}
@end
