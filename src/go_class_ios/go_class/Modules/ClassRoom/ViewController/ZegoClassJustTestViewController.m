//
//  ZegoClassJustTestControllerViewController.m
//  ZegoWhiteboardVideoDemo
//
//  Created by Vic on 2020/11/8.
//  Copyright © 2020 zego. All rights reserved.
//


#import "ZegoClassJustTestViewController.h"
#import "ZegoRotationManager.h"

ZegoJustTestDataKey const ZegoJustTestWhiteboardEnabled = @"ZegoJustTestWhiteboardEnabled";




@interface ZegoClassJustTestViewController ()
@property (weak, nonatomic) IBOutlet UITextField *addText;
@property (weak, nonatomic) IBOutlet UITextField *positionX;
@property (weak, nonatomic) IBOutlet UITextField *positionY;
@property (weak, nonatomic) IBOutlet UITextField *customTextTf;
@property (weak, nonatomic) IBOutlet UITextField *clearPageTf;

@property (weak, nonatomic) IBOutlet UIButton *whiteboardEnabledBtn;
@property (nonatomic, assign) BOOL whiteboardEnabled;

@end

@implementation ZegoClassJustTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"功能测试";
    [ZegoRotationManager defaultManager].orientation = UIDeviceOrientationLandscapeRight;
    
    [self updateWhiteboardEnabledBtn];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        if (dict[ZegoJustTestWhiteboardEnabled]) {
            NSNumber *ret = dict[ZegoJustTestWhiteboardEnabled];
            self.whiteboardEnabled = ret.boolValue;
        }else {
            self.whiteboardEnabled = YES;
        }
    }
    return self;
}

- (void)updateWhiteboardEnabledBtn {
    self.whiteboardEnabledBtn.backgroundColor = self.whiteboardEnabled ? UIColor.greenColor : UIColor.redColor;
    [self.whiteboardEnabledBtn setTintColor:self.whiteboardEnabled ? UIColor.blackColor : UIColor.whiteColor];
    [self.whiteboardEnabledBtn setTitle:self.whiteboardEnabled ? @"禁用白板交互" : @"启用白板交互" forState:UIControlStateNormal];
}

#pragma mark - Actions
- (IBAction)dismissAction:(id)sender {
    [self dismiss];
}

- (IBAction)addTextAction:(id)sender {
    NSString *text = self.addText.text;
    CGFloat x = self.positionX.text.floatValue;
    CGFloat y = self.positionY.text.floatValue;
    
    if ([self.delegate respondsToSelector:@selector(addText:positionX:positionY:)]) {
        [self.delegate addText:text positionX:x positionY:y];
    }
    [self dismiss];
}

- (IBAction)setCustomTextAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(setCustomText:)]) {
        [self.delegate setCustomText:self.customTextTf.text];
    }
    [self dismiss];
}

- (IBAction)setWhiteboardEnabledAction:(id)sender {
    self.whiteboardEnabled = !self.whiteboardEnabled;
    [self updateWhiteboardEnabledBtn];
    if ([self.delegate respondsToSelector:@selector(setWhiteboardEnabled:)]) {
        [self.delegate setWhiteboardEnabled:self.whiteboardEnabled];
    }
    [self dismiss];
}

- (IBAction)clearPage:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clearPage:)]) {
        NSString *pageString = self.clearPageTf.text;
        NSInteger pageNum = pageString.integerValue;
        if (pageNum < 0) {
            pageNum = 0;
        }
        [self.delegate clearPage:pageNum];
    }
    [self dismiss];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
