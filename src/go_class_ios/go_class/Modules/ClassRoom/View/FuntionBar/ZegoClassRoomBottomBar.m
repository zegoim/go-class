//
//  ZegoClassRoomBottomBar.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/2.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoClassRoomBottomBar.h"
#import "ZegoViewAnimator.h"
#import "ZegoClassRoomCameraPopView.h"
#import "ZegoClassRoomSharePopView.h"
#import "ZegoUIConstant.h"
#import "ZegoToast.h"
#import "NSString+ZegoExtension.h"
#define cellWidth 56
@interface ZegoBottomBarLayout:UICollectionViewLayout

@end

@implementation ZegoBottomBarLayout


@end

@interface ZegoClassRoomBottomBar ()<UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *cellModels;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewWidthCons;

@end


@implementation ZegoClassRoomBottomBar
- (void)tapBody:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomBarDidTapBarArea)]) {
        [self.delegate bottomBarDidTapBarArea];
    }
}

- (BOOL)isMicOpen {
    for (ZegoClassRoomBottomCellModel *model in self.cellModels) {
        if (model.type == ZegoClassRoomBottomCellTypeMic) {
            return model.isSelected;
        }
    }
    return NO;
}

- (BOOL)isCamareOpen {
    for (ZegoClassRoomBottomCellModel *model in self.cellModels) {
        if (model.type == ZegoClassRoomBottomCellTypeCamera) {
            return model.isSelected;
        }
    }
    return NO;
}

- (void)setupCameraOpen:(BOOL)open react:(BOOL)react{
    if (open == [self isCamareOpen]) {
        return;
    }
    for (int i = 0; i < self.cellModels.count; i++) {
        ZegoClassRoomBottomCellModel *model = self.cellModels[i];
        if (model.type == ZegoClassRoomBottomCellTypeCamera) {
            if (react) {
                [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            } else {
                model.isSelected = open;
                [self.collectionView reloadData];
            }
            break;
        }
    }

}

- (void)setupMicOpen:(BOOL)open react:(BOOL)react{
    if (open == [self isMicOpen]) {
        return;
    }
    for (int i = 0; i < self.cellModels.count; i++) {
        ZegoClassRoomBottomCellModel *model = self.cellModels[i];
        if (model.type == ZegoClassRoomBottomCellTypeMic) {
            if (react) {
                [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            } else {
                model.isSelected = open;
                [self.collectionView reloadData];
            }
            break;
        }
    }
    
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [[NSBundle mainBundle] loadNibNamed:@"ZegoClassRoomBottomBar" owner:self options:nil];
        [self addSubview:self.view];
        self.view.frame = self.bounds;
        [self setup];
    }
    return self;
}

- (void)hiddenItems:(NSArray *)items
{
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.cellModels];
    for (int j = 0; j < temp.count; j++) {
        ZegoClassRoomBottomCellModel *model = temp[j];
        for (int i = 0; i < items.count; i++) {
            ZegoClassRoomBottomCellType type = (ZegoClassRoomBottomCellType)[items[i] integerValue];
            if (type == model.type) {
                j--;
                [temp removeObject:model];
                continue;;
            }
        }
    }
    self.cellModels = temp.copy;
    self.collectionViewWidthCons.constant = self.cellModels.count * cellWidth;
    [self.collectionView reloadData];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
}

- (void)setup {
    self.cellModels = @[
        [[ZegoClassRoomBottomCellModel alloc] initWithType:ZegoClassRoomBottomCellTypeCamera isSelected:NO imageName:@"camera_close" selectedImageName:@"camera_open" title:[NSString zego_localizedString:@"room_controller_camera"]],
        [[ZegoClassRoomBottomCellModel alloc] initWithType:ZegoClassRoomBottomCellTypeMic isSelected:NO imageName:@"micphone_close" selectedImageName:@"micphone_open" title:[NSString zego_localizedString:@"room_controller_mic"]],
        [[ZegoClassRoomBottomCellModel alloc] initWithType:ZegoClassRoomBottomCellTypeShare isSelected:NO imageName:@"gongxiang" selectedImageName:@"gongxiang" title:[NSString zego_localizedString:@"room_controller_share"]],
        [[ZegoClassRoomBottomCellModel alloc] initWithType:ZegoClassRoomBottomCellTypeInvite isSelected:NO imageName:@"yaoqing" selectedImageName:@"yaoqing" title:[NSString zego_localizedString:@"room_controller_invitation"]],
        [[ZegoClassRoomBottomCellModel alloc] initWithType:ZegoClassRoomBottomCellTypeMember isSelected:NO imageName:@"chengyuan" selectedImageName:@"chengyuan" title:[NSString zego_localizedString:@"room_controller_member"]]
    ];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    self.collectionView = [[UICollectionView alloc] init];
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"ZegoClassRoomBottomBarCell" bundle:nil] forCellWithReuseIdentifier:@"ZegoClassRoomBottomBarCell"];
    self.collectionView.backgroundColor = [UIColor whiteColor];

//    [self addSubview:self.collectionView];
    
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBody:)];
    ges.delegate = self;
    [self addGestureRecognizer:ges];
}

- (void)refreshUserCount:(NSUInteger)count {
    for (ZegoClassRoomBottomCellModel *model in self.cellModels) {
        if (model.type == ZegoClassRoomBottomCellTypeMember) {
            if (count < 0) {
                model.numberString = nil;
            } else {
                model.numberString = @(count).stringValue;
            }
            [self reloadData];
            break;
        }
    }
}

- (void)reloadData {
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZegoClassRoomBottomBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZegoClassRoomBottomBarCell" forIndexPath:indexPath];
    ZegoClassRoomBottomCellModel *model = self.cellModels[indexPath.item];
    [cell refreshWithModel: model];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(cellWidth, 40);
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ZegoClassRoomBottomCellModel *model = self.cellModels[indexPath.item];
    if (model.type == ZegoClassRoomBottomCellTypeCamera) {
        if (model.isSelected) {
            __weak typeof(self) weakSelf = self;
            ZegoClassRoomCameraPopView *pop = [[ZegoClassRoomCameraPopView alloc] initWithFrame:CGRectMake(0, 0, 192, 107)];
            pop.onTapAction = ^void(NSUInteger type) {
                if (type == 0) {
                    model.type = ZegoClassRoomBottomCellTypeCameraSwitch;
                }
                if (weakSelf.delegate) {
                    [weakSelf.delegate bottomBarCell:(ZegoClassRoomBottomBarCell *)[collectionView cellForItemAtIndexPath:indexPath] didSelectCellModel:model];
                }
                model.type = ZegoClassRoomBottomCellTypeCamera;
                [ZegoViewAnimator fadeView:nil completion:nil];
            };
            [ZegoViewAnimator popUpView:pop onTopOfView:[collectionView cellForItemAtIndexPath:indexPath]  backColorAlpha:0];
        } else {
            if (self.delegate) {
                [self.delegate bottomBarCell:(ZegoClassRoomBottomBarCell *)[collectionView cellForItemAtIndexPath:indexPath] didSelectCellModel:model];
            }
        }
    } else if (model.type == ZegoClassRoomBottomCellTypeShare) {
        if (self.currentModel.canShare == 2) {
            __weak typeof(self) weakSelf = self;
            ZegoClassRoomSharePopView *pop = [[ZegoClassRoomSharePopView alloc] initWithFrame:CGRectMake(0, 0, 184, 107)];
            pop.onTapAction = ^void(NSUInteger type) {
                if (type == 0) {
                    model.type = ZegoClassRoomBottomCellTypeShareBoard;
                } else {
                    model.type = ZegoClassRoomBottomCellTypeShareFile;
                }
                if (weakSelf.delegate) {
                    [weakSelf.delegate bottomBarCell:(ZegoClassRoomBottomBarCell *)[collectionView cellForItemAtIndexPath:indexPath] didSelectCellModel:model];
                }
                model.type = ZegoClassRoomBottomCellTypeShare;
                [ZegoViewAnimator fadeView:nil completion:nil];
            };
            [ZegoViewAnimator popUpView:pop onTopOfView:[collectionView cellForItemAtIndexPath:indexPath] backColorAlpha:0];
        } else {
            [ZegoToast showText:@"老师还未允许你使用共享功能"];
        }
    } else {
        if (self.delegate) {
            [self.delegate bottomBarCell:(ZegoClassRoomBottomBarCell *)[collectionView cellForItemAtIndexPath:indexPath] didSelectCellModel:model];
        }
    }
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view.superview.superview class]) hasPrefix:@"UICollectionView"] || [NSStringFromClass([touch.view.superview.superview class]) hasPrefix:@"UICollectionView"]) {//如果当前是tableView
        //做自己想做的事
        return NO;
    }
    return YES;
}
@end
