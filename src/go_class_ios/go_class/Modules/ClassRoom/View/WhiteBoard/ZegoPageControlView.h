//
//  ZegoPageControlView.h
//  ZegoWhiteboardVideoDemo
//
//  Created by MartinNie on 2020/8/5.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZegoPageControlViewDelegate <NSObject>

- (void)pageControlViewNextPage;
- (void)pageControlViewPreviousPage;

@end

@interface ZegoPageControlView : UIView
@property (nonatomic, weak) id<ZegoPageControlViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
