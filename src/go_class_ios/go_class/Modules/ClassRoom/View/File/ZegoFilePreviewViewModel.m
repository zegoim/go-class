//
//  ZegoFilePreviewViewModel.m
//  ZegoWhiteboardVideoDemo
//
//  Created by MartinNie on 2020/8/21.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoFilePreviewViewModel.h"
#import "ZegoFilePreviewView.h"

@implementation ZegoFilePreviewViewModel

- (instancetype)init {
    if (self = [super init]) {
        [self reset];
    }
    return self;
}

- (void)setupPreviewViewFrame:(CGRect)frame onSuperView:(nonnull UIView *)superView withData:(NSArray *)dataArray {
    if (!self.previewView && superView ) {
        _previewView = [[ZegoFilePreviewView alloc] initWithFrame:frame];
    }
    [superView addSubview:self.previewView];
    [self.previewView reset];
    _previewView.selectedPageBlock = _selectedPageBlock;
    [self.previewView setDataArray:dataArray];
    
}

- (void)setSelectedPageBlock:(void (^)(NSInteger))selectedPageBlock {
    _selectedPageBlock = selectedPageBlock;
    self.previewView.selectedPageBlock = selectedPageBlock;
}

- (void)reset {
    [_previewView removeFromSuperview];
    _previewView = nil;
    _isShow = NO;
    _currentPage = 0;
}

- (void)setCurrentPageCount:(NSInteger)pageCount {
    if (pageCount < 0) {
        return;
    }
    _currentPage = pageCount;
    [self.previewView setPreviewPageCount:pageCount];
}

- (void)showPreviewWithPage:(NSInteger)pageCount {
    if (!_isShow) {
        _isShow = YES;
        [self setCurrentPageCount:pageCount];
        [UIView animateWithDuration:0.5 animations:^{
            CGRect currentFrame = self.previewView.frame;
            self.previewView.frame = CGRectOffset(currentFrame, -currentFrame.size.width, 0);
        } completion:nil];
    }
}

- (void)hiddenPreview {
    if (_isShow) {
        _isShow = NO;
        [UIView animateWithDuration:0.5 animations:^{
            CGRect currentFrame = self.previewView.frame;
            self.previewView.frame = CGRectOffset(currentFrame, currentFrame.size.width, 0);
        } completion:nil];
    }
}
@end
