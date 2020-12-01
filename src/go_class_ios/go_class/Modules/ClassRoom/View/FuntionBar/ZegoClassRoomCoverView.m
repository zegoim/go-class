//
//  ZegoClassRoomCoverView.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/8.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoClassRoomCoverView.h"
#import "UIColor+ZegoExtension.h"
#import "ZegoUIConstant.h"

@interface ZegoClassRoomCoverView ()

@property (nonatomic, copy) void (^exitAction)(void);

@end

@implementation ZegoClassRoomCoverView

- (instancetype)initWithTitle:(NSString *)title exitButtonTapped:(void (^)(void))exitAction {
    if (self = [super init]) {
        self.exitAction = exitAction;
        self.frame = CGRectMake(0, 0, kScreenWidth, 44);
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.85];
        
        self.exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.exitButton];
        [self.exitButton addTarget:self action:@selector(exitButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.exitButton setTitleColor:[UIColor colorWithRGB:@"#f54326"] forState:UIControlStateNormal];
        [self.exitButton setTitle:@"退出" forState:UIControlStateNormal];
        self.exitButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        self.exitButton.frame = CGRectMake(kScreenWidth - 34 - 20, 0, 34, 44);
        

        self.titleLabel = [[UILabel alloc] init];
        [self addSubview:self.titleLabel];
        self.titleLabel.text = [NSString stringWithFormat:@"课堂ID:%@", title];
        self.titleLabel.textColor = kTextColor1;
        self.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        [self.titleLabel sizeToFit];
        CGSize labelSize = self.titleLabel.frame.size;
        self.titleLabel.frame = CGRectMake((kScreenWidth - labelSize.width)/2, 0, labelSize.width, 44);
    }
    return self;
}

- (void)exitButtonTapped {
    if (self.exitAction) {
        self.exitAction();
    }
}

@end
