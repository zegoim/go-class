//
//  ZegoUploadFileTypeSelectorView.h
//  go_class
//
//  Created by MartinNie on 2021/1/15.
//  Copyright © 2021 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoUploadFileTypeSelectorView : UIView
@property (nonatomic, strong) void(^didClickUploadFileType)(BOOL isDynamicFile);
@end

NS_ASSUME_NONNULL_END
