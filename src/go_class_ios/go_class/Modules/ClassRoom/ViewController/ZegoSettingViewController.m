//
//  ZegoSettingViewController.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/1.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoSettingViewController.h"
#import "RadioButton.h"
#import "UIColor+ZegoExtension.h"
#import "ZegoAuthConstants.h"
#import "ZegoUIConstant.h"
#import "ZegoToast.h"
#import "ZGAppSignHelper.h"
#import "ZegoDocsViewDependency.h"
#import <ZegoWhiteboardView/ZegoWhiteboardView.h>
#import "ZFDropDown.h"
#import "ZegoLiveCenter.h"

@interface ZegoSettingViewController ()<ZFDropDownDelegate,UIDocumentPickerDelegate>
@property (weak, nonatomic) IBOutlet RadioButton *envButton;
@property (weak, nonatomic) IBOutlet RadioButton *testEnvButton;
@property (weak, nonatomic) IBOutlet UILabel *uploadProgressLabel;

@property (weak, nonatomic) IBOutlet UITextField *appIDTF;
@property (weak, nonatomic) IBOutlet UITextField *appSignTF;
@property (weak, nonatomic) IBOutlet UIButton *clearCacheButton;

@property (nonatomic, strong) ZFDropDown * dropDown;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (copy, nonatomic) NSArray<NSString *> *fontNames;

@property (nonatomic, strong) UIButton *logUploadBtn;

@end

@implementation ZegoSettingViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.envButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.testEnvButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.navigationController setNavigationBarHidden:YES];
    NSAttributedString *appIDAttrString = [[NSAttributedString alloc] initWithString:@"请输入App ID" attributes:
    @{NSForegroundColorAttributeName:[UIColor colorWithRGB:@"#b1b4bd"],
      NSFontAttributeName:self.appIDTF.font
         }];
    self.appIDTF.textColor = kTextColor1;
    self.appIDTF.attributedPlaceholder = appIDAttrString;
    self.appIDTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    NSAttributedString *signAttrString = [[NSAttributedString alloc] initWithString:@"请输入App Sign" attributes:
    @{NSForegroundColorAttributeName:[UIColor colorWithRGB:@"#b1b4bd"],
      NSFontAttributeName:self.appIDTF.font
         }];
    self.appSignTF.textColor = kTextColor1;
    self.appSignTF.attributedPlaceholder = signAttrString;
    self.appSignTF.secureTextEntry = YES;
    self.appSignTF.clearButtonMode = UITextFieldViewModeWhileEditing;

    long cacheSize = [[ZegoDocsViewManager sharedInstance] calculateCacheSize] / 1024;
    [self.clearCacheButton setTitle:[NSString stringWithFormat:@"清除缓存(%0.1ldKB)", cacheSize] forState:UIControlStateNormal];
    
    [self loadLocal];
    [self showVersionLabel];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
//    [self setupFontSwitchButton];
    self.logUploadBtn.frame = CGRectMake((self.view.bounds.size.width - 100)/2, CGRectGetMinY(self.versionLabel.frame) - 40, 100, 40);
}

- (void)didClickUploadLog:(UIButton *)sender
{
    [ZegoLiveCenter uploadLog];
    NSLog(@"开始上传日志");       
}

- (void)setupFontSwitchButton {
    if (!self.dropDown) {
        self.fontNames = @[@"SourceHanSansSC", @"系统字体"];
        CGFloat width = 300;
        CGFloat height = 40;
        CGFloat xPos = (SCREEN_WIDTH - width) / 2;
        CGFloat yPos = CGRectGetMaxY(self.clearCacheButton.frame) + 20;
        self.dropDown = [[ZFDropDown alloc] initWithFrame:CGRectMake(xPos, yPos, width, height) pattern:kDropDownPatternDefault];
        self.dropDown.delegate = self;
        self.dropDown.borderStyle = kDropDownTopicBorderStyleRect;
        [self.dropDown.topicButton setTitle:self.fontNames.firstObject forState:UIControlStateNormal];
        self.dropDown.topicButton.titleLabel.font = [UIFont systemFontOfSize:17.f];
        self.dropDown.cornerRadius = 5.f;
        self.dropDown.shadowOpacity = 0.2;
        [self.view addSubview:self.dropDown];
    }
}

- (void)showVersionLabel {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [info objectForKey:@"CFBundleShortVersionString"];
    NSString *appBuild = [info objectForKey:@"CFBundleVersion"];
    NSString *rtc = @"express";
#ifdef IS_USE_LIVEROOM
    rtc = @"liveroom";
#endif
    self.versionLabel.text = [NSString stringWithFormat:@"%@ V%@.%@",rtc, appVersion,appBuild];;
}

- (void)setupUpLoadLogButton {
    self.logUploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.logUploadBtn];
    [self.logUploadBtn setTitle:@"上传日志" forState:UIControlStateNormal];
    [self.logUploadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.logUploadBtn addTarget:self action:@selector(didClickUploadLog:) forControlEvents:UIControlEventTouchUpInside];
    [self.logUploadBtn setBackgroundColor:[UIColor colorWithRGB:@"#f0f4ff"]];
}

- (void)loadLocal {
    NSInteger localAppID = [[NSUserDefaults standardUserDefaults] integerForKey:kAppIDKey];
    if (localAppID) {
        self.appIDTF.text = @(localAppID).stringValue;
    }
    
    NSString *localAppSign = [[NSUserDefaults standardUserDefaults] stringForKey:kAppSignKey];
    if (localAppID) {
        self.appSignTF.text = localAppSign;
    }
    
    BOOL isTestEnv = [[NSUserDefaults standardUserDefaults] boolForKey:kIsTestEnvKey];
    [self.envButton setSelectedWithTag:isTestEnv];
}

- (void)showChoosenFile
{
    NSArray *documentTypes = @[@"public.content",
                               @"com.adobe.pdf",
                               @"com.microsoft.word.doc",
                               @"com.microsoft.excel.xls",
                               @"com.microsoft.powerpoint.ppt",
                               @"public.image"];
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;
    if (@available(iOS 11.0, *)) {
        documentPicker.allowsMultipleSelection = NO;
    }
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (IBAction)didClickUploadFile:(UIButton *)sender {
    
    [self didClickUploadLog:sender];

}

- (IBAction)restoreDefault:(id)sender {
    self.appIDTF.text = @(kZegoAppID).stringValue;
#ifdef IS_USE_LIVEROOM
    self.appSignTF.text = [ZGAppSignHelper convertAppSignToStringFromChars:kZegoSign];
#else
    self.appSignTF.text = [ZGAppSignHelper convertAppSignStringFromString:kZegoSign];
#endif
    [self.envButton setSelectedWithTag:1];
}


- (IBAction)onEnvButtonTapped:(RadioButton *)sender {
    
}

- (IBAction)onSaveButtonTapped:(id)sender {
    if (self.appIDTF.text && self.appIDTF.text.length) {
        [[NSUserDefaults standardUserDefaults] setInteger:self.appIDTF.text.integerValue forKey:kAppIDKey];
    }
    
    if (self.appSignTF.text && self.appSignTF.text.length) {
        [[NSUserDefaults standardUserDefaults] setObject:self.appSignTF.text forKey:kAppSignKey];
    }
    [[NSUserDefaults standardUserDefaults] setBool:self.envButton.selectedButton.tag forKey:kIsTestEnvKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [ZegoToast showText:@"设置已更改，请手动关闭应用后重启"];
}

- (IBAction)onBackButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onClearButtonTapped:(id)sender {
    [[ZegoDocsViewManager sharedInstance] clearCacheFolder];
    long cacheSize = [[ZegoDocsViewManager sharedInstance] calculateCacheSize] / 1024;
    [self.clearCacheButton setTitle:[NSString stringWithFormat:@"清除缓存(%0.1ldKB)", cacheSize] forState:UIControlStateNormal];
}

#pragma mark - ZFDropDownDelegate


- (NSArray *)itemArrayInDropDown:(ZFDropDown *)dropDown{
    return self.fontNames;
}

- (void)dropDown:(ZFDropDown *)dropDown didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *name = self.fontNames[indexPath.row];
    if ([name containsString:@"SourceHanSansSC"]){
        [[ZegoWhiteboardManager sharedInstance] setCustomFontWithName:@"SourceHanSansSC-Regular" boldFontName:@"SourceHanSansSC-Bold"];
    } else {
        [[ZegoWhiteboardManager sharedInstance] setCustomFontWithName:nil boldFontName:nil];
    }

}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls NS_AVAILABLE_IOS(11_0)
{
    if([urls isKindOfClass:[NSArray class]])
        [self documentPicker:controller didPickDocumentAtURL:urls.firstObject];
}

// 选中icloud里的pdf文件 iOS 8-11
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    BOOL fileUrlAuthozied = [url startAccessingSecurityScopedResource];
    if(fileUrlAuthozied){
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        __weak typeof(self) weakSelf = self;
        [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
            [weakSelf uploadFileWithUrl:newURL isReupload:NO];
        }];
        if (error) {
            [url stopAccessingSecurityScopedResource];
        }
    } else {
        NSLog(@"--- no permission ---");
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    NSLog(@"--- cancel ---");
}


- (void)uploadFileWithUrl:(NSURL *)url isReupload:(BOOL)isReupload
{
    NSLog(@"uploadFileWithUrl, url: %@, isReupload: %d", [url path], isReupload);
    
    [url startAccessingSecurityScopedResource];
    NSError *error;
    NSData *fileData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
    NSLog(@"uploadFileWithUrl, get file data error: %@", error);
    
    // 上传文件大小限制
    NSInteger limitFileSize = NSIntegerMax;
    if (fileData.length > limitFileSize) {
        NSLog(@"limit file size!");
        [url stopAccessingSecurityScopedResource];
        return;
    }
    
    NSString *fileName = [url lastPathComponent];
    //    NSString *extension = [url pathExtension];
    
    self.uploadProgressLabel.alpha = 0.8;
    self.uploadProgressLabel.textColor = UIColor.blackColor;
    self.uploadProgressLabel.text = [NSString stringWithFormat:@" %@\n 上传中...\n 进度为 %0.2f",fileName,0.0];
    [[ZegoDocsViewManager sharedInstance] uninit];
    ZegoDocsViewConfig *config = [[ZegoDocsViewConfig alloc] init];
    config.appID = kZegoAppID;
#ifdef IS_USE_LIVEROOM
    config.appSign = [ZGAppSignHelper convertAppSignToStringFromChars:kZegoSign];
#else
    config.appSign = [ZGAppSignHelper convertAppSignStringFromString:kZegoSign];
#endif
    config.dataFolder = kZegoDocsDataPath;
    config.logFolder = kZegoLogPath;
    config.cacheFolder = kZegoDocsDataPath;
    
    [[ZegoDocsViewManager sharedInstance] initWithConfig:config completionBlock:nil];
        

    [[ZegoDocsViewManager sharedInstance] uploadFile:[url path] renderType:ZegoDocsViewRenderTypeVector completionBlock:^(ZegoDocsViewUploadState state, ZegoDocsViewError errorCode, NSDictionary * _Nonnull infoDictionary) {
        
        if (errorCode == ZegoDocsViewSuccess) {
            if (state == ZegoDocsViewUploadStateUpload) {
                NSNumber * upload_percent = infoDictionary[UPLOAD_PERCENT];
                NSLog(@"upload_percent is %0.2f",upload_percent.floatValue);
                self.uploadProgressLabel.text = [NSString stringWithFormat:@" %@\n 上传中...\n 进度为 %0.2f",fileName,upload_percent.floatValue];
                if(upload_percent.intValue == 1){
                    self.uploadProgressLabel.text = @"转换中";
                }
                
            }else if (state == ZegoDocsViewUploadStateConvert){
                NSString * fileID = infoDictionary[UPLOAD_FILEID];
                self.uploadProgressLabel.text =  [NSString stringWithFormat:@"转换完毕，文件id：%@",fileID];
                [url stopAccessingSecurityScopedResource];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.uploadProgressLabel.alpha = 0;
                    
                });
            }
        }else{
            NSLog(@"error %ld",errorCode);
            [url stopAccessingSecurityScopedResource];
            self.uploadProgressLabel.text = @"上传失败";
            self.uploadProgressLabel.textColor = UIColor.redColor;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.uploadProgressLabel.alpha = 0;
                
            });
            
            
        }
    }];
    
}

@end
