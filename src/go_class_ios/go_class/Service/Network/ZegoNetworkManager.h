//
//  ZegoNetworkManager.h
//  TalkLineSDK
//
//  Created by Larry on 2020/6/14.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZegoBaseCommand.h"
#import "ZegoResponseModel.h"

typedef void(^ZegoRequestBlock)(ZegoResponseModel *response);

@interface ZegoNetworkManager : NSObject

+ (ZegoNetworkManager *)sharedInstance;

+ (void)requestWithCommand:(ZegoBaseCommand *)command
                   success:(ZegoRequestBlock)success
                   failure:(ZegoRequestBlock)failure;

+ (void)regListener:(id)listener
            command:(ZegoBaseCommand *)command
           response:(ZegoRequestBlock)response;

+ (void)removeListener:(id)listener
               command:(ZegoBaseCommand *)command
              response:(ZegoRequestBlock)response;

+ (NSString *)getHostWithEnv;
@end
