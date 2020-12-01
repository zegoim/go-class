//
//  ZegoClassRoomSharePopView.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/3.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoClassRoomSharePopView.h"

@interface ZegoClassRoomSharePopView ()
@property (strong, nonatomic) IBOutlet ZegoClassRoomSharePopView *view;

@end

@implementation ZegoClassRoomSharePopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[NSBundle mainBundle] loadNibNamed:@"ZegoClassRoomSharePopView" owner:self options:nil];
        [self addSubview:self.view];
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
