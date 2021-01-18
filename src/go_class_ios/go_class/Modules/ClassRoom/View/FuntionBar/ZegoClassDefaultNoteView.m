//
//  ZegoClassDefaultNoteView.m
//  ZegoWhiteboardVideoDemo
//
//  Created by MartinNie on 2020/11/5.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoClassDefaultNoteView.h"
#import "NSString+ZegoExtension.h"
@interface ZegoClassDefaultNoteView ()

@property (nonatomic, weak) IBOutlet UIButton *fileTypeBtn;
@property (nonatomic, weak) IBOutlet UIButton *whiteboardTypeBtn;
@property (nonatomic, weak) IBOutlet UILabel *tipLabel;
@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, weak) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, weak) IBOutlet UIImageView *placeholderIV;
@end
@implementation ZegoClassDefaultNoteView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.fileTypeBtn setTitle:[NSString zego_localizedString:@"wb_shared_file"] forState:UIControlStateNormal];
    [self.whiteboardTypeBtn setTitle:[NSString zego_localizedString:@"wb_shared_wb"] forState:UIControlStateNormal];
    self.tipLabel.text = [NSString zego_localizedString:@"wb_select_share"];
    self.placeholderLabel.text = [NSString zego_localizedString:@"wb_tip_wait_teacher_share"];
}

- (void)showTipStyleWithClassType:(ZegoClassPatternType)classType
{
    if (classType == ZegoClassPatternTypeBig) {
        self.contentView.hidden = YES;
        self.placeholderLabel.hidden = NO;
        self.placeholderIV.hidden = NO;
    } else {
        self.contentView.hidden = NO;
        self.placeholderLabel.hidden = YES;
        self.placeholderIV.hidden = YES;
    }
}

@end
