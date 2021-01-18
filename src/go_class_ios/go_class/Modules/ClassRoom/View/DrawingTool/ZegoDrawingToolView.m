//
//  ZegoDrawingToolView.m
//  ZegoEducation
//
//  Created by MrLQ  on 2018/4/12.
//  Copyright © 2018年 Shenzhen Zego Technology Company Limited. All rights reserved.
//

#import "ZegoDrawingToolView.h"
#import "ZegoViewAnimator.h"
#import "UIColor+ZegoExtension.h"
#import "ZegoUIConstant.h"
#import "ZegoDrawingToolModel.h"
#import "ZegoDrawToolGeometryView.h"
#import "NSString+ZegoExtension.h"
#if ZEGO_TOOL_JUST_TEST_NEEDED == 1
#define ZEGO_TOOL_TEST_VISIBLE
#endif

typedef NS_ENUM(NSUInteger, ZegoDrawingToolIndex) {
#ifdef ZEGO_TOOL_TEST_VISIBLE
    ZegoDrawingToolIndexJustTest,       //测试页
#endif
    ZegoDrawingToolIndexClick,          //点击
    ZegoDrawingToolIndexSelect,         //选择
    ZegoDrawingToolIndexDrag,           //拖拽
    ZegoDrawingToolIndexPath,           //画笔
    ZegoDrawingToolIndexLaser,          //激光笔
    ZegoDrawingToolIndexText,           //文本
    ZegoDrawingToolIndexGeometry,       //图形
    ZegoDrawingToolIndexFormat,         //格式
    ZegoDrawingToolIndexEraser,         //橡皮擦
    ZegoDrawingToolIndexClear,          //清空
    ZegoDrawingToolIndexUndo,           //撤销
    ZegoDrawingToolIndexRedo,           //重做
    ZegoDrawingToolIndexSave,           //保存
    ZegoDrawingToolIndexTotalCount,     //教具总数 13-14
};

@interface ZegoDrawingToolView ()<ZegoDrawToolFormatViewDelegate, ZegoDrawToolGeometryViewDelegate>

@property (nonatomic, strong) UITableView *toolTableView;

@property (nonatomic, strong) ZegoDrawToolFormatView *formatView;
@property (nonatomic, strong) ZegoDrawToolGeometryView *geoView;

@property (nonatomic, copy) NSDictionary *toolTypeIndexMap;
@property (nonatomic, strong) NSMutableArray *toolModels;
@property (nonatomic, strong) NSArray *colorArray;

@end

#pragma mark - 选择工具 cell
@interface ZegoDrawingToolTableViewCell : UITableViewCell

@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) ZegoDrawingToolModel *toolModel;

@end

@implementation ZegoDrawingToolView

+ (instancetype)defaultInstance {
    CGFloat drawingToolViewY = 44;
    ZegoDrawingToolView *toolView = [[ZegoDrawingToolView alloc] initWithFrame:CGRectMake(kBoardViewWidth - kDrawingToolViewWidth - 8, drawingToolViewY, kDrawingToolViewWidth, kDrawingToolViewHeight)];
    toolView.hidden = YES;
    return toolView;
}

- (BOOL)isDragEnable {
    ZegoDrawingToolModel *dragModel = self.toolModels[ZegoDrawingToolIndexDrag];
    if (!dragModel) {
        return NO;
    }
    return dragModel.isSelected;
//    for (ZegoDrawingToolModel *model in self.toolModels) {
//        if (model.type == ZegoDrawingToolViewItemTypeDrag) {
//            if (model.isSelected) {
//                return YES;
//            }
//        }
//    }
//    return NO;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didChangeFormat:)]) {
            [self.delegate didChangeFormat:self.formatView.selectedFormat];
        }
    }
}

#pragma mark - public method

- (void)changeToItemType:(ZegoDrawingToolViewItemType)itemType response:(BOOL)response{
    ZegoDrawingToolIndex toolIndex = [self toolIndexWithToolType:itemType];
    if (toolIndex >= ZegoDrawingToolIndexTotalCount || toolIndex < 0) {
        return;
    }
    ZegoDrawingToolModel *toolModel = self.toolModels[toolIndex];
    if (response) {
        [self tableView:self.toolTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:toolIndex inSection:0]];
        return;
    }
    toolModel.isSelected = YES;
    [self.toolTableView reloadData];
    
//    for (int i = 0 ; i < self.toolModels.count; i++) {
//        ZegoDrawingToolModel *toolModel = self.toolModels[i];
//        BOOL change = (toolModel.type == itemType);
//        if (response && change) {
//            [self tableView:self.toolTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
//            return;
//        } else {
//            toolModel.isSelected = change;
//        }
//    }
//    [self.toolTableView reloadData];
}

- (void)enableItemType:(ZegoDrawingToolViewItemType)itemType isEnabled:(BOOL)isEnabled {
    ZegoDrawingToolModel *toolModel = [self toolModelWithToolType:itemType];
    if (!toolModel) {
        return;
    }
    toolModel.isEnabled = isEnabled;
    [self.toolTableView reloadData];
}

- (void)resetDrawingColorView
{
    for(ZegoDrawingToolModel * toolModel in self.toolModels){
        toolModel.isSelected = (toolModel.type == ZegoDrawingToolViewItemTypePath);
    }
    _selectedColor = UIColorHex(#f54326);
    [self configUI];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.toolModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZegoDrawingToolTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZegoDrawingToolTableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selectedColor = _selectedColor;
    cell.toolModel  = self.toolModels[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZegoDrawingToolModel * selectedTool = self.toolModels[indexPath.row];
    BOOL geoViewAlreadySelected = NO;
    if (selectedTool.type == ZegoDrawingToolViewItemTypeGeometry) {
        geoViewAlreadySelected = selectedTool.isSelected;
    }
    
    if ([self.delegate itemCanBeSelectedWithType:selectedTool.type]) {
        for (ZegoDrawingToolModel * model in self.toolModels) {
            // 到 模型数组 中遍历模型, 视情况更改被选中教具的 isSelected 选中状态
            if (model.type == selectedTool.type) {
                model.isSelected = YES;
            }else {
                model.isSelected = NO;
            }
            if (selectedTool.type == ZegoDrawingToolViewItemTypeText && model.type == ZegoDrawingToolViewItemTypeArrow) {
                model.isSelected = YES;
            }
        }
    }

    if ([self.delegate respondsToSelector:@selector(selectItemType:selected:)]) {
        [self.delegate selectItemType:selectedTool.type selected:selectedTool.isSelected];
        if (selectedTool.type == ZegoDrawingToolViewItemTypeText) {
            [self.delegate selectItemType:ZegoDrawingToolViewItemTypeArrow selected:YES];
        }
    }
    
    if (selectedTool.type == ZegoDrawingToolViewItemTypeFormat) {
        [ZegoViewAnimator fadeInView:self.formatView onLeftOfView:tableView];
    }else if (selectedTool.type == ZegoDrawingToolViewItemTypeGeometry) {
        [self showGeoToolViewBesideTableView:tableView];
        // 如果 geoView 已经是选中态, 那么不要选择矩形, 保持原状
        if (!geoViewAlreadySelected) {
            [self.geoView selectItemWithType:ZegoDrawingToolViewItemTypeRect];
        }
    }
    
    [self.toolTableView reloadData];
}

#pragma mark - ZegoDrawToolFormatViewDelegate
- (void)zegoDrawToolFormatView:(ZegoDrawToolFormatView *)formatView didSelectFormat:(ZegoDrawToolFormat *)format {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didChangeFormat:)]) {
            [self.delegate didChangeFormat:format];
        }
    }
}

#pragma mark - ZegoDrawToolGeometryViewDelegate
- (void)geometryView:(ZegoDrawToolGeometryView *)geoView didSelectTool:(ZegoDrawingToolViewItemType)toolType dismissAfterSelection:(BOOL)dismiss {
    // 反选已经存在的, 然后选中 '图形' 教具
    for (ZegoDrawingToolModel *model in self.toolModels) {
        if (model.isSelected) {
            if (model.type != ZegoDrawingToolViewItemTypeGeometry) {
                model.isSelected = NO;
            }
            break;
        }
    }
    if (dismiss) {
        [ZegoViewAnimator fadeView:nil completion:nil];
    }
    
    if ([self.delegate respondsToSelector:@selector(selectItemType:selected:)]) {
        [self.delegate selectItemType:toolType selected:YES];
    }
}

#pragma mark - private method
- (ZegoDrawingToolIndex)toolIndexWithToolType:(ZegoDrawingToolViewItemType)toolType {
    NSNumber *indexNumber = self.toolTypeIndexMap[@(toolType)];
    ZegoDrawingToolIndex toolIndex = indexNumber.integerValue;
    return toolIndex;
}

- (ZegoDrawingToolModel *)toolModelWithToolType:(ZegoDrawingToolViewItemType)toolType {
    ZegoDrawingToolIndex toolIndex = [self toolIndexWithToolType:toolType];
    if (toolIndex >= ZegoDrawingToolIndexTotalCount || toolIndex < 0) {
        return nil;
    }
    return self.toolModels[toolIndex];
}

- (void)configUI {
    self.formatView = [[ZegoDrawToolFormatView alloc] init];
    self.formatView.delegate = self;
    self.backgroundColor = [UIColor clearColor];
    self.toolTableView = [self createTableView];
    self.toolTableView.frame = CGRectMake(0, 0, 32, self.frame.size.height);
    [self.toolTableView registerClass:[ZegoDrawingToolTableViewCell class]
               forCellReuseIdentifier:@"ZegoDrawingToolTableViewCell"];
    
    {
        self.geoView = [[ZegoDrawToolGeometryView alloc] init];
        self.geoView.delegate = self;
    }
}

- (UITableView *)createTableView {
    UITableView *tableView = [[UITableView alloc] init];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 30;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.contentInset = UIEdgeInsetsMake(kDrawingToolViewInsetTopMargin, 0, 0, 0);
    [self addSubview:tableView];
    return tableView;
}
// 显示 '图形' 选择 view
- (void)showGeoToolViewBesideTableView:(UITableView *)tableView {
    ZegoDrawingToolIndex toolIndex = [self toolIndexWithToolType:ZegoDrawingToolViewItemTypeGeometry];
    if (toolIndex >= ZegoDrawingToolIndexTotalCount || toolIndex < 0) {
        return;
    }
    
//    NSInteger index = -1;
//    for (NSInteger i = 0; i < self.toolModels.count; i++) {
//        ZegoDrawingToolModel *model = self.toolModels[i];
//        if (model.type == ZegoDrawingToolViewItemTypeGeometry) {
//            index = i;
//            break;
//        }
//    }
//    if (index < 0) {
//        return;
//    }
    NSIndexPath *geoToolIndexPath = [NSIndexPath indexPathForRow:toolIndex inSection:0];
    UITableViewCell *geoCell = [tableView cellForRowAtIndexPath:geoToolIndexPath];  //为获取 cell 的 frame 做准备
    CGFloat cellHeight = geoCell.frame.size.height;
    CGFloat geoCellOffsetY = geoCell.frame.origin.y - tableView.contentOffset.y;
    CGFloat geoHeight = self.geoView.bounds.size.height;
    CGFloat tableViewHeight = tableView.bounds.size.height;
    CGFloat pointY = 0;
    /**
     如果 y + halfcellheight - halfheight < 0, 则与 tableview 上方平齐
     如果 y + halfcellheight + halfheight > tableview.height, 则显示在tableview底部
     else 则显示在 '图形' 工具的正左边
     */
    if (geoCellOffsetY + cellHeight / 2 - geoHeight / 2 < 0) {
        pointY = 5;
    }else if (geoCellOffsetY + cellHeight / 2 + geoHeight / 2 > tableViewHeight) {
        pointY = tableViewHeight - geoHeight - 5;
    }else {
        pointY = geoCellOffsetY + cellHeight / 2 - geoHeight / 2;
    }
    [ZegoViewAnimator fadeInView:self.geoView onLeftOfView:tableView offset:CGPointMake(-8, pointY)];
}

#pragma mark -- Getter
- (NSArray *)colorArray
{
    if (!_colorArray) {
        _colorArray = @[UIColorHex(#ffffff),
                        UIColorHex(#b3b3b3),
                        UIColorHex(#333333),
                        UIColorHex(#000000),
                        UIColorHex(#f54326),
                        UIColorHex(#fc7802),
                        UIColorHex(#fbe600),
                        UIColorHex(#41bb54),
                        UIColorHex(#00eae7),
                        UIColorHex(#4c9efe),
                        UIColorHex(#fa7d7d),
                        UIColorHex(#825fd0)];
    _selectedColor = UIColorHex(#f54326);
    }
    return _colorArray;
}


- (NSArray *)toolInitArray
{
    return @[
#ifdef ZEGO_TOOL_TEST_VISIBLE
        @{@"text":@"测试", @"selectedImage":@"dianji", @"normalImage":@"dianji", @"isSelected":@(0), @"type":@(ZegoDrawingToolViewItemTypeJustTest)},
#endif
        @{@"text":[NSString zego_localizedString:@"wb_tool_click"], @"selectedImage":@"dianji_click", @"normalImage":@"dianji", @"isSelected":@(0), @"type":@(ZegoDrawingToolViewItemTypeClick)},
        @{@"text":[NSString zego_localizedString:@"wb_tool_choice"], @"selectedImage":@"xuanze_click", @"normalImage":@"xuanze", @"isSelected":@(0), @"type":@(ZegoDrawingToolViewItemTypeArrow)},
        @{@"text":[NSString zego_localizedString:@"wb_tool_drag"], @"selectedImage":@"tuozhuai_click", @"normalImage":@"tuozhuai", @"isSelected":@(0), @"type":@(ZegoDrawingToolViewItemTypeDrag)},
        @{@"text":[NSString zego_localizedString:@"wb_tool_brush"], @"selectedImage":@"huabi_click", @"normalImage":@"huabi", @"isSelected":@(1), @"type":@(ZegoDrawingToolViewItemTypePath)},
        @{@"text":[NSString zego_localizedString:@"wb_tool_laser"], @"selectedImage":@"tool_laser_click", @"normalImage":@"tool_laser", @"isSelected":@(0), @"type":@(ZegoDrawingToolViewItemTypeLaser)},
        @{@"text":[NSString zego_localizedString:@"wb_tool_text"], @"selectedImage":@"wenben_click", @"normalImage":@"wenben", @"isSelected":@(0), @"type":@(ZegoDrawingToolViewItemTypeText)},
        @{@"text":[NSString zego_localizedString:@"wb_tool_graphical"], @"selectedImage":@"tool_figure_click", @"normalImage":@"tool_figure", @"isSelected":@(0), @"type":@(ZegoDrawingToolViewItemTypeGeometry)},
        @{@"text":[NSString zego_localizedString:@"wb_tool_format"], @"selectedImage":@"geshi_click", @"normalImage":@"geshi", @"isSelected":@(0), @"type":@(ZegoDrawingToolViewItemTypeFormat)},
        @{@"text":[NSString zego_localizedString:@"wb_tool_erase"], @"selectedImage":@"xiangpica_click", @"normalImage":@"xiangpica", @"isSelected":@(0), @"type":@(ZegoDrawingToolViewItemTypeEraser)},
        @{@"text":[NSString zego_localizedString:@"wb_tool_clear"], @"selectedImage":@"qingkong_click", @"normalImage":@"qingchu", @"isSelected":@(0), @"type":@(ZegoDrawingToolViewItemTypeClear)},
        @{@"text":[NSString zego_localizedString:@"wb_tool_revoke"], @"selectedImage":@"chexiao_click", @"normalImage":@"chexiao", @"isSelected":@(0), @"type":@(ZegoDrawingToolViewItemTypeUndo)},
        @{@"text":[NSString zego_localizedString:@"wb_tool_redo"], @"selectedImage":@"chongzuo_click", @"normalImage":@"chongzuo", @"isSelected":@(0), @"type":@(ZegoDrawingToolViewItemTypeRedo)},
        @{@"text":[NSString zego_localizedString:@"wb_tool_save"], @"selectedImage":@"tool_save_click", @"normalImage":@"tool_save", @"isSelected":@(0), @"type":@(ZegoDrawingToolViewItemTypeSave)},
    ];
}

- (NSMutableArray *)toolModels
{
    if (!_toolModels) {
        _toolModels = [NSMutableArray new];
        for (NSDictionary * data in [self toolInitArray] ) {
            ZegoDrawingToolModel * model = [[ZegoDrawingToolModel alloc] initWithJson:data];
            [_toolModels addObject:model];
        }
    }
    return _toolModels;
}
/**
 tooltype -> index
 */
- (NSDictionary *)toolTypeIndexMap {
    if (!_toolTypeIndexMap) {
        _toolTypeIndexMap = @{
#ifdef ZEGO_TOOL_TEST_VISIBLE
            @(ZegoDrawingToolViewItemTypeJustTest):     @(ZegoDrawingToolIndexJustTest),
#endif
            @(ZegoDrawingToolViewItemTypePath):         @(ZegoDrawingToolIndexPath),
            @(ZegoDrawingToolViewItemTypeText):         @(ZegoDrawingToolIndexText),
            @(ZegoDrawingToolViewItemTypeLine):         @(ZegoDrawingToolIndexGeometry),
            @(ZegoDrawingToolViewItemTypeRect):         @(ZegoDrawingToolIndexGeometry),
            @(ZegoDrawingToolViewItemTypeEllipse):      @(ZegoDrawingToolIndexGeometry),
            @(ZegoDrawingToolViewItemTypeGeometry):     @(ZegoDrawingToolIndexGeometry),
            @(ZegoDrawingToolViewItemTypeArrow):        @(ZegoDrawingToolIndexSelect),
            @(ZegoDrawingToolViewItemTypeEraser):       @(ZegoDrawingToolIndexEraser),
            @(ZegoDrawingToolViewItemTypeFormat):       @(ZegoDrawingToolIndexFormat),
            @(ZegoDrawingToolViewItemTypeUndo):         @(ZegoDrawingToolIndexUndo),
            @(ZegoDrawingToolViewItemTypeRedo):         @(ZegoDrawingToolIndexRedo),
            @(ZegoDrawingToolViewItemTypeClear):        @(ZegoDrawingToolIndexClear),
            @(ZegoDrawingToolViewItemTypeDrag):         @(ZegoDrawingToolIndexDrag),
            @(ZegoDrawingToolViewItemTypeLaser):        @(ZegoDrawingToolIndexLaser),
            @(ZegoDrawingToolViewItemTypeClick):        @(ZegoDrawingToolIndexClick),
            @(ZegoDrawingToolViewItemTypeSave):         @(ZegoDrawingToolIndexSave),
        };
    }
    return _toolTypeIndexMap;
}

@end

#pragma mark - Tool cell
@interface ZegoDrawingToolTableViewCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *selectedView;

@end

@implementation ZegoDrawingToolTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    self.selectedView.frame = CGRectMake(0, 0, width, height - 4);
    self.iconImageView.frame = CGRectMake((width - 16) / 2.0, 2, 16, 16);
    self.titleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.iconImageView.frame), width, 9);
    
}

- (void)setToolModel:(ZegoDrawingToolModel *)toolModel
{
    _toolModel = toolModel;
    self.titleLabel.text = toolModel.text;
    //有选中态工具：指针、画笔、矩形、椭圆、橡皮、直线、拖拽、颜色、动态点击
    if (toolModel.isSelected && (toolModel.type == ZegoDrawingToolViewItemTypeArrow ||
                                 toolModel.type == ZegoDrawingToolViewItemTypePath||
                                 toolModel.type == ZegoDrawingToolViewItemTypeLaser||
                                 toolModel.type == ZegoDrawingToolViewItemTypeEraser ||
                                 toolModel.type == ZegoDrawingToolViewItemTypeDrag ||
                                 toolModel.type == ZegoDrawingToolViewItemTypeFormat ||
                                 toolModel.type == ZegoDrawingToolViewItemTypeClick ||
                                 toolModel.type == ZegoDrawingToolViewItemTypeGeometry)) {
        self.titleLabel.textColor = UIColorHex(#0044ff);
        self.iconImageView.image = [UIImage imageNamed:toolModel.selectedImage];
    } else {
        self.titleLabel.textColor = kTextColor1;
        self.iconImageView.image = [UIImage imageNamed:toolModel.normalImage];
    }
    if (toolModel.isEnabled) {
        self.titleLabel.alpha = 1;
        self.iconImageView.alpha = 1;
    } else {
        self.titleLabel.alpha = 0.4;
        self.iconImageView.alpha = 0.4;
    }
}

- (void)configUI
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    self.backgroundColor = [UIColor clearColor];
    self.selectedView = [[UIView alloc] initWithFrame:CGRectMake(4, 4, width - 8, height - 8)];
    self.selectedView.backgroundColor = UIColor.whiteColor;
    self.selectedView.layer.masksToBounds = YES;
    self.selectedView.layer.cornerRadius = 2;
    self.selectedView.layer.borderColor = kGrayLineColor.CGColor;
    self.selectedView.layer.borderWidth = kLineWidth;
    [self.contentView addSubview:self.selectedView];
    
    self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((width - 16) / 2.0, 2, 16, 16)];
    self.iconImageView.layer.cornerRadius = 8;
    self.iconImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.contentView addSubview:self.iconImageView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, height - 16, width, 9)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:9];
    [self.contentView addSubview:self.titleLabel];
}

@end
