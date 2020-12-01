//
//  ZegoClassInviteManager.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/11.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoClassInviteManager.h"
#import <MessageUI/MessageUI.h>
#import "ZegoToast.h"
@implementation ZegoClassInviteManager


+ (void)pastInviteContentWithUserName:(NSString *)userName roomID:(NSString *)roomID isEnvAbroad:(BOOL)isAbroad {
    NSMutableString *inviteText = [[NSMutableString alloc] init];
    
    // xxx邀请你加入会议
    [inviteText appendString:[NSString stringWithFormat:@"%@邀请你加入课堂",userName]];
    [inviteText appendString:@"\n\n"];
    
    // 会议ID
    [inviteText appendString:@"课堂链接:"];
    [inviteText appendString:@"\n"];
    [inviteText appendFormat:@"https://goclass.zego.im/#/login?roomId=%@&env=%@", roomID, isAbroad ? @"overseas" : @"home"];
    [inviteText appendString:@"\n"];
    
    // 会议时间
    [inviteText appendString: [NSString stringWithFormat:@"课堂ID: %@", roomID]];
    [inviteText appendString:@"\n"];
    [inviteText appendString: [NSString stringWithFormat:@"接入环境: %@", isAbroad ? @"海外" : @"中国内地"]];
    
    if (inviteText.length) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = inviteText;
        [ZegoToast showText:@"邀请信息复制成功"];
    }
    
}


@end
