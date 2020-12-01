//
//  ZegoChatTableViewCell.h
//  ZegoEducation
//
//  Created by MrLQ  on 2018/10/29.
//  Copyright © 2018 Shenzhen Zego Technology Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZegoChatModel;
NS_ASSUME_NONNULL_BEGIN

@interface ZegoChatTableViewCell : UITableViewCell

@property (nonatomic, strong) ZegoChatModel *lastModel;//记录上一条消息用来判断是否显示名字
@property (nonatomic, strong) ZegoChatModel *chatModel;

+ (CGFloat)caculateCellHeight:(ZegoChatModel *)model lastModel:(ZegoChatModel *)lastModel;

@end

NS_ASSUME_NONNULL_END
