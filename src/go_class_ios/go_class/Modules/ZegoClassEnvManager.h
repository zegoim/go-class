//
//  ZegoClassEnvManager.h
//  ZegoWhiteboardVideoDemo
//
//  Created by MartinNie on 2020/11/10.
//  Copyright © 2020 z/Users/zego/Desktop/未命名文件夹/ZegoWhiteboardVideoDemo/ZegoWhiteboardVideoDemo/Modules/ZegoEnvSettingViewController.hego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoClassEnvManager : NSObject
@property (nonatomic, assign) BOOL businessTestEnv;
@property (nonatomic, assign) BOOL roomSeviceTestEnv;
@property (nonatomic, assign) BOOL docsSeviceTestEnv;
@property (nonatomic, assign) BOOL abroadEnv;
@property (nonatomic, assign) BOOL isChinese;
@property (nonatomic, assign) BOOL isSystemFont;

// “1”: 正常上一步和下一步，如果外部未设置，默认该模式；
// “2”: 页中的第一步执行上一步时，不跳转，页中的最后一步执行下一步时，不跳转。
@property (nonatomic, assign) BOOL pptStepDefaultMode;

+ (instancetype)shareManager;

- (void)setNomalEnv;

@end

NS_ASSUME_NONNULL_END
