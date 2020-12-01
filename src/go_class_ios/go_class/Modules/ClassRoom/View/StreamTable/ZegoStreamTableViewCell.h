//
//  ZegoStreamTableViewCell.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/5/28.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoLiveCenterModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZegoStreamTableViewCell : UITableViewCell
@property (nonatomic, strong, readonly) ZegoStreamWrapper *model;
@property (nonatomic, assign) BOOL hiddenMarkView;

- (void)setupModel:(ZegoStreamWrapper *)model complement:(void(^)(UIView *previewView))startPlayStreamBlock;

@end

NS_ASSUME_NONNULL_END
