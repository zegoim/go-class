#ifndef zego_api_edu_whiteboard_settings_h
#define zego_api_edu_whiteboard_settings_h

#include "zego-api-whiteboard-defines.h"

#define ZEGOCALL

#ifdef __cplusplus
extern "C" {
#endif

	/** 获取指定类型图元当前设置的粗细、尺寸，enum ZegoWhiteboardGraphicSizeLevel \ enum enum ZegoWhiteboardGraphicFontLevel, 默认都为Level2 */
	ZEGOEDU_API unsigned int  zego_whiteboard_settings_get_graphic_size(enum ZegoWhiteboardGraphic graphic_type);

	/** 设置指定类型图元的粗细、尺寸，参考 enum ZegoWhiteboardGraphicSizeLevel \ enum enum ZegoWhiteboardGraphicFontLevel */
	ZEGOEDU_API int      zego_whiteboard_settings_set_graphic_size(enum ZegoWhiteboardGraphic graphic_type, unsigned int size_level);

	/** 获取指定类型图元当前设置的颜色，默认为黑色 */
	ZEGOEDU_API unsigned int  zego_whiteboard_settings_get_graphic_color(enum ZegoWhiteboardGraphic graphic_type);

	/** 获取指定类型图元当前设置的颜色字符串，如#ffffff，默认为黑色 */
	ZEGOEDU_API const char*   zego_whiteboard_settings_get_graphic_color_string(enum ZegoWhiteboardGraphic graphic_type);

	/** 设置指定类型图元的颜色 */
	ZEGOEDU_API int      zego_whiteboard_settings_set_graphic_color(enum ZegoWhiteboardGraphic graphic_type, unsigned int graphic_color);
    
    /** 获取指定类型图元当前设置的粗体属性，一般用于文本图元 */
    ZEGOEDU_API bool  zego_whiteboard_settings_get_graphic_bold(enum ZegoWhiteboardGraphic graphic_type);
    
    /** 设置指定类型图元的粗体属性，一般用于文本图元 */
    ZEGOEDU_API void  zego_whiteboard_settings_set_graphic_bold(enum ZegoWhiteboardGraphic graphic_type, bool bold);
    
    /** 获取指定类型图元当前设置的斜体属性，一般用于文本图元 */
    ZEGOEDU_API bool  zego_whiteboard_settings_get_graphic_italic(enum ZegoWhiteboardGraphic graphic_type);
    
    /** 设置指定类型图元的斜体属性，一般用于文本图元 */
    ZEGOEDU_API void  zego_whiteboard_settings_set_graphic_italic(enum ZegoWhiteboardGraphic graphic_type, bool bold);

#ifdef __cplusplus
} // __cplusplus defined.
#endif

#endif
