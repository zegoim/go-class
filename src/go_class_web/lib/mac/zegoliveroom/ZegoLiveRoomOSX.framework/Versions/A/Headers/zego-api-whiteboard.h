#ifndef zego_api_edu_whiteboard_h
#define zego_api_edu_whiteboard_h

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// 互动白板由一个虚拟模型（WhiteboardModel，白板本身各种属性的载体）关联一块虚拟画布（宽高等比，所有图元操作和绘制在此操作）构成。
// 这里提供互动白板的底层核心逻辑，包括图元同步、互动操作时的冲突判定、Undo\Redo等。 
// 另需要各平台UI层配合实现，UI层负责传入坐标、文字等必要的原始数据，大多数情况下仅负责基于回调展示数据即可。

#include "zego-api-whiteboard-defines.h"

#ifdef __cplusplus
extern "C" {
#endif

	///////////////////////////////////////////////////////////////////////////////////////////////////////////
	// 以下是创建互动白板模型对象，以及从指定白板模型中获取各种属性信息的接口

	/**
	 创建互动白板模型，与zego_whiteboard_model_delete配对使用

	 @param mode 互动白板模式
	 @return 互动白板模型对象
	 */
	ZEGOEDU_API struct ZegoWhiteboardModel* zego_whiteboard_model_make(enum ZegoWhiteboardMode mode);
	/**
	 释放由zego_whiteboard_model_make产生的互动白板对象

	 @param whiteboard 待释放的互动白板对象
	 */
	ZEGOEDU_API void        zego_whiteboard_model_delete(struct ZegoWhiteboardModel* whiteboard);

	/** 获取白板唯一标识符 */
	ZEGOEDU_API ZegoWhiteboardId zego_whiteboard_model_get_id(const struct ZegoWhiteboardModel* whiteboard);

	/** 获取白板模式 */
	ZEGOEDU_API enum ZegoWhiteboardMode zego_whiteboard_model_get_mode(const struct ZegoWhiteboardModel* whiteboard);

	/** 获取白板名 */
	ZEGOEDU_API const char*  zego_whiteboard_model_get_name(const struct ZegoWhiteboardModel* whiteboard);

	/** 获取白板宽高比 */
	ZEGOEDU_API void         zego_whiteboard_model_get_aspect_ratio(const struct ZegoWhiteboardModel* whiteboard, unsigned int* width, unsigned int* height);

	/** 获取白板画布的滚动、滑动百分比、动态ppt步骤 */
	ZEGOEDU_API void        zego_whiteboard_model_get_scroll_percent(const struct ZegoWhiteboardModel* whiteboard, float* horizontal_percen, float* vertical_percent, unsigned int* ppt_step);

	/** 获取白板内容 */
	ZEGOEDU_API const char*  zego_whiteboard_model_get_content(const struct ZegoWhiteboardModel* whiteboard);

	/** 获取白板扩展信息 */
	ZEGOEDU_API const char*  zego_whiteboard_model_get_extra(const struct ZegoWhiteboardModel* whiteboard);

	/** 获取白板附加的h5信息 全量信息*/
	ZEGOEDU_API const char*  zego_whiteboard_model_get_h5_extra(const struct ZegoWhiteboardModel* whiteboard);

	/** 获取module创建时间 */
	ZEGOEDU_API unsigned long long   zego_whiteboard_model_get_create_time(const struct ZegoWhiteboardModel* whiteboard);

	/** 对 zego_whiteboard_model_make 产生的白板模型设置白板名 */
	ZEGOEDU_API int     zego_whiteboard_model_set_name(struct ZegoWhiteboardModel* whiteboard, const char* name);

	/** 对 zego_whiteboard_model_make 产生的白板模型设置白板等比宽高 */
	ZEGOEDU_API int     zego_whiteboard_model_set_aspect_ratio(struct ZegoWhiteboardModel* whiteboard, unsigned int width, unsigned int height);

	/** 对 zego_whiteboard_model_make 产生的白板模型设置内容 */
	ZEGOEDU_API int     zego_whiteboard_model_set_content(struct ZegoWhiteboardModel* whiteboard, const char* content);

	/** 对 zego_whiteboard_model_make 产生的白板模型设置内容 */
	ZEGOEDU_API int     zego_whiteboard_model_set_extra(struct ZegoWhiteboardModel* whiteboard, const char* extra);


	///////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 互动白板创建、销毁，以及改变属性相关接口
    
    /**
     初始化白板模块
     
     @note 该接口需要在LIVEROOM::InitSDK之后调用，在其他白板模块接口前调用
     */
    ZEGOEDU_API unsigned int zego_whiteboard_init();
    
    /**
     注册 初始化白板 的回调
     */
    ZEGOEDU_API void zego_whiteboard_reg_init_callback(zego_whiteboard_init_callback_func cb, void* user_context);
    
    /**
     反初始化白板模块
     
     @note 该接口需要在LIVEROOM::UnInitSDK之前调用
     */
    ZEGOEDU_API void  zego_whiteboard_uninit();

	/**
	设置缓存路径
	*/
	ZEGOEDU_API int  zego_whiteboard_set_cache_directory(const char* directory);

	/**
	获取缓存路径
	*/
	ZEGOEDU_API const char*  zego_whiteboard_get_cache_directory();

	/**
	清除缓存
	*/
	ZEGOEDU_API void  zego_whiteboard_clear_cache();

	/**
	 设置指定白板对应view的当前实际尺寸，有其他人绘制的图元到达时，将根据设置的当前宽高算出合适坐标再通知UI层更新

	 @param whiteboard_id 白板id
	 @param width\height 白板关联的UI宽高
	 @return 错误码，0为成功
	 @note 这里的UI宽高 ！不仅仅是 ！可视区域（即视口 viewport）的宽高，而应为包括滚动轴覆盖范围的宽高
	 */
	ZEGOEDU_API void zego_whiteboard_set_size(ZegoWhiteboardId whiteboard_id, unsigned int width, unsigned int height);

	/**
	 设置指定白板对应view的可视区域宽高

	 @param whiteboard_id 白板id
	 @param width\height 白板关联的UI可视区域宽高
	 @return 错误码，0为成功
	 */
	ZEGOEDU_API void zego_whiteboard_set_viewport_size(ZegoWhiteboardId whiteboard_id, unsigned int width, unsigned int height);

	/**
	 指定白板模型，创建互动白板

	 @param whiteboard 模块模型，可由zego_whiteboard_model_make生成
	 @param width\height 白板关联的UI宽高
	 @return 0为调用失败，非0为请求序号
	 */
	ZEGOEDU_API unsigned int  zego_whiteboard_create(const struct ZegoWhiteboardModel* whiteboard);
	/**
	 注册 创建白板 的回调
	 */
	ZEGOEDU_API void     zego_whiteboard_reg_create_callback(zego_whiteboard_create_callback_func cb, void* user_context);
	/**
	 注册 有白板新增 的通知
	 */
	ZEGOEDU_API void     zego_whiteboard_reg_added_notify(zego_whiteboard_added_notify_func cb, void* user_context);

	/**
	 销毁指定互动白板

	 @param whiteboard_id 白板id
	 @return 0为调用失败，非0为请求序号
	 */
	ZEGOEDU_API unsigned int  zego_whiteboard_destroy(ZegoWhiteboardId whiteboard_id);
	/**
	 注册 销毁白板 的回调
	 */
	ZEGOEDU_API void     zego_whiteboard_reg_destroy_callback(zego_whiteboard_destroy_callback_func cb, void* user_context);
	/**
	 注册 有白板被销毁 的通知
	 */
	ZEGOEDU_API void      zego_whiteboard_reg_removed_notify(zego_whiteboard_removed_notify_func cb, void* user_context);

	/**
	 拉取互动白板列表

	 @return 0为调用失败，非0为请求序号
	 */
	ZEGOEDU_API unsigned int   zego_whiteboard_get_list(void);
	/** 注册 互动白板拉取结果 的回调 */
	ZEGOEDU_API void      zego_whiteboard_reg_get_list_callback(zego_whiteboard_get_list_callback_func cb, void* user_context);

	/**
	 设置指定白板的内容

	 @param module_id 白板id
	 @param content 内容
	 @return 0为调用失败，非0为请求序号
	 */
	ZEGOEDU_API unsigned int   zego_whiteboard_set_content(ZegoWhiteboardId whiteboard_id, const char* content);
	/** 注册 设置白板内容 的回调 */
	ZEGOEDU_API void      zego_whiteboard_reg_set_content_callback(zego_whiteboard_set_content_callback_func cb, void* user_context);
	/** 注册 白板内容发生变化 的通知 */
	ZEGOEDU_API void      zego_whiteboard_reg_content_changed_notify(zego_whiteboard_content_changed_notify_func cb, void* user_context);


	/**
	设置指定白板的扩展信息

	@param module_id 白板id
	@param extra 扩展信息
	@return 0为调用失败，非0为请求序号
	*/
	ZEGOEDU_API unsigned int   zego_whiteboard_set_extra(ZegoWhiteboardId whiteboard_id, const char* extra);
	/** 注册 设置白板扩展信息 的回调 */
	ZEGOEDU_API void      zego_whiteboard_reg_set_extra_callback(zego_whiteboard_set_extra_callback_func cb, void* user_context);
	/** 注册 白板扩展信息发生变化 的通知 */
	ZEGOEDU_API void      zego_whiteboard_reg_extra_changed_notify(zego_whiteboard_extra_changed_notify_func cb, void* user_context);


	/**
	追加白板附加的h5信息

	@param module_id 白板id
	@param h5_extra h5扩展信息
	{
		"H5_target": 
		{
			"s": 1, 
			"p": 2, 
			"e":
			[
				{ "id": "xxxx","t":123, "scene":1 }
			]
		}
	}
	@return 0为调用失败，非0为请求序号
	*/
	ZEGOEDU_API unsigned int   zego_whiteboard_append_h5_extra(ZegoWhiteboardId whiteboard_id, const char* h5_extra);
	/** 注册 追加白板附加的h5信息 的回调 */
	ZEGOEDU_API void      zego_whiteboard_reg_append_h5_extra_callback(zego_whiteboard_append_h5_extra_callback_func cb, void* user_context);
	/** 注册 追加白板附加h5信息的 通知 */
	ZEGOEDU_API void      zego_whiteboard_reg_h5_extra_appended_notify(zego_whiteboard_h5_extra_appended_notify_func cb, void* user_context);


	/**
	 根据滑动的百分比拉取最新的图元

	 @param whiteboard_id 白板id
	 @param horizontal_percen 水平百分比
	 @param vertical_percent 竖直百分比
	 @return 0为调用失败，非0为请求序号
	 @note 当ui滚动时调用，更新可见区域图元
	 */
	ZEGOEDU_API void  zego_whiteboard_load_current_graphics(ZegoWhiteboardId whiteboard_id, float horizontal_percen, float vertical_percent);


	/**
	 滑动、翻滚白板画布

	 @param whiteboard_id 白板id
	 @param horizontal_percen 水平百分比
	 @param vertical_percent 竖直百分比
	 @param ppt_step 动态ppt步骤
	 @return 0为调用失败，非0为请求序号
	 @note ui主动触发滚动时调用，通知其他用户滚动
	 */
	ZEGOEDU_API unsigned int  zego_whiteboard_scroll_canvas(ZegoWhiteboardId whiteboard_id, float horizontal_percen, float vertical_percent, unsigned int ppt_step);


	/**
	 注册 滑动、滚动白板画布 的回调
	 */
	ZEGOEDU_API void      zego_whiteboard_reg_scroll_canvas_callback(zego_whiteboard_scroll_canvas_callback_func cb, void* user_context);
	/**
	 注册 白板画布发生滑动、滚动 的通知
	 */
	ZEGOEDU_API void      zego_whiteboard_reg_canvas_scrolled_notify(zego_whiteboard_canvas_scrolled_notify_func cb, void* user_context);

	/**
	设置白板view的版本号(初始化前设置)
	*/
	ZEGOEDU_API void    zego_whiteboard_set_view_version(const char * version);

	/**
	获取native的白板版本号
	*/
	ZEGOEDU_API const char*   zego_whiteboard_get_version();

	/**
	上传图片

	@param address 本地路径
	@return 0为调用失败，非0为请求序号
	*/
	ZEGOEDU_API unsigned int   zego_whiteboard_upload_file(const char * address);

	/**
	取消上传

	@param seq 上传seq
	*/
	ZEGOEDU_API void  zego_whiteboard_cancel_upload_file(unsigned int seq);

	/**
	注册上传图片回调
	*/
	ZEGOEDU_API void  zego_whiteboard_reg_upload_file_notify(zego_whiteboard_upload_file_notify_func cb, void* user_context);

	/**
	下载图片

	@param address 网络路径
	@param hash （可填空）经过上传着填，主要用来本地验证缓存避免重复下载
	@type 图片类型
	@return 0为调用失败，非0为请求序号
	*/
	ZEGOEDU_API unsigned int   zego_whiteboard_download_file(const char * url, const char *hash, enum ZegoWhiteboardGraphicImageType type);


	/**
	取消下载

	@param seq 下载seq
	*/
	ZEGOEDU_API void  zego_whiteboard_cancel_download_file(unsigned int seq);

	/**
	注册上传图片回调
	*/
	ZEGOEDU_API void  zego_whiteboard_reg_download_file_notify(zego_whiteboard_download_file_notify_func cb, void* user_context);

#ifdef __cplusplus
} // __cplusplus defined.
#endif

#endif
