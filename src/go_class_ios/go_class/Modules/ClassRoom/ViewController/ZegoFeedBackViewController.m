//
//  ZegoFeedBackViewController.m
//  go_class
//
//  Created by zego on 2021/5/27.
//  Copyright © 2021 zego. All rights reserved.
//

#import "ZegoFeedBackViewController.h"
#import <WebKit/WebKit.h>
#import "ZegoLiveCenter.h"
#import "ZegoDocsViewDependency.h"
#import "ZegoClassEnvManager.h"
#import "NSString+ZegoDeviceInfoTool.h"
#import <ZegoWhiteboardView/ZegoWhiteboardManager.h>

@interface ZegoFeedBackViewController ()<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (nonatomic,strong)WKWebView *webview;

@end

@implementation ZegoFeedBackViewController

- (void)dealloc {
    NSLog(@"__%s__",__FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"意见反馈";

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBarHidden = NO;
    
    [self setNavBarBackButton];
    
    [self.view addSubview:self.webview];
    [self loadUrl];
}

- (void)setNavBarBackButton {
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    [backButton setImage:[UIImage imageNamed:@"arrow_left_2"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)backItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.webview.configuration.userContentController removeScriptMessageHandlerForName:@"uploadLog"];
    [self.webview.configuration.userContentController removeScriptMessageHandlerForName:@"callback"];
    self.navigationController.navigationBarHidden = YES;
}

- (void)loadUrl {
    
    NSString * system_version = [[UIDevice currentDevice] systemVersion];
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [info objectForKey:@"CFBundleShortVersionString"];
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *client = [NSString deviceName];
    
    NSString *docsVersion = [[ZegoDocsViewManager sharedInstance]getVersion];
    NSString *wbVersion = [[ZegoWhiteboardManager sharedInstance]getVersion];
    NSString *rtcVersion = [ZegoLiveCenter getVersion];
    NSString *resultVersion = [NSString stringWithFormat:@"%@_%@_%@",docsVersion,wbVersion,rtcVersion];
    NSString *logFileName = [NSString stringWithFormat:@"%@_iOS_goclass_%@_%@.zip",[self getCurrentTime],appVersion,deviceId];
    BOOL isRTCTest = [ZegoClassEnvManager shareManager].roomSeviceTestEnv;
    
    NSString *urlString;
    if (isRTCTest) {
        urlString = [NSString stringWithFormat:@"http://192.168.100.62:4001/feedback/goclass/index.html?platform=4&system_version=iOS_%@&app_version=%@&sdk_version=%@&client=%@&device_id=%@&log_filename=%@",system_version,appVersion,resultVersion,client,deviceId,logFileName];
    } else {
        urlString = [NSString stringWithFormat:@"https://demo-operation.zego.im/feedback/goclass/index.html?platform=4&system_version=iOS_%@&app_version=%@&sdk_version=%@&client=%@&device_id=%@&log_filename=%@",system_version,appVersion,resultVersion,client,deviceId,logFileName];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request];
}

- (NSString *)getCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
}


- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [self.webview reload];
}


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    NSString *name = message.name;
    if ([name isEqualToString:@"uploadLog"]) {
        //上传日志
        [ZegoLiveCenter uploadLog];
    } else if ([name isEqualToString:@"callback"]) {
        //返回
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (WKWebView *)webview {
    if (!_webview) {
        //以下代码适配大小
        WKUserContentController *userController = [[WKUserContentController alloc] init];
        WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
        wkWebConfig.userContentController = userController;
        

        // 1、JS调用OC
        [userController addScriptMessageHandler:self name:@"uploadLog"];
        [userController addScriptMessageHandler:self name:@"callback"];
        
        _webview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:wkWebConfig];
        _webview.UIDelegate = self;
        _webview.navigationDelegate = self;
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        if (@available(iOS 11.0, *)) {
            _webview.scrollView.contentInsetAdjustmentBehavior =   UIScrollViewContentInsetAdjustmentNever;
        }
        
    }
    return _webview;
}

@end
