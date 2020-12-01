//
//  ZegoViewCaptor.m
//  ZegoWhiteboardVideoDemo
//
//  Created by Vic on 2020/11/24.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoViewCaptor.h"
#import <Photos/Photos.h>


@interface ZegoViewCaptor (PermissionRequest)

- (void)requestPermissionForPhotoLibraryComplete:(void(^)(BOOL isPermitted, BOOL alert))complete;

@end

@implementation ZegoViewCaptor (PermissionRequest)

- (void)requestPermissionForPhotoLibraryComplete:(void(^)(BOOL isPermitted, BOOL alert))complete {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        dispatch_async(dispatch_get_main_queue(), ^{
            !complete ?: complete(YES, NO);
        });
        return;
    }
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        dispatch_async(dispatch_get_main_queue(), ^{
            !complete ?: complete(NO, YES);
        });
        return;
    }
//    if (@available(iOS 14.0, *)) {
//        if (status == PHAuthorizationStatusLimited) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                !complete ?: complete(NO, YES);
//            });
//            return;
//        }
//    }
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status != PHAuthorizationStatusAuthorized) {
                    !complete ?: complete(NO, NO);
                }else {
                    !complete ?: complete(YES, NO);
                }
            });
        }];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            !complete ?: complete(NO, NO);
        });
    }
}
@end


@implementation ZegoViewCaptor

+ (instancetype)sharedInstance {
    static ZegoViewCaptor *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[ZegoViewCaptor alloc] init];
    });
    return _instance;
}

- (void)writeToAlbumWithView:(UIView *)view complete:(void(^)(BOOL success, BOOL alert))complete {
    UIImage *img = [self imageWithView:view];
    [self writeToAlbumWithImage:img complete:complete];
}

- (void)writeToAlbumWithPath:(NSString *)path complete:(void (^)(BOOL, BOOL))complete {
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    [self writeToAlbumWithImage:img complete:complete];
}

- (void)writeToAlbumWithImage:(UIImage *)image complete:(void (^)(BOOL, BOOL))complete {
    if (!image) {
        !complete ?: complete(NO, NO);
    }
    NSData *imgData = UIImagePNGRepresentation(image);
    UIImage *pngImage = [UIImage imageWithData:imgData];
    [self requestPermissionForPhotoLibraryComplete:^(BOOL isPermitted, BOOL alert) {
        if (isPermitted) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                UIImageWriteToSavedPhotosAlbum(pngImage, nil, NULL, NULL);
//                [PHAssetChangeRequest creationRequestForAssetFromImage:pngImage]; // ios8
                // ios 9 可以改变相片名称 - 万伟琦 2020.12.4(别删)
//                PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
//                PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
//                options.originalFilename = @"testfile.png";
//                [request addResourceWithType:PHAssetResourceTypePhoto data:imgData options:options];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    !complete ?: complete(success, NO);
                });
            }];
        }else {
            !complete ?: complete(NO, alert);
        }
    }];
}

- (UIImage *)imageWithView:(UIView *)theView {
    UIGraphicsBeginImageContextWithOptions(theView.bounds.size, theView.opaque, 0.0f);
    [theView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end


