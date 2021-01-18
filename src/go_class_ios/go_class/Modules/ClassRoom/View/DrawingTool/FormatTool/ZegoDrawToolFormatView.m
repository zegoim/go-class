//
//  ZegoDrawToolFormatView.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/5.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoDrawToolFormatView.h"
#import "ZegoUIConstant.h"
#import "UIColor+ZegoExtension.h"
#import "RadioButton.h"
#import "NSString+ZegoExtension.h"
@interface ZegoDrawToolFormatView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (copy, nonatomic) NSArray<ZegoDrawToolBrush *> *brushes;
@property (copy, nonatomic) NSArray<ZegoDrawToolColor *> *colors;
@property (copy, nonatomic) NSArray<ZegoDrawToolFont *> *fonts;
@property (copy, nonatomic) NSArray<ZegoTextFormat *> *textFormats;

@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation ZegoDrawToolFormatView

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithSelectedFormat:(ZegoDrawToolFormat *)format {
    if (self = [super init]) {
        _selectedFormat = format;
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setupDefaultFormat];
        self.selectedFormat = [[ZegoDrawToolFormat alloc] initWithBrush:self.brushes[1] color:self.colors[4] font:self.fonts[1] textFormats:nil];

    self.backgroundColor = [UIColor whiteColor];
    self.frame = CGRectMake(0, 0, kDrawingToolViewFormatViewWidth, kDrawingToolViewFormatViewHeight);
    self.layer.cornerRadius = 5;
    self.layer.shadowColor = [UIColor colorWithRGB:@"#1a6666" alpha:0.15].CGColor;
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 6;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0.0;
        layout.minimumInteritemSpacing = 0.0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(15, 15, kDrawingToolViewFormatViewWidth - 32, kDrawingToolViewFormatViewHeight - 32) collectionViewLayout: layout];
    self.collectionView.scrollEnabled = NO;
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];  //  一定要设置

    [self.collectionView registerClass:[ZegoDrawToolFormatCell class] forCellWithReuseIdentifier:@"ZegoDrawToolFormatCell"];
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.collectionView];
    
//    UILabel *brushHeader = [self headerLabelWithText:@"笔触&边框粗细"];
//    [self.container addSubview:brushHeader];
//    brushHeader.frame = CGRectMake(0, 0, brushHeader.bounds.size.width, brushHeader.bounds.size.height);
    
}

- (void)setupDefaultFormat {
     NSArray *textFormats = @[
        [[ZegoTextFormat alloc] initWithTextFormatId:1 textFormatType:ZegoTextFormatTypeBold normalImageName:@"text_Bold_select_1" selectedImageName:@"text_Bold_1" isSelected:NO],
        [[ZegoTextFormat alloc] initWithTextFormatId:2 textFormatType:ZegoTextFormatTypeItalic normalImageName:@"text_italic_select_1" selectedImageName:@"text_italic_1" isSelected:NO]
     ];

    self.textFormats = textFormats;
    

    NSArray *brushes = @[
        [[ZegoDrawToolBrush alloc] initWithBrushWidth:4 isSelected:NO],
        [[ZegoDrawToolBrush alloc] initWithBrushWidth:6 isSelected:YES],
        [[ZegoDrawToolBrush alloc] initWithBrushWidth:8 isSelected:NO],
        [[ZegoDrawToolBrush alloc] initWithBrushWidth:10 isSelected:NO]
    ];
    self.brushes = brushes;
    
    NSArray *colors = @[
        [[ZegoDrawToolColor alloc] initWithColor:[UIColor colorWithRGB:@"#ffffff"] isSelected:NO],
        [[ZegoDrawToolColor alloc] initWithColor:[UIColor colorWithRGB:@"#b3b3b3"] isSelected:NO],
        [[ZegoDrawToolColor alloc] initWithColor:[UIColor colorWithRGB:@"#333333"] isSelected:NO],
        [[ZegoDrawToolColor alloc] initWithColor:[UIColor colorWithRGB:@"#000000"] isSelected:NO],
        [[ZegoDrawToolColor alloc] initWithColor:[UIColor colorWithRGB:@"#f54326"] isSelected:YES],
        [[ZegoDrawToolColor alloc] initWithColor:[UIColor colorWithRGB:@"#fc7802"] isSelected:NO],
        
        [[ZegoDrawToolColor alloc] initWithColor:[UIColor colorWithRGB:@"#fbe600"] isSelected:NO],
        [[ZegoDrawToolColor alloc] initWithColor:[UIColor colorWithRGB:@"#41bb54"] isSelected:NO],
        [[ZegoDrawToolColor alloc] initWithColor:[UIColor colorWithRGB:@"#00eae7"] isSelected:NO],
        [[ZegoDrawToolColor alloc] initWithColor:[UIColor colorWithRGB:@"#4c9efe"] isSelected:NO],
        [[ZegoDrawToolColor alloc] initWithColor:[UIColor colorWithRGB:@"#fa7d7d"] isSelected:NO],
        [[ZegoDrawToolColor alloc] initWithColor:[UIColor colorWithRGB:@"#825fd0"] isSelected:NO]
    ];
    self.colors = colors;
    
    NSArray *fonts = @[
        [[ZegoDrawToolFont alloc] initWithFont:[UIFont systemFontOfSize:18] isSelected:NO],
        [[ZegoDrawToolFont alloc] initWithFont:[UIFont systemFontOfSize:24] isSelected:YES],
        [[ZegoDrawToolFont alloc] initWithFont:[UIFont systemFontOfSize:36] isSelected:NO],
        [[ZegoDrawToolFont alloc] initWithFont:[UIFont systemFontOfSize:48] isSelected:NO],
    ];
    self.fonts = fonts;
}

- (UILabel *)headerLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    label.text = text;
    label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    label.textColor = kTextColor1;
    [label sizeToFit];
    return label;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.delegate && [self.delegate respondsToSelector:@selector(zegoDrawToolFormatView:didSelectFormat:)]) {
        [self.delegate zegoDrawToolFormatView:self didSelectFormat:self.selectedFormat];
    }
}


#pragma mark - CollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
     if (indexPath.section == 0) {
         for (NSInteger i = 0; i < self.textFormats.count; i++) {
             ZegoTextFormat *obj = self.textFormats[i];
             if (i == indexPath.item) {
                 obj.isSelected = !obj.isSelected;
             }
         }
        self.selectedFormat.textFormats = self.textFormats;

    } else if (indexPath.section == 1) {

        for (NSInteger i = 0; i < self.fonts.count; i++) {
            ZegoDrawToolFont *obj = self.fonts[i];
            if (i == indexPath.item) {
                obj.isSelected = YES;
            } else {
                obj.isSelected = NO;
            }
        }
        self.selectedFormat.font = self.fonts[indexPath.item];
    } else if (indexPath.section == 2) {

        for (NSInteger i = 0; i < self.brushes.count; i++) {
            ZegoDrawToolBrush *obj = self.brushes[i];
            if (i == indexPath.item) {
                obj.isSelected = YES;
            } else {
                obj.isSelected = NO;
            }
        }
        self.selectedFormat.brush = self.brushes[indexPath.item];
    } else {
        for (NSInteger i = 0; i < self.colors.count; i++) {
            ZegoDrawToolColor *obj = self.colors[i];
            if (i == indexPath.item) {
                obj.isSelected = YES;
            } else {
                obj.isSelected = NO;
            }
        }
        self.selectedFormat.color = self.colors[indexPath.item];
    }
    if (self.delegate) {
        [self.delegate zegoDrawToolFormatView:self didSelectFormat:self.selectedFormat];
    }
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
     if (section == 0) {
        return self.textFormats.count;
     } else if (section == 1) {
         return self.fonts.count;
        
     } else if (section == 2) {
         return self.brushes.count;
     } else {
         return self.colors.count;
     }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 4;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZegoDrawToolFormatCell *cell = (ZegoDrawToolFormatCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ZegoDrawToolFormatCell" forIndexPath:indexPath];
    cell.titleLabel.text = @"18";
    if (indexPath.section == 0) {
            cell.layer.masksToBounds = YES;
            CGFloat h = [self collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath].height;
            cell.layer.cornerRadius = h / 2;
            cell.layer.borderWidth = 0;
            ZegoTextFormat *textFormat = self.textFormats[indexPath.item];
            cell.textFormatImageView.hidden = NO;

            if (textFormat.isSelected) {
                [cell.textFormatImageView setImage:[UIImage imageNamed:textFormat.normalImageName]];
                cell.titleLabel.textColor = [UIColor colorWithRGB:@"ffffff"];
                cell.contentView.backgroundColor = [UIColor colorWithRGB:@"0044ff"];
            } else {
                [cell.textFormatImageView setImage:[UIImage imageNamed:textFormat.selectedImageName]];
                cell.titleLabel.textColor = kTextColor1;
                cell.contentView.backgroundColor = [UIColor colorWithRGB:@"f4f5f8"];
            }
    } else if (indexPath.section == 1) {
        cell.layer.masksToBounds = YES;
          CGFloat h = [self collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath].height;
          cell.layer.cornerRadius = h / 2;
          cell.layer.borderWidth = 0;
          ZegoDrawToolFont *font = self.fonts[indexPath.item];
          cell.titleLabel.hidden = NO;
        
          cell.titleLabel.text = @(font.font.pointSize).stringValue;
          if (font.isSelected) {
              cell.titleLabel.textColor = [UIColor colorWithRGB:@"ffffff"];
              cell.contentView.backgroundColor = [UIColor colorWithRGB:@"0044ff"];
          } else {
              cell.titleLabel.textColor = kTextColor1;
              cell.contentView.backgroundColor = [UIColor colorWithRGB:@"f4f5f8"];
          }
        
    } else if (indexPath.section == 2) {
        cell.brushView.hidden = NO;
        CGFloat width = 20;
        CGFloat widthC = (indexPath.item + 4) * 2;
        CGFloat heightC = widthC;
        CGFloat x = (width - widthC)/2;
        cell.brushView.layer.masksToBounds = YES;
        cell.brushView.layer.cornerRadius = heightC / 2;
        cell.brushView.frame = CGRectMake(x, x, widthC, heightC);
        ZegoDrawToolBrush *brush = self.brushes[indexPath.item];
        cell.contentView.backgroundColor = [UIColor clearColor];
        if (brush.isSelected) {
            cell.brushView.backgroundColor = [UIColor colorWithRGB:@"0044ff"];
        } else {
            cell.brushView.backgroundColor = [UIColor colorWithRGB:@"b1b4bd"];
        }
        
        cell.layer.borderWidth = 0;
        
    } else {
        ZegoDrawToolColor *color = self.colors[indexPath.item];
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = 20 / 2;
        cell.layer.borderWidth = 2;
        cell.layer.borderColor = [UIColor colorWithRGB:@"f4f5f8"].CGColor;
        if (indexPath.row == 0) {
            cell.colorSelectedImageView.image = [UIImage imageNamed:@"click_color"];
        } else {
            cell.colorSelectedImageView.image = [UIImage imageNamed:@"click_none"];
        }
        cell.colorSelectedImageView.hidden = !color.isSelected;
        cell.contentView.backgroundColor = color.color;
        
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    for (UIView *subView in headerView.subviews) {
        if (subView.tag == 9991) {
            [subView removeFromSuperview];
        }
    }
    UILabel *header = [[UILabel alloc] init];
    header.tag = 9991;
    [headerView addSubview:header];
    header.font = [UIFont systemFontOfSize:12];
    header.textColor = kTextColor1;
     if (indexPath.section == 0) {
        header.text = [NSString zego_localizedString:@"wb_tool_font"];
     } else if (indexPath.section == 1){
         header.text = [NSString zego_localizedString:@"wb_tool_font_size"];
     } else if (indexPath.section == 2) {
        header.text = [NSString zego_localizedString:@"wb_tool_pen_border_thickness"];
     } else {
         header.text = [NSString zego_localizedString:@"wb_tool_color"];
     }
     if (indexPath.section == 0) {
//        header.frame = CGRectMake(0, 0, collectionView.bounds.size.width, 12);
        header.frame = CGRectMake(0, 0, collectionView.bounds.size.width, 12);
     } else if (indexPath.section == 1) {
        header.frame = CGRectMake(0, 14, collectionView.bounds.size.width, 12);
     } else if (indexPath.section == 2) {
         header.frame = CGRectMake(0, 14, collectionView.bounds.size.width, 12);
     } else {
         header.frame = CGRectMake(0, 11, collectionView.bounds.size.width, 12);
     }
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
        if (section == 0) {
        return CGSizeMake(collectionView.bounds.size.width, 21);
    } else if (section == 1) {
        return CGSizeMake(collectionView.bounds.size.width, 36);
    } else if (section == 2){
        return CGSizeMake(collectionView.bounds.size.width, 33);
    } else{
        return CGSizeMake(collectionView.bounds.size.width, 33);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(40, 24);
    } else if (indexPath.section == 1) {
        return CGSizeMake(40, 24);
    } else if (indexPath.section == 2) {
        CGFloat width = 20;
        return CGSizeMake(width, width);
    } else {
        return CGSizeMake(20, 20);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return 0;
        
    } else if (section == 1) {
        return 0;
    } else if (section == 2) {
        return 10;
    } else {
        return 10;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        
            return (195-40*4)/3;
    } else if (section == 1){
        
            return (195-40*4)/3;
    } else if (section == 2) {

            return (195-20*4)/3;
    } else {
            return 15;
    }
}
@end

#pragma mark - Cell

@implementation ZegoDrawToolFormatCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    self.titleLabel.frame = CGRectMake(0,0, width, height);
    self.textFormatImageView.frame = CGRectMake((width - 13)/2, (height - 13)/2, 13, 13);
    self.colorSelectedImageView.frame = CGRectMake(0, 0, width, height);
    
}

- (void)configUI {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    self.titleLabel.hidden = YES;
    self.colorSelectedImageView = [[UIImageView alloc] init];
    self.colorSelectedImageView.image = [UIImage imageNamed:@"click_color"];
    self.colorSelectedImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.colorSelectedImageView.hidden = YES;
    self.brushView = [[UIView alloc] init];
    self.brushView.hidden = YES;
    self.textFormatImageView = [[UIImageView alloc] init];
    self.textFormatImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.textFormatImageView.hidden = YES;
    [self.contentView addSubview:self.brushView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.colorSelectedImageView];
    [self.contentView addSubview:self.textFormatImageView];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.titleLabel.hidden = YES;
    self.brushView.hidden = YES;
    self.colorSelectedImageView.hidden = YES;
    self.textFormatImageView.hidden = YES;
}

@end
