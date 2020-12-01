//
//  ZegoDefaultFileLoader.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/7/1.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZegoFileInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface ZegoDefaultFileLoader : NSObject

+ (instancetype)defaultLoader;

- (void)loadFileListWithEnv:(BOOL)isTestEnv
                   complete:(void(^)(NSArray<ZegoFileInfoModel *> *fileModels, NSError *error))complete;

@end

NS_ASSUME_NONNULL_END
