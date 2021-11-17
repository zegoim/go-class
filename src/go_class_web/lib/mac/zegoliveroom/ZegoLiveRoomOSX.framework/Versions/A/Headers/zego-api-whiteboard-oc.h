//
//  zego-whiteboard-oc.h
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
#import "zego-api-whiteboard-canvas-oc.h"


#pragma mark - whiteboard callback block

/**
 初始化白板的结果回调
 
 @param seq create: public: apsectRatio: 返回的调用序号
 @param errorCode 错误码，0 成功，非0 失败
 */
typedef void(^ZegoWhiteboardInitBlock)(unsigned int seq, int errorCode);

/**
 拉取白板列表的结果回调
 
 @param seq getList: 返回的调用序号
 @param errorCode 错误码，0为成功
 @param whiteboardsJson 拉取到的白板列表
 [
 {
     "whiteboardId": 99975923,          //白板ID
     "mode": 1,                                   //白板模式
     "name": “白板1”,                         //白板名称
     "width": 1028,                             //白板宽
     "height": 576,                             //白板高
     ""
     "horizontalScrollPercent": 0,      //横向滚动比
     "verticalScrollPercent": 0,          //纵向滚动比
 },
 ]
 */
typedef void(^ZegoWhiteboardGetListBlock)(unsigned int seq, int errorCode, NSArray *whiteboardsJson);

/**
 创建白板的结果回调
 
 @param seq create: public: apsectRatio: 返回的调用序号
 @param errorCode 错误码，0 成功，非0 失败
 @param whiteboardJson  白板数据，如失败则该值为空
 {
     "whiteboardId": 99975923,          //白板ID
     "mode": 1,                                   //白板模式
     "name": “白板1”,                         //白板名称
     "horizontalScrollPercent": 0,      //横向滚动比
     "verticalScrollPercent": 0,          //纵向滚动比
 }
 */
typedef void(^ZegoWhiteboardCreateBlock)(unsigned int seq, int errorCode, NSDictionary *whiteboardJson);

/**
 销毁白板的结果回调
 
 @param seq destroy: 返回的调用序号
 @param errorCode 错误码，0为成功
 @param whiteboardId 被销毁的白板id
 */
typedef void(^ZegoWhiteboardDestroyBlock)(unsigned int seq, int errorCode, unsigned long long whiteboardId);

/**
 设置白板宽高比的结果回调
 
 @param seq setAspectRatio: 返回的调用序号
 @param error_code 错误码，0为成功
 @param whiteboard_id 待修改的白板id
 @param width\height 白板宽高比
 @param user_context 用户上下文数据透传
 */
typedef void(^ZegoWhiteboardSetAspectRatioBlock)(unsigned int seq, int errorCode, unsigned long long whiteboardId, CGSize aspectRatio);

/**
 设置白板内容的结果回调
 
 @param seq setContent: 返回的调用序号
 @param errorCode 错误码，0 成功，非0 失败
 @param whiteboard_id 待修改的白板id
 */
typedef void(^ZegoWhiteboardSetContentBlock)(unsigned int seq, int errorCode, unsigned long long whiteboardId);

/**
 设置白板扩展信息的结果回调
 
 @param seq setExtra: 返回的调用序号
 @param errorCode 错误码，0 成功，非0 失败
 @param whiteboard_id 待修改的白板id
 */
typedef void(^ZegoWhiteboardSetExtraBlock)(unsigned int seq, int errorCode, unsigned long long whiteboardId);

/**
 追加白板H5扩展信息的结果回调
 
 @param seq appendH5Extra: 返回的调用序号
 @param errorCode 错误码，0 成功，非0 失败
 @param whiteboard_id 待修改的白板id
 */
typedef void(^ZegoWhiteboardAppendH5ExtraBlock)(unsigned int seq, int errorCode, unsigned long long whiteboardId);

/**
 滑动、滚动白板画布的结果回调
 
 @param seq scrollCanvas: 返回的调用序号
 @param errorCode 错误码，0为成功
 @param whiteboardId 要滚动、滑动的白板id（关联画布）
 @param horizontalPercent 横向滚动的相对位置百分比
 @param verticalPercent 竖直滚动的相对位置百分比
 @param pptStep 动态ppt步骤
 */
typedef void(^ZegoWhiteboardScrollCanvasBlock)(unsigned int seq, int error_code, unsigned long long whiteboard_id, float horizontalPercent, float verticalPercent, unsigned int pptStep);

/**
上传图片回调

@param seq 上传请求seq
@param error 错误码
@param bFinsh 是否完成
@param rate 进度
@param file_id 文件id
@param url url
@param hash hash
*/
typedef void(^ZegoWhiteboardUploadFileBlock)(unsigned int seq, int error, bool bFinsh, float rate, NSString * file_id, NSString * url, NSString * hash);

/**
下载图片回调

@param seq 下载请求seq
@param error 错误码
@param bFinsh 是否完成
@param rate 进度
@param address 本地路径
*/
typedef void(^ZegoWhiteboardDownloadFileBlock)(unsigned int seq, int error, bool bFinsh, float rate, NSString* address);

#pragma mark - whiteboard notify delegate

@protocol ZegoWhiteboardDelegate <NSObject>

@optional

/**
 有白板新增的通知
 
 @param whiteboardJson 新增白板的详细信息
 */
- (void)onAdded:(NSDictionary *)whiteboardJson;

/**
 有白板被删除的通知
 
 @param whiteboardId 被删除的白板 ID
 */
- (void)onRemoved:(unsigned long long)whiteboardId;

/**
 白板宽高比变化的通知
 
 @param aspectRatio 新的宽高比
 @param whiteboardId 白板 ID
 */
- (void)onAspectRatioChanged:(CGSize)aspectRatio
            whiteboardId:(unsigned long long)whiteboardId;


/**
 白板内容发生变化的通知
 
 @param content 内容
 @param whiteboardId 内容发生变化的白板 ID
 */
- (void)onContentChanged:(NSString *)content 
            whiteboardId:(unsigned long long)whiteboardId;


/**
 白板扩展信息发生变化的通知
 
 @param extra 扩展信息
 @param whiteboardId 扩展信息发生变化的白板 ID
 */
- (void)onExtraChanged:(NSString *)extra 
            whiteboardId:(unsigned long long)whiteboardId;

/**
 白板H5扩展信息追加的通知
 
 @param h5Extra 扩展信息
 @param whiteboardId 扩展信息发生变化的白板 ID
 */
- (void)onH5ExtraAppended:(NSString *)h5Extra 
            whiteboardId:(unsigned long long)whiteboardId;

/**
 白板画布发生滑动、滚动的通知
 
 @param horPercent 横向滚动的相对位置百分比（可以理解为滚动条Handle在滚动条Bar中的百分比）
 @param verPercent 纵向滚动的相对位置百分比
 @param whiteboardId 滚动、滑动的白板id（关联画布）
 @param pptStep 动态ppt步骤
 @note 可能只有一个方向的scroll值真正发生变化，界面层需过滤
 */
- (void)onCanvasHorizontalScrolled:(float)horPercent
                  verticalScrolled:(float)verPercent
						   pptStep:(unsigned int)pptStep
                      whiteboardId:(unsigned long long)whiteboardId;

@end


#pragma mark - whiteboard interface

@interface ZegoWhiteboard : NSObject

+ (id)sharedInstance;

/** 设置白板通知 delegate */
- (void)setDelegate:(id<ZegoWhiteboardDelegate>)delegate;

/**
 获取画布管理对象
 */
- (ZegoWhiteboardCanvas *)sharedCanvasManager;

/**
 初始化白板
 
 @note 该接口需要在LIVEROOM::InitSDK之后调用，在其他白板模块接口前调用
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)initWhiteboardWithCompletionBlock:(ZegoWhiteboardInitBlock)block;

/**
 反初始化白板
 
 @note 该接口需要在LIVEROOM::UnInitSDK之前调用
 */
- (void)unInitWhiteboard;

/**
 拉取已打开的白板列表
 
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)getListWithCompletionBlock:(ZegoWhiteboardGetListBlock)block;

/**
 创建新的白板
 
 @param whiteboardJson 白板数据
 {
     "mode": 1,                                   // 白板模式
     "name": “白板1”,                         // 白板名称
     "width": 1028,                             // 白板宽
     "height": 576,                             // 白板高
 }
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)create:(NSDictionary *)whiteboardJson
  completionBlock:(ZegoWhiteboardCreateBlock)block;

/**
 关闭指定白板
 
 @param whiteboardId 待关闭的白板 ID
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)destroy:(unsigned long long)whiteboardId
   completionBlock:(ZegoWhiteboardDestroyBlock)block;

/**
 设置指定白板对应view的当前实际内容尺寸
 
 @param size
 @param whiteboardId 待关闭的白板 ID
 @return 0成功，非0 失败
 */
- (int)resize:(CGSize)size whiteboardId:(unsigned long long)whiteboardId;

/**
设置指定白板对应view的可视区域尺寸
 
@param size
@param whiteboard_id 白板id
@return 错误码，0为成功
*/
- (int)setViewportSize:(CGSize)size whiteboardId:(unsigned long long)whiteboardId;


/**
 设置指定白板的内容
 
 @param content 内容
 @param whiteboardId 白板ID
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)setContent: (NSString *)content 
                whiteboardId: (unsigned long long)whiteboardId 
                completionBlock: (ZegoWhiteboardSetContentBlock)block;

/**
 设置指定白板的扩展信息
 
 @param extra 内容
 @param whiteboardId 白板ID
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)setExtra: (NSString *)extra 
            whiteboardId: (unsigned long long)whiteboardId 
            completionBlock: (ZegoWhiteboardSetExtraBlock)block;


/**
 追加指定白板H5的扩展信息
 
 @param h5Extra 内容
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
 @param whiteboardId 白板ID
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)appendH5Extra: (NSString *)h5Extra 
            whiteboardId: (unsigned long long)whiteboardId 
            completionBlock: (ZegoWhiteboardAppendH5ExtraBlock)block;

/**
 滚动、滑动白板画布（仅用于驱动界面层）
 
 @param horizontalPercent 横向滚动百分比
 @param verticalPercent 纵向滚动百分比
 @param whiteboardId 要滚动白板 ID
 @param pptStep 动态ppt步骤
 @return 0为调用失败，非0为请求序号
 */
- (unsigned int)scrollToHorizontalPercent:(CGFloat)horizontalPercent
                  verticalPercent:(CGFloat)verticalPercent
						  pptStep:(unsigned int)pptStep
                     whiteboardId:(unsigned long long)whiteboardId
                  completionBlock:(ZegoWhiteboardScrollCanvasBlock)block;
/**
根据滑动的百分比拉取最新的图元

@param horizontalPercent 水平百分比
@param verticalPercent 竖直百分比
@param whiteboardId 白板id
@return 0为调用失败，非0为请求序号
*/
- (void)loadGraphicsWithHorizontalPercent:(CGFloat)horizontalPercent
                               verticalPercent:(CGFloat)verticalPercent
                                  whiteboardId:(unsigned long long)whiteboardId;


/**
设置白板view版本号

@param version view版本号
*/
-(void)setWhiteboardViewVersion: (NSString *)version;

/**
返回 native 白板版本号

@return 路径
*/
-(NSString *)getWhiteboardVersion;


/**
设置缓存路径

@param directory 路径
@return 错误码
*/
-(unsigned int)setCacheDirectory: (NSString *)directory;

/**
返回缓存路径

@return 路径
*/
-(NSString *)getCacheDirectory;

/**
清空缓存
*/
-(void)clearCache;

/**
上传图片

@param address 本地路径
*/
-(unsigned int)uploadFile:(NSString *)address
				completionBlock : (ZegoWhiteboardUploadFileBlock)block;

/**
取消上传图片

@param seq 
*/
-(void)cancelUploadFile:(unsigned int)seq;


/**
下载图片

@param url url
@param hash 
*/
-(unsigned int)downloadFile:(NSString *)url
				filehash:(NSString *)hash
				imagetype:(int) type
				completionBlock : (ZegoWhiteboardDownloadFileBlock)block;

/**
取消下载图片

@param seq 
*/
-(void)cancelDownloadFile:(unsigned int)seq;

@end
