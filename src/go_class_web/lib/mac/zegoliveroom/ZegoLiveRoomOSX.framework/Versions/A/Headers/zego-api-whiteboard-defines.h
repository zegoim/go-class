#ifndef zego_api_edu_whiteboard_defines_h
#define zego_api_edu_whiteboard_defines_h

#include "zego-api-whiteboard-constant.h"

/** 白板模型，从中获取白板详细属性 */
struct ZegoWhiteboardModel;

/** 白板画布上的图元模型，从中可获取图元详细属性 */
struct ZegoWhiteboardGraphicProperties;

/** 图元中单个点信息 */
struct ZegoWhiteboardPoint
{
	int x;
	int y;
};

struct ZegoWhiteboardRect
{
	struct ZegoWhiteboardPoint begin_point;
	struct ZegoWhiteboardPoint end_point;
};

struct ZegoWhiteboardUndoRect
{
	struct ZegoWhiteboardPoint begin_point;
	struct ZegoWhiteboardPoint end_point;
};

struct ZegoWhiteboardMoveInfo
{
	ZegoWhiteboardGraphicId graphic_id;
	struct ZegoWhiteboardPoint pos;
};

/**
 初始化版本回调
 
 @param seq zego_whiteboard_init返回的调用序号
 @param error_code 错误码，0为成功
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_init_callback_func)(unsigned int seq, int error_code, void* user_context);

/**
 拉取白板列表的结果回调

 @param seq zego_whiteboard_get_list返回的调用序号
 @param error_code 错误码，0为成功
 @param whiteboard_list 拉取到的白板列表
 @param whiteboard_count 拉取到的白板数
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_get_list_callback_func)(unsigned int seq, int error_code, const struct ZegoWhiteboardModel** whiteboard_list, unsigned int whiteboard_count, void* user_context);

/**
 创建白板的结果回调

 @param seq zego_whiteboard_create返回的调用序号
 @param error_code 错误码，0为成功
 @param whiteboard 创建的白板模型，如失败则该值为空
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_create_callback_func)(unsigned int seq, int error_code, const struct ZegoWhiteboardModel* whiteboard, void* user_context);
/**
 有白板新增的通知

 @param whiteboard 新增的白板模型
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_added_notify_func)(const struct ZegoWhiteboardModel* whiteboard, void* user_context);

/**
 销毁白板的结果回调

 @param seq zego_whiteboard_destroy返回的调用序号
 @param error_code 错误码，0为成功
 @param whiteboard_id 被销毁的白板id
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_destroy_callback_func)(unsigned int seq, int error_code, ZegoWhiteboardId whiteboard_id, void* user_context);

/**
 有白板被销毁的通知

 @param whiteboard_id 被销毁的白板id
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_removed_notify_func)(ZegoWhiteboardId whiteboard_id, void* user_context);

/**
* 获取白板view列表回调
* @param seq				请求seq
* @param view_list			白板view数组
* @param count				已创建的白板个数
* @param code				错误码，参见ZegoWhiteboardViewErrorCode定义
* @param user_data			自定义透传数据
*/
typedef void(*zego_whiteboard_view_get_list_notify_func)(ZegoSeq seq, const struct ZegoWhiteboardView* view_list, unsigned int count, void *user_data);

/**
 滑动、滚动白板画布的结果回调

 @param seq zego_whiteboard_scroll_canvas返回的调用序号
 @param error_code 错误码，0为成功
 @param whiteboard_id 要滚动、滑动的白板id（关联画布）
 @param horizontal_scroll_percent 横向滚动的相对位置百分比（可以理解为滚动条Handle在滚动条Bar中的百分比）
 @param vertical_scroll_percent 纵向滚动的相对位置百分比
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_scroll_canvas_callback_func)(unsigned int seq, int error_code, ZegoWhiteboardId whiteboard_id, float horizontal_scroll_percent, float vertical_scroll_percent, unsigned int ppt_step, void* user_context);
/**
 白板画布发生滑动、滚动的通知

 @param whiteboard_id 滚动、滑动的白板id（关联画布）
 @param horizontal_scroll_percent 横向滚动的相对位置百分比（可以理解为滚动条Handle在滚动条Bar中的百分比）
 @param vertical_scroll_percent 纵向滚动的相对位置百分比
 @param user_context 用户上下文数据透传
 @note 可能只有一个方向的scroll值真正发生变化，界面层需过滤
 */
typedef void(*zego_whiteboard_canvas_scrolled_notify_func)(ZegoWhiteboardId whiteboard_id, float horizontal_scroll_percent, float vertical_scroll_percent, unsigned int ppt_step, void* user_context);

/**
 设置白板宽content的结果回调

 @param seq zego_whiteboard_set_content返回的调用序号
 @param error_code 错误码，0为成功
 @param whiteboard_id 待修改的白板id
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_set_content_callback_func)(unsigned int seq, int error_code, ZegoWhiteboardId whiteboard_id, void* user_context);
/**
 白板内容发生变化的通知

 @param whiteboard_id 内容发生变化的白板id
 @param content 内容
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_content_changed_notify_func)(ZegoWhiteboardId whiteboard_id, const char* content, void* user_context);

/**
 设置白板扩展字段的结果回调

 @param seq zego_whiteboard_set_extra返回的调用序号
 @param error_code 错误码，0为成功
 @param whiteboard_id 待修改的白板id
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_set_extra_callback_func)(unsigned int seq, int error_code, ZegoWhiteboardId whiteboard_id, void* user_context);
/**
 白板扩展字段内容发生变化的通知

 @param whiteboard_id 内容发生变化的白板id
 @param extra 内容
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_extra_changed_notify_func)(ZegoWhiteboardId whiteboard_id, const char* extra, void* user_context);


/**
 追加白板附加h5信息的结果回调

 @param seq zego_whiteboard_set_extra返回的调用序号
 @param error_code 错误码，0为成功
 @param whiteboard_id 待修改的白板id
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_append_h5_extra_callback_func)(unsigned int seq, int error_code, ZegoWhiteboardId whiteboard_id, void* user_context);
/**
 新增白板附加h5信息的通知

 @param whiteboard_id 内容发生变化的白板id
 @param h5_extra 内容
{
	"H5_target":
	{
		"s": 1,
		"p": 2,
		"e":
		[
			{ "id": 7}
		]
	}
}
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_h5_extra_appended_notify_func)(ZegoWhiteboardId whiteboard_id, const char* h5_extra, void* user_context);


/**
白板画布中单个图片图元更新通知

@param whiteboard_id 白板id
@param graphic_id 图片图元id
@param graphic_properties 图元属性信息，起始点\粗细\颜色\绘制人等
@param point_begin 图元起始位置
@param path 图片相关url链接
@param hash 图片hash (可填空)
@param user_context 用户上下文数据透传
*/
typedef void(*zego_whiteboard_canvas_image_update_notify_func)(ZegoWhiteboardId whiteboard_id,
	ZegoWhiteboardGraphicId graphic_id, const struct ZegoWhiteboardGraphicProperties* graphic_properties,
	const struct ZegoWhiteboardPoint* point_begin, const struct ZegoWhiteboardPoint* point_end, const char* path, const char* hash,
	void* user_context);

/**
 白板画布中单个涂鸦图元更新通知

 @param whiteboard_id 白板id
 @param graphic_id 涂鸦图元id
 @param graphic_properties 图元属性信息，起始点\粗细\颜色\绘制人等
 @param points 涂鸦线条上所有点的数组
 @param point_count 点数量
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_canvas_path_update_notify_func)(ZegoWhiteboardId whiteboard_id,
	ZegoWhiteboardGraphicId graphic_id, const struct ZegoWhiteboardGraphicProperties* graphic_properties,
	const struct ZegoWhiteboardPoint* points, unsigned int point_count,
	void* user_context);

/**
 白板画布中单个文本更新通知

 @param whiteboard_id 白板id
 @param graphic_id 文本图元id
 @param graphic_properties 图元属性信息，粗细\颜色\绘制人等
 @param point_begin 文本起始位置
 @param text 文本内容
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_canvas_text_update_notify_func)(ZegoWhiteboardId whiteboard_id,
	ZegoWhiteboardGraphicId graphic_id, const struct ZegoWhiteboardGraphicProperties* graphic_properties,
	const struct ZegoWhiteboardPoint* point_begin, const char* text,
	void* user_context);

/**
 白板画布中单个线条更新通知

 @param whiteboard_id 白板id
 @param graphic_id 线条图元id
 @param graphic_properties 图元属性信息，起始点\粗细\颜色\绘制人等
 @param point_begin\point_end 起始点和结束点
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_canvas_line_update_notify_func)(ZegoWhiteboardId whiteboard_id,
	ZegoWhiteboardGraphicId graphic_id, const struct ZegoWhiteboardGraphicProperties* graphic_properties,
	const struct ZegoWhiteboardPoint* point_begin, const struct ZegoWhiteboardPoint* point_end,
	void* user_context);

/**
 白板画布中单个矩形更新通知

 @param whiteboard_id 白板id
 @param graphic_id 线条图元id
 @param graphic_properties 图元属性信息，起始点\粗细\颜色\绘制人等
 @param point_begin\point_end 起始点（左上角）和结束点（右下角）
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_canvas_rect_update_notify_func)(ZegoWhiteboardId whiteboard_id,
	ZegoWhiteboardGraphicId graphic_id, const struct ZegoWhiteboardGraphicProperties* graphic_properties,
	const struct ZegoWhiteboardPoint* point_begin, const struct ZegoWhiteboardPoint* point_end,
	void* user_context);

/**
 白板画布中单个圆或椭圆更新通知

 @param whiteboard_id 白板id
 @param graphic_id 园和椭圆的图元id
 @param graphic_properties 图元属性信息，起始点\粗细\颜色\绘制人等
 @param point_begin\point_end 起始点（左上角）和结束点（右下角）
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_canvas_ellipse_update_notify_func)(ZegoWhiteboardId whiteboard_id,
	ZegoWhiteboardGraphicId graphic_id, const struct ZegoWhiteboardGraphicProperties* graphic_properties,
	const struct ZegoWhiteboardPoint* point_begin, const struct ZegoWhiteboardPoint* point_end,
	void* user_context);

/**
@param whiteboard_id 白板id
@param graphic_id 文本图元id
@param graphic_properties 图元属性信息，粗细\颜色\绘制人等
@param point 激光笔起始位置
@param user_context 用户上下文数据透传
*/

typedef void(*zego_whiteboard_canvas_laser_update_notify_func)(ZegoWhiteboardId whiteboard_id,

	ZegoWhiteboardGraphicId graphic_id, const struct ZegoWhiteboardGraphicProperties* graphic_properties,

	const struct ZegoWhiteboardPoint* point, void* user_context);

/**
 白板画布中单个图元删除通知

 @param whiteboard_id 单个图元被删除的白板id
 @param graphic_id 被删除的图元id
 @param operator_id 删除该图元的用户id
 @param operator_name 删除该图元的用户昵称
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_canvas_item_deleted_notify_func)(ZegoWhiteboardId whiteboard_id, ZegoWhiteboardGraphicId graphic_id,
	const char* operator_id, const char* operator_name,
	void* user_context);

/**
 清空白板画布中的所有图元

 @param whiteboard_id 图元被清除的白板id
 @param operator_id 清除画布的用户id
 @param operator_name 清除画布的用户昵称
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_canvas_clear_notify_func)(ZegoWhiteboardId whiteboard_id,
	const char* operator_id, const char* operator_name,
	void* user_context);

/**
 调整图元的zorder

 @param whiteboard_id 图元所在的白板id
 @param graphic_id 要调整 zorder 的图元id
 @param zorder 要调整的新 zorder 值
 @param user_context 用户上下文数据透传
 */
typedef void(*zego_whiteboard_canvas_item_zorder_changed_notify_func)(ZegoWhiteboardId whiteboard_id, ZegoWhiteboardGraphicId graphic_id,
	unsigned long long zorder, void* user_context);



/**
上传图片回调

@param seq 上传请求seq
@param error 错误码
@param bFinsh 是否完成
@param rate 进度
@param file_id 文件id
@param url url
@param hash hash
@param user_context 用户上下文数据透传
*/
typedef void(*zego_whiteboard_upload_file_notify_func)(unsigned int seq, int error, bool bFinsh, float rate, const char* file_id, const char* url, const char* hash, void* user_context);


/**
下载图片回调

@param seq 下载请求seq
@param error 错误码
@param bFinsh 是否完成
@param rate 进度
@param address 本地路径
@param user_context 用户上下文数据透传
*/
typedef void(*zego_whiteboard_download_file_notify_func)(unsigned int seq, int error, bool bFinsh, float rate, const char* address, void* user_context);

#endif
