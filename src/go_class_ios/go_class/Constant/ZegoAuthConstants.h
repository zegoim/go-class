//
//  ZegoAuthConstants.h
//  ZegoWhiteboardViewDemo
//
//  Created by zego on 2020/4/28.
//  Copyright © 2020 zego. All rights reserved.
//

#ifndef ZegoAuthConstants_h
#define ZegoAuthConstants_h
//此处是对应了 国内环境,国外环境，大班课，小班课appid及appSign，如果仅测试国内环境小班课则只需要填充kZegoAppID，kZegoSign
//使用此demo运行时，必须与技术支持获取业务后台代码，并部署完成后，替换下方的kZegoGoClassHomeServerHost字段对应的地址，方可登录成功。
//SDK 运行分为正式环境和测试环境，相关设置请查看：ZegoClassEnvManager

//此处是国内小班课appID及appSign
#ifdef IS_USE_LIVEROOM
static long long kZegoAppID = 0;
static unsigned char kZegoSign[] = { 
};

//此处是国外小班课appID及appSign
static long long kZegoAppIDAbroad = 0;
static unsigned char kZegoSignAbroad[] = { 
};

//此处是国内大班课appID及appSign
static long long kZegoAppIDBigClass = 0;
static unsigned char kZegoSignBigClass[] = { 
};

//此处是国外大班课appID及appSign
static long long kZegoAppIDAbroadBigClass = 0;
static unsigned char kZegoSignAbroadBigClass[] = {
};

#else
static long long kZegoAppID = 0;
static NSString * kZegoSign = @"";

//此处是国外小班课appID及appSign
static long long kZegoAppIDAbroad = 0;
static NSString * kZegoSignAbroad = @"";

//此处是国内大班课appID及appSign
static long long kZegoAppIDBigClass = 0;
static NSString * kZegoSignBigClass = @"";

//此处是国外大班课appID及appSign
static long long kZegoAppIDAbroadBigClass = 0;
static NSString * kZegoSignAbroadBigClass = @"";
#endif

//国内正式环境业务后台地址
static NSString *kZegoGoClassHomeServerHost = @"https://goclass-server-sh.zego.im";
//国内测试环境业务后台地址
static NSString *kZegoGoClassHomeServerHostTest = @"https://backend-alpha.talkline.cn";
//国外正式环境业务后台地址
static NSString *kZegoGoClassAbroadServerHost = @"https://goclass-server-hk.zegocloud.com";
//国外测试环境业务后台地址
static NSString *kZegoGoClassAbroadServerHostTest = @"https://goclass-server-alpha.zego.im";



static NSString *kIsTestEnvKey = @"ZegoIsTestEnvKey";
static NSString *kUserIDKey = @"ZegoUserIDKey";
static NSString *kAppIDKey = @"ZegoAppID";
static NSString *kAppSignKey = @"ZegoAppAppSign";

#define kZegoRoomId @"555"
#define kZegoDocsDataPath [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ZegoDocs"] stringByAppendingString:@""]
#define kZegoLogPath [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ZegoLogFile"]
#define kZegoAPPTeminalNotification @"kZegoAPPTeminalNotification"

#define kZegoRoomCurrentWhiteboardKey @"1001"
#endif /* ZegoAuthConstants_h */
