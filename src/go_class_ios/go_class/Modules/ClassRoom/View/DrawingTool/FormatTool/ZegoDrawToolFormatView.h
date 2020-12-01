//
//  ZegoDrawToolFormatView.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/5.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoDrawToolFormatModel.h"

NS_ASSUME_NONNULL_BEGIN
@class ZegoDrawToolFormatView;
@protocol ZegoDrawToolFormatViewDelegate <NSObject>

- (void)zegoDrawToolFormatView:(ZegoDrawToolFormatView *)formatView didSelectFormat:(ZegoDrawToolFormat *)format;

@end

@interface ZegoDrawToolFormatView : UIView

- (instancetype)initWithSelectedFormat:(ZegoDrawToolFormat *)format;
@property (nonatomic, weak) id<ZegoDrawToolFormatViewDelegate> delegate;
@property (strong, nonatomic) ZegoDrawToolFormat *selectedFormat;

@end

#pragma mark - Tool cell
@interface ZegoDrawToolFormatCell: UICollectionViewCell


@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *colorSelectedImageView;
@property (nonatomic, strong) UIView *brushView;
@property (nonatomic, strong) UIImageView *textFormatImageView;

@end

NS_ASSUME_NONNULL_END
