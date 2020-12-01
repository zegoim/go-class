//
//  ZegoUserTableView.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/5/29.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoUserTableView.h"
#import "ZegoUserTableViewCell.h"
#import "ZegoUIConstant.h"
#import "UIColor+ZegoExtension.h"

@interface ZegoUserTableView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ZegoUserTableView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor whiteColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.bounces = NO;
    self.delegate = self;
    self.dataSource = self;
    if (@available(iOS 11.0, *)) {
        self.insetsContentViewsToSafeArea = NO;
    }
    [self registerNib:[UINib nibWithNibName:NSStringFromClass([ZegoUserTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ZegoUserTableViewCell class])];
}

- (void)setRoomMemberArray:(NSMutableArray<ZegoRoomMemberInfoModel *> *)roomMemberArray
{
    _roomMemberArray = roomMemberArray;
    [self reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.roomMemberArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *myHeader = [[UIView alloc] init];
    UILabel *myLabel = [[UILabel alloc] init];
    [myLabel setFrame:CGRectMake(12, 0, self.bounds.size.width, 60)];
    myLabel.textColor = kTextColor1;
    myLabel.font = kFontTitle15;
    [myLabel setBackgroundColor:[UIColor whiteColor]];
    [myLabel setText:[NSString stringWithFormat:@"已加入成员(%lu)",(unsigned long)self.roomMemberArray.count]];
    [myHeader addSubview:myLabel];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 59, self.bounds.size.width, kLineWidth)];
    line.backgroundColor = kGrayLineColor;
    [myHeader addSubview:line];
    return myHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZegoUserTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZegoUserTableViewCell class]) forIndexPath:indexPath];
    cell.didClickAuthorityStatusBlock = self.didClickAuthorityStatusBlock;
    ZegoRoomMemberInfoModel *user = self.roomMemberArray[indexPath.row];
    if (self.showUserStatusOperationButton) {
        cell.userInteractionEnabled = YES;
        [cell hiddenStatusMark:NO];
    } else {
        cell.userInteractionEnabled = NO;
        [cell hiddenStatusMark:YES];
    }
    cell.model = user;
    if (@available(iOS 11.0, *)) {
        cell.insetsLayoutMarginsFromSafeArea = NO;
    }
    return cell;
}

@end
