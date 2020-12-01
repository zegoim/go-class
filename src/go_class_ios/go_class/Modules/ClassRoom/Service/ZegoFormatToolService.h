//
//  ZegoFormatToolService.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/9/14.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZegoDrawingToolView.h"

@class ZegoBoardContainer;

NS_ASSUME_NONNULL_BEGIN

@interface ZegoFormatToolService : NSObject<ZegoDrawingToolViewDelegate>

@property (nonatomic, weak) id<ZegoDrawingToolViewDelegate> delegate;

- (instancetype)initWithBoardContainer:(ZegoBoardContainer *)container;
- (void)refreshBoardContainer:(ZegoBoardContainer *)container;

@end

NS_ASSUME_NONNULL_END
