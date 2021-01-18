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
#import "NSString+ZegoExtension.h"
@implementation ZegoClassInviteManager


+ (void)pastInviteContentWithUserName:(NSString *)userName roomID:(NSString *)roomID isEnvAbroad:(BOOL)isAbroad {
    NSMutableString *inviteText = [[NSMutableString alloc] init];
    
    // xxx邀请你加入会议
    [inviteText appendString:[NSString stringWithFormat:@"%@%@",userName,[NSString zego_localizedString:@"room_dialog_invite_join_class"]]];
    [inviteText appendString:@"\n\n"];
    
    // 会议ID
    [inviteText appendString:[NSString stringWithFormat:@"%@:",[NSString zego_localizedString:@"room_dialog_classroom_link"]]];
    [inviteText appendString:@"\n"];
    [inviteText appendFormat:@"https://goclass.zego.im/#/login?roomId=%@&env=%@", roomID, isAbroad ? @"overseas" : @"home"];
    [inviteText appendString:@"\n"];
    
    // 会议时间
    [inviteText appendString: [NSString stringWithFormat:@"%@: %@",[NSString zego_localizedString:@"room_dialog_class_id"], roomID]];
    [inviteText appendString:@"\n"];
    [inviteText appendString: [NSString stringWithFormat:@"%@: %@", [NSString zego_localizedString:@"room_dialog_access_env"],isAbroad ? [NSString zego_localizedString:@"room_dialog_overseas"] : [NSString zego_localizedString:@"room_dialog_mainland_china"]]];
    
    if (inviteText.length) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = inviteText;
        [ZegoToast showText:[NSString zego_localizedString:@"room_dialog_invitation_successfully"]];
    }
    
}


@end
