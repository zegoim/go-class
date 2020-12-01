//
//  ZegoDrawingToolModel.m
//  ZegoWhiteboardVideoDemo
//
//  Created by Vic on 2020/11/23.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoDrawingToolModel.h"

@implementation ZegoDrawingToolModel

- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super init];
    if (self) {
        _isEnabled = YES;
        [self parseJson:json];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        _isEnabled = YES;
    }
    return self;
}

- (void)parseJson:(NSDictionary *)json
{
    if (![json isKindOfClass:[NSDictionary class]]) {
        return;
    }
    self.text = json[@"text"];
    self.selectedImage = json[@"selectedImage"];
    self.normalImage = json[@"normalImage"];
    self.isSelected = [json[@"isSelected"] boolValue];
    self.type = [json[@"type"] unsignedIntegerValue];
}

@end
