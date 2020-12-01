//
//  ZegoWhiteBoardListCell.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/15.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoWhiteBoardListCell.h"

@implementation ZegoWhiteBoardListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)onCloseButtonTapped:(id)sender {
    if (self.onTapCloseButton) {
        self.onTapCloseButton();
    }
}

@end
