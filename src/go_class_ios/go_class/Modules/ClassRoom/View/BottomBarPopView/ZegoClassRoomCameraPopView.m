//
//  ZegoClassRoomCameraPopView.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/3.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoClassRoomCameraPopView.h"
#import "NSString+ZegoExtension.h"
@interface ZegoClassRoomCameraPopView ()
@property (strong, nonatomic) IBOutlet ZegoClassRoomCameraPopView *view;
@property (weak, nonatomic) IBOutlet UILabel *closeCameraLabel;
@property (weak, nonatomic) IBOutlet UILabel *switchCameraLabel;

@end

@implementation ZegoClassRoomCameraPopView

- (IBAction)onTapSwitchCamera:(id)sender {
    if (self.onTapAction) {
        self.onTapAction(0);
    }
}

- (IBAction)onTapCloseCamera:(id)sender {
    if (self.onTapAction) {
        self.onTapAction(1);
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[NSBundle mainBundle] loadNibNamed:@"ZegoClassRoomCameraPopView" owner:self options:nil];
        [self addSubview:self.view];
        self.switchCameraLabel.text = [NSString zego_localizedString:@"room_controller_switch_camera"];
        self.closeCameraLabel.text = [NSString zego_localizedString:@"room_turn_off_camera"];
    }
    
    return self;
}


@end
