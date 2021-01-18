//
//  ViewController.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/5/27.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoLoginViewController.h"
#import "Reachability.h"
#import "ZegoLiveCenter.h"
#import "ZegoAuthConstants.h"
#import "ZegoSettingViewController.h"
#import "ZegoClassViewController.h"
#import "ZegoLoginService.h"
#import "ZegoToast.h"
#import "ZGAppSignHelper.h"
#import "UIColor+ZegoExtension.h"
#import "ZegoUIConstant.h"
#import <ZegoWhiteboardView/ZegoWhiteboardView.h>
#import "ZegoNetworkManager.h"
#import "ZegoClassCommand.h"
#import "ZegoHttpHeartbeat.h"
#import "ZegoDemoRoundTextField.h"
#import "ZegoStringPickerView.h"
#import "ZegoRoomMemberListRspModel.h"
#import "ZegoRotationManager.h"
#import "ZegoClassEnvManager.h"
#import "NSString+ZegoExtension.h"

#define IS_OPENSOURCE

@interface ZegoLoginViewController ()<UITextFieldDelegate,ZegoLiveCenterDelegate>
@property (weak, nonatomic) IBOutlet UITextField *classRoomTF;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet ZegoDemoRoundTextField *classTypeTF;
@property (weak, nonatomic) IBOutlet ZegoDemoRoundTextField *userRoleTF;
@property (weak, nonatomic) IBOutlet UIButton *joinClassButton;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIButton *chinaEnvButton;
@property (weak, nonatomic) IBOutlet UIButton *abroadEnvButton;

@property (nonatomic, strong) ZegoLoginService *loginService;

@property (nonatomic, assign) NSInteger appID;
@property (nonatomic, strong) NSData *appSign;
@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, assign) ZegoUserRoleType userRoleType;
@property (nonatomic, assign) ZegoClassPatternType classPatternType;
@property (nonatomic, strong) Reachability *internetReachability;

@property (nonatomic, strong) NSArray<ZegoLiveStream *> *streamList;
//@property (nonatomic, assign) BOOL isWhiteboardInit;
@property (weak, nonatomic) IBOutlet UILabel *welcomLabel;
@property (weak, nonatomic) IBOutlet UILabel *joinEnvLabel;
@property (weak, nonatomic) IBOutlet UIButton *cnEnvButton;
@property (weak, nonatomic) IBOutlet UIButton *otherEnvButton;
@property (weak, nonatomic) IBOutlet UILabel *envTipLabel;

@end

@implementation ZegoLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setInterfaceOrientation:UIInterfaceOrientationPortrait];  //强制竖屏
    [self setupReachabilityObserver];   //配置网络监听
    [self setupNavigationBar];          //加载并设置导航栏
    [self setupSubviews];               //加载并设置子视图
    [self loadDefault];                 //加载默认配置
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)updateLocalLanguage {
    self.welcomLabel.text = [NSString zego_localizedString:@"login_welcome_join_goclass"];
    [self.joinClassButton setTitle:[NSString zego_localizedString:@"login_join_class"] forState:UIControlStateNormal];
    self.joinEnvLabel.text = [NSString zego_localizedString:@"login_access_env"];
    [self.cnEnvButton setTitle:[NSString zego_localizedString:@"login_mainland_china"] forState:UIControlStateNormal];
    [self.otherEnvButton setTitle:[NSString zego_localizedString:@"login_overseas"] forState:UIControlStateNormal];
    self.envTipLabel.text = [NSString zego_localizedString:@"login_interconnected"];
    self.classTypeTF.text = [NSString zego_localizedString:@"login_small_class"];
    self.userRoleTF.text = [NSString zego_localizedString:@"login_teacher"];
    self.classPatternType = ZegoClassPatternTypeSmall;
    self.userRoleType = ZegoUserRoleTypeTeacher;
    self.classRoomTF.placeholder = [NSString zego_localizedString:@"login_input_classid"];
    self.nameTF.placeholder = [NSString zego_localizedString:@"login_enter_name"];
}

- (void)setupReachabilityObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];  //通知回调添加到RunLoop
    [self updateInterfaceWithReachability:self.internetReachability];
}

- (void)setupNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    UIButton *settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];

    [settingBtn addTarget:self action:@selector(onSettingButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    UIImage *settingImg = [UIImage imageNamed:@"shezhi"];
    [settingBtn setImage:settingImg forState:UIControlStateNormal];
    [settingBtn setShowsTouchWhenHighlighted:NO];
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithCustomView:settingBtn];
    self.navigationItem.rightBarButtonItems = @[settingItem];
}

- (void)setupSubviews {
    [self.view addSubview:self.activityIndicator];
    
    self.classRoomTF.placeholder = [NSString zego_localizedString:@"login_input_classid"];
    self.classRoomTF.keyboardType = UIKeyboardTypeNumberPad;
    [self.classRoomTF addTarget:self action:@selector(textFieldTextChanged:) forControlEvents:UIControlEventEditingChanged];
    self.classRoomTF.delegate = self;
    
    self.classTypeTF.text = [NSString zego_localizedString:@"login_small_class"];
    self.classTypeTF.userInteractionEnabled = NO;

    self.nameTF.placeholder = [NSString zego_localizedString:@"login_enter_name"];
    [self.nameTF addTarget:self action:@selector(textFieldTextChanged:) forControlEvents:UIControlEventEditingChanged];
    self.nameTF.delegate = self;

    self.userRoleTF.text = [NSString zego_localizedString:@"login_teacher"];
    self.userRoleTF.userInteractionEnabled = NO;
    self.userRoleType = ZegoUserRoleTypeTeacher;
    
    [self enableJoinClassButton:NO];
    
    [self updateLocalLanguage];
    
#ifdef DEBUG
    NSInteger classroomIndex = arc4random_uniform(100000);
    self.classRoomTF.text = [NSString stringWithFormat:@"%ld", classroomIndex];
    self.nameTF.text = @"姓名";
    [self enableJoinClassButton:YES];
#endif
    //    [self showVersionLabel];
}

- (void)loadDefault {
    /**
    设置默认配置:
        appID
        appSign
        userID
        classPatternType(大班课, 小班课)
     */
    NSInteger localAppID = [[NSUserDefaults standardUserDefaults] integerForKey:kAppIDKey];
    if (localAppID) {
        self.appID = localAppID;
    }
    NSString *localAppSign = [[NSUserDefaults standardUserDefaults] stringForKey:kAppSignKey];
    if (localAppSign) {
        self.appSign = [ZGAppSignHelper convertAppSignFromString:localAppSign];
    }
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:kUserIDKey];
    if (!userID) {
        userID = @([NSDate date].timeIntervalSince1970).stringValue;
        [[NSUserDefaults standardUserDefaults] setObject:userID forKey:kUserIDKey];
    }
    self.userID = [userID integerValue];
    self.classPatternType = ZegoClassPatternTypeSmall;
}

- (void)setupSDK {
#ifdef IS_USE_LIVEROOM
    if (self.classPatternType == ZegoClassPatternTypeSmall) {
        if ([ZegoClassEnvManager shareManager].abroadEnv) {
            
            self.appID = kZegoAppIDAbroad;
            self.appSign = [ZGAppSignHelper convertAppSignFromChars:kZegoSignAbroad ];
        } else {
            self.appID = kZegoAppID;
            self.appSign = [ZGAppSignHelper convertAppSignFromChars:kZegoSign ];
        }
    } else {
        if ([ZegoClassEnvManager shareManager].abroadEnv) {
            self.appID = kZegoAppIDAbroadBigClass;
            self.appSign = [ZGAppSignHelper convertAppSignFromChars:kZegoSignAbroadBigClass ];
        } else {
            self.appID = kZegoAppIDBigClass;
            self.appSign = [ZGAppSignHelper convertAppSignFromChars:kZegoSignBigClass ];
        }
    }
#else
    if (self.classPatternType == ZegoClassPatternTypeSmall) {
        if ([ZegoClassEnvManager shareManager].abroadEnv) {
            
            self.appID = kZegoAppIDAbroad;
            self.appSign = [ZGAppSignHelper convertAppSignFromString:[ZGAppSignHelper convertAppSignStringFromString:kZegoSignAbroad]];
        } else {
            self.appID = kZegoAppID;
            self.appSign = [ZGAppSignHelper convertAppSignFromString:[ZGAppSignHelper convertAppSignStringFromString:kZegoSign]];
        }
    } else {
        if ([ZegoClassEnvManager shareManager].abroadEnv) {
            self.appID = kZegoAppIDAbroadBigClass;
            self.appSign = [ZGAppSignHelper convertAppSignFromString:[ZGAppSignHelper convertAppSignStringFromString:kZegoSignAbroadBigClass]];
        } else {
            self.appID = kZegoAppIDBigClass;
            self.appSign = [ZGAppSignHelper convertAppSignFromString:[ZGAppSignHelper convertAppSignStringFromString:kZegoSignBigClass]];
        }
    }
#endif
    BOOL isDocTest = [ZegoClassEnvManager shareManager].docsSeviceTestEnv;
    BOOL isRTCTest = [ZegoClassEnvManager shareManager].roomSeviceTestEnv;
    
    /**
     初始化 LiveRoom / Express.
     scenario 参数目前只有 Express 用
     */
    [ZegoLiveCenter setupWithAppID:(unsigned int)self.appID
                           appSign:self.appSign
                      isDocTestEnv:isDocTest
                      isRTCTestEnv:isRTCTest
                          scenario:2
                          complete:^(int errorCode) {
        if (errorCode) {
            [self showNetworkError];
        }else {
            // 白板初始化. 需要在 LiveRoom 初始化之后, 登录房间之前.
//            if (!self.isWhiteboardInit) {
//                [[ZegoWhiteboardManager sharedInstance] initWithCompleteBlock:^(ZegoWhiteboardViewError errorCode) {
//                    if (errorCode == ZegoWhiteboardViewSuccess) {
//                        self.isWhiteboardInit = YES;
//                    }
//                }];
//            }
            [[ZegoWhiteboardManager sharedInstance] initWithCompleteBlock:nil];
        }
    } delegate:self];
    
    [[ZegoWhiteboardManager sharedInstance] setCustomFontWithName:@"SourceHanSansSC-Regular" boldFontName:@"SourceHanSansSC-Bold"];
}

#pragma mark - Action
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)onTestButtonTapped {

}

- (IBAction)onRoleTypeButtonTapped:(id)sender {
    [self.view endEditing:YES];
    [ZegoStringPickerView showStringPickerWithTitle:[NSString zego_localizedString:@"wb_tool_choice"] dataSource:@[[NSString zego_localizedString:@"login_teacher"], [NSString zego_localizedString:@"login_student"]] defaultSelValue:[NSString zego_localizedString:@"login_teacher"] isAutoSelect:YES manager:nil resultBlock:^(id selectValue, id selectRow) {
        NSLog(@"%@",selectValue);
        if ([selectRow intValue] == 0) {
            self.userRoleType = ZegoUserRoleTypeTeacher;
            self.userRoleTF.text = [NSString zego_localizedString:@"login_teacher"];
        } else if ([selectRow intValue] == 1) {
            self.userRoleType = ZegoUserRoleTypeStudent;
            self.userRoleTF.text = [NSString zego_localizedString:@"login_student"];
        }
    }];
}

- (IBAction)onClassPatternTypeTaped:(UIButton *)sender {
    [self.view endEditing:YES];
    [ZegoStringPickerView showStringPickerWithTitle:[NSString zego_localizedString:@"wb_tool_choice"] dataSource:@[[NSString zego_localizedString:@"login_small_class"], [NSString zego_localizedString:@"login_large_class"]] defaultSelValue:[NSString zego_localizedString:@"login_small_class"] isAutoSelect:YES manager:nil resultBlock:^(id selectValue, id selectRow) {
        NSLog(@"%@",selectValue);
        if ([selectRow intValue] == 0) {
            self.classPatternType = ZegoClassPatternTypeSmall;
            self.classTypeTF.text = [NSString zego_localizedString:@"login_small_class"];
        } else if ([selectRow intValue] == 1) {
            self.classPatternType = ZegoClassPatternTypeBig;
            self.classTypeTF.text = [NSString zego_localizedString:@"login_large_class"];
        }
    }];
}
// 点击进入课堂
- (IBAction)onJoinClassButtonTapped:(id)sender {
    if (![self isNameLegal:self.nameTF.text]){
        [ZegoToast showText:[NSString zego_localizedString:@"login_supports_characters_number_uppercase_letter"]];
        return;
    }
    
    if (![self isClassRoomIDLegal:self.classRoomTF.text]){
        [ZegoToast showText:[NSString zego_localizedString:@"login_supports_pure_digits"]];
        return;
    }
    #ifdef IS_OPENSOURCE
    [[ZegoClassEnvManager shareManager]setNomalEnv];
    #endif
    [self setupSDK];
//    [self updateInterfaceWithReachability:self.internetReachability];
    [self.activityIndicator startAnimating];
    @weakify(self);
    self.loginService = [ZegoLoginService new];
    self.userID = [ZegoLoginService randomUserID];
    [self.loginService serverloginRoomWithRoomID:self.classRoomTF.text
                                          userID:self.userID
                                        userName:self.nameTF.text
                                        userRole:self.userRoleType
                                       classType:self.classPatternType
                                         success:^(ZegoRoomMemberInfoModel *userModel, NSString *roomID) {
        @strongify(self);
        [self.activityIndicator stopAnimating];
        ZegoClassViewController *vc = [[ZegoClassViewController alloc] initWithRoomID:roomID
                                                                                 user:userModel
                                                                            classType:self.classPatternType
                                                                           streamList:[ZegoLiveCenter streamList]
                                                                          isEnvAbroad:self.abroadEnvButton.selected];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    } failure:^(ZegoResponseModel *response) {
        @strongify(self);
        [self.activityIndicator stopAnimating];
        [ZegoToast showText:response.message];
    }];
}

- (void)onSettingButtonTapped {
    ZegoSettingViewController *settingVC = [[ZegoSettingViewController alloc] init];
    @weakify(self);
    settingVC.languageChangeBlock = ^{
        @strongify(self);
        [self updateLocalLanguage];
    };
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (IBAction)onChinaEnvButtonTapped:(id)sender {
    [self setupEnvIfAbroad:NO];
}

- (IBAction)onAbroadEnvButtonTapped:(id)sender {
    [self setupEnvIfAbroad:YES];
}

- (void)setupEnvIfAbroad:(BOOL)abroad {
    self.chinaEnvButton.selected = !abroad;
    self.abroadEnvButton.selected = abroad;
    [ZegoClassEnvManager shareManager].abroadEnv = abroad;
}

#pragma mark - Check validity
- (BOOL)isNameLegal:(NSString *)name {
    if (name.length <= 30) {
        NSString *regex = @"^(?!_)(?!.*?_$)[a-zA-Z0-9_\u4e00-\u9fa5]{1,13}+$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        BOOL result = [pred evaluateWithObject:name];
        return result;
    }
    return NO;
}

- (BOOL)isClassRoomIDLegal:(NSString *)ID {
    return (ID.length <= 9);
}

#pragma mark - ZegoLiveCenterDelegate
- (void)onStreamUpdated:(int)type streams:(NSArray<ZegoLiveStream *> *)streamList roomID:(NSString *)roomID {
    self.streamList = streamList;
}

#pragma mark - Delegate
- (void)textFieldTextChanged:(UITextField *)textField {
    BOOL enable = (self.classRoomTF.text.length > 0 && self.nameTF.text.length > 0);
    [self enableJoinClassButton:enable];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [ZegoLiveCenter setUserId:@(self.userID).stringValue userName:self.nameTF.text];
}

#pragma mark - UI
- (void)enableJoinClassButton:(BOOL)enable {
    if (enable) {
        self.joinClassButton.userInteractionEnabled = YES;
        self.joinClassButton.backgroundColor = kThemeColorBlue;
    }else {
        self.joinClassButton.userInteractionEnabled = NO;
        self.joinClassButton.backgroundColor = [UIColor colorWithRGB:@"#94b0ff"];
    }
}

- (void)showVersionLabel {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
//    NSString *appVersion = [info objectForKey:@"CFBundleShortVersionString"];
    NSString *appBuild = [info objectForKey:@"CFBundleVersion"];
    
    NSString *dependency = nil;
#ifdef IS_USE_LIVEROOM
    dependency = @"Liveroom";
#else
    dependency = @"Express";
#endif
    self.versionLabel.text = [NSString stringWithFormat:@"%@ Build:%@ uid:%ld", dependency, appBuild, self.userID];
}

- (void)showNetworkError {
    [ZegoToast showText:[NSString zego_localizedString:@"login_network_exception"]];
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability {
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    switch (netStatus) {
        case NotReachable:
            NSLog(@"====当前网络状态不可用=======");
            break;
        case ReachableViaWiFi:
            NSLog(@"====当前网络状态为wifi=======keso");
            break;
        case ReachableViaWWAN:
            NSLog(@"====当前网络状态为流量=======keso");
            break;
    }
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        _activityIndicator.frame= self.view.bounds;
        _activityIndicator.center = self.view.center;
        _activityIndicator.hidesWhenStopped = YES;
    }
    [self.view bringSubviewToFront:_activityIndicator];
    return _activityIndicator;
}

//强制转屏
- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation {
    [ZegoRotationManager defaultManager].orientation = UIDeviceOrientationPortrait;
}
@end
