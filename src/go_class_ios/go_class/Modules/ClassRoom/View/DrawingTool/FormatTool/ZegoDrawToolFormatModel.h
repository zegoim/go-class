//
//  ZegoDrawToolFormatModel.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/5.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    ZegoTextFormatTypeBold = 1,
    ZegoTextFormatTypeItalic,
} ZegoTextFormatType;

@interface ZegoDrawToolBrush : NSObject
@property (assign, nonatomic) CGFloat brushWidth;
@property (assign, nonatomic) BOOL isSelected;
- (instancetype)initWithBrushWidth:(CGFloat)brushWidth isSelected:(BOOL)isSelected;
@end

@interface ZegoDrawToolColor : NSObject
@property (strong, nonatomic) UIColor *color;
@property (assign, nonatomic) BOOL isSelected;
- (instancetype)initWithColor:(UIColor *)color isSelected:(BOOL)isSelected;
@end

@interface ZegoDrawToolFont : NSObject
@property (strong, nonatomic) UIFont *font;
@property (assign, nonatomic) BOOL isSelected;
- (instancetype)initWithFont:(UIFont *)font isSelected:(BOOL)isSelected;
@end


@interface ZegoTextFormat : NSObject
@property (assign, nonatomic) NSInteger formatId;
@property (assign, nonatomic) BOOL isSelected;
@property (assign, nonatomic) ZegoTextFormatType textFormatType;
@property (copy, nonatomic) NSString *normalImageName;
@property (copy, nonatomic) NSString *selectedImageName;

- (instancetype)initWithTextFormatId:(NSInteger)formatId textFormatType:(ZegoTextFormatType)textFormatType normalImageName:(NSString *)normalImageName selectedImageName:(NSString *)selectedImageName isSelected:(BOOL)isSelected;

@end

@interface ZegoDrawToolFormat : NSObject


@property (strong, nonatomic) ZegoDrawToolBrush *brush;
@property (strong, nonatomic) ZegoDrawToolColor *color;
@property (strong, nonatomic) ZegoDrawToolFont *font;
@property (strong, nonatomic) NSArray <ZegoTextFormat *> *textFormats;
- (instancetype)initWithBrush:(ZegoDrawToolBrush *)brush color:(ZegoDrawToolColor *)color font:(ZegoDrawToolFont *)font textFormats:(NSArray <ZegoTextFormat *> *)textFormats;



@end



NS_ASSUME_NONNULL_END
