//
//  ZegoChatTableViewCell.m
//  ZegoEducation
//
//  Created by MrLQ  on 2018/10/29.
//  Copyright © 2018 Shenzhen Zego Technology Company Limited. All rights reserved.
//

#import "ZegoChatTableViewCell.h"
#import "UIColor+ZegoExtension.h"
#import "ZegoChatModel.h"
#import "ZegoUIConstant.h"
#import "ZegoImBubbleImage.h"
#import <YYText/YYText.h>

#define TextMarginEdgeInset 8
#define BubbleMarginTop 2.5
#define NameHeight 10

@implementation ZegoChatTableViewCell
{
    YYLabel      * _nameLabel;
    YYLabel      * _contentLabel;
    YYLabel      * _systemMsgLabel;
    CAShapeLayer * _maskLayer;
    UIButton     * _faileButton;
    UIButton     * _sendingButton;
    ZegoImBubbleImage  *_bubbleImage;//文字背景
    UIActivityIndicatorView *_indicatorView;//菊花
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setCellUI];
    }
    return self;
}

- (void)setCellUI
{
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.clipsToBounds = YES;
    
    _nameLabel = [[YYLabel alloc]init];
    _nameLabel.numberOfLines = 1;
    _nameLabel.textColor = UIColorHex(#85878b);
    _nameLabel.font = [UIFont systemFontOfSize:9];
    _nameLabel.hidden = YES;
    [self.contentView addSubview:_nameLabel];
    
    _bubbleImage = [[ZegoImBubbleImage alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    _bubbleImage.borderTopLeftRadius = 12;
    _bubbleImage.borderTopRightRadius = 3;
    _bubbleImage.borderBottomLeftRadius = 12;
    _bubbleImage.borderBottomRightRadius = 12;
    _bubbleImage.contentMode = UIViewContentModeRedraw;
    [self.contentView addSubview:_bubbleImage];
    
//    _maskLayer = [CAShapeLayer layer];
//    _maskLayer.shadowOpacity = 1;
//    _maskLayer.shadowOffset = CGSizeMake(0, 1);
//    _maskLayer.shadowRadius = 3;
//    [_bubbleImage.layer addSublayer:_maskLayer];
    
    _contentLabel = [[YYLabel alloc] init];
    _contentLabel.backgroundColor = [UIColor clearColor];
    _contentLabel.numberOfLines = 0 ;
    _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [_bubbleImage addSubview:_contentLabel];
    
    _systemMsgLabel = [[YYLabel alloc]init];
    _systemMsgLabel.textAlignment = NSTextAlignmentCenter;
    _systemMsgLabel.numberOfLines = 1;
    _systemMsgLabel.hidden = YES;
    [self.contentView addSubview:_systemMsgLabel];
    
    UIImage * image = [UIImage imageNamed:@"discuss_fail_1"];
    _faileButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
    [_faileButton setImage:image forState:UIControlStateNormal];
    _faileButton.hidden = YES;
    [self.contentView addSubview:_faileButton];
    
    _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGAffineTransform transform = CGAffineTransformMakeScale(0.7, 0.7);
    _indicatorView.transform = transform;
    _indicatorView.hidden = YES;
    _indicatorView.frame = CGRectMake(0, 0, 17, 17);
    [self.contentView addSubview:_indicatorView];
    
    
    [_faileButton addTarget:self action:@selector(onResendMessage) forControlEvents:UIControlEventTouchUpInside];
}


- (void)setChatModel:(ZegoChatModel *)chatModel
{
    _chatModel = chatModel;
    if (chatModel.messageInfo.fromUser) {
        [_nameLabel setText:chatModel.messageInfo.fromUser.userName];
    }
    
    CGSize contentSize = [ZegoChatTableViewCell caculateContentSize:chatModel];
    
    CGFloat originX = 0;
    CGFloat originY = BubbleMarginTop;
    if (chatModel.senderType == ZegoChatMsgSenderTypeSelf) {//我的消息
        originX = kStreamCellWidth - contentSize.width - TextMarginEdgeInset - TextMarginEdgeInset - BubbleMarginTop;
        _systemMsgLabel.hidden = YES;
        _nameLabel.hidden = YES;
        _contentLabel.hidden = NO;
        _bubbleImage.hidden = NO;
        _nameLabel.frame = CGRectMake(TextMarginEdgeInset, BubbleMarginTop, 0, 0);//不显示名字
        _bubbleImage.borderTopLeftRadius = 12;
        _bubbleImage.borderTopRightRadius = 3;
        _bubbleImage.borderBottomLeftRadius = 12;
        _bubbleImage.borderBottomRightRadius = 12;
        _bubbleImage.backgroundColor = UIColorHex(#1742f5);
        //_maskLayer.shadowColor = [UIColor colorWithRed:23.0f/255.0f green:66.0f/255.0f blue:245.0f/255.0f alpha:0.2f].CGColor;
        
    } else if (chatModel.senderType == ZegoChatMsgSenderTypeOther) {//他人消息
        originX = 8.f;
        originY = BubbleMarginTop + NameHeight + BubbleMarginTop;
        _systemMsgLabel.hidden = YES;
        _contentLabel.hidden = NO;
        _bubbleImage.hidden = NO;
        if (self.lastModel && self.lastModel.messageInfo.fromUser && [self.lastModel.messageInfo.fromUser.uid isEqualToString:chatModel.messageInfo.fromUser.uid]) {
            originY = BubbleMarginTop;
            _nameLabel.hidden = YES;
            _nameLabel.frame = CGRectMake(TextMarginEdgeInset, BubbleMarginTop, 0, 0);
        } else {
            _nameLabel.hidden = NO;
            _nameLabel.frame = CGRectMake(TextMarginEdgeInset, BubbleMarginTop, kStreamCellWidth - 16, NameHeight);
        }
        _bubbleImage.borderTopLeftRadius = 3;
        _bubbleImage.borderTopRightRadius = 12;
        _bubbleImage.borderBottomLeftRadius = 12;
        _bubbleImage.borderBottomRightRadius = 12;
        _bubbleImage.backgroundColor = UIColorHex(#ffffff);
        //_maskLayer.shadowColor = [UIColor colorWithRed:23.0f/255.0f green:66.0f/255.0f blue:245.0f/255.0f alpha:0.2f].CGColor;
    } else if (chatModel.senderType == ZegoChatMsgSenderTypeSystem) {//系统消息
        _systemMsgLabel.hidden = NO;
        _nameLabel.hidden = YES;
        _contentLabel.hidden = YES;
        _bubbleImage.hidden = YES;
        _systemMsgLabel.frame = CGRectMake(8, BubbleMarginTop, kStreamCellWidth - 16, contentSize.height);
        _systemMsgLabel.attributedText = [ZegoChatTableViewCell getAttributedString:chatModel];
    }
    _bubbleImage.frame = CGRectMake(originX, originY, contentSize.width + TextMarginEdgeInset *2, contentSize.height + TextMarginEdgeInset *2);
    _contentLabel.frame = CGRectMake(TextMarginEdgeInset, TextMarginEdgeInset, contentSize.width, contentSize.height);
    _contentLabel.attributedText = [ZegoChatTableViewCell getAttributedString:chatModel];
    
//    CGRect pathRect = CGRectMake(0, 0, _bubbleImage.frame.size.width + 48 * 0.5, _bubbleImage.frame.size.height + 14 * 0.5);
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:pathRect byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(8 * 0.5, 8 * 0.5)];
//    _maskLayer.path = maskPath.CGPath;
    
//    _maskLayer.bounds = _bubbleImage.bounds;
//    CGFloat shadowSize0 = -1;
//    CGRect shadowSpreadRect0 = CGRectMake(-shadowSize0, -shadowSize0, _bubbleImage.bounds.size.width+shadowSize0*2, _bubbleImage.bounds.size.height+shadowSize0*2);
//    CGFloat shadowSpreadRadius0 =  _bubbleImage.layer.cornerRadius == 0 ? 0 : _bubbleImage.layer.cornerRadius+shadowSize0;
//    UIBezierPath *shadowPath0 = [UIBezierPath bezierPathWithRoundedRect:shadowSpreadRect0 cornerRadius:shadowSpreadRadius0];
//    _maskLayer.shadowPath = shadowPath0.CGPath;
    
    _faileButton.frame = CGRectMake(CGRectGetMinX(_bubbleImage.frame) - 15 - 5, CGRectGetMinY(_bubbleImage.frame) + (CGRectGetHeight(_bubbleImage.frame) - 15) / 2, 15, 15);
    
    _indicatorView.frame = CGRectMake(_faileButton.frame.origin.x - 1, _faileButton.frame.origin.y - 1, 17, 17);
    
    _faileButton.hidden = YES;
    _indicatorView.hidden = YES;
    [_indicatorView stopAnimating];
    
    if (chatModel.msgStatus == kZegoChatSending) {
        _indicatorView.hidden = NO;
        [_indicatorView startAnimating];
    }else if(chatModel.msgStatus == kZegoChatSendFailed){
        _faileButton.hidden = NO;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

+ (NSAttributedString *)getAttributedString:(ZegoChatModel *)chatModel
{
    // 系统消息
    if (chatModel.senderType == ZegoChatMsgSenderTypeSystem) {
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc]init];
        NSAttributedString * content = [[NSAttributedString alloc]initWithString:chatModel.messageInfo.message attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9.0], NSForegroundColorAttributeName :UIColorHex(#85878b)}];
        [str appendAttributedString:content];
        str.yy_alignment = NSTextAlignmentCenter;
        return str;
    }
    UIColor *textColor = chatModel.senderType == ZegoChatMsgSenderTypeSelf ? UIColorHex(#ffffff):UIColorHex(#585c62);
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc]init];
    NSMutableAttributedString * content = [[NSMutableAttributedString alloc]initWithString:chatModel.messageInfo.message attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9.0], NSForegroundColorAttributeName : textColor}];
    content.yy_lineSpacing = 4.f;

    //判断超链接
//    NSError *error;
//    NSString *regulaStr = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
//                                                                               options:NSRegularExpressionCaseInsensitive
//                                                                                 error:&error];
//    NSArray *arrayOfAllMatches = [regex matchesInString:chatModel.messageInfo.message options:0 range:NSMakeRange(0, [chatModel.messageInfo.message length])];
//
//    for (NSTextCheckingResult *match in arrayOfAllMatches)
//    {
//        [content setTextHighlightRange:match.range
//                                   color:UIColorHex(#1a7bff)
//                           backgroundColor:UIColor.clearColor
//                                 tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
//            if (text.length) {
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[text.string substringWithRange:range]]];
//            }
//        }];
//        [content setUnderlineStyle:NSUnderlineStyleSingle range:match.range];
//    }
    [str appendAttributedString:content];
    return str;
}

+ (CGSize)caculateContentSize:(ZegoChatModel *)model
{
    //计算文本尺寸
    CGFloat maxWidth = kStreamCellWidth - 8 - 8 - 8 - 11 - 5 - 8;
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(maxWidth, CGFLOAT_MAX) text:[ZegoChatTableViewCell getAttributedString:model]];
    return layout.textBoundingSize;
}

+ (CGFloat)caculateCellHeight:(ZegoChatModel *)model lastModel:(ZegoChatModel *)lastModel {
    if (model.senderType == ZegoChatMsgSenderTypeSelf) {
        return [ZegoChatTableViewCell caculateContentSize:model].height + BubbleMarginTop *2 + TextMarginEdgeInset * 2;
    } else if (model.senderType == ZegoChatMsgSenderTypeOther) {
        if (lastModel && lastModel.messageInfo.fromUser && [lastModel.messageInfo.fromUser.uid isEqualToString:model.messageInfo.fromUser.uid]) {
            return [ZegoChatTableViewCell caculateContentSize:model].height + BubbleMarginTop * 2 + TextMarginEdgeInset *2;
        } else {
            return [ZegoChatTableViewCell caculateContentSize:model].height + NameHeight + BubbleMarginTop *3 + TextMarginEdgeInset *2;
        }
    } else if (model.senderType == ZegoChatMsgSenderTypeSystem) {
        return [ZegoChatTableViewCell caculateContentSize:model].height + BubbleMarginTop * 2;
    }
    return 0.0;
}

- (void)onResendMessage //重发
{
//    self.chatModel.msgStatus = kZegoChatSending;
//    _sendingButton.hidden = NO;
//    _faileButton.hidden = YES;
    //__weak typeof(self) weakSelf = self;
//    [[ZegoMessage sharedInstance]sendMessage:self.chatModel.messageModel withCompletionBlock:^(ZegoSeq seq, ZegoError errorCode, NSString *roomId, unsigned long long messageId) {
//        if (errorCode == kZegoSucceed) {
//            weakSelf.chatModel.status = kZegoChatSendSuccess;
//            [weakSelf setChatModel:weakSelf.chatModel];
//        }else{
//            weakSelf.chatModel.status = kZegoChatSendFailed;
//            [weakSelf setChatModel:weakSelf.chatModel];
//        }
//    }];
}


@end

