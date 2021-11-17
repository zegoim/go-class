//
//  zego-api-external-video-render.h
//

#ifndef zego_api_extrnal_video_render_h
#define zego_api_extrnal_video_render_h
#include "video_format.h"
#include "zego-api-defines.h"
#include "video_capture.h"

namespace ZEGO
{
    namespace EXTERNAL_RENDER
    {

        extern ZEGOAVKIT_API const char* kZegoVideoDataMainPublishingStream;
        extern ZEGOAVKIT_API const char* kZegoVideoDataAuxPublishingStream;

        enum VideoRenderType
        {
            /** 默认值, 不开外部渲染 */
            VIDEO_RENDER_TYPE_NONE = 0,
            /** 默认 BGRA32（Android 为 RGBA32）, 仅外部渲染，内部不渲染 */
            VIDEO_RENDER_TYPE_RGB = 1,
            /** 默认 I420。仅外部渲染，内部不渲染 */
            VIDEO_RENDER_TYPE_YUV = 2,
            /** 由返回参数指定类型。仅外部渲染，内部不渲染*/
            VIDEO_RENDER_TYPE_ANY = 3,
            /** 外部渲染同时内部渲染，且数据格式为 RGB。默认 BGRA32（Android 为 RGBA32） */
            VIDEO_RENDER_TYPE_EXTERNAL_INTERNAL_RGB = 4,
            /** 外部渲染同时内部渲染，且数据格式为 YUV。默认 I420 */
            VIDEO_RENDER_TYPE_EXTERNAL_INTERNAL_YUV = 5
        };

        /**
         * SDK 用于将接收到的待渲染视频帧数据回调给调用者
         */
        class IZegoVideoRenderCallback
        {
        public:
            /**
             视频帧数据回调
             @param pData 视频数据每个面的起始地址，共四个面
             @param dataLen 视频数据每个面的长度起始地址
             @param pszStreamID 流 ID，如果是本地预览数据，值为 kZegoVideoDataMainPublishingStream 或者 kZegoVideoDataAuxPublishingStream
             @param width 视频帧宽度
             @param height 视频帧高度
             @param strides 视频帧每个平面一行字节数
             @param pixel_format 视频帧数据格式
             */
            virtual void OnVideoRenderCallback(unsigned char **pData, int* dataLen, 
                                     const char* pszStreamID, 
                                     int width, int height, int strides[4],                                               
                                     AVE::VideoPixelFormat pixel_format) = 0;

            /**
             通知即将接收的帧数据是否需要翻转
             @param pszStreamID 流 ID，如果是本地预览数据，值为 kZegoVideoDataMainPublishingStream 或者 kZegoVideoDataAuxPublishingStream
             @param mode 翻转类型，参见 VideoFlipMode 定义
             @note 仅本地预览的外部渲染会回调。此处的 mode 是基于推流图像计算出来的，和 SetVideoMirrorMode 不一定一致，请基于 SetFlipMode 的参数决定是否翻转
             */
            virtual void SetFlipMode(const char* pszStreamID, int mode) = 0;

            /**
             通知即将接收的帧数据需要旋转的角度
             @param pszStreamID 流 ID，如果是本地预览数据，值为 kZegoVideoDataMainPublishingStream 或者 kZegoVideoDataAuxPublishingStream
             @param rotation 逆时针旋转角度
             */
            virtual void SetRotation(const char* pszStreamID, int rotation) = 0;

            virtual ~IZegoVideoRenderCallback() {}
        };

#if defined(TARGET_OS_IPHONE) || TARGET_OS_OSX
        /**
         SDK 将接收到的待渲染数据转成 CVPixelBuffer 数据回调给调用者，在 iOS/Mac 平台上可以减少内存拷贝，提升效率
         @note 仅在 iOS / Mac 平台上有效
         */
        class IZegoVideoRenderCVPixelBufferCallback
        {
        public:
            /**
             视频帧数据回调
             @param cv_pixel_buffer 待渲染的 CVPixelBuffer 数据
             @param pszStreamID  流 ID，如果是本地预览数据，值为 kZegoVideoDataMainPublishingStream 或者 kZegoVideoDataAuxPublishingStream
             */
            virtual void OnVideoRenderCallback(void* cv_pixel_buffer, const char* pszStreamID) = 0;
            
            /**
             通知即将接收的帧数据是否需要翻转
             @param pszStreamID 流 ID，如果是本地预览数据，值为 kZegoVideoDataMainPublishingStream 或者 kZegoVideoDataAuxPublishingStream
             @param mode 翻转类型，参见 VideoFlipMode 定义
             @note 仅本地预览的外部渲染会回调。此处的 mode 是基于推流图像计算出来的，和 SetVideoMirrorMode 不一定一致，请基于 SetFlipMode 的参数决定是否翻转
             */
            virtual void SetFlipMode(const char* pszStreamID, int mode) = 0;
          
            /**
             通知即将接收的帧数据需要旋转的角度
             @param pszStreamID 流 ID，如果是本地预览数据，值为 kZegoVideoDataMainPublishingStream 或者 kZegoVideoDataAuxPublishingStream
             @param rotation 逆时针旋转角度
             */
            virtual void SetRotation(const char* pszStreamID, int rotation) = 0;

            virtual ~IZegoVideoRenderCVPixelBufferCallback() {}
        };
#endif

        /**
         * SDK 用于将接收到的待渲染视频码流回调给调用者
         */
        class IZegoVideoDecodeCallback
        {
        public:
            /**
             * 视频码流数据回调
             * @param data 待解码码流数据起始地址
             * @param length 待解码码流数据长度
             * @param pszStreamID 流 ID
             * @param codec_config 视频码流附加信息
             * @param b_keyframe 是否关键帧
             * @param reference_time_ms 采集时间戳
             */
            virtual void OnVideoDecodeCallback(const unsigned char* data, int length,
                                       const char* pszStreamID, const AVE::VideoCodecConfig& codec_config,
                                       bool b_keyframe, double reference_time_ms) = 0;

            virtual ~IZegoVideoDecodeCallback() {}
        };

        /**
         设置当开启外部视频渲染时要求 SDK 提供的渲染方式（仅外部渲染或者内部外部同时渲染）及数据格式

         @param type 指定 SDK 提供的渲染方式及数据格式
         @note 在启动推/拉流 及 预览 前设置有效
         */
        ZEGOAVKIT_API void SetVideoRenderType(VideoRenderType type);

        /**
         设置外部视频渲染回调。App 通过此回调接收 SDK 提供的待渲染视频数据

         @param callback 外部渲染回调
         @note 启动拉流/预览前设置，确保所有拉流及预览已经停止 或 反初始化 SDK 之后才能置空，否则可能出现空指针异常
         */
        ZEGOAVKIT_API void SetVideoRenderCallback(IZegoVideoRenderCallback* callback);

#if defined(TARGET_OS_IPHONE) || TARGET_OS_OSX
        /**
         设置接收 CVPixelBuffer 类型数据的外部视频渲染回调。App 通过此回调接收 SDK 提供的待渲染 CVPixelBuffer 类型视频数据

         @param callback 外部渲染回调
         @note 启动拉流/预览前设置，确保所有拉流及预览已经停止 或 反初始化 SDK 之后才能置空，否则可能出现空指针异常
         @note 仅用于接收 CVPixelBuffer 类型的数据时用，内存数据请使用 SetVideoRenderCallback 或者 SetVideoDecodeCallback
         @note 仅在 iOS / Mac 平台上有效
         */
        ZEGOAVKIT_API void SetVideoRenderCVPixelBufferCallback(IZegoVideoRenderCVPixelBufferCallback* callback);
#endif

        /**
         设置外部视频解码回调。当调用该 API 设置了回调后，App 通过此回调接收 SDK 原始码流。

         @param callback 外部解码回调
         @note 启动拉流/预览前设置，中途不要随便置空；
         @note 当设置了此回调后，内部渲染与外部渲染都将无效，必须由 App 自己实现解码渲染。
         */
        ZEGOAVKIT_API void SetVideoDecodeCallback(IZegoVideoDecodeCallback* callback);

        /**
         设置是否开启/关闭外部视频渲染（拉流）
         
         @param pszStreamID 播放流ID
         @param bEnable true 开启， false 不开启，默认为不开启
         @note 只有当 VideoRenderType 设置为非 VIDEO_RENDER_TYPE_NONE 时，该接口才有效
         @note 在拉流(startPlayingStream)之后调用有效
         */
        ZEGOAVKIT_API bool EnableVideoRender(bool bEnable, const char *pszStreamID);
        
        /**
        设置是否开启/关闭外部视频渲染（拉流）

        @param nPlayChannel 播放通道
        @param bEnable true 开启， false 不开启，默认为不开启
        @note 只有当 VideoRenderType 设置为非 VIDEO_RENDER_TYPE_NONE 时，该接口才有效
        @note 在拉流(startPlayingStream)之后调用有效
        */
        ZEGOAVKIT_API bool EnableVideoRender(bool bEnable, int nPlayChannel);

        /**
        设置是否需要 SDK 将推流预览的数据抛出。当置为 true 时，SDK 通过 SetVideoRenderCallback 设置的接口将预览数据返回给 App

        @param bEnable true 开启， false 不开启，默认为不开启
        @param nPublishChannel 推流通道，默认为主通道
        @note 在启动预览(StartPreview)前调用有效
        */
        ZEGOAVKIT_API bool EnableVideoPreview(bool bEnable, AV::PublishChannelIndex nPublishChannel = AV::PUBLISH_CHN_MAIN);
    }
}

#endif /* zego_api_extrnal_video_render_h */
