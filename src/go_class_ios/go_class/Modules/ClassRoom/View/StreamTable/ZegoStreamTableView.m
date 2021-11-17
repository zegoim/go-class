//
//  StreamTableView.m
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/5/28.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoStreamTableView.h"
#import "ZegoStreamTableViewCell.h"
#import "ZegoLiveCenter.h"
#import "UIColor+ZegoExtension.h"
#import "ZegoToast.h"
#import "ZegoUIConstant.h"

@interface ZegoStreamTableView ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray<ZegoStreamTableViewCell *> *tableCells;


@property (strong, nonatomic) NSMutableArray<ZegoStreamWrapper *> *streamWrappers;

@end

@implementation ZegoStreamTableView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame style:UITableViewStylePlain]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    if (@available(iOS 11.0, *)) {
        self.insetsContentViewsToSafeArea = NO;
    }
    self.backgroundColor = [UIColor colorWithRGB:@"#fbfcff"];
    self.delegate = self;
    self.showsVerticalScrollIndicator = NO;
    self.dataSource = self;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self registerClass:[ZegoStreamTableViewCell class] forCellReuseIdentifier:NSStringFromClass([ZegoStreamTableViewCell class])];
}

//添加占位的老师数据
- (void)inserTeacherPlaceholderModel {
    ZegoStreamWrapper *teacherPlayerHolder = [[ZegoStreamWrapper alloc] init];
    if (self.teacherModel) {
        teacherPlayerHolder.userStatusModel = [[ZegoRoomMemberInfoModel alloc] initWithUid:_teacherModel.uid userName:_teacherModel.userName role:ZegoUserRoleTypeTeacher];
    } else {
        teacherPlayerHolder.userStatusModel = [[ZegoRoomMemberInfoModel alloc] initWithUid:0 userName:@"" role:ZegoUserRoleTypeTeacher];
    }
    teacherPlayerHolder.streamStatusType = ZegoStreamStatusTypeIdle;
    [self.streamWrappers insertObject:teacherPlayerHolder atIndex:0];
}

- (void)setTeacherModel:(ZegoRoomMemberInfoModel *)teacherModel
{
    _teacherModel = teacherModel;
    if (self.streamWrappers.count > 0 && teacherModel) {
        ZegoStreamWrapper *teacher = self.streamWrappers.firstObject;
        teacher.userStatusModel = teacherModel;
        
    } else {
        [self.streamWrappers removeObjectAtIndex:0];
        [self inserTeacherPlaceholderModel];
    }
    [self reloadData];
}

//初始化数据源
- (void)setupStreamDataSources:(NSArray <ZegoStreamWrapper *> *)streamDataSource {
    NSLog(@"初始化连麦数据流");
    [ZegoLiveCenter stopPreview];
    [ZegoLiveCenter stopPublishingStream];
    for (ZegoStreamWrapper *wrapper in self.streamWrappers) {
        [ZegoLiveCenter stopPlayingStream:wrapper.stream.streamID];
    }
    self.streamWrappers = [NSMutableArray array];
    [self inserTeacherPlaceholderModel];
    for (ZegoStreamWrapper *wrapper in streamDataSource) {
        //如果数据时老师，则移除占位视图
        [self checkAddModel:wrapper];
     }
    [self reloadData];
 }

- (void)addStream:(ZegoStreamWrapper *)wrapper {
    NSLog(@"新增连麦成员流");
    [self checkAddModel:wrapper];
    [self reloadData];
}

- (void)checkAddModel:(ZegoStreamWrapper *)wrapper
{
    if (wrapper.userStatusModel.role == 1) {
        [self.streamWrappers removeObjectAtIndex:0];
        [self.streamWrappers insertObject:wrapper atIndex:0];
    } else {
        [self.streamWrappers addObject:wrapper];
    }
}

- (void)removeStream:(ZegoStreamWrapper *)wrapper {
    NSLog(@"移除连麦成员流");
    for (int i = 0; i < self.streamWrappers.count; i++) {
        ZegoStreamWrapper *localWrapper = self.streamWrappers[i];
        if (localWrapper.userStatusModel.uid == wrapper.userStatusModel.uid) {
            if (localWrapper.userStatusModel.isMyself) {
                [ZegoLiveCenter stopPreview];
                [ZegoLiveCenter stopPublishingStream];
            } else {
                [ZegoLiveCenter stopPlayingStream:wrapper.stream.streamID];
        
            }
            [self.streamWrappers removeObjectAtIndex:i];
            break;
        }
    }
    if (wrapper.userStatusModel.role == ZegoUserRoleTypeTeacher) {
        ZegoStreamWrapper *teacher = self.streamWrappers.firstObject;
        if (teacher.userStatusModel.role != ZegoUserRoleTypeTeacher) {
            [self inserTeacherPlaceholderModel];
        }
    }
    [self reloadData];
 }

// 执行推拉流后更新流状态
- (void)updateStream:(ZegoStreamWrapper *)streamWrapper {
    NSLog(@"流状态更新");
    for (int i = 0; i < self.streamWrappers.count; i++) {
        ZegoStreamWrapper *localWrapper = self.streamWrappers[i];
        if (localWrapper.userStatusModel.uid == streamWrapper.userStatusModel.uid) {
            
            [self.streamWrappers replaceObjectAtIndex:i withObject:streamWrapper];
            break;
        }
    }
    [self reloadData];

}

// 获取列表流信息
- (ZegoStreamWrapper *)getStreamWrapper:(NSString *)streamId {

    for (int i = 0; i < self.streamWrappers.count; i++) {
        ZegoStreamWrapper *wrapper = self.streamWrappers[i];
        if ([wrapper.stream.streamID isEqualToString:wrapper.stream.streamID]) {
            return wrapper;
        }
     }
    return nil;
 }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.streamWrappers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kStreamCellHeight;
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     ZegoStreamWrapper *wrapper = self.streamWrappers[indexPath.row];
    //根据Index 创建cell,不使用tableViewCell重用，每一个位置占用一个cell。

     ZegoStreamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZegoStreamTableViewCell class]) forIndexPath:indexPath];
     if (!cell) {
        cell = [[ZegoStreamTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([ZegoStreamTableViewCell class])];
     }
     cell.hiddenMarkView = self.teacherModel?NO:YES;
     [cell setupModel:wrapper complement:^(UIView * _Nonnull previewView) {
        
         if (wrapper.userStatusModel.isMyself) {
             //当数据流是自己且没有推流时，开始推流
             [ZegoLiveCenter muteAudio:wrapper.userStatusModel.mic == 1];
             [ZegoLiveCenter muteVideo:wrapper.userStatusModel.camera == 1];
             [ZegoLiveCenter stopPreview];
             [ZegoLiveCenter previewInView:previewView];
             if (wrapper.streamStatusType == ZegoStreamStatusTypeIdle && ( wrapper.userStatusModel.camera == 2 || wrapper.userStatusModel.mic == 2)) {
                 wrapper.streamStatusType = ZegoStreamStatusTypePublishing;
                 [ZegoLiveCenter publishStream:self.publishStreamId];
                 NSLog(@"开始推流，%@，userName= %@  view = %@",self.publishStreamId,wrapper.userStatusModel.userName,cell);
             }
             
         } else {
             if (wrapper.stream.streamID.length < 1) {
                 return;
             }
             if (wrapper.streamStatusType == ZegoStreamStatusTypeIdle) {
                 //当数据流不是自己且没有拉流时，开始拉流
                 wrapper.streamStatusType = ZegoStreamStatusTypePlaying;
                 [ZegoLiveCenter stopPlayingStream:wrapper.stream.streamID];
                 [ZegoLiveCenter playStream:wrapper.stream.streamID inView:previewView];
                 NSLog(@" 拉流 StreamID= %@，userName= %@  view = %@",wrapper.stream.streamID,wrapper.userStatusModel.userName,cell);
             } else {
                 //如果既不是自己 也不是空闲状态，数据流只是更换了显示位置，则只更新预览视图
                 [ZegoLiveCenter updateStream:wrapper.stream.streamID inView:previewView];
                 NSLog(@" 更新拉流 StreamID= %@，userName= %@  view = %@",wrapper.stream.streamID,wrapper.userStatusModel.userName,cell);
             }
         }
         
         wrapper.indexPath = indexPath;
     }];
    
     return cell;
 }

@end
