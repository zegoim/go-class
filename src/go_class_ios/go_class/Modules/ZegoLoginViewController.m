//
//  ViewController.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/5/27.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoLoginViewController.h"
#import "ZegoEnvSettingViewController.h"
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
    
    self.classRoomTF.placeholder = @"请输入课堂ID";
    self.classRoomTF.keyboardType = UIKeyboardTypeNumberPad;
    [self.classRoomTF addTarget:self action:@selector(textFieldTextChanged:) forControlEvents:UIControlEventEditingChanged];
    self.classRoomTF.delegate = self;
    
    self.classTypeTF.text = @"小班课";
    self.classTypeTF.userInteractionEnabled = NO;

    self.nameTF.placeholder = @"请输入姓名";
    [self.nameTF addTarget:self action:@selector(textFieldTextChanged:) forControlEvents:UIControlEventEditingChanged];
    self.nameTF.delegate = self;

    self.userRoleTF.text = @"老师";
    self.userRoleTF.userInteractionEnabled = NO;
    self.userRoleType = ZegoUserRoleTypeTeacher;
    
    [self enableJoinClassButton:NO];
    
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
#ifdef DEBUG
    ZegoEnvSettingViewController *setting = [[ZegoEnvSettingViewController alloc] init];
    [self presentViewController:setting animated:YES completion:nil];
#endif
}

- (IBAction)onRoleTypeButtonTapped:(id)sender {
    [self.view endEditing:YES];
    [ZegoStringPickerView showStringPickerWithTitle:@"选择角色" dataSource:@[@"老师", @"学生"] defaultSelValue:@"老师" isAutoSelect:YES manager:nil resultBlock:^(id selectValue, id selectRow) {
        NSLog(@"%@",selectValue);
        if ([selectRow intValue] == 0) {
            self.userRoleType = ZegoUserRoleTypeTeacher;
            self.userRoleTF.text = @"老师";
        } else if ([selectRow intValue] == 1) {
            self.userRoleType = ZegoUserRoleTypeStudent;
            self.userRoleTF.text = @"学生";
        }
    }];
}

- (IBAction)onClassPatternTypeTaped:(UIButton *)sender {
    [self.view endEditing:YES];
    [ZegoStringPickerView showStringPickerWithTitle:@"课堂类型" dataSource:@[@"小班课", @"大班课"] defaultSelValue:@"小班课" isAutoSelect:YES manager:nil resultBlock:^(id selectValue, id selectRow) {
        NSLog(@"%@",selectValue);
        if ([selectRow intValue] == 0) {
            self.classPatternType = ZegoClassPatternTypeSmall;
            self.classTypeTF.text = @"小班课";
        } else if ([selectRow intValue] == 1) {
            self.classPatternType = ZegoClassPatternTypeBig;
            self.classTypeTF.text = @"大班课";
        }
    }];
}
// 点击进入课堂
- (IBAction)onJoinClassButtonTapped:(id)sender {
    if (![self isNameLegal:self.nameTF.text]){
        [ZegoToast showText:@"姓名仅支持汉字，数字，大写字母，小写字母"];
        return;
    }
    
    if (![self isClassRoomIDLegal:self.classRoomTF.text]){
        [ZegoToast showText:@"课堂ID，禁止输入大于9位的数字"];
        return;
    }
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
                                         success:^(ZegoRoomMemberInfoModel *userModel, NSString *roomID, ZegoLiveReliableMessage *reliableMessage) {
        @strongify(self);
        [self.activityIndicator stopAnimating];
        ZegoClassViewController *vc = [[ZegoClassViewController alloc] initWithRoomID:roomID
                                                                                 user:userModel
                                                                            classType:self.classPatternType
                                                                          syncMessage:reliableMessage
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
    [self.navigationController pushViewController:[[ZegoSettingViewController alloc] init] animated:YES];
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
    [ZegoToast showText:@"网络异常，请检查网络后重试"];
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
