//
//  ZegoWhiteboardListView.m
//  ZegoWhiteboardViewDemo
//
//  Created by zego on 2020/4/16.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoWhiteboardListView.h"
#import "UIColor+ZegoExtension.h"
#import "ZegoWhiteBoardListCell.h"
#import "ZegoUIConstant.h"
#include "NSString+Size.h"

@interface ZegoWhiteboardListView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *viewList;
@property (nonatomic, strong) ZegoBoardContainer *selectedView;

@end

@implementation ZegoWhiteboardListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}

#pragma mark - public method
- (void)refreshWithBoardContainerModels:(NSArray <ZegoWhiteBoardViewContainerModel *>*)boardContainerModels selected:(ZegoBoardContainer *)selected
{
    self.viewList = [boardContainerModels copy];
    self.selectedView = selected;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZegoWhiteBoardListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZegoWhiteBoardListCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (@available(iOS 11.0, *)) {
        cell.insetsLayoutMarginsFromSafeArea = NO;
    }
    ZegoWhiteBoardViewContainerModel *fileView = [self getViewWithIndex:indexPath.row];
    cell.nameLabel.text = [fileView.selectedBoardContainer.whiteboardView.whiteboardModel.name stringForContainerWidth:kStreamCellWidth - 66 font:[UIFont systemFontOfSize:13 weight:UIFontWeightRegular]];
    cell.nameLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    cell.nameLabel.textColor = fileView.selectedBoardContainer.whiteboardID == self.selectedView.whiteboardID ? kThemeColorBlue : kTextColor1;
    cell.onTapCloseButton = ^{
        ZegoWhiteBoardViewContainerModel *fileView = [self getViewWithIndex:indexPath.row];
        if (fileView != nil &&
            [self.delegate respondsToSelector:@selector(whiteBoardListDidDeleteView:)]) {
            [self.delegate whiteBoardListDidDeleteView:fileView];
        }
    };

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZegoWhiteBoardViewContainerModel *fileView = [self getViewWithIndex:indexPath.row];
    if (fileView != nil &&
        [self.delegate respondsToSelector:@selector(whiteBoardListDidSelectView:)]) {
        [self.delegate whiteBoardListDidSelectView:fileView];
    }
}

#pragma mark - private method
- (ZegoWhiteBoardViewContainerModel *)getViewWithIndex:(NSInteger)index
{
    if (self.viewList.count > index) {
        ZegoWhiteBoardViewContainerModel *view = self.viewList[index];
        if ([view.selectedBoardContainer isKindOfClass:[ZegoBoardContainer class]]) {
            return view;
        }
    }
    return nil;
}

- (void)configUI
{
    self.backgroundColor = UIColor.whiteColor;
    UITableView *tableView = [[UITableView alloc] init];
    tableView.backgroundColor = UIColor.whiteColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 44;
    tableView.bounces = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0);
    tableView.separatorColor = kGrayLineColor;
    tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    if (@available(iOS 11.0, *)) {
        tableView.insetsContentViewsToSafeArea = NO;
        
    }
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [tableView registerNib:[UINib nibWithNibName:@"ZegoWhiteBoardListCell" bundle:nil] forCellReuseIdentifier:@"ZegoWhiteBoardListCell"];
    [self addSubview:tableView];
    self.tableView = tableView;
    self.tableView.frame = CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height - 44);
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
    header.backgroundColor = [UIColor whiteColor];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.bounds.size.width - 20, 44)];
    [header addSubview:headerLabel];
    headerLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    headerLabel.backgroundColor = [UIColor whiteColor];
    headerLabel.textColor = kTextColor1;
    headerLabel.text = @"白板及文件列表";
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 43, self.bounds.size.width, 0.5)];
    line.backgroundColor = kGrayLineColor;
    [header addSubview:line];
    [self addSubview:header];
}

@end
