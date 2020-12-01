//
//  ZegoHUD.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/9/14.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoHUD.h"
#import <MBProgressHUD.h>

@implementation ZegoHUD

+ (void)showIndicatorHUDText:(NSString *)text {
    UIWindow *key = [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD hideHUDForView:key animated:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:key animated:YES];
    hud.bezelView.color = [UIColor colorWithWhite:0 alpha:0.8];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.layer.masksToBounds = YES;
    hud.bezelView.layer.cornerRadius = 4;
    
    hud.contentColor = [UIColor whiteColor];
    
    hud.label.textColor = [UIColor whiteColor];
    hud.label.text = text;
    hud.label.font = [UIFont systemFontOfSize:12];
}

+ (void)dismiss {
    UIWindow *key = [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD hideHUDForView:key animated:YES];
}
@end
