//
//  ZegoExcelSheetList.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/9.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoExcelSheetListView.h"
#import "UIColor+ZegoExtension.h"
#import "ZegoUIConstant.h"
#import "ZegoWhiteBoardListCell.h"

@interface ZegoExcelSheetListView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray<NSString *> *sheetList;
@property (nonatomic, copy) NSString *selectedSheet;

@end

@implementation ZegoExcelSheetListView

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
- (void)updateViewWithSheetNameList:(NSArray <NSString *>*)sheetList selectedSheet:(NSString *)selectedSheetName
{
    self.sheetList = sheetList;
    self.selectedSheet = selectedSheetName;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sheetList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZegoWhiteBoardListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZegoWhiteBoardListCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (@available(iOS 11.0, *)) {
        cell.insetsLayoutMarginsFromSafeArea = NO;
    }
    NSString *sheet = self.sheetList[indexPath.row];
    cell.nameLabel.text = sheet;
    cell.closeButton.hidden = YES;
    cell.nameLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    cell.nameLabel.textColor = [sheet isEqualToString:self.selectedSheet] ? kThemeColorBlue : kTextColor1;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(zegoExcelSheetList:didSelectSheet:index:)]) {
            [self.delegate zegoExcelSheetList:self didSelectSheet:self.sheetList[indexPath.row] index:(int)indexPath.row];
        }
    }
    self.selectedSheet = self.sheetList[indexPath.row];
}

- (void)configUI
{
    UITableView *tableView = [[UITableView alloc] init];
    [tableView registerNib:[UINib nibWithNibName:@"ZegoWhiteBoardListCell" bundle:nil] forCellReuseIdentifier:@"ZegoWhiteBoardListCell"];
    tableView.layer.borderColor = UIColorHex(#343434).CGColor;
    tableView.backgroundColor = UIColor.whiteColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 44;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = kGrayLineColor;
    tableView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        tableView.insetsContentViewsToSafeArea = NO;
    }
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
    header.backgroundColor = [UIColor whiteColor];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.bounds.size.width - 20, 44)];
    [header addSubview:headerLabel];
    headerLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    headerLabel.backgroundColor = [UIColor whiteColor];
    headerLabel.textColor = kTextColor1;
    headerLabel.text = @"sheet列表";
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 43, self.bounds.size.width, 0.5)];
       line.backgroundColor = kGrayLineColor;
       [header addSubview:line];
    
    tableView.tableHeaderView = header;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [tableView registerClass:[UITableViewCell class]
               forCellReuseIdentifier:@"UITableViewCellIdentify"];
    [self addSubview:tableView];
    self.tableView = tableView;
    self.tableView.frame = self.bounds;
}

@end
