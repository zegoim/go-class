//
//  ZegoClassRoomTopFunctionView.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/1.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoClassRoomTopBar.h"
#import "UIColor+ZegoExtension.h"
#import "ZegoUIConstant.h"
#import "NSString+ZegoExtension.h"

@interface ZegoClassRoomTopBar ()
@property (weak, nonatomic) IBOutlet UILabel *boardNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pageNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *sheetNameLabel;

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIView *infoContainer;
@property (weak, nonatomic) IBOutlet UIView *pageNumberContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageNumberWidth;
@property (weak, nonatomic) IBOutlet UIView *sheetContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sheetWidth;
@property (weak, nonatomic) IBOutlet UIButton *previewBtn;
@end

@implementation ZegoClassRoomTopBar

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.previewBtn setTitle:[NSString zego_localizedString:@"wb_preview"] forState:UIControlStateNormal];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [[NSBundle mainBundle] loadNibNamed:@"ZegoClassRoomTopBar" owner:self options:nil];
        [self addSubview:self.view];
        
        self.view.frame = self.bounds;
        self.infoContainer.layer.masksToBounds = YES;
        self.infoContainer.layer.cornerRadius = 14;
        self.infoContainer.layer.borderColor = kGrayLineColor.CGColor;
        self.infoContainer.layer.borderWidth = 1;
        
        self.pageNumberContainer.layer.masksToBounds = YES;
        self.pageNumberContainer.layer.cornerRadius = 14;
        self.pageNumberContainer.layer.borderColor = kGrayLineColor.CGColor;
        self.pageNumberContainer.layer.borderWidth = 1;
        
        self.sheetContainer.layer.masksToBounds = YES;
        self.sheetContainer.layer.cornerRadius = 14;
        self.sheetContainer.layer.borderColor = kGrayLineColor.CGColor;
        self.sheetContainer.layer.borderWidth = 1;
        
        self.previewBtn.layer.masksToBounds = YES;
        self.previewBtn.layer.cornerRadius = 3;
        self.previewBtn.layer.borderColor = kGrayLineColor.CGColor;
        self.previewBtn.layer.borderWidth = 1;
        [self.previewBtn setTitleColor:kTextColor1 forState:UIControlStateNormal];
    }
    return self;
}

- (void)setCanPreview:(BOOL)canPreview {
    _canPreview = canPreview;
    if (canPreview && self.canShare) {
        self.previewBtn.hidden = NO;
    } else {
        self.previewBtn.hidden = YES;
    }
}

- (void)setCanShare:(BOOL)canShare {
    _canShare = canShare;
    self.pageNumberContainer.hidden = !canShare;
    self.infoContainer.hidden = !canShare;
    self.sheetContainer.hidden = !canShare;
    if (self.canPreview) {
        self.previewBtn.hidden = !canShare;
    } else {
        self.previewBtn.hidden = YES;
    }
}

- (void)refreshWithTitle:(NSString *)title currentIndex:(NSInteger)index totalCount:(NSUInteger)count sheetName:(NSString *)sheetName {
    if (sheetName && self.canShare) {
        self.sheetContainer.hidden = NO;
        self.sheetWidth.constant = 110;
        self.sheetNameLabel.text = sheetName;
    } else {
        self.sheetContainer.hidden = YES;
        self.sheetWidth.constant = 0;
    }
    if (index < 0 && self.canShare) {
        self.pageNumberLabel.hidden = YES;
        self.pageNumberWidth.constant = 0;
    } else {
        self.pageNumberWidth.constant = 110;
        self.pageNumberLabel.hidden = NO;
    }
    self.boardNameLabel.text = [title stringForContainerWidth:self.boardNameLabel.bounds.size.width font:[UIFont systemFontOfSize:12]];
    self.pageNumberLabel.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)index+1, count];
}

- (IBAction)onTapNextButton:(id)sender {
    [self.delegate topBar:self didSelectAction:ZegoClassRoomTopActionTypeNextBoard];
}
- (IBAction)onTapPreButton:(id)sender {
    [self.delegate topBar:self didSelectAction:ZegoClassRoomTopActionTypePreBoard];
}
- (IBAction)onTapFilesButton:(id)sender {
    [self.delegate topBar:self didSelectAction:ZegoClassRoomTopActionTypeBoardList];
}

- (IBAction)onTapSheetsButton:(id)sender {
    [self.delegate topBar:self didSelectAction:ZegoClassRoomTopActionTypeSheetList];
    
}
- (IBAction)didClickPreviewBtn:(UIButton *)sender {
    if (!self.canPreview) {
        return;
    }
    [self resetPreviewDisplay:!sender.selected];
    [self.delegate topBar:self didSelectAction:ZegoClassRoomTopActionTypePreview];
}

- (void)resetPreviewDisplay:(BOOL)display {
    self.previewBtn.selected = display;
    if (display) {
        self.previewBtn.layer.borderColor = kThemeColorBlue.CGColor;
        [self.previewBtn setTitleColor:kThemeColorBlue forState:UIControlStateNormal];
        [self.previewBtn setBackgroundColor:[UIColor colorWithRGB:@"#f0f4ff"]];
    } else {
        self.previewBtn.layer.borderColor = kGrayLineColor.CGColor;
        [self.previewBtn setTitleColor:kTextColor1 forState:UIControlStateNormal];
        [self.previewBtn setBackgroundColor:[UIColor whiteColor]];
    }
}

@end
