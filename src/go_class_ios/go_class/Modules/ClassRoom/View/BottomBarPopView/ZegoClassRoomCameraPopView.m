//
//  ZegoClassRoomCameraPopView.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/3.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoClassRoomCameraPopView.h"

@interface ZegoClassRoomCameraPopView ()
@property (strong, nonatomic) IBOutlet ZegoClassRoomCameraPopView *view;

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
    }
    
    return self;
}


@end
