//
//  ZegoFilePreviewView.m
//  ZegoWhiteboardVideoDemo
//
//  Created by MartinNie on 2020/8/19.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoFilePreviewView.h"
#import "ZegoFilePreviewCollectionViewCell.h"
#import "ZegoUIConstant.h"
#import "UIColor+ZegoExtension.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "NSString+ZegoExtension.h"
@interface ZegoFilePreviewView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger totoalPageCount;
@property (nonatomic, strong) UILabel *titleLabel;
@end
@implementation ZegoFilePreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self reset];
        [self setupSubviews];
        
    }
    return self;
}

- (void)setupSubviews
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 10;
    self.layer.shadowOpacity = 0.2;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 14, self.frame.size.width - 40, 15)];
    [self addSubview:self.titleLabel];
    self.titleLabel.text = [NSString zego_localizedString:@"wb_preview"];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.textColor = kTextColor1;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame) + 14, self.frame.size.width, kLineWidth)];
    [self addSubview:lineView];
    lineView.backgroundColor = [UIColor colorWithRGB:@"edeff3"];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), self.frame.size.width,  self.frame.size.height - 44) collectionViewLayout:layout];
    [self addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[ZegoFilePreviewCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"head"];
}

- (void)setPreviewPageCount:(NSInteger)pageCount
{
    //将选中的item 定位在当前列表的第二行
    if (_currentPage != pageCount) {
    
        _currentPage = pageCount;
        NSIndexPath *realIndexPath = [NSIndexPath  indexPathForRow:pageCount inSection:0];
        pageCount = (pageCount - 1) < 0?pageCount:pageCount-1;
        NSIndexPath *logicIndexPath = [NSIndexPath  indexPathForRow:pageCount inSection:0];
        [self.collectionView scrollToItemAtIndexPath:logicIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        [self.collectionView selectItemAtIndexPath:realIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    
}

- (void)setDataArray:(NSArray *)dataArray
{
    _dataArray = dataArray;
    _currentPage = -1;
    self.totoalPageCount = dataArray.count;
    [self.collectionView reloadData];
}

- (void)reset
{
    _currentPage = -1;
    _dataArray = nil;
    _totoalPageCount = 0;
    [self.collectionView reloadData];
}

#pragma Mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    ZegoFilePreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.pageLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row + 1];
    [cell.contentIV yy_setImageWithURL:[NSURL URLWithString:self.dataArray[indexPath.row]] placeholder:nil];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentPage == indexPath.row) {
        cell.selected = YES;
    } else {
        cell.selected = NO;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.bounds.size.width, (kScreenHeight - 5 * 12)/4);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger pageCount = indexPath.row;
    if (pageCount == self.currentPage) {
        return;
    }
    [self setPreviewPageCount:pageCount];
    if (self.selectedPageBlock) {
        self.selectedPageBlock(pageCount);
    }
}


@end
