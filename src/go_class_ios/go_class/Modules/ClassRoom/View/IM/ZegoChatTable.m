//
//  ZegoChatTable.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/11/4.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoChatTable.h"
#import "ZegoChatTableViewCell.h"
#import "ZegoChatModel.h"
#import "UIColor+ZegoExtension.h"
#import <Masonry/Masonry.h>
#import "NSString+ZegoExtension.h"
@interface ZegoChatTable ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)UIView *bottomView;
@property (nonatomic,strong)UITextView *textView;
@property (nonatomic,strong)NSArray *msgArray;

@end

@implementation ZegoChatTable

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)configUI {
    
    self.backgroundColor = UIColorHex(#fbfcff);
    [self addSubview:self.tableView];
    [self addSubview:self.bottomView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(self.mas_bottom).offset(-50);
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self);
        make.height.mas_equalTo(50);
    }];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView.mas_left).offset(10);
        make.right.equalTo(self.bottomView.mas_right).offset(-10);
        make.top.equalTo(self.bottomView.mas_top).offset(10);
        make.height.mas_equalTo(30);
    }];
}


#pragma mark - Action
- (void)tapClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatTableClickTextView)]) {
        [self.delegate chatTableClickTextView];
    }
}


#pragma mark - Public
- (void)reloadData:(NSArray *)dataArray {
    _msgArray = dataArray;
    [self.tableView reloadData];
}

- (void)onScrollToBottom
{
    double delayInSeconds = 0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    __weak typeof(self) weakSelf = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (weakSelf.msgArray.count > 0) {
            NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:weakSelf.msgArray.count-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    });
}


#pragma mark -UITableViewDelegate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _msgArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZegoChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZegoChatTableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ZegoChatModel *model = _msgArray[indexPath.row];
    ZegoChatModel *lastModel = indexPath.row > 0 ? _msgArray[indexPath.row - 1] : nil;
    cell.lastModel = lastModel;
    cell.chatModel = model;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = UIColorHex(#fbfcff);
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 25)];
    titleLabel.text = [NSString zego_localizedString:@"room_im_discuss"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont systemFontOfSize:10]];
    [headView addSubview:titleLabel];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 24, self.frame.size.width, 1)];
    [line setBackgroundColor:UIColorHex(#edeff3)];
    [headView addSubview:line];
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >_msgArray.count) {
        return 0.01;
    }
    ZegoChatModel *model = _msgArray[indexPath.row];
    ZegoChatModel *lastModel = indexPath.row > 0 ? _msgArray[indexPath.row - 1] : nil;
    return [ZegoChatTableViewCell caculateCellHeight:model lastModel:lastModel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.f;
}

#pragma mark -Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.bounces = NO;
        _tableView.backgroundColor = UIColorHex(#fbfcff);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[ZegoChatTableViewCell class] forCellReuseIdentifier:@"ZegoChatTableViewCell"];
    }
    return _tableView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectZero];
        _textView = [[UITextView alloc]initWithFrame:CGRectZero];
        _textView.text = [NSString zego_localizedString:@"room_im_say_something"];
        _textView.textContainerInset = UIEdgeInsetsMake(9.5, 5, 0, 0);
        _textView.textColor = UIColorHex(#585c62);
        _textView.font = [UIFont systemFontOfSize:10];
        _textView.userInteractionEnabled = NO;
        _textView.layer.masksToBounds = YES;
        _textView.layer.cornerRadius = 15.f;
        _textView.layer.borderWidth = 1;
        _textView.layer.borderColor = [UIColorHex(#edeff3) CGColor];
        [_bottomView addSubview:_textView];
        UITapGestureRecognizer *tapClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
        [_bottomView addGestureRecognizer:tapClick];
    }
    return _bottomView;
}

@end
