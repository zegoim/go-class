//
//  ZegoAlertView.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/11.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Update type
typedef NS_ENUM(NSUInteger, ZegoAlertViewThemeStyle) {
    ZegoAlertViewThemeStyleNormal = 0,
    ZegoAlertViewThemeStyleTeacher = 1,
    ZegoAlertViewThemeStyleStudent = 2,
    ZegoAlertViewThemeStyleRetry = 3,
    ZegoAlertViewThemeStyleGalleryAuth = 4,
};

@interface ZegoAlertView : UIView
+ (void)alertWithTitle:(NSString *)title onTapYes:(void (^)(void))yesAction;
+ (void)alertWithTitle:(NSString *)title hasCancelButton:(BOOL)hasCancelButton onTapYes:(void (^)(void))yesAction;
+ (void)alertWithTitle:(NSString *)title onTapYes:(void (^)(void))yesAction onTapRetryButton:(void (^)(void))retryAction;
+ (void)alertWithTitle:(NSString *)title subTitle:(NSString *)subTitle onTapYes:(void (^)(void))yesAction onTapSecondButton:(void (^)(void))secondAction themeStyle:(ZegoAlertViewThemeStyle)style;

+ (void)dismiss;
@end

NS_ASSUME_NONNULL_END
