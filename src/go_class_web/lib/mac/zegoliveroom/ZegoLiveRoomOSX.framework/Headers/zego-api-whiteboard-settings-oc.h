//
//  zego-whiteboard-settings-oc.h
//
//  Copyright © Shenzhen Zego Technology Company Limited
//

#import <Foundation/Foundation.h>

//#import "../zego-api-whiteboard-constant.h"


#pragma mark - whiteboard settings interface

@interface ZegoWhiteboardSettings : NSObject

/**
 获取指定类型图元当前设置的粗细、尺寸，该值是一个相对水平，参考 enum ZegoWhiteboardGraphicSizeLevel，默认为 kZegoWhiteboardGraphicSizeLevel2
 */
+ (int) sizeOfGraphic: (int) graphicType;

/**
 设置指定类型图元的粗细、尺寸
 */
+ (int) setSize:(int)size ofGraphic: (int) graphicType;

/**
 获取指定类型图元当前设置的颜色，默认为黑色
 */
+ (unsigned int) colorOfGraphic: (int) graphicType;

/**
 获取指定类型图元当前设置的颜色字符串，如#ffffff，默认为黑色
 */
+ (NSString *) colorStringOfGraphic: (int) graphicType;

/**
 设置指定类型图元的颜色
 */
+ (int) setColor: (unsigned int)color ofGraphic: (int) graphicType;


/**
 获取指定类型图元的粗体，一般用于文本图元
 */
+ (Boolean) boldOfGraphic: (int) graphicType;

/**
 设置指定类型图元的粗体，一般用于文本图元
 */
+ (void) setBold: (Boolean)bold ofGraphic: (int) graphicType;

/**
 获取指定类型图元的斜体，一般用于文本图元
 */
+ (Boolean) italicOfGraphic: (int) graphicType;

/**
 设置指定类型图元的斜体，一般用于文本图元
 */
+ (void) setItalic: (Boolean)italic ofGraphic: (int) graphicType;

@end
