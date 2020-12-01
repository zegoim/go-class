//
//  TouchAreaButton.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/15.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoTouchAreaButton.h"

@implementation ZegoTouchAreaButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {

      //获取当前button的实际大小
      CGRect bounds = self.bounds;

     //若原热区小于44x44，则放大热区，否则保持原大小不变
     CGFloat widthDelta = MAX(60.0 - bounds.size.width, 0);
     CGFloat heightDelta = MAX(60.0 - bounds.size.height, 0);

     //扩大bounds
     bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
 
      //如果点击的点在新的bounds里，就返回YES
     return CGRectContainsPoint(bounds, point);
 }

@end
