//
//  ZegoImBubbleImage.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/11/10.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoImBubbleImage.h"

typedef struct {
     CGFloat topLeft;
     CGFloat topRight;
     CGFloat bottomLeft;
     CGFloat bottomRight;
} CornerRadii;

@interface ZegoImBubbleImage ()

@property (nonatomic, assign) CornerRadii cornerRadii;

@end

@implementation ZegoImBubbleImage

- (void)drawRect:(CGRect)rect {
    //切圆角
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    self.cornerRadii = CornerRadiiMake(self.borderTopLeftRadius, self.borderTopRightRadius, self.borderBottomLeftRadius, self.borderBottomRightRadius);
    CGPathRef path = CYPathCreateWithRoundedRect(self.bounds,self.cornerRadii);
    shapeLayer.path = path;
    CGPathRelease(path);
    self.layer.mask = shapeLayer;
}

CornerRadii CornerRadiiMake(CGFloat topLeft,CGFloat topRight,CGFloat bottomLeft,CGFloat bottomRight){
     return (CornerRadii){
          topLeft,
          topRight,
          bottomLeft,
          bottomRight,
     };
}
//切圆角函数
CGPathRef CYPathCreateWithRoundedRect(CGRect bounds,
                                      CornerRadii cornerRadii)
{
     const CGFloat minX = CGRectGetMinX(bounds);
     const CGFloat minY = CGRectGetMinY(bounds);
     const CGFloat maxX = CGRectGetMaxX(bounds);
     const CGFloat maxY = CGRectGetMaxY(bounds);
     
     const CGFloat topLeftCenterX = minX +  cornerRadii.topLeft;
     const CGFloat topLeftCenterY = minY + cornerRadii.topLeft;
     
     const CGFloat topRightCenterX = maxX - cornerRadii.topRight;
     const CGFloat topRightCenterY = minY + cornerRadii.topRight;
     
     const CGFloat bottomLeftCenterX = minX +  cornerRadii.bottomLeft;
     const CGFloat bottomLeftCenterY = maxY - cornerRadii.bottomLeft;
     
     const CGFloat bottomRightCenterX = maxX -  cornerRadii.bottomRight;
     const CGFloat bottomRightCenterY = maxY - cornerRadii.bottomRight;
     //虽然顺时针参数是YES，在iOS中的UIView中，这里实际是逆时针
     
     CGMutablePathRef path = CGPathCreateMutable();
     //顶 左
     CGPathAddArc(path, NULL, topLeftCenterX, topLeftCenterY,cornerRadii.topLeft, M_PI, 3 * M_PI_2, NO);
     //顶 右
     CGPathAddArc(path, NULL, topRightCenterX , topRightCenterY, cornerRadii.topRight, 3 * M_PI_2, 0, NO);
     //底 右
     CGPathAddArc(path, NULL, bottomRightCenterX, bottomRightCenterY, cornerRadii.bottomRight,0, M_PI_2, NO);
     //底 左
     CGPathAddArc(path, NULL, bottomLeftCenterX, bottomLeftCenterY, cornerRadii.bottomLeft, M_PI_2,M_PI, NO);
     CGPathCloseSubpath(path);
     return path;
};

@end
