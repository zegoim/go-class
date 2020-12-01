//
//  ZegoMediaCenter.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/5/28.
//  Copyright © 2020 zego. All rights reserved.
//


#ifdef IS_USE_LIVEROOM
#import "ZegoLiveRoomLiveCenter.h"
#define ZegoLiveCenter ZegoLiveRoomLiveCenter

#else
#import "ZegoExpressLiveCenter.h"
#define ZegoLiveCenter ZegoExpressLiveCenter

#endif

