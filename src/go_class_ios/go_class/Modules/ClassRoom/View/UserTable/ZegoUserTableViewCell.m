//
//  ZegoUserTableViewCell.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/5/29.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoUserTableViewCell.h"
#import "ZegoUIConstant.h"
#import "UIColor+ZegoExtension.h"
#import "ZegoNetworkManager.h"
#import "ZegoClassCommand.h"
#import <NSObject+YYModel.h>
#import "NSString+ZegoExtension.h"
@interface ZegoUserTableViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *cameraStatuBtn;
@property (weak, nonatomic) IBOutlet UIButton *micStatuBtn;
@property (weak, nonatomic) IBOutlet UIButton *fileShareStatusBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end
@implementation ZegoUserTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Initialization code
    
    self.nameLabel.font = kFontText13;
    self.nameLabel.textColor = kTextColor1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for theww selected state
}

- (void)setModel:(ZegoRoomMemberInfoModel *)model
{
    _model = model;
    //优先显示（我），如果不是自己在判断是否是老师。
    if (model.role == 1) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@(%@)",model.userName,[NSString zego_localizedString:@"login_teacher"]];
    } else {
        self.nameLabel.text = [NSString stringWithFormat:@"%@",model.userName];
    }
    BOOL display = model.isMyself || !self.userInteractionEnabled;
    self.cameraStatuBtn.hidden = display;
    self.micStatuBtn.hidden = display;
    self.fileShareStatusBtn.hidden = display;
    self.cameraStatuBtn.selected = model.camera == 2;
    self.micStatuBtn.selected = model.mic == 2;
    self.fileShareStatusBtn.selected = model.canShare == 2;
}

- (void)hiddenStatusMark:(BOOL)hidden;
{
    self.cameraStatuBtn.hidden = hidden;
    self.micStatuBtn.hidden = hidden;
    self.fileShareStatusBtn.hidden = hidden;
    self.nameLabelToRight.constant = hidden ? 20 : 111;
}

- (IBAction)didClickShareFileBtn:(UIButton *)sender {

    sender.selected = !sender.selected;
    //修改副本的值，然后发送网络请求，以后端判断为根本，成功后由成员状态变更消息中，刷新UI
    ZegoRoomMemberInfoModel *temp = [self.model yy_modelCopy];
    temp.canShare = sender.selected ?2:1;
    if (self.didClickAuthorityStatusBlock) {
        self.didClickAuthorityStatusBlock(temp);
    }
}

- (IBAction)didClickMicBtn:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    //修改副本的值，然后发送网络请求，以后端判断为根本，成功后由成员状态变更消息中，刷新UI
    ZegoRoomMemberInfoModel *temp = [self.model yy_modelCopy];
    temp.mic = sender.selected ?2:1;
    if (self.didClickAuthorityStatusBlock) {
        self.didClickAuthorityStatusBlock(temp);
    }
}

- (IBAction)didClickCameraBtn:(UIButton *)sender {

    sender.selected = !sender.selected;
    //修改副本的值，然后发送网络请求，以后端判断为根本，成功后由成员状态变更消息中，刷新UI
    ZegoRoomMemberInfoModel *temp = [self.model yy_modelCopy];
    temp.camera = sender.selected ?2:1;
    if (self.didClickAuthorityStatusBlock) {
        self.didClickAuthorityStatusBlock(temp);
    }
}

@end
