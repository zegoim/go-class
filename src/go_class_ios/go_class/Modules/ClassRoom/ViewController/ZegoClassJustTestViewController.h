//
//  ZegoClassJustTestControllerViewController.h
//  ZegoWhiteboardVideoDemo
//
//  Created by Vic on 2020/11/8.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * ZegoJustTestDataKey;

UIKIT_EXTERN ZegoJustTestDataKey const ZegoJustTestWhiteboardEnabled;



@protocol ZegoClassJustTestViewControllerDelegate <NSObject>

- (void)addText:(NSString *)text positionX:(CGFloat)x positionY:(CGFloat)y;
- (void)setCustomText:(NSString *)text;
- (void)setWhiteboardEnabled:(BOOL)enable;
- (void)clearPage:(NSInteger)page;

@end

@interface ZegoClassJustTestViewController : UIViewController

@property (nonatomic, weak) id<ZegoClassJustTestViewControllerDelegate> delegate;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
