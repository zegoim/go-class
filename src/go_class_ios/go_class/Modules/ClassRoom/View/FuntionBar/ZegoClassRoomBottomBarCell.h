//
//  ZegoClassRoomBottomBarCell.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/2.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZegoClassRoomBottomCellType) {
    ZegoClassRoomBottomCellTypeCamera = 1,
    ZegoClassRoomBottomCellTypeMic,
    ZegoClassRoomBottomCellTypeShare,
    ZegoClassRoomBottomCellTypeInvite,
    ZegoClassRoomBottomCellTypeMember,
    ZegoClassRoomBottomCellTypeCameraSwitch,
    ZegoClassRoomBottomCellTypeShareBoard,
    ZegoClassRoomBottomCellTypeShareFile,
};

@interface ZegoClassRoomBottomCellModel: NSObject

@property (assign, nonatomic) ZegoClassRoomBottomCellType type;
@property (assign, nonatomic) BOOL isSelected;
@property (copy, nonatomic) NSString *imageName;
@property (copy, nonatomic) NSString *selectedImageName;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString * _Nullable numberString;

- (instancetype)initWithType:(ZegoClassRoomBottomCellType)type isSelected:(BOOL)isSelected imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName title:(NSString *)title;
@end

@interface ZegoClassRoomBottomBarCell : UICollectionViewCell
- (void)refreshWithModel:(ZegoClassRoomBottomCellModel *)model;
@end

NS_ASSUME_NONNULL_END
