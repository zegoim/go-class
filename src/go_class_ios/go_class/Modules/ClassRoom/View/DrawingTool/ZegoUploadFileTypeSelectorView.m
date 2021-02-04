//
//  ZegoUploadFileTypeSelectorView.m
//  go_class
//
//  Created by MartinNie on 2021/1/15.
//  Copyright © 2021 zego. All rights reserved.
//

#import "ZegoUploadFileTypeSelectorView.h"
#import "UIColor+ZegoExtension.h"
#import "NSString+ZegoExtension.h"
@interface ZegoUploadFileTypeSelectorView ()
@property (nonatomic, strong) UILabel *uploadStaticFileLabel;
@property (nonatomic, strong) UILabel *uploadDynamicFileLabel;
@property (nonatomic, strong) UILabel *staticFileDetailLabel;
@property (nonatomic, strong) UILabel *dynamicFileDetailLabel;
@property (nonatomic, strong) UIImageView *staticFlagIV;
@property (nonatomic, strong) UIImageView *dynamicFlagIV;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIButton *responseStaticBtn;
@property (nonatomic, strong) UIButton *responseDynamicBtn;
@end
@implementation ZegoUploadFileTypeSelectorView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    CGFloat margin = 16;
    CGFloat perHeight = 12.5;
    CGFloat totalWidth = self.bounds.size.width  - (2 * margin);
    CGFloat totalHeight = self.bounds.size.height;
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    self.uploadStaticFileLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin,totalWidth,perHeight )];
    [self addSubview:self.uploadStaticFileLabel];
    self.uploadStaticFileLabel.font = [UIFont systemFontOfSize:11];
    self.uploadStaticFileLabel.textAlignment = NSTextAlignmentLeft;
    self.uploadStaticFileLabel.text = [NSString zego_localizedString:@"wb_tool_upload_static"];
    self.uploadStaticFileLabel.textColor = [UIColor colorWithRGB:@"#18191a"];
    
    self.staticFlagIV = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.uploadStaticFileLabel.frame) - margin, margin, margin, margin)];
    [self addSubview:self.staticFlagIV];
    self.staticFlagIV.image = [UIImage imageNamed:@"static_file"];
    
    self.staticFileDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(self.uploadStaticFileLabel.frame) + 9,totalWidth,2 * perHeight)];
    [self addSubview:self.staticFileDetailLabel];
    self.staticFileDetailLabel.font = [UIFont systemFontOfSize:9];
    self.staticFileDetailLabel.textAlignment = NSTextAlignmentLeft;
    self.staticFileDetailLabel.text = [NSString zego_localizedString:@"wb_tool_upload_static_content"];
    self.staticFileDetailLabel.textColor = [UIColor colorWithRGB:@"#999999"];
    self.staticFileDetailLabel.numberOfLines = 0;
    
    self.lineView = [[UIView alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(self.staticFileDetailLabel.frame) + 14, totalWidth, 0.5)];
    self.lineView.backgroundColor = [UIColor colorWithRGB:@"#edeff3"];
    [self addSubview:self.lineView];
    
    self.uploadDynamicFileLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(self.lineView.frame) + 14,totalWidth ,perHeight )];
    [self addSubview:self.uploadDynamicFileLabel];
    self.uploadDynamicFileLabel.font = [UIFont systemFontOfSize:11];
    self.uploadDynamicFileLabel.textAlignment = NSTextAlignmentLeft;
    self.uploadDynamicFileLabel.text = [NSString zego_localizedString:@"wb_tool_upload_dynamic"];
    self.uploadDynamicFileLabel.textColor = [UIColor colorWithRGB:@"#18191a"];
    
    self.dynamicFlagIV = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.uploadDynamicFileLabel.frame) - margin, CGRectGetMinY(self.uploadDynamicFileLabel.frame) , margin, margin)];
    [self addSubview:self.dynamicFlagIV];
    self.dynamicFlagIV.image = [UIImage imageNamed:@"dynamic_file"];
    
    self.staticFileDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(self.uploadDynamicFileLabel.frame) + 9,totalWidth,perHeight )];
    [self addSubview:self.staticFileDetailLabel];
    self.staticFileDetailLabel.font = [UIFont systemFontOfSize:10];
    self.staticFileDetailLabel.textAlignment = NSTextAlignmentLeft;
    self.staticFileDetailLabel.text = [NSString zego_localizedString:@"wb_tool_upload_dynamic_content"];
    self.staticFileDetailLabel.textColor = [UIColor colorWithRGB:@"#999999"];
    
    self.responseStaticBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.responseStaticBtn];
    [self.responseStaticBtn setBackgroundColor:[UIColor clearColor]];
    [self.responseStaticBtn addTarget:self action:@selector(didClickUploadStaticType) forControlEvents:UIControlEventTouchUpInside];
    self.responseStaticBtn.frame = CGRectMake(0, 0, totalWidth + 2 * margin, CGRectGetMaxY(self.lineView.frame));
    
    self.responseDynamicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.responseDynamicBtn];
    [self.responseDynamicBtn setBackgroundColor:[UIColor clearColor]];
    [self.responseDynamicBtn addTarget:self action:@selector(didClickUploadDynamicType) forControlEvents:UIControlEventTouchUpInside];
    self.responseDynamicBtn.frame = CGRectMake(0, CGRectGetMaxY(self.lineView.frame), totalWidth + 2 * margin, totalHeight - CGRectGetMaxY(self.lineView.frame));
    
    self.backgroundColor = [UIColor whiteColor];
    
}

- (void)didClickUploadStaticType {
    if (self.didClickUploadFileType) {
        self.didClickUploadFileType(NO);
    }
}

- (void)didClickUploadDynamicType {
    if (self.didClickUploadFileType) {
        self.didClickUploadFileType(YES);
    }
}

@end
