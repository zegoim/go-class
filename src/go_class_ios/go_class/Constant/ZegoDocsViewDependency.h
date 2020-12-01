//
//  ZegoDocsViewDependency.h
//  ZegoWhiteboardVideoDemo
//
//  Created by Vic on 2020/11/16.
//  Copyright © 2020 zego. All rights reserved.
//

#ifndef ZegoDocsViewDependency_h
#define ZegoDocsViewDependency_h

/**
 如果 ZegoDocsView SDK 通过 pod 以 framework 的形式引入, 则设值为 1. 否则为 0.
 主要为了方便直接调试 ZegoDocsView
 */
#define ZEGO_DOCS_AS_POD_FRAMEWORK 1

#if ZEGO_DOCS_AS_POD_FRAMEWORK == 1
#import <ZegoDocsView/ZegoDocsView.h>
#import <ZegoDocsView/ZegoDocsViewManager.h>
#else
#import "ZegoDocsView/Header/ZegoDocsView.h"
#import "ZegoDocsView/Header/ZegoDocsViewManager.h"
#endif

#endif /* ZegoDocsViewDependency_h */
