//
//  zego-module-model-oc.h
//
//  Copyright © Shenzhen Zego Technology Company Limited
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

//#import "../zego-api-module-constant.h"


@interface ZegoModuleModelOC: NSObject

/** 模块唯一标识符，创建成功后有效 */
@property (nonatomic, assign) unsigned long long moduleId;

/** 模块类型 */
@property (nonatomic, assign, readonly) unsigned int type;

/** 模块子类型 */
@property (nonatomic, assign, readonly) unsigned int subType;

/** 创建 module 时指定 enum ZegoModuleDeleteFlag 值，可控制 module 的生命周期 */
@property (nonatomic, assign, readonly) int deleteFlag;

/** 模块创建时间，创建成功后有效 */
@property (nonatomic, assign) unsigned long long createTime;

/** 模块标题，最多128字节 */
@property (nonatomic, copy, readonly) NSString *title;

/** 模块内容 */
@property (nonatomic, copy, readonly) NSString *content;

/** 模块预留信息，最多1024字节 */
@property (nonatomic, assign) unsigned int reserved;

/** 模块扩展内容，最多1024字节 */
@property (nonatomic, copy, readonly) NSString *extraInfo;

/** 模块尺寸 */
@property (nonatomic, assign) CGSize size;

/** 模块位置，即左上角坐标 */
@property (nonatomic, assign) CGPoint position;

/** 模块对应的UI窗口（如果有的话）状态，见 enum ZegoModuleWindowState */
@property (nonatomic, assign) int windowState;

/** zOrder */
@property (nonatomic, assign) int zOrder;

/** 模块enable属性 */
@property (nonatomic, assign) BOOL isEnabled;

/** 模块visible属性 */
@property (nonatomic, assign) BOOL isVisible;

/**
 初始化
 
 @param type 模块类型，值须大于kZegoModuleCustomTypeBegin
 @param subType 模块子类型，自定义非0值
 */
- (id)initWithModuleType:(unsigned int)type andSubType:(unsigned int)subType;

/**
 初始化，同时指定 deletFlag 和 uniqueFlag 用于 create
 
 @param type 模块类型，值须大于kZegoModuleCustomTypeBegin
 @param subType 模块子类型，自定义非0值
 @param deleteFlag 控制 module 的生命周期，见 enum ZegoModuleDeleteFlag
 */
- (id)initWithModuleType:(unsigned int)type andSubType:(unsigned int)subType deleteFlag:(int)deleteFlag;

- (int)setTitle: (NSString *)title;

- (int)setContent: (NSString *)content;

- (int)setExtraInfo: (NSString *)extraInfo;

@end
