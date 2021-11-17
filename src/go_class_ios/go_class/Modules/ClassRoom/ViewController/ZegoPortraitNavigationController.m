//
//  ZegoPortraitNavigationController.m
//  go_class
//
//  Created by Vic on 2021/6/18.
//  Copyright © 2021 zego. All rights reserved.
//

#import "ZegoPortraitNavigationController.h"

@interface ZegoPortraitNavigationController ()

@end

@implementation ZegoPortraitNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotate {
  return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
  return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

@end
