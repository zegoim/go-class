//
//  ZegoDrawingToolModel.h
//  ZegoWhiteboardVideoDemo
//
//  Created by Vic on 2020/11/23.
//  Copyright © 2020 zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZegoDrawToolConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZegoDrawingToolModel : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *selectedImage;
@property (nonatomic, strong) NSString *normalImage;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, assign) ZegoDrawingToolViewItemType type;

- (instancetype)initWithJson:(NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
