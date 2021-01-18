//
//  ZegoChatTextInputView.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/11/4.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoChatTextInputView.h"
#import "UIColor+ZegoExtension.h"
#import "ZegoUIConstant.h"
#import <ZegoWhiteboardView/ZegoWhiteboardManager.h>
#import "NSString+ZegoExtension.h"
#define kZegoChatRoomMaxTextLength 100 //限制最大输入字符数

@interface ZegoChatTextInputView ()<UITextViewDelegate>

@property (nonatomic, strong)UITextView *textView;
@property (nonatomic, strong)UIButton *sendButton;
@property (nonatomic, strong)UIView *maskView;//遮挡视图

@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) BOOL isWhiteBoardTextKeyBoard;//用来记录当前是否是白板文本的键盘弹起

@end

@implementation ZegoChatTextInputView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self configUI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

- (void)configUI
{
    self.backgroundColor = [UIColor whiteColor];
    self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 48);
    self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - kScreenHeight, kScreenWidth, kScreenHeight - self.frame.size.height)];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
    [self.maskView addGestureRecognizer:tap];
    [self addSubview:self.maskView];
    
    self.textView = [[UITextView alloc] init];
    [self addSubview:self.textView];
    self.textView.textContainerInset = UIEdgeInsetsMake(4, 15, 4, 15);
    self.textView.frame = CGRectMake(15, 9, kScreenWidth - 70, 30);
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.cornerRadius = 15;
    self.textView.textAlignment = NSTextAlignmentLeft;
    self.textView.textColor = UIColorHex(#333333);
    self.textView.font = [UIFont systemFontOfSize:15];
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.borderColor = [UIColorHex(#cdcdcd) CGColor];
    self.textView.delegate = self;
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.sendButton];
    self.sendButton.frame = CGRectMake(kScreenWidth - 50, 0, 40, self.frame.size.height);
    [self.sendButton setTitle:[NSString zego_localizedString:@"room_im_send"] forState:UIControlStateNormal];
    self.sendButton.backgroundColor = [UIColor clearColor];
    self.sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.sendButton setTitleColor:UIColorHex(#007aff) forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(senderButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -public
- (void)beginEdit {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    self.hidden = NO;
    [self.textView becomeFirstResponder];
}

#pragma mark - Action
- (void)senderButtonClick:(UIButton *)button {
    if (self.textView.text.length > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendMsgButtonClick:)]) {
            [self.delegate sendMsgButtonClick:self.textView.text];
        }
        self.textView.text = @"";
        [self.textView resignFirstResponder];
        self.hidden = YES;
        [self removeFromSuperview];
    }
}

- (void)click:(UITapGestureRecognizer *)gesture
{
    self.textView.text = @"";
    [self.textView resignFirstResponder];
    self.hidden = YES;
    [self removeFromSuperview];
}

#pragma mark - Noti
- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    if ([ZegoWhiteboardManager sharedInstance].toolType == ZegoWhiteboardViewToolText) {
        self.isWhiteBoardTextKeyBoard = YES;
        return;
    }
    if (self.isWhiteBoardTextKeyBoard) {
        self.isWhiteBoardTextKeyBoard = NO;
        return;
    }
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         [self willShowKeyboardFromFrame:beginFrame toFrame:endFrame];}
                     completion:nil];
}

- (void)willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame {
    
    if (toFrame.origin.y == [[UIScreen mainScreen] bounds].size.height){//键盘收起
        self.hidden = YES;
    } else { //键盘升起
        self.keyboardHeight = toFrame.size.height;
        self.frame = CGRectMake(0.0, kScreenHeight - self.keyboardHeight - self.frame.size.height, kScreenWidth, self.frame.size.height);
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
        return [self.delegate textViewShouldBeginEditing:textView];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
        [self.delegate textViewDidBeginEditing:textView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
        [self.delegate textViewDidEndEditing:textView];
    }
    self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 48);
    self.textView.frame = CGRectMake(15, 9, kScreenWidth - 70, 30);
    self.sendButton.frame = CGRectMake(kScreenWidth - 50, 0, 40, self.frame.size.height);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *str = [textView.text stringByReplacingCharactersInRange:range withString:text];
    CGFloat height = MAX(30, [self getStringHeightWithText:str font:[UIFont systemFontOfSize:15] viewWidth:self.textView.frame.size.width - 15] + 5);
    self.frame = CGRectMake(0, kScreenHeight - self.keyboardHeight - height - 21, kScreenWidth, height + 20);
    self.textView.frame = CGRectMake(15, 9, kScreenWidth - 70, height + 1);
    self.sendButton.frame = CGRectMake(kScreenWidth - 50, 0, 40, self.frame.size.height);
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > kZegoChatRoomMaxTextLength) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(exceedTextNumber:)]) {
            [self.delegate exceedTextNumber:kZegoChatRoomMaxTextLength];
        }
        textView.text = [textView.text substringToIndex:kZegoChatRoomMaxTextLength];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
        [self.delegate textViewDidChange:textView];
    }
}

- (CGFloat)getStringHeightWithText:(NSString *)text font:(UIFont *)font viewWidth:(CGFloat)width {
    // 设置文字属性 要和label的一致
    NSDictionary *attrs = @{NSFontAttributeName :font};
    CGSize maxSize = CGSizeMake(width, MAXFLOAT);

    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;

    // 计算文字占据的宽高
    CGSize size = [text boundingRectWithSize:maxSize options:options attributes:attrs context:nil].size;

   // 当你是把获得的高度来布局控件的View的高度的时候.size转化为ceilf(size.height)。
    return  ceilf(size.height);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint maskPoint = [self convertPoint:point toView:self.maskView];
    if ([self.maskView pointInside:maskPoint withEvent:event]) {
        return self.maskView;
    }else {
        return [super hitTest:point withEvent:event];
    }
}

@end
