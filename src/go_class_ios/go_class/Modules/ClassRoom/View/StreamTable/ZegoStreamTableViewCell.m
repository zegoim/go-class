//
//  ZegoStreamTableViewCell.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/5/28.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoStreamTableViewCell.h"
#import "UIColor+ZegoExtension.h"
@interface ZegoStreamTableViewCell ()
@property (nonatomic, strong) UILabel *roleTypeLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIImageView *placeHolderIV;
@property (nonatomic, strong) UIImageView *cameraIV;
@property (nonatomic, strong) UIImageView *micIV;
@property (nonatomic, strong) UIImageView *fileShareIV;
@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) UIView *lineView;
@end
@implementation ZegoStreamTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    self.backgroundColor = [UIColor colorWithRGB:@"#f3f6ff"];
    self.tipLabel = [[UILabel alloc] init];
    self.tipLabel.font = [UIFont systemFontOfSize:10];
    self.tipLabel.textColor = [UIColor grayColor];
    self.tipLabel.backgroundColor = [UIColor clearColor];
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.tipLabel];
    
    self.placeHolderIV = [[UIImageView alloc] init];
    [self.contentView addSubview:self.placeHolderIV];
    
    self.previewView = [[UIView alloc] init];
    [self.contentView addSubview:self.previewView];
    self.previewView.backgroundColor = [UIColor clearColor];
    
    self.roleTypeLabel = [[UILabel alloc] init];
    self.roleTypeLabel.font = [UIFont systemFontOfSize:10];
    self.roleTypeLabel.textColor = [UIColor whiteColor];
    self.roleTypeLabel.backgroundColor = [UIColor colorWithRGB:@"#4879ff"];
    self.roleTypeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.roleTypeLabel];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont systemFontOfSize:10];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.backgroundColor = [UIColor colorWithRGB:@"#000000" alpha:0.4];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.nameLabel];
    self.nameLabel.clipsToBounds = YES;
    
    self.cameraIV = [[UIImageView alloc] init];
    [self.contentView addSubview:self.cameraIV];
    self.cameraIV.image = [UIImage imageNamed:@"camera"];
    self.cameraIV.backgroundColor = [UIColor colorWithRGB:@"#000000" alpha:0.5];
    self.cameraIV.clipsToBounds = YES;
    
    self.micIV = [[UIImageView alloc] init];
    [self.contentView addSubview:self.micIV];
    self.micIV.image = [UIImage imageNamed:@"micophone"];
    self.micIV.backgroundColor = [UIColor colorWithRGB:@"#000000" alpha:0.5];
    self.micIV.clipsToBounds = YES;
    
    self.fileShareIV = [[UIImageView alloc] init];
    [self.contentView addSubview:self.fileShareIV];
    self.fileShareIV.image = [UIImage imageNamed:@"share"];
    self.fileShareIV.backgroundColor = [UIColor colorWithRGB:@"#000000" alpha:0.5];
    self.fileShareIV.clipsToBounds = YES;

    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.lineView];
    self.hiddenMarkView = NO;
}

- (void)setupModel:(ZegoStreamWrapper *)model complement:(void(^)(UIView *previewView))startPlayStreamBlock;
{
    _model = model;
    if (model.userStatusModel.camera == 2) {
        self.cameraIV.image = [UIImage imageNamed:@"camera_1"];
        self.previewView.hidden = NO;
    } else {
        self.cameraIV.image = [UIImage imageNamed:@"camera_close_1"];
        self.previewView.hidden = YES;
    }
    
    if (model.userStatusModel.mic == 2) {
        self.micIV.image = [UIImage imageNamed:@"micophone"];
    } else {
        self.micIV.image = [UIImage imageNamed:@"micophone_close"];
    }
    
    if (model.userStatusModel.canShare == 2) {
        self.fileShareIV.image = [UIImage imageNamed:@"share"];
    } else {
        self.fileShareIV.image = [UIImage imageNamed:@"share_clos"];
    }
    //如果角色信息不确定则按占位视图显示
    if (self.hiddenMarkView && model.userStatusModel.userName.length < 1) {
        self.fileShareIV.hidden = YES;
        self.micIV.hidden = YES;
        self.cameraIV.hidden = YES;
        self.tipLabel.text = @"等待老师加入";
        
    } else {
        self.fileShareIV.hidden = NO;
        self.micIV.hidden = NO;
        self.cameraIV.hidden = NO;
        self.tipLabel.text = @"";
    }
    
    if (model.userStatusModel.role == ZegoUserRoleTypeTeacher) {
        self.placeHolderIV.image = [UIImage imageNamed:@"teacher"];
        self.roleTypeLabel.hidden = NO;
        self.roleTypeLabel.text = @"老师";
        self.fileShareIV.hidden = YES;
    } else {
        self.placeHolderIV.image = [UIImage imageNamed:@"student"];
        self.tipLabel.text = nil;
        self.roleTypeLabel.hidden = YES;
        self.fileShareIV.hidden = NO;
    }
    if (model.userStatusModel.userName.length > 0) {
        self.nameLabel.hidden = NO;
        self.nameLabel.text = model.userStatusModel.userName;
    } else {
        self.nameLabel.hidden = YES;
    }
    if (startPlayStreamBlock) {
        startPlayStreamBlock(self.previewView);
    }
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
   
    CGFloat contentWidth = self.contentView.bounds.size.width;
    CGFloat contentHeight = self.contentView.bounds.size.height;
    self.previewView.frame = CGRectMake(0, 0, contentWidth, contentHeight - 1);
    self.roleTypeLabel.frame = CGRectMake(0, 0, 28, 16);

    CGFloat height = 18;
    //尺寸设定为75 最多显示6个字。
    CGFloat margin = 8;
    if (!self.nameLabel.hidden) {
        CGFloat width = [self.nameLabel.text boundingRectWithSize:CGSizeMake(75, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.nameLabel.font} context:nil].size.width + 2 * margin;
        
        self.nameLabel.frame = CGRectMake(contentWidth - margin - width, contentHeight - margin - height, width, height);
        self.nameLabel.layer.cornerRadius = height/2;
    }
    CGFloat imageWidth = 16;
    CGFloat imageMargin = 5;
    if (!self.fileShareIV.hidden) {
        self.fileShareIV.frame = CGRectMake(contentWidth - margin - imageWidth, margin, imageWidth, imageWidth);
        self.micIV.frame = CGRectMake(CGRectGetMinX(self.fileShareIV.frame) - imageWidth - imageMargin, margin, imageWidth, imageWidth);
    } else {
        self.fileShareIV.frame = CGRectMake(contentWidth - margin - imageWidth, margin, 0, imageWidth);
        self.micIV.frame = CGRectMake(CGRectGetMaxX(self.fileShareIV.frame), margin, imageWidth, imageWidth);
    }
    
    self.cameraIV.frame = CGRectMake(CGRectGetMinX(self.micIV.frame) - imageWidth - imageMargin, margin, imageWidth, imageWidth);
    self.fileShareIV.layer.cornerRadius = imageWidth/2;
    self.micIV.layer.cornerRadius = imageWidth/2;
    self.cameraIV.layer.cornerRadius = imageWidth/2;
    CGFloat placeHolderWidth = 32;
    CGFloat tipTxtHeight = 0;
    CGFloat tipTxtWidth = [self.tipLabel.text boundingRectWithSize:CGSizeMake(contentWidth, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.tipLabel.font} context:nil].size.width;
    tipTxtHeight = tipTxtWidth > 0 ? height:0;
    CGFloat placeHolderOriginalY = (contentHeight - placeHolderWidth - margin - tipTxtHeight)/2;
    self.tipLabel.frame = CGRectMake((contentWidth - tipTxtWidth)/2, contentHeight - placeHolderOriginalY - tipTxtHeight , tipTxtWidth, tipTxtHeight);
    self.placeHolderIV.frame = CGRectMake((contentWidth - placeHolderWidth)/2, CGRectGetMinY(self.tipLabel.frame) - margin - placeHolderWidth , placeHolderWidth, placeHolderWidth);
    self.lineView.frame = CGRectMake(0, contentHeight - 1, contentWidth, 1);
}



@end
