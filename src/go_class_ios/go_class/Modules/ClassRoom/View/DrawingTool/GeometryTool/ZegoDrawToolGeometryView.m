//
//  ZegoDrawToolGeometryView.m
//  ZegoWhiteboardVideoDemo
//
//  Created by Vic on 2020/11/23.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoDrawToolGeometryView.h"
#import "ZegoDrawingToolModel.h"
#import <Masonry/Masonry.h>
#import "UIColor+ZegoExtension.h"
#import "ZegoDrawToolGeoToolButton.h"

#define TOOL_GEO_BTN_COUNT      3
#define TOOL_GEO_BTN_WIDTH      20
#define TOOL_GEO_BTN_HEIGHT     20

#define TOOL_GEO_BTN_LEADING    16
#define TOOL_GEO_BTN_TRAIL      16
#define TOOL_GEO_BTN_SPACE      17

#define TITLE_TOP_MARGIN        15
#define TITLE_FONT_SIZE         12
#define TOOL_VERTICAL_SPACE     12
#define TOOL_BOTTOM_MARGIN      15

#define TOOL_GEO_VIEW_HEIGHT    TITLE_TOP_MARGIN + \
                                TITLE_FONT_SIZE + \
                                TOOL_VERTICAL_SPACE + \
                                TOOL_GEO_BTN_HEIGHT + \
                                TOOL_BOTTOM_MARGIN

#define TOOL_GEO_VIEW_WIDTH     TOOL_GEO_BTN_LEADING + \
                                TOOL_GEO_BTN_TRAIL + \
                                TOOL_GEO_BTN_COUNT * TOOL_GEO_BTN_HEIGHT + \
                                (TOOL_GEO_BTN_COUNT - 1) * TOOL_GEO_BTN_SPACE

@interface ZegoDrawToolGeometryView ()

@property (nonatomic, strong) UILabel *geoTitle;

@property (nonatomic, copy) NSArray<ZegoDrawingToolModel *> *geoToolModels;
@property (nonatomic, copy) NSArray<ZegoDrawToolGeoToolButton *> *geoToolBtns;
@property (nonatomic, strong) ZegoDrawToolGeoToolButton *selectedGeoToolBtn;

@end

@implementation ZegoDrawToolGeometryView

- (instancetype)init {
    self = [super init];
    [self setup];
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor whiteColor];
    CGFloat height = TOOL_GEO_VIEW_HEIGHT;
    CGFloat width = TOOL_GEO_VIEW_WIDTH;
    self.frame = CGRectMake(0, 0, width, height);
    self.layer.cornerRadius = 5;
    self.layer.shadowColor = [UIColor colorWithRGB:@"#000000" alpha:0.1].CGColor;
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 6;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    
    [self addSubviews];
}

- (void)addSubviews {
    UILabel *geoTitle = [[UILabel alloc] init];
    self.geoTitle = geoTitle;
    [self addSubview:geoTitle];
    geoTitle.attributedText = [[NSAttributedString alloc] initWithString:@"形状选择" attributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:12],
        NSForegroundColorAttributeName: UIColorHex(0x18191a),
    }];
    
    for (ZegoDrawToolGeoToolButton *btn in self.geoToolBtns) {
        [self addSubview:btn];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.geoTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(TOOL_GEO_BTN_LEADING);
        make.top.offset(TITLE_TOP_MARGIN);
    }];
    [self.geoToolBtns mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
                                  withFixedSpacing:TOOL_GEO_BTN_SPACE
                                       leadSpacing:TOOL_GEO_BTN_LEADING
                                       tailSpacing:TOOL_GEO_BTN_TRAIL];
    [self.geoToolBtns mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.geoTitle.mas_bottom).offset(TOOL_VERTICAL_SPACE);
        make.height.mas_equalTo(TOOL_GEO_BTN_HEIGHT);
    }];
}

#pragma mark - Button Action
// 手指主动点击
- (void)onClickGeoToolBtn:(id)sender {
    ZegoDrawToolGeoToolButton *button = (ZegoDrawToolGeoToolButton *)sender;
    [self geoBtnClickAction:button dismiss:NO];
}

// 选择图形, 代码自动点击
- (BOOL)selectItemWithType:(ZegoDrawingToolViewItemType)toolType {
    for (ZegoDrawToolGeoToolButton *geoBtn in self.geoToolBtns) {
        if (geoBtn.toolModel.type == toolType) {
            [self geoBtnClickAction:geoBtn dismiss:NO];
            return YES;
        }
    }
    return NO;
}

- (void)geoBtnClickAction:(ZegoDrawToolGeoToolButton *)button dismiss:(BOOL)dismiss {
    [self.selectedGeoToolBtn setSelected:NO];
    [button setSelected:YES];
    self.selectedGeoToolBtn = button;
    if ([self.delegate respondsToSelector:@selector(geometryView:didSelectTool:dismissAfterSelection:)]) {
        [self.delegate geometryView:self didSelectTool:button.toolModel.type dismissAfterSelection:dismiss];
    }
}



#pragma mark - Lazy load
- (NSArray *)geoToolsData {
    return @[
        @{@"text":@"矩形", @"selectedImage":@"tool_rectangle_click", @"normalImage":@"tool_rectangle", @"isSelected":@(0), @"type":@(ZegoDrawingToolViewItemTypeRect)},
        @{@"text":@"椭圆", @"selectedImage":@"tool_oval_click", @"normalImage":@"tool_oval", @"isSelected":@(0), @"type":@(ZegoDrawingToolViewItemTypeEllipse)},
        @{@"text":@"直线", @"selectedImage":@"tool_line_click", @"normalImage":@"tool_line", @"isSelected":@(0), @"type":@(ZegoDrawingToolViewItemTypeLine)},
    ];
}

- (NSArray<ZegoDrawingToolModel *> *)geoToolModels {
    if (!_geoToolModels) {
        NSMutableArray *ret = [NSMutableArray array];
        for (NSDictionary *data in [self geoToolsData]) {
            ZegoDrawingToolModel * model = [[ZegoDrawingToolModel alloc] initWithJson:data];
            [ret addObject:model];
        }
        _geoToolModels = ret.copy;
    }
    return _geoToolModels;
}

- (NSArray<ZegoDrawToolGeoToolButton *> *)geoToolBtns {
    if (!_geoToolBtns) {
        NSMutableArray *ret = [NSMutableArray array];
        for (ZegoDrawingToolModel *model in self.geoToolModels) {
            ZegoDrawToolGeoToolButton *btn = [[ZegoDrawToolGeoToolButton alloc] initWithToolModel:model];
            [btn setFrame:CGRectMake(0, 0, TOOL_GEO_BTN_WIDTH, TOOL_GEO_BTN_HEIGHT)];
            [btn addTarget:self action:@selector(onClickGeoToolBtn:) forControlEvents:UIControlEventTouchUpInside];
            [ret addObject:btn];
        }
        _geoToolBtns = ret.copy;
    }
    return _geoToolBtns;
}

@end
