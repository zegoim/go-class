#ifndef zego_api_edu_whiteboard_constant_h
#define zego_api_edu_whiteboard_constant_h

#include "zego-api-edu-defines.h"

/** 白板id类型，唯一标识一块白板 */
typedef unsigned long long ZegoWhiteboardId;

/** 白板画布上图元id类型，唯一标识一个图元 */
typedef unsigned long long ZegoWhiteboardGraphicId;


/** 白板模式 */
enum ZegoWhiteboardMode
{
	kZegoWhiteboardModeFullUpdate = 0x1,            /**< 单个图元绘制完毕后才全量同步该图元 */
	kZegoWhiteboardModeRealTime = 0x2,            /**< 实时模式，边绘制边同步，适用于人数较少的环境 */
	kZegoWhiteboardModeSingleOperator = 0x3,            /**< 1对多非互动模式 */
};

/** 白板画布上简单图元类型 */
enum ZegoWhiteboardGraphic
{
	kZegoWhiteboardGraphicNone = 0x0,             /**< 空图元 */
	kZegoWhiteboardGraphicPath = 0x1,             /**< 涂鸦 */
	kZegoWhiteboardGraphicText = 0x2,             /**< 文本 */
	kZegoWhiteboardGraphicLine = 0x4,             /**< 直线 */
	kZegoWhiteboardGraphicRect = 0x8,             /**< 矩形 */
	kZegoWhiteboardGraphicEllipse = 0x10,            /**< 圆或椭圆 */
	kZegoWhiteboardGraphicLaser = 0x80,            /**< 激光笔 */
	kZegoWhiteboardGraphicImage = 0x100				/**< 图片 */
};

enum ZegoWhiteboardGraphicImageType {
	//图片图元
	ZegoWhiteboardGraphicImageGraphic = 0,
	//自定义教具图片
	ZegoWhiteboardGraphicImageCustom = 1
};

/** 白板画布上简单图元粗细（在画布视口宽度为1280px情况下的推荐标准值，画布大小变化时请自行缩放图元） */
enum ZegoWhiteboardGraphicSizeLevel
{
	kZegoWhiteboardGraphicSizeLevel1 = 2,               /**< 单位px */
	kZegoWhiteboardGraphicSizeLevel2 = 4,
	kZegoWhiteboardGraphicSizeLevel3 = 10,
	kZegoWhiteboardGraphicSizeLevel4 = 20,
};

/** 白板画布上文本图元字体大小（在画布视口宽度为1280px情况下的推荐标准值，画布大小变化时请自行缩放图元） */
enum ZegoWhiteboardGraphicFontLevel
{
	kZegoWhiteboardGraphicFontLevel1 = 16,              /**< 单位px */
	kZegoWhiteboardGraphicFontLevel2 = 24,
	kZegoWhiteboardGraphicFontLevel3 = 36,
	kZegoWhiteboardGraphicFontLevel4 = 48,
};

/** 白板画布滑动、滚动方向 */
enum ZegoWhiteboardCanvasScrollDirection
{
	kZegoWhiteboardCanvasScrollDirectionHorizontal = 0x1,        /**< 水平方向 */
	kZegoWhiteboardCanvasScrollDirectionVertical = 0x2,        /**< 竖直方向 */
};

/**
* 图片类型枚举定义
*/
enum ZegoWhiteboardViewImageType 
{											
	ZegoWhiteboardViewImageGraphic = 0,		/**< 图片图元 */
	ZegoWhiteboardViewImageCustom = 1		/**< 自定义教具图片 */
};

#endif
