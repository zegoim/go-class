//
//  ZegoClassEnvManager.m
//  ZegoWhiteboardVideoDemo
//
//  Created by MartinNie on 2020/11/10.
//  Copyright © 2020 zego. All rights reserved.
//
#define Zego_Env_BusinessEnv @"Zego_Env_BusinessEnv"
#define Zego_Env_RoomSeviceEnv @"Zego_Env_RoomSeviceEnv"
#define Zego_Env_DocsSeviceEnv @"Zego_Env_DocsSeviceEnv"

#define Zego_Test_pptStepDefaultMode @"Zego_Test_pptStepDefaultMode"
#define Zego_Env_Language_Chinese @"Zego_Env_Language_Chinese"
#import "ZegoClassEnvManager.h"

@implementation ZegoClassEnvManager
+ (instancetype)shareManager {
    static ZegoClassEnvManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZegoClassEnvManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _businessTestEnv = [[NSUserDefaults standardUserDefaults] boolForKey:Zego_Env_BusinessEnv];
        _roomSeviceTestEnv = [[NSUserDefaults standardUserDefaults] boolForKey:Zego_Env_RoomSeviceEnv];
        _docsSeviceTestEnv = [[NSUserDefaults standardUserDefaults] boolForKey:Zego_Env_DocsSeviceEnv];
        _pptStepDefaultMode = [[NSUserDefaults standardUserDefaults] boolForKey:Zego_Test_pptStepDefaultMode];
        _isChinese = [[[NSUserDefaults standardUserDefaults] objectForKey:Zego_Env_Language_Chinese] isEqual:@"NO"] ? NO : YES;
    }
    return self;
}

- (void)setNomalEnv {
    [self setBusinessTestEnv:YES];
    [self setRoomSeviceTestEnv:YES];
    [self setDocsSeviceTestEnv:NO];
}

- (void)setBusinessTestEnv:(BOOL)businessEnv {
    _businessTestEnv = businessEnv;
    [[NSUserDefaults standardUserDefaults] setBool:businessEnv forKey:Zego_Env_BusinessEnv];
}

- (void)setRoomSeviceTestEnv:(BOOL)roomSeviceEnv {
    _roomSeviceTestEnv = roomSeviceEnv;
    [[NSUserDefaults standardUserDefaults] setBool:roomSeviceEnv forKey:Zego_Env_RoomSeviceEnv];
}

- (void)setDocsSeviceTestEnv:(BOOL)docsSeviceEnv {
    _docsSeviceTestEnv = docsSeviceEnv;
    [[NSUserDefaults standardUserDefaults] setBool:docsSeviceEnv forKey:Zego_Env_DocsSeviceEnv];
}

- (void)setPptStepDefaultMode:(BOOL)pptStepDefaultMode {
    _pptStepDefaultMode = pptStepDefaultMode;
    [[NSUserDefaults standardUserDefaults] setBool:pptStepDefaultMode forKey:Zego_Test_pptStepDefaultMode];
}

- (void)setIsChinese:(BOOL)isChinese {
    _isChinese = isChinese;
    [[NSUserDefaults standardUserDefaults] setObject:isChinese?@"YES":@"NO" forKey:Zego_Env_Language_Chinese];
}
@end
