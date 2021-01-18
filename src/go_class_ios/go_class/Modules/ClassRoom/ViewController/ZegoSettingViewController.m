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
#import "NSString+ZegoExtension.h"
#import "ZegoClassEnvManager.h"
#import "NSBundle+ZegoExtension.h"
#import "ZegoStringPickerView.h"
@interface ZegoSettingTableViewCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLable;
@property (nonatomic, strong) UIImageView *arrowIV;
@end

@implementation ZegoSettingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, 100, self.bounds.size.height - 16)];
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textColor = [UIColor colorWithRGB:@"#18191a"];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;

    self.arrowIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - 16 - 14, (self.bounds.size.height - 14)/2, 14, 14)];
    [self.contentView addSubview:self.arrowIV];
    self.arrowIV.image = [UIImage imageNamed:@"arrow_right_2"];
    
    self.descriptionLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.arrowIV.frame) -100, 8, 100, self.bounds.size.height - 16)];
    [self.contentView addSubview:self.descriptionLable];
    self.descriptionLable.font = [UIFont systemFontOfSize:16];
    self.descriptionLable.textColor = [UIColor colorWithRGB:@"#565e66"];
    self.descriptionLable.textAlignment = NSTextAlignmentRight;
    
    
}

- (void)setModel:(ZegoSettingCellModel *)model {
    _model = model;
    self.titleLabel.text = model.titleText;
    self.descriptionLable.text = (model.descriptionText.length > 0)?model.descriptionText:model.optionArray.firstObject;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(12, 8, 100, self.bounds.size.height - 16);
    self.arrowIV.frame = CGRectMake(self.contentView.bounds.size.width - 16 - 14, (self.bounds.size.height - 14)/2, 14, 14);
    self.descriptionLable.frame = CGRectMake(CGRectGetMinX(self.arrowIV.frame) -100, 8, 100, self.bounds.size.height - 16);
}

@end

@implementation ZegoSettingCellModel



@end


@interface ZegoSettingViewController ()<UITableViewDelegate,UITableViewDataSource,UIDocumentPickerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *settingTitle;
@property (strong, nonatomic) NSArray *dataArray;

@property (copy, nonatomic) NSArray<NSString *> *fontNames;

@end

@implementation ZegoSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    self.settingTitle.text = [NSString zego_localizedString:@"login_setting"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[ZegoSettingTableViewCell class] forCellReuseIdentifier:@"cell"];
    [self showVersionLabel];
    [self loadDefaultData];
    
}

- (void)loadDefaultData {
    NSMutableArray *temp = [NSMutableArray array];
    ZegoSettingCellModel *languageModel = [[ZegoSettingCellModel alloc] init];
    languageModel.titleText =  [NSString zego_localizedString:@"room_setting_language"];
    languageModel.descriptionText = [ZegoClassEnvManager shareManager].isChinese ? @"简体中文":@"English";
    languageModel.optionArray = @[@"简体中文",@"English"];
    __weak typeof(languageModel) weakLanguageModel= languageModel;
    languageModel.optionSelectedBlock = ^(NSInteger cellIndex, NSInteger selectedIndex) {
        BOOL isChinese = (selectedIndex == 0);
        if ([ZegoClassEnvManager shareManager].isChinese != isChinese) {
            [ZegoClassEnvManager shareManager].isChinese = isChinese;
            weakLanguageModel.descriptionText = weakLanguageModel.optionArray[selectedIndex];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cellIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [NSBundle zego_setLanguage:isChinese?ZEGOLanguageChinese:ZEGOLanguageEnglish];
            self.languageChangeBlock();
        }
    };
    [temp addObject:languageModel];
    
    ZegoSettingCellModel *clearCacheModel = [[ZegoSettingCellModel alloc] init];
    clearCacheModel.titleText =  [NSString zego_localizedString:@"login_clear_cache"];
    long cacheSize = [[ZegoDocsViewManager sharedInstance] calculateCacheSize] / 1024;
    clearCacheModel.descriptionText = [NSString stringWithFormat:@"%0.1ldKB",cacheSize];
    __weak typeof(clearCacheModel) weakClearCacheModel= clearCacheModel;
    clearCacheModel.optionSelectedBlock = ^(NSInteger cellIndex, NSInteger selectedIndex) {
        [[ZegoDocsViewManager sharedInstance] clearCacheFolder];
        weakClearCacheModel.descriptionText = @"0KB";
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cellIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    };
    [temp addObject:clearCacheModel];

//#if DEBUG
//    ZegoSettingCellModel *fontModel = [[ZegoSettingCellModel alloc] init];
//    fontModel.titleText =  [NSString zego_localizedString:@""];
//    fontModel.descriptionText = [ZegoClassEnvManager shareManager].isSystemFont ? @"系统字体":@"思源字体";
//    fontModel.optionArray = @[@"系统字体",@"思源字体"];
//    [temp addObject:fontModel];
//
//    ZegoSettingCellModel *uploadLogModel = [[ZegoSettingCellModel alloc] init];
//    uploadLogModel.titleText =  [NSString zego_localizedString:@""];
//    uploadLogModel.descriptionText = @"";
//    uploadLogModel.optionSelectedBlock = ^(NSInteger cellIndex, NSInteger selectedIndex) {
//        [self didClickUploadLog:nil];
//    };
//    [temp addObject:uploadLogModel];
//#endif

    
    
    
    
    self.dataArray = temp.copy;
    [self.tableView reloadData];
}

- (void)showOptionSelectViewWithModel:(ZegoSettingCellModel *)model cellIndex:(NSInteger)cellIndex {
   
    [ZegoStringPickerView showStringPickerWithTitle:@"" dataSource:model.optionArray defaultSelValue:model.optionArray.firstObject isAutoSelect:NO manager:nil resultBlock:^(id selectValue, id selectRow) {
        if (model.optionSelectedBlock) {
            model.optionSelectedBlock(cellIndex, [selectRow integerValue]);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZegoSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    ZegoSettingCellModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ZegoSettingCellModel *model = self.dataArray[indexPath.row];
    if (model.optionArray.count < 1) {
        model.optionSelectedBlock(indexPath.row, 0);
    } else {
        [self showOptionSelectViewWithModel:model cellIndex:indexPath.row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57;
}

- (void)didClickUploadLog:(UIButton *)sender
{
    [ZegoLiveCenter uploadLog];
    NSLog(@"开始上传日志");       
}

//- (void)setupFontSwitchButton {
//    if (!self.dropDown) {
//        self.fontNames = @[@"SourceHanSansSC", @"系统字体"];
//        CGFloat width = 300;
//        CGFloat height = 40;
//        CGFloat xPos = (SCREEN_WIDTH - width) / 2;
//        CGFloat yPos = CGRectGetMaxY(self.clearCacheButton.frame) + 20;
//        self.dropDown = [[ZFDropDown alloc] initWithFrame:CGRectMake(xPos, yPos, width, height) pattern:kDropDownPatternDefault];
//        self.dropDown.delegate = self;
//        self.dropDown.borderStyle = kDropDownTopicBorderStyleRect;
//        [self.dropDown.topicButton setTitle:self.fontNames.firstObject forState:UIControlStateNormal];
//        self.dropDown.topicButton.titleLabel.font = [UIFont systemFontOfSize:17.f];
//        self.dropDown.cornerRadius = 5.f;
//        self.dropDown.shadowOpacity = 0.2;
//        [self.view addSubview:self.dropDown];
//    }
//}

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

- (void)didClickUploadFile:(UIButton *)sender {
    
    [self didClickUploadLog:sender];

}


- (IBAction)onBackButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
//            [weakSelf uploadFileWithUrl:newURL isReupload:NO];
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


//- (void)uploadFileWithUrl:(NSURL *)url isReupload:(BOOL)isReupload
//{
//    NSLog(@"uploadFileWithUrl, url: %@, isReupload: %d", [url path], isReupload);
//
//    [url startAccessingSecurityScopedResource];
//    NSError *error;
//    NSData *fileData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
//    NSLog(@"uploadFileWithUrl, get file data error: %@", error);
//
//    // 上传文件大小限制
//    NSInteger limitFileSize = NSIntegerMax;
//    if (fileData.length > limitFileSize) {
//        NSLog(@"limit file size!");
//        [url stopAccessingSecurityScopedResource];
//        return;
//    }
//
//    NSString *fileName = [url lastPathComponent];
//    //    NSString *extension = [url pathExtension];
//
//    [[ZegoDocsViewManager sharedInstance] uninit];
//    ZegoDocsViewConfig *config = [[ZegoDocsViewConfig alloc] init];
//    config.appID = kZegoAppID;
//#ifdef IS_USE_LIVEROOM
//    config.appSign = [ZGAppSignHelper convertAppSignToStringFromChars:kZegoSign];
//#else
//    config.appSign = [ZGAppSignHelper convertAppSignStringFromString:kZegoSign];
//#endif
//    config.dataFolder = kZegoDocsDataPath;
//    config.logFolder = kZegoLogPath;
//    config.cacheFolder = kZegoDocsDataPath;
//
//    [[ZegoDocsViewManager sharedInstance] initWithConfig:config completionBlock:nil];
//
//
//    [[ZegoDocsViewManager sharedInstance] uploadFile:[url path] renderType:ZegoDocsViewRenderTypeVector completionBlock:^(ZegoDocsViewUploadState state, ZegoDocsViewError errorCode, NSDictionary * _Nonnull infoDictionary) {
//
//        if (errorCode == ZegoDocsViewSuccess) {
//            if (state == ZegoDocsViewUploadStateUpload) {
//                NSNumber * upload_percent = infoDictionary[UPLOAD_PERCENT];
//                NSLog(@"upload_percent is %0.2f",upload_percent.floatValue);
//                self.uploadProgressLabel.text = [NSString stringWithFormat:@" %@\n 上传中...\n 进度为 %0.2f",fileName,upload_percent.floatValue];
//                if(upload_percent.intValue == 1){
//                    self.uploadProgressLabel.text = @"转换中";
//                }
//
//            }else if (state == ZegoDocsViewUploadStateConvert){
//                NSString * fileID = infoDictionary[UPLOAD_FILEID];
//                self.uploadProgressLabel.text =  [NSString stringWithFormat:@"转换完毕，文件id：%@",fileID];
//                [url stopAccessingSecurityScopedResource];
//
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    self.uploadProgressLabel.alpha = 0;
//
//                });
//            }
//        }else{
//            NSLog(@"error %ld",errorCode);
//            [url stopAccessingSecurityScopedResource];
//            self.uploadProgressLabel.text = @"上传失败";
//            self.uploadProgressLabel.textColor = UIColor.redColor;
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                self.uploadProgressLabel.alpha = 0;
//
//            });
//
//
//        }
//    }];
//
//}

@end
