//
//  ZegoClassRoomBottomBarCell.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/2.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoClassRoomBottomBarCell.h"
#import "UIColor+ZegoExtension.h"
#import "ZegoUIConstant.h"

@implementation ZegoClassRoomBottomCellModel
- (instancetype)initWithType:(ZegoClassRoomBottomCellType)type isSelected:(BOOL)isSelected imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName title:(NSString *)title {
    if (self = [super init]) {
        _type = type;
        _isSelected = isSelected;
        _imageName = imageName;
        _selectedImageName = selectedImageName;
        _title = title;
    }
    return self;
}
@end


@interface ZegoClassRoomBottomBarCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@property (strong, nonatomic) ZegoClassRoomBottomCellModel *model;

@end

@implementation ZegoClassRoomBottomBarCell

- (void)refreshWithModel:(ZegoClassRoomBottomCellModel *)model {
    self.model = model;
    if (model.isSelected) {
        self.imageView.image = [UIImage imageNamed:model.selectedImageName];
        self.titleLabel.textColor = kThemeColorBlue;
    } else{
        self.imageView.image = [UIImage imageNamed:model.imageName];
        self.titleLabel.textColor = [UIColor colorWithRGB:@"#585c62"];
    }
    if (model.numberString) {
        self.numberLabel.hidden = NO;
        self.numberLabel.text = model.numberString;
    } else {
        self.numberLabel.hidden = YES;
    }
    
    self.titleLabel.text = model.title;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.numberLabel.layer.masksToBounds = YES;
    self.numberLabel.layer.cornerRadius = 2;
    // Initialization code
}

@end
