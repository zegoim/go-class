//
//  ZegoFileListView.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/1.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoFileListView.h"
#import "ZegoFileTableViewCell.h"
#import "UIColor+ZegoExtension.h"
#import "ZegoDocsViewDependency.h"
#import "ZegoUIConstant.h"
#import "NSString+ZegoExtension.h"
@interface ZegoFileListView ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UILabel *topLabel;
@property (strong, nonatomic) UILabel *bottomLabel;
@property (strong, nonatomic) NSArray<ZegoFileInfoModel *> *files;
@property (strong, nonatomic) ZegoFileInfoModel *selectedFileInfo;
@end

@implementation ZegoFileListView

- (void)updateWithFiles:(NSArray<ZegoFileInfoModel *> *)files {
    self.files = files;
    [self.tableView reloadData];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.topLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.bounds.size.width - 20, 49)];
    [self addSubview:self.topLabel];
    self.topLabel.text = [NSString zego_localizedString:@"room_file_select_file"];
    self.topLabel.textColor = kTextColor1;
    self.topLabel.font = kFontTitle15;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 48, self.bounds.size.width, 0.5)];
    line.backgroundColor = kGrayLineColor;
    [self addSubview:line];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 49, self.bounds.size.width, self.bounds.size.height - 98) style:UITableViewStylePlain];
    [self addSubview:self.tableView];
    if (@available(iOS 11.0, *)) {
        self.tableView.insetsContentViewsToSafeArea = NO;
    }
    self.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorColor = kGrayLineColor;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ZegoFileTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ZegoFileTableViewCell class])];
    self.tableView.bounces = NO;
    self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight - 49, self.bounds.size.width, 49)];
    [self addSubview:self.bottomLabel];
    self.bottomLabel.text = [NSString stringWithFormat:@"%@,%@",[NSString zego_localizedString:@"room_file_static_animation_displayed"],[NSString zego_localizedString:@"room_file_dynamic_animation_show"]];
    self.bottomLabel.backgroundColor = UIColor.whiteColor;
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    self.bottomLabel.textColor = kTextColor1;
    self.bottomLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightRegular];
    
    UIView *lineBottom = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 49, self.bounds.size.width, 0.5)];
    lineBottom.backgroundColor = kGrayLineColor;
    [self addSubview:lineBottom];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.files.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZegoFileTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZegoFileTableViewCell class])];
    ZegoFileInfoModel *fileInfo = self.files[indexPath.row];
    cell.nameLabel.text = fileInfo.fileName;
    if (fileInfo.fileType == ZegoDocsViewFileTypeDynamicPPTH5) {
        cell.typeLabel.text = [NSString zego_localizedString:@"room_file_dynamic"];
        cell.typeLabel.backgroundColor = [UIColor colorWithRGB:@"#ffae00"];
    } else {
        cell.typeLabel.text = [NSString zego_localizedString:@"room_file_static_file"];
        cell.typeLabel.backgroundColor = [UIColor colorWithRGB:@"#0045ff"];
    }
    cell.nameLabel.textColor = fileInfo == self.selectedFileInfo ? kThemeColorBlue : kTextColor1;
    cell.nameLabel.font = kFontText13;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate) {
        [self.delegate zegoFileListView:self didSelectFile:self.files[indexPath.row]];
    }
}

@end
