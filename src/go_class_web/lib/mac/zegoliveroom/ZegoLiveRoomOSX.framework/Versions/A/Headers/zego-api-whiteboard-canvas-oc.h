//
//  zego-whiteboard-canvas-oc.h
//
//  Copyright © Shenzhen Zego Technology Company Limited
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif
//#import "../zego-api-whiteboard-constant.h"

#pragma mark - whitebaord canvas notify delegate

@protocol ZegoWhiteboardCanvasDelegate <NSObject>

@optional

/**
 拉取白板图元操作记录的结果回调
 
 @param whiteboardId 白板 ID
 @param errorCode 错误码
 */
- (void)onLoaded:(unsigned long long)whiteboardId error:(int)errorCode;

/**
 白板画布中的所有图元被清除
 
 @param whiteboardId 图元被清除的白板 ID
 @param operatorId 清除画布的用户 ID
 @param operatorName 清除画布的用户昵称
 */
- (void)onCleared:(unsigned long long)whiteboardId
       byOperator:(NSString *)operatorId
             name:(NSString *)operatorName;

/**
 白板画布中单个涂鸦图元更新通知
 
 @param whiteboardId 白板 ID
 @param json    图元数据
 {
     "operatorId": "99975923",                // 图元创建者ID
     "graphicId": 3019181292,                // 图元ID
     "operatorName": “xiaoqiang”,          // 图元创建者名字
     "size": 4,             // 图元大小
     "pos": (x, y),       // 图元位置NSValue
     "color": 4294263590,                       // 图元颜色
     "zOrder": 1918378406,                    // z轴偏移
     "points": []         // 图元点集合NSValue
 }
 
 */
- (void)onPathUpdatedWithJson:(NSDictionary *)json
                 whiteboardId:(unsigned long long)whiteboardId;
/**
 白板画布中单个文本更新通知
 
 @param whiteboardId 白板 ID
 @param json    图元数据
 {
     "operatorId": "99975923",                // 图元创建者ID
     "graphicId": 3019181292,                // 图元ID
     "operatorName": “xiaoqiang”,          // 图元创建者名字
     "size": 4,             // 图元大小
     "pos": (x, y),       // 图元位置NSValue
     "color": 4294263590,                       // 图元颜色
     "zOrder": 1918378406,                    // z轴偏移
     "text":"文本"，   //图元文案
     "points": []         // 图元点集合NSValue
 }
 */
- (void)onTextUpdatedWithJson:(NSDictionary *)json
                 whiteboardId:(unsigned long long)whiteboardId;

/**
 白板画布中单个线条更新通知
 
 @param whiteboardId 白板 ID
 @param json    图元数据
 {
     "operatorId": "99975923",                // 图元创建者ID
     "graphicId": 3019181292,                // 图元ID
     "operatorName": “xiaoqiang”,          // 图元创建者名字
     "size": 4,             // 图元大小
     "pos": (x, y),       // 图元位置NSValue
     "color": 4294263590,                       // 图元颜色
     "zOrder": 1918378406,                    // z轴偏移
     "points": []         // 图元点集合NSValue
 }
 */
- (void)onLineUpdatedWithJson:(NSDictionary *)json
                 whiteboardId:(unsigned long long)whiteboardId;

/**
 白板画布中单个矩形更新通知
 
 @param whiteboardId 白板 ID
 @param json    图元数据
 {
     "operatorId": "99975923",                // 图元创建者ID
     "graphicId": 3019181292,                // 图元ID
     "operatorName": “xiaoqiang”,          // 图元创建者名字
     "size": 4,             // 图元大小
     "pos": (x, y),       // 图元位置NSValue
     "color": 4294263590,                       // 图元颜色
     "zOrder": 1918378406,                    // z轴偏移
     "points": []         // 图元点集合NSValue
 }
 */
- (void)onRectangleUpdatedWithJson:(NSDictionary *)json
                      whiteboardId:(unsigned long long)whiteboardId;

/**
 白板画布中单个圆或椭圆更新通知
 
 @param whiteboardId 白板 ID
 @param json    图元数据
 {
     "operatorId": "99975923",                // 图元创建者ID
     "graphicId": 3019181292,                // 图元ID
     "operatorName": “xiaoqiang”,          // 图元创建者名字
     "size": 4,             // 图元大小
     "pos": (x, y),       // 图元位置NSValue
     "color": 4294263590,                       // 图元颜色
     "zOrder": 1918378406,                    // z轴偏移
     "points": []         // 图元点集合NSValue
 }
 */
- (void)onEllipseUpdatedWithJson:(NSDictionary *)json
                    whiteboardId:(unsigned long long)whiteboardId;

/**
激光笔更新通知

@param whiteboardId 白板 ID
@param json    图元数据
{
"operatorId": "99975923",                // 图元创建者ID
"graphicId": 3019181292,                // 图元ID
"operatorName": “xiaoqiang”,          // 图元创建者名字
"size": 4,             // 图元大小
"pos": (x, y),       // 图元位置NSValue
"color": 4294263590,                       // 图元颜色
"zOrder": 1918378406,                    // z轴偏移
"points": []         // 图元点集合NSValue
}
*/
-(void)onLaserUpdatedWithJson:(NSDictionary *)json
whiteboardId : (unsigned long long)whiteboardId;

/**
图片图元更新通知

@param whiteboardId 白板 ID
@param json    图元数据
{
"operatorId": "99975923",                // 图元创建者ID
"graphicId": 3019181292,                // 图元ID
"operatorName": “xiaoqiang”,          // 图元创建者名字
"pos": (x, y),       // 图元位置NSValue
"zOrder": 1918378406,                    // z轴偏移
"url": "http://",			//图片url
"hash":"sadasdsad"			//图片hash
"points": []         // 图元点集合NSValue
}
*/
-(void)onImageUpdatedWithJson:(NSDictionary *)json
whiteboardId : (unsigned long long)whiteboardId;

/**
 白板画布中单个图元删除通知
 
 @param graphicId 被删除的图元 ID
 @param operatorId 删除该图元的用户 ID
 @param operatorName 删除该图元的用户昵称
 @param whiteboardId 单个图元被删除的白板 ID
 */
- (void)onDeleted:(unsigned long long)graphicId
       byOperator:(NSString *)operatorId
             name:(NSString *)operatorName
     onWhiteboard:(unsigned long long)whiteboardId;
	 
/**
 图元 zOrder 发生变化

 @param zOrder 调整后的新 zorder 值
 @param graphicId 要调整 zOrder 的图元 ID
 @param whiteboardId 图元所在的白板 ID
 */
- (void)onZOrderChanged:(unsigned long long)zOrder
              ofGraphic:(unsigned long long)graphicId
           onWhiteboard:(unsigned long long)whiteboardId;

@end


#pragma mark - whiteboard canvas interface

@interface ZegoWhiteboardCanvas : NSObject

/** 设置画布、图元更新通知 delegate */
- (void)setDelegate:(id<ZegoWhiteboardCanvasDelegate>)delegate;

/**
 加载指定白板关联画布上的所有图元
 
 @param whiteboardId 白板 ID
 @note 加载完最后一个图元后，将从 delegate onLoadFinished 反馈结束
 @note 具体的图元数据，根据加载过程中的实际操作类型，从 delegate 各 update 接口通知
 */
- (void)load:(unsigned long long)whiteboardId;

/**
 加载指定白板关联画布上 SDK 缓存的所有图元
 
 @param whiteboardId 白板 ID
 @note 同上
 */
- (void)loadCache:(unsigned long long)whiteboardId;

/**
 清除指定白板关联画布上的所有图元，所有人或白板操作者会收到该指令
 
 @param whiteboardId 白板 ID
 @note 调用该接口后，白板关联的UI层自行清除所有绘制
 */
- (void)clear:(unsigned long long)whiteboardId;

/**
 撤销指定白板画布的上一次图元操作，绘制过程中调用无效
 
 @param whiteboardId 白板 ID
 @note 调用该接口后，根据上一次图元操作类型，从 delegate 各 update 接口通知
 */
- (void)undo:(unsigned long long)whiteboardId;

/**
 重做指定白板画布上一次撤销的图元操作，绘制过程中调用无效
 
 @param whiteboardId 白板 ID
 @note 调用该接口后，根据上一次撤销的图元操作类型，从 delegate 各 update 接口通知
 */
- (void)redo:(unsigned long long)whiteboardId;


/*******************************************************************************
 图元绘制、移动、删除操作，绘制用法举例：
 
 [[whiteboard sharedCanvasManager] beginDraw:]; // 手指触碰屏幕等
 [[whiteboard sharedCanvasManager] drawPath:];  // 手指在屏幕滑动，产生点坐标
 ......
 [[whiteboard sharedCanvasManager] endDraw:];   // 手指离开屏幕等
 
 在一次绘制过程中，开始和结束方法要配对使用，在开始和结束间不要出现多种类型的图元绘制请求
 *******************************************************************************/

/**
 通知指定白板的虚拟画布要开始绘制一个新的图元，并得到新图元的id。与zego_whiteboard_canvas_end_draw配对使用
 
 @param graphicType 图元类型
 @param pos 传入起始坐标（UI层原始坐标即可），比如鼠标右键按下、触碰屏幕时的点击坐标。
 @param whiteboardId 白板 ID
 @return 新图元 ID
 */
- (unsigned long long)beginDraw:(int)graphicType
                                 pos:(CGPoint)pos
                        onWhiteboard:(unsigned long long)whiteboardId;

/**
 通知指定白板的虚拟画布图元绘制结束。与beginDraw: pos: atWhiteboard: 配对使用
 
 @param whiteboardId 白板 ID
 */
- (void)endDraw:(unsigned long long)whiteboardId;

/**
 向指定白板的虚拟画布绘制涂鸦点
 
 @param whiteboardId 白板 ID
 @param pos 涂鸦点
 */
- (void)drawPath:(CGPoint)pos onWhiteboard:(unsigned long long)whiteboardId;

/**
 向指定白板的虚拟画布绘制简单文本
 
 @param whiteboardId 白板 ID
 @param text 简单文本内容
 */
- (void)drawText:(NSString *)text
    onWhiteboard:(unsigned long long)whiteboardId;

/**
 编辑指定白板虚拟画布上的已存在文本图元，即修改文本内容
 
 @param text 新的文本内容
 @param graphicId 已存在的文本图元 ID
 @param whiteboardId 白板 ID
 */
- (void)editText:(NSString *)text
       ofGraphic:(unsigned long long)graphicId
	onWhiteboard:(unsigned long long)whiteboardId;



/**
向指定白板的虚拟增加图片图元

@param url 图片路径url
@param hash 图片hash
@param pos 图片终点
@param whiteboardId 白板 ID
*/
-(void)addImage:(NSString *)url
	ofImageHash : (NSString *)hash
	ofEndPoint : (CGPoint)pos
	onWhiteboard : (unsigned long long)whiteboardId;

/**
向指定白板的编辑图片图元

@param pos 图片终点
@param epos 图片终点
@param graphicId 已存在的图片图元 ID
@param whiteboardId 白板 ID
*/
-(void)editImage:(CGPoint)pos
		ofEndPoint : (CGPoint)epos
		ofGraphic : (unsigned long long)graphicId
	onWhiteboard : (unsigned long long)whiteboardId;


/**
 向指定白板的虚拟画布绘制直线终点
 
 @param pos 直线终点
 @param whiteboardId 白板 ID
 */
- (void)drawLine:(CGPoint)pos onWhiteboard:(unsigned long long)whiteboardId;

/**
 向指定白板的虚拟画布绘制矩形的右下角点
 
 @param pos 矩形右下角点
 @param whiteboardId 白板 ID
 */
- (void)drawRectangle:(CGPoint)pos onWhiteboard:(unsigned long long)whiteboardId;

/**
 向指定白板的虚拟画布绘制椭圆矩形外框的右下角点
 
 @param pos 椭圆矩形外框右下角点
 @param whiteboardId 白板 ID
 */
- (void)drawEllipse:(CGPoint)pos onWhiteboard:(unsigned long long)whiteboardId;

/**
 移动虚拟画布上的指定图元
 
 @param graphicId 图元 ID，由 beginDraw: 产生
 @param pos 要移动的目标位置坐标，相对图元来说是左上角坐标
 @param whiteboardId 白板 ID
 */
- (void)moveGraphic:(unsigned long long)graphicId
        toPosistion:(CGPoint)pos
       onWhiteboard:(unsigned long long)whiteboardId;

/**
 批量移动虚拟画布上的指定图元

 @param moveInfo 图元移动信息，包含图元 ID 和移动的目标位置坐标，NSNumber * 即 unsigned long long，NSValue * 即 CGPoint
 @param whiteboardId 白板 ID
 */
- (void)moveGraphics:(NSDictionary<NSNumber *, NSValue *> *)moveInfo
        onWhiteboard:(unsigned long long)whiteboardId;

/**
 删除虚拟画布上的指定图元
 
 @param graphicId 图元 ID，由 beginDraw: 产生
 @param whiteboardId 白板 ID
 */
- (void)deleteGraphic:(unsigned long long)graphicId
         onWhiteboard:(unsigned long long)whiteboardId;

/**
 批量删除虚拟画布上的指定图元
 
 @param items 待删除的图元 ID 数组，NSNumber * 即unsigned long long
 */
- (void)deleteGraphics:(NSArray<NSNumber *> *)items
          onWhiteboard:(unsigned long long)whiteboardId;

@end
