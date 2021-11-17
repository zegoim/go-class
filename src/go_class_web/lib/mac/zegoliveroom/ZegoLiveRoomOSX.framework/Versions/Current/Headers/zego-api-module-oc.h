//
//  zego-module-oc.h
//
//  Copyright © Shenzhen Zego Technology Company Limited
//

#import <Foundation/Foundation.h>

#import "zego-api-module-model-oc.h"


#pragma mark - module callback block

/**
 拉取模块列表的结果回调
 
 @param seq getList: 返回的调用序号
 @param errorCode 拉取模块列表相关错误码，0 成功，非0 失败
 @param modules 拉取到的模块列表
 */
typedef void(^ZegoModuleGetListBlock)(unsigned int seq, int errorCode, const NSArray<ZegoModuleModelOC*> *modules);

/**
 创建模块的结果回调
 
 @param seq create: 返回的调用序号
 @param errorCode 创建模块相关错误码，0 成功，非0 失败
 @param module 创建的模块模型，如创建失败该值为空
 */
typedef void(^ZegoModuleCreateBlock)(unsigned int seq, int errorCode, const ZegoModuleModelOC* module);

/**
 销毁模块的结果回调
 
 @param seq destroy: 返回的调用序号
 @param errorCode 销毁模块相关错误码，0 成功，非0 失败
 @param moduleId 被销毁的模块 ID
 */
typedef void(^ZegoModuleDestroyBlock)(unsigned int seq, int errorCode, unsigned long long moduleId);

/**
 设置模块标题的结果回调
 
 @param seq setTitle: 返回的调用序号
 @param errorCode 错误码，0 成功，非0 失败
 @param moduleId 待修改的模块 ID
 @param title 标题，如失败该值为修改前的值
 */
typedef void(^ZegoModuleSetTitleBlock)(unsigned int seq, int errorCode, unsigned long long moduleId, NSString* title);

/**
 设置模块内容的结果回调
 
 @param seq setContent: 返回的调用序号
 @param errorCode 错误码，0 成功，非0 失败
 @param moduleId 待修改的模块 ID
 @param content 内容，如失败该值为修改前的值
 */
typedef void(^ZegoModuleSetContentBlock)(unsigned int seq, int errorCode, unsigned long long moduleId, NSString* content);

/**
 设置模块预留字段值的结果回调
 
 @param seq setReserve: 返回的调用序号
 @param errorCode 错误码，0 成功，非0 失败
 @param moduleId 待修改的模块id
 @param reserved 预留字段值，如失败该值为修改前的值
 */
typedef void(^ZegoModuleSetReserveBlock)(unsigned int seq, int errorCode, unsigned long long moduleId, unsigned int reserved);

/**
 设置模块扩展信息的结果回调
 
 @param seq setExtraInfo: 返回的调用序号
 @param errorCode 错误码，0 成功，非0 失败
 @param moduleId 待修改的模块 ID
 @param extraInfo 扩展信息，如失败该值为修改前的值
 */
typedef void(^ZegoModuleSetExtraInfoBlock)(unsigned int seq, int errorCode, unsigned long long moduleId, NSString* extraInfo);

/**
 改变模块尺寸的结果回调
 
 @param seq resize: 返回的调用序号
 @param errorCode 错误码，0 成功，非0 失败
 @param moduleId 待修改尺寸的模块 ID
 @param size 宽高，如失败该值为修改前的值
 */
typedef void(^ZegoModuleResizeBlock)(unsigned int seq, int errorCode, unsigned long long moduleId, CGSize size);

/**
 改变模块位置的结果回调
 
 @param seq move: 返回的调用序号
 @param errorCode 错误码，0 成功，非0 失败
 @param moduleId 待移动的模块id
 @param position 要移动到的左上角坐标，如失败该值为修改前的值
 */
typedef void(^ZegoModuleMoveBlock)(unsigned int seq, int errorCode, unsigned long long moduleId, CGPoint position);

/**
 改变模块zOrder的结果回调
 
 @param seq setZOrder返回的调用序号
 @param errorCode 错误码，0 成功，非0 失败
 @param moduleId 待改变zOrder的模块 ID
 @param zOrder zOrder值，如失败该值为修改前的值
 */
typedef void(^ZegoModuleSetZOrderBlock)(unsigned int seq, int errorCode, unsigned long long moduleId, unsigned int zOrder);

/**
 改变模块enable属性的结果回调
 
 @param seq setEnable 返回的调用序号
 @param errorCode 错误码，0 成功，非0 失败
 @param moduleId 待改变enable的模块 ID
 @param enable 是否可用，如失败该值为修改前的值
 */
typedef void(^ZegoModuleSetEnableBlock)(unsigned int seq, int errorCode, unsigned long long moduleId, BOOL enable);

/**
 改变模块visible属性的结果回调
 
 @param seq setVisible 返回的调用序号
 @param errorCode 错误码，0 成功，非0 失败
 @param moduleId 待改变visible的模块 ID
 @param visible 是否可用，如失败该值为修改前的值
 */
typedef void(^ZegoModuleSetVisibleBlock)(unsigned int seq, int errorCode, unsigned long long moduleId, BOOL visible);

/**
 改变模块windowState属性的结果回调
 
 @param seq setWindowState 返回的调用序号
 @param errorCode 错误码，0 成功，非0 失败
 @param moduleId 待改变windowState的模块 ID
 @param windowState windowState的值，如失败该值为修改前的值
 */
typedef void(^ZegoModuleSetWindowStateBlock)(unsigned int seq, int errorCode, unsigned long long moduleId, int windowState);

#pragma mark - module notify delegate

@protocol ZegoModuleDelegate <NSObject>

@optional

/**
 有模块新增的通知
 
 @param module 新增的模块模型
 */
- (void)onAdded:(const ZegoModuleModelOC*)module;

/**
 有模块被销毁的通知
 
 @param moduleId 被销毁的模块 ID
 */
- (void)onRemoved:(unsigned long long)moduleId;

/**
 模块标题发生变化的通知
 
 @param title 标题
 @param moduleId 标题发生变化的模块 ID
 */
- (void)onTitleChanged:(NSString *)title ofModule:(unsigned long long)moduleId;

/**
 模块内容发生变化的通知
 
 @param content 内容
 @param moduleId 内容发生变化的模块 ID
 */
- (void)onContentChanged:(NSString *)content ofModule:(unsigned long long)moduleId;

/**
 模块预留字段值发生变化的通知
 
 @param reserved 预留字段值
 @param moduleId 内容发生变化的模块 ID
 */
- (void)onReserveChanged:(unsigned int)reserved ofModule:(unsigned long long)moduleId;

/**
 模块扩展信息发生变化的通知
 
 @param extraInfo 扩展信息
 @param moduleId 扩展信息发生变化的模块 ID
 */
- (void)onExtraInfoChanged:(NSString *)extraInfo ofModule:(unsigned long long)moduleId;

/**
 模块尺寸发生变化的通知
 
 @param size 宽高
 @param moduleId 尺寸发生变化的模块 ID
 */
- (void)onSizeChanged:(CGSize)size ofModule:(unsigned long long)moduleId;

/**
 模块位置发生变化的通知
 
 @param pos 移动到的左上角坐标
 @param moduleId 位置发生变化的模块 ID
 */
- (void)onPositionChanged:(CGPoint)pos ofModule:(unsigned long long)moduleId;

/**
 模块zOrder发生变化的通知
 
 @param zorder 新的zOrder
 @param moduleId zOrder发生变化的模块 ID
 */
- (void)onZOrderChanged:(unsigned int)zOrder ofModule:(unsigned long long)moduleId;

/**
 模块enable属性发生变化的通知
 
 @param enable enable属性值
 @param moduleId enable属性发生变化的模块 ID
 */
- (void)onEnableChanged:(BOOL)enable ofModule:(unsigned long long)moduleId;

/**
 模块visible属性发生变化的通知
 
 @param visible visible属性值
 @param moduleId visible属性发生变化的模块 ID
 */
- (void)onVisibleChanged:(BOOL)visible ofModule:(unsigned long long)moduleId;

/**
 模块windowState属性发生变化的通知
 
 @param windowState 属性值
 @param moduleId windowState属性发生变化的模块 ID
 */
- (void)onWindowStateChanged:(int)windowState ofModule:(unsigned long long)moduleId;

@end


#pragma mark - module interface

@interface ZegoModule : NSObject

+ (id)sharedInstance;

/** 设置模块变化通知代理 */
- (void)setDelegate:(id<ZegoModuleDelegate>)delegate;

/**
 指定模块模型，创建互动模块
 
 @param module 模块模型
 @param isPublic 是否公开创建。YES，所有人可见；NO，仅模型操作者可见
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)create: (ZegoModuleModelOC *)module public: (BOOL)isPublic withCompletionBlock: (ZegoModuleCreateBlock)block;

/**
 销毁指定互动模块
 
 @param moduleId 模块 ID
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)destroy: (unsigned long long)moduleId withCompletionBlock: (ZegoModuleDestroyBlock)block;

/**
 拉取指定类型的互动模块列表
 
 @param moduleType 模块类型
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)getList: (unsigned int)moduleType withCompletionBlock: (ZegoModuleGetListBlock)block;

/**
 设置指定模块的标题
 
 @param title 标题
 @param moduleId 模块 ID
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)setTitle: (NSString *)title forModule: (unsigned long long)moduleId withCompletionBlock: (ZegoModuleSetTitleBlock)block;

/**
 设置指定模块的内容
 
 @param content 内容
 @param moduleId 模块 ID
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)setContent: (NSString *)content forModule: (unsigned long long)moduleId withCompletionBlock: (ZegoModuleSetContentBlock)block;

/**
 设置指定模块的预留信息
 
 @param reserved 预留字段值
 @param moduleId 模块 ID
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)setReserve: (unsigned int)reserved forModule: (unsigned long long)moduleId withCompletionBlock: (ZegoModuleSetReserveBlock)block;

/**
 设置指定模块的扩展信息
 
 @param extraInfo 扩展信息
 @param moduleId 模块 ID
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)setExtraInfo: (NSString *)extraInfo forModule: (unsigned long long)moduleId withCompletionBlock: (ZegoModuleSetExtraInfoBlock)block;

/**
 设置指定模块的尺寸
 
 @param size 模块长宽
 @param moduleId 模块 ID
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)resize: (CGSize)size module: (unsigned long long)moduleId withCompletionBlock: (ZegoModuleResizeBlock)block;

/**
 移动指定模块
 
 @param position 左上角坐标
 @param moduleId 模块 ID
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)move: (CGPoint)position module: (unsigned long long)moduleId withCompletionBlock: (ZegoModuleMoveBlock)block;

/**
 设置指定模块zOrder
 
 @param zorder zOrder值
 @param moduleId 模块 ID
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)setZOrder: (unsigned int)zOrder module: (unsigned long long)moduleId withCompletionBlock: (ZegoModuleSetZOrderBlock)block;

/**
 设置指定模块enable属性
 
 @param moduleId 模块 ID
 @param enable enable属性值
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)setEnable: (BOOL)enable module: (unsigned long long)moduleId withCompletionBlock: (ZegoModuleSetEnableBlock)block;

/**
 设置指定模块visible属性
 
 @param visible visible属性值
 @param moduleId 模块 ID
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)setVisible: (BOOL)visible module: (unsigned long long)moduleId withCompletionBlock: (ZegoModuleSetVisibleBlock)block;

/**
 设置指定模块windowState属性
 
 @param windowState属性值
 @param moduleId 模块 ID
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)setWindowState: (int)windowState module: (unsigned long long)moduleId withCompletionBlock: (ZegoModuleSetWindowStateBlock)block;

@end
