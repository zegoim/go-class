//
//  ZegoDefaultFileLoader.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/7/1.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoDefaultFileLoader.h"
#ifdef IS_WHITE_BOARD_VIEW_SOURCE_CODE
#import "ZegoWhiteboardView.h"
#else
#import <ZegoWhiteboardView/ZegoWhiteboardView.h>
#endif
#import "ZegoDocsViewDependency.h"
#import "ZegoAuthConstants.h"

#import <AFNetworking/AFNetworking.h>
#import <YYModel/YYModel.h>

//文件列表获取地址
static NSString *kZegoFileListServerHost = @"https://storage.zego.im/goclass/config.json";

@interface ZegoDefaultFileLoader ()
@property (nonatomic, strong) AFHTTPSessionManager *httpManager;
@property (nonatomic, strong) NSDictionary *generalFileMap;
@property (nonatomic, strong) NSDictionary *dynamicPPTFileMap;
@end

@implementation ZegoDefaultFileLoader

+ (instancetype)defaultLoader {
    static ZegoDefaultFileLoader * _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[ZegoDefaultFileLoader alloc] init];
        _instance.httpManager = [AFHTTPSessionManager manager];
        _instance.httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"application/jsoncharset=utf-8", @"text/json", @"text/javascript", nil];
    });
    return _instance;
}

- (void)loadFileListWithEnv:(BOOL)isTestEnv complete:(void (^)(NSArray<ZegoFileInfoModel *> * __nullable, NSError * _Nullable))complete {
    
    [self.httpManager GET:kZegoFileListServerHost parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *files = nil;
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        if (isTestEnv) {
            files = responseDict[@"docs_test"];
        }else {
            files = responseDict[@"docs_prod"];
        }
        NSMutableArray *ret = [NSMutableArray array];
        for (NSDictionary *file in files) {
            NSString *fileID = file[@"id"];
            NSString *fileName = file[@"name"];
            BOOL isDynamic = file[@"isDynamic"] ?: NO;
            BOOL isH5 = file[@"isH5"] ?: NO;
            ZegoDocsViewFileType fileType = [self fileTypeWithFileName:fileName isDynamic:isDynamic isCustomH5:isH5];
            ZegoFileInfoModel *fileModel = [self fileInfoWithID:fileID name:fileName authKey:@"123" fileType:fileType];
            [ret addObject:fileModel];
        }
        if (complete) {
            complete(ret.copy, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (complete) {
            complete(nil, error);
        }
    }];
}

- (ZegoDocsViewFileType)fileTypeWithFileName:(NSString *)fileName
                                   isDynamic:(BOOL)isDynamic
                                  isCustomH5:(BOOL)isCustomH5

{
    ZegoDocsViewFileType type = ZegoDocsViewFileTypeUnknown;
    NSString *fileSuffix = [fileName pathExtension];
    if (!fileSuffix || !self.generalFileMap[fileSuffix]) {
        return type;
    }
    NSDictionary *fileMap = nil;
  
    if (isDynamic) {
        fileMap = self.dynamicPPTFileMap;
    }else {
        fileMap = self.generalFileMap;
    }
    NSNumber *ret = fileMap[fileSuffix];
    type = (ZegoDocsViewFileType)ret.integerValue;
    if (isCustomH5) {
        type = ZegoDocsViewFileTypeCustomH5;
    }
    return type;
}

- (ZegoFileInfoModel *)fileInfoWithID:(NSString *)fileId name:(NSString *)fileName authKey:(NSString *)authKey fileType:(ZegoDocsViewFileType)fileType {
    ZegoFileInfoModel *fileInfo = [[ZegoFileInfoModel alloc] init];
    fileInfo.fileID = fileId;
    fileInfo.fileName = fileName;
    fileInfo.authKey = authKey;
    fileInfo.fileType = fileType;
    return fileInfo;
}

- (NSDictionary *)generalFileMap {
    if (!_generalFileMap) {
        _generalFileMap = @{
            @"xls": @(ZegoDocsViewFileTypeELS),
            @"xlsx": @(ZegoDocsViewFileTypeELS),
            
            @"ppt": @(ZegoDocsViewFileTypePPT),
            @"pptx": @(ZegoDocsViewFileTypePPT),
            
            @"pdf": @(ZegoDocsViewFileTypePDF),
            
            @"doc": @(ZegoDocsViewFileTypeDOC),
            @"docx": @(ZegoDocsViewFileTypeDOC),
            
            @"txt": @(ZegoDocsViewFileTypeTXT),
            
            @"jpg": @(ZegoDocsViewFileTypeIMG),
            @"jpeg": @(ZegoDocsViewFileTypeIMG),
            @"png": @(ZegoDocsViewFileTypeIMG),
            @"bmp": @(ZegoDocsViewFileTypeIMG),
            @"zip": @(ZegoDocsViewFileTypeCustomH5),
        };
    }
    return _generalFileMap;
}

- (NSDictionary *)dynamicPPTFileMap {
    if (!_dynamicPPTFileMap) {
        _dynamicPPTFileMap = @{
            @"ppt": @(ZegoDocsViewFileTypeDynamicPPTH5),
            @"pptx": @(ZegoDocsViewFileTypeDynamicPPTH5),
        };
    }
    return _dynamicPPTFileMap;
}

@end
