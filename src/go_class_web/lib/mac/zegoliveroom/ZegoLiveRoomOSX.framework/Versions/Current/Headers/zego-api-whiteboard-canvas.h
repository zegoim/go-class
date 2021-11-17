#ifndef zego_api_edu_whiteboard_canvas_h
#define zego_api_edu_whiteboard_canvas_h

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// 互动白板关联的虚拟画布，所有绘制操作在此完成
// 白板的UI层只需要严格按照图元更新的通知（zego_whiteboard_canvas_XXX_notify_func）中提供的数据来绘制图元
// 无需关心图元同步的成功或失败（失败时通知数据会反馈将该图元恢复为绘制前的状态）

#include "zego-api-whiteboard-defines.h"

#define  ZEGOCALL

#ifdef __cplusplus
extern "C" {
#endif

	/** 获取图元粗细，取值在 zego_whiteboard_settings_get_supported_graphic_size_list 范围中 */
	ZEGOEDU_API unsigned int  zego_whiteboard_graphic_item_get_size(const struct ZegoWhiteboardGraphicProperties* graphic_properties);

	/** 获取图元颜色，取值在 zego_whiteboard_settings_get_supported_graphic_color_list 范围中 */
	ZEGOEDU_API unsigned int  zego_whiteboard_graphic_item_get_color(const struct ZegoWhiteboardGraphicProperties* graphic_properties);

	/** 获取图元坐标 */
	ZEGOEDU_API void          zego_whiteboard_graphic_item_get_pos(const struct ZegoWhiteboardGraphicProperties* graphic_properties, struct ZegoWhiteboardPoint* point);

	/** 获取图元 zOrder */
	ZEGOEDU_API unsigned long long  zego_whiteboard_graphic_item_get_zorder(const struct ZegoWhiteboardGraphicProperties* graphic_properties);

	/** 获取图元操作者 ID */
	ZEGOEDU_API const char*   zego_whiteboard_graphic_item_get_operator_id(const struct ZegoWhiteboardGraphicProperties* graphic_properties);

	/** 获取图元操作者昵称 */
	ZEGOEDU_API const char*   zego_whiteboard_graphic_item_get_operator_name(const struct ZegoWhiteboardGraphicProperties* graphic_properties);

    /** 获取图元是否粗体，一般是文本图元用到 */
    ZEGOEDU_API bool  zego_whiteboard_graphic_item_get_bold(const struct ZegoWhiteboardGraphicProperties* graphic_properties);
    
    /** 获取图元是否斜体，一般是文本图元用到 */
    ZEGOEDU_API bool  zego_whiteboard_graphic_item_get_italic(const struct ZegoWhiteboardGraphicProperties* graphic_properties);

	/** 获取图片图元的执行， true为上传false为下载 */
	ZEGOEDU_API bool  zego_whiteboard_image_item_is_upload(const struct ZegoWhiteboardGraphicProperties* graphic_properties);

	/** 获取图片图元的状态，true为已完成false为进行中 */
	ZEGOEDU_API bool  zego_whiteboard_image_item_is_finished(const struct ZegoWhiteboardGraphicProperties* graphic_properties);

	/** 获取图片图元的进度， 0.0~1.0 */
	ZEGOEDU_API float  zego_whiteboard_image_item_progress(const struct ZegoWhiteboardGraphicProperties* graphic_properties);
    
	/**
	 撤销指定白板画布的上一次图元操作，绘制过程中调用无效

	 @param whiteboard_id 白板id
	 @note 调用该接口后，根据上一次图元操作类型，从相应通知接口（zego_whiteboard_canvas_XXX_notify_func）反馈撤销后应进行的操作
	 */
	ZEGOEDU_API void  zego_whiteboard_canvas_undo(ZegoWhiteboardId whiteboard_id);

	/**
	 重做指定白板画布上一次撤销的图元操作，绘制过程中调用无效

	 @param whiteboard_id 白板id
	 @note 调用该接口后，根据上一次撤销的图元操作类型，从相应通知接口（zego_whiteboard_canvas_XXX_notify_func）反馈重做后应进行的操作
	 */
	ZEGOEDU_API void  zego_whiteboard_canvas_redo(ZegoWhiteboardId whiteboard_id);

	/*****************************************************************************************
	 图元绘制、移动、删除操作，绘制用法举例：

	 zego_whiteboard_canvas_begin_draw(...) // 鼠标按下、手指触碰屏幕等
	 zego_whiteboard_canvas_draw_path(...)  // 鼠标移动、手指在屏幕滑动，产生点坐标
	 ......
	 zego_whiteboard_canvas_end_draw(...)   // 鼠标释放、手指离开屏幕等

	 在一次绘制过程中，开始和结束方法要配对使用，在开始和结束间不要出现多种类型的图元绘制请求
	******************************************************************************************/

	/**
	 通知指定白板的虚拟画布要开始绘制一个新的图元，并得到新图元的id。与zego_whiteboard_canvas_end_draw配对使用

	 @param whiteboard_id 白板id
	 @param graphic_type 图元类型
	 @param begin_x\begin_y 传入起始坐标（UI层原始坐标即可），比如鼠标右键按下、触碰屏幕时的点击坐标。
	 @return 新图元id
	 */
	ZEGOEDU_API ZegoWhiteboardGraphicId  zego_whiteboard_canvas_begin_draw(ZegoWhiteboardId whiteboard_id, enum ZegoWhiteboardGraphic graphic_type, int begin_x, int begin_y);

	/**
	 通知指定白板的虚拟画布图元绘制结束。与zego_whiteboard_canvas_begin_draw配对使用

	 @param whiteboard_id 白板id
	 */
	ZEGOEDU_API void  zego_whiteboard_canvas_end_draw(ZegoWhiteboardId whiteboard_id);

	/**
	 向指定白板的虚拟画布绘制涂鸦点

	 @param whiteboard_id 白板id
	 @param pos_x\pos_y 涂鸦点
	 */
	ZEGOEDU_API void  zego_whiteboard_canvas_draw_path(ZegoWhiteboardId whiteboard_id, int pos_x, int pos_y);

	/**
	向指定白板位置插入图片

	@param whiteboard_id 白板id
	@param url 图片url
	@param hash 图片hash（可填空）
	@param pos_x\pos_y 结束位置
	*/
	ZEGOEDU_API void zego_whiteboard_canvas_add_image(ZegoWhiteboardId whiteboard_id, const char* url, const char* hash, int pos_x, int pos_y);


	/**
	编辑指定白板虚拟画布上的已存在图片图元，修改大小

	@param whiteboard_id 白板id
	@param graphic_id 已存在的图片图元id
	@param pos_x\pos_y 其实位置
	@param epos_x\epos_y 结束位置
	*/
	ZEGOEDU_API void  zego_whiteboard_canvas_edit_image(ZegoWhiteboardId whiteboard_id, ZegoWhiteboardGraphicId graphic_id, int pos_x, int pos_y, int epos_x, int epos_y);

	/**
	 向指定白板的虚拟画布绘制简单文本

	 @param whiteboard_id 白板id
	 @param text 简单文本内容
	 */
	ZEGOEDU_API void  zego_whiteboard_canvas_draw_text(ZegoWhiteboardId whiteboard_id, const char* text);

	/**
	 编辑指定白板虚拟画布上的已存在文本图元，即修改文本内容

	 @param whiteboard_id 白板id
	 @param graphic_id 已存在的文本图元id
	 @param text 新的文本内容
	 */
	ZEGOEDU_API void  zego_whiteboard_canvas_edit_text(ZegoWhiteboardId whiteboard_id, ZegoWhiteboardGraphicId graphic_id, const char* text);

	/**
	 向指定白板的虚拟画布绘制直线终点

	 @param whiteboard_id 白板id
	 @param pos_x\pos_y 直线终点
	 */
	ZEGOEDU_API void  zego_whiteboard_canvas_draw_line(ZegoWhiteboardId whiteboard_id, int pos_x, int pos_y);

	/**
	 向指定白板的虚拟画布绘制矩形的右下角点

	 @param whiteboard_id 白板id
	 @param pos_x\pos_y 矩形右下角点
	 */
	ZEGOEDU_API void  zego_whiteboard_canvas_draw_rect(ZegoWhiteboardId whiteboard_id, int pos_x, int pos_y);

	/**
	 向指定白板的虚拟画布绘制椭圆矩形外框的右下角点

	 @param whiteboard_id 白板id
	 @param pos_x\pos_y 椭圆矩形外框右下角点
	 */
	ZEGOEDU_API void  zego_whiteboard_canvas_draw_ellipse(ZegoWhiteboardId whiteboard_id, int pos_x, int pos_y);


	/**
	 注册 所有图元类型的数据发生变化的 通知
	 */
	ZEGOEDU_API void  zego_whiteboard_canvas_reg_draw_notify(
		zego_whiteboard_canvas_path_update_notify_func path_cb,
		zego_whiteboard_canvas_text_update_notify_func text_cb,
		zego_whiteboard_canvas_line_update_notify_func line_cb,
		zego_whiteboard_canvas_rect_update_notify_func rect_cb,
		zego_whiteboard_canvas_ellipse_update_notify_func ellipse_cb,
		zego_whiteboard_canvas_laser_update_notify_func laser_cb,
		void* user_context);

	/**
	注册 所有图片图元类型的数据发生变化的 通知
	*/
	ZEGOEDU_API void  zego_whiteboard_canvas_reg_image_notify(
		zego_whiteboard_canvas_image_update_notify_func image_cb,
		void* user_context
	);
	/**
	 移动虚拟画布上的指定图元

	 @param whiteboard_id 白板id
	 @param graphic_id 图元id，由zego_whiteboard_canvas_begin_draw产生
	 @param pos_x\pos_y 要移动的目标位置坐标，相对图元来说是左上角坐标
	 */
	ZEGOEDU_API void  zego_whiteboard_canvas_move_item(ZegoWhiteboardId whiteboard_id, ZegoWhiteboardGraphicId graphic_id, int pos_x, int pos_y);

	/**
	批量移动虚拟画布上的指定图元

	@param whiteboard_id 白板id
	@param item_move_infos 图元移动信息数组，包含图元的id和移动的目标位置坐标
	@param count 图元移动信息数组的元素个数
	*/
	ZEGOEDU_API void  zego_whiteboard_canvas_move_items(ZegoWhiteboardId whiteboard_id, struct ZegoWhiteboardMoveInfo *move_info, int count);


	/**
	 删除虚拟画布上的指定图元

	 @param whiteboard_id 白板id
	 @param graphic_id 图元id，由zego_whiteboard_canvas_begin_draw产生
	 */
	ZEGOEDU_API void  zego_whiteboard_canvas_delete_item(ZegoWhiteboardId whiteboard_id, ZegoWhiteboardGraphicId graphic_id);

	/**
	删除虚拟画布上的指定图元

	@param whiteboard_id 白板id
	@param graphic_id 图元id数组，由zego_whiteboard_canvas_begin_draw产生
	@param count 图元id数组中元素个数
	*/
	ZEGOEDU_API void  zego_whiteboard_canvas_delete_items(ZegoWhiteboardId whiteboard_id, ZegoWhiteboardGraphicId *graphic_ids, int count);

	/** 注册 图元被删除 的通知 */
	ZEGOEDU_API void  zego_whiteboard_canvas_reg_item_deleted_notify(zego_whiteboard_canvas_item_deleted_notify_func cb, void* user_context);

	/**
	 清除指定白板关联画布上的所有图元，所有人或白板操作者会收到该指令

	 @param whiteboard_id 白板id
	 @note 调用该接口后，白板关联的UI层自行清除所有绘制
	 */
	ZEGOEDU_API void  zego_whiteboard_canvas_clear(ZegoWhiteboardId whiteboard_id);

	/** 注册 所有图元被清除 的通知 */
	ZEGOEDU_API void  zego_whiteboard_canvas_reg_cleared_notify(zego_whiteboard_canvas_clear_notify_func cb, void* user_context);

	/** 注册 图元 zOrder 发送变化 的通知 */
	ZEGOEDU_API void  zego_whiteboard_canvas_reg_item_zorder_changed_notify(zego_whiteboard_canvas_item_zorder_changed_notify_func cb, void* user_context);

#ifdef __cplusplus
} // __cplusplus defined.
#endif

#endif
