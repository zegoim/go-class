//
//  ZegoChatTextInputView.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/11/4.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,ZegoChatTextInputState) {
    ZegoChatTextInputStateNomal,
    ZegoChatTextInputStateEditor,
};

@protocol ZegoChatTextInputViewDelegate <NSObject>

@optional
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
- (void)textViewDidBeginEditing:(UITextView *)textView;
- (void)textViewDidChange:(UITextView *)textView;
- (void)textViewDidEndEditing:(UITextView *)textView;
- (void)sendMsgButtonClick:(NSString *)msg;

//超出100个文字提示
- (void)exceedTextNumber:(NSInteger)length;

@end

@interface ZegoChatTextInputView : UIView
/*当前输入状态*/
@property (nonatomic,assign)ZegoChatTextInputState inputState;
@property (nonatomic,weak)id<ZegoChatTextInputViewDelegate>delegate;

//开始编辑
- (void)beginEdit;

@end

NS_ASSUME_NONNULL_END
