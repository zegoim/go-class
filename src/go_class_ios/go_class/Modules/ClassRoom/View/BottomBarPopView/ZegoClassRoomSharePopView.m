//
//  ZegoClassRoomSharePopView.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/3.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoClassRoomSharePopView.h"
#import "NSString+ZegoExtension.h"
@interface ZegoClassRoomSharePopView ()
@property (strong, nonatomic) IBOutlet ZegoClassRoomSharePopView *view;
@property (weak, nonatomic) IBOutlet UILabel *whiteboardLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileLabel;

@end

@implementation ZegoClassRoomSharePopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[NSBundle mainBundle] loadNibNamed:@"ZegoClassRoomSharePopView" owner:self options:nil];
        [self addSubview:self.view];
        self.whiteboardLabel.text = [NSString zego_localizedString:@"room_controller_whiteboard"];
        self.fileLabel.text = [NSString zego_localizedString:@"room_controller_docs"];
    }
    
    return self;
}

- (IBAction)onTapWhiteBoard:(id)sender {
    if (self.onTapAction) {
        self.onTapAction(0);
    }
}


- (IBAction)onTapFileButton:(id)sender {
    if (self.onTapAction) {
        self.onTapAction(1);
    }
}


@end
