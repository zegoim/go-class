//
//  ZegoSettingViewController.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/1.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface ZegoSettingCellModel : NSObject
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, strong) NSArray *optionArray;
@property (nonatomic, strong) void(^optionSelectedBlock)(NSInteger cellIndex, NSInteger selectedIndex);
@end
@interface ZegoSettingTableViewCell : UITableViewCell
@property (nonatomic, strong) ZegoSettingCellModel *model;

@end

@interface ZegoSettingViewController : UIViewController
@property (nonatomic, strong) void(^languageChangeBlock)(void);
@end

NS_ASSUME_NONNULL_END
