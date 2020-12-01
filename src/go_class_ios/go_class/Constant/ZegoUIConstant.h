//
//  ZegoUIConstant.h
//  ZegoWhiteboardVideoDemo
//
//  Created by zego on 2020/6/2.
//  Copyright © 2020 zego. All rights reserved.
//

#ifndef ZegoUIConstant_h
#define ZegoUIConstant_h

#import <UIKit/UIKit.h>

#define kZegoFont [UIFont fontWithName:@"Source Han Sans CN" size:14]

#define kScreenHeight MIN([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)
#define kScreenWidth MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)

#define kDrawingToolViewHeight (kScreenHeight - 44 - 49)
#define kDrawingToolViewWidth 32
#define kDrawingToolViewFormatViewWidth 227
#define kDrawingToolViewFormatViewHeight 273
#define kDrawingToolViewInsetTopMargin 4


#define kStreamCellHeight (kScreenHeight/4)
#define kStreamCellWidth kStreamCellHeight*331/186
#define kBoardViewWidth kScreenWidth-kStreamCellWidth
#define kSideListWidth 250

#define kGrayLineColor [UIColor colorWithRGB:@"#edeff3"]
#define kTextColor1 [UIColor colorWithRGB:@"#18191a"]
#define kThemeColorBlue [UIColor colorWithRGB:@"#0044ff"]
#define kFontTitle15 [UIFont systemFontOfSize:15 weight:UIFontWeightRegular]
#define kFontText14 [UIFont systemFontOfSize:14 weight:UIFontWeightRegular]
#define kFontText13 [UIFont systemFontOfSize:13 weight:UIFontWeightRegular]
#define kFontText12 [UIFont systemFontOfSize:12 weight:UIFontWeightRegular]

#define kLineWidth 0.5
#define kIconWidth22 22
#define kIconWidth32 22


#endif /* ZegoUIConstant_h */
