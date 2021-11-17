//
//  zego-api-mediaplayer-defines.h
//  ZegoLiveRoom
//
//  Copyright © 2018年 Zego. All rights reserved.
//

#ifndef zego_api_mediaplayer_defines_h
#define zego_api_mediaplayer_defines_h

namespace ZEGO
{
namespace MEDIAPLAYER
{
        
    enum ZegoMediaPlayerType
    {
        ZegoMediaPlayerTypePlayer   = 0,
        ZegoMediaPlayerTypeAux      = 1
    };
    
    enum ZegoMediaPlayerVideoPixelFormat
    {
        ZegoMediaPlayerVideoPixelFormatUnknown  = 0,
        ZegoMediaPlayerVideoPixelFormatI420     = 1,
        ZegoMediaPlayerVideoPixelFormatNV12     = 2,
        ZegoMediaPlayerVideoPixelFormatNV21     = 3,
        ZegoMediaPlayerVideoPixelFormatBGRA32   = 4,
        ZegoMediaPlayerVideoPixelFormatRGBA32   = 5,
        ZegoMediaPlayerVideoPixelFormatARGB32   = 6,
        ZegoMediaPlayerVideoPixelFormatABGR32   = 7,
    };
    
    enum ZegoMediaPlayerIndex
    {
        ZegoMediaPlayerIndexFirst   = 0,
        ZegoMediaPlayerIndexSecond  = 1,
        ZegoMediaPlayerIndexThird   = 2,
        ZegoMediaPlayerIndexFourth  = 3,
    };
    
    enum ZegoMediaPlayerAudioChannel
    {
        ZegoMediaPlayerAudioChannelLeft  = 1,
        ZegoMediaPlayerAudioChannelRight = 2,
        ZegoMediaPlayerAudioChannelAll   = 3
    };

    /**
     媒体播放器错误码
     */
    enum ZegoMediaPlayerError
    {
        /** ok */
        ZegoMediaPlayerErrorOK = 0,
        /** 文件格式不支持 */
        ZegoMediaPlayerErrorFile = -1,
        /** 路径不存在 */
        ZegoMediaPlayerErrorPath = -2,
        /** 文件无法解码 */
        ZegoMediaPlayerErrorCodec = -3,
        /** 文件中没有可播放的音视频流 */
        ZegoMediaPlayerErrorNoSupportStream = -4,
        /** 文件解析过程中出现错误 */
        ZegoMediaPlayerErrorDemux = -5,
        /** 播放掉帧 */
        ZegoMediaPlayerErrorFrameDrop = -6,
        /** 加载资源超时 */
        ZegoMediaPlayerErrorLoadTimeout = -7
    };
    
    struct ZegoMediaPlayerVideoDataFormat
    {
        int width;
        int height;
        int strides[4];
        int rotation;
        ZegoMediaPlayerVideoPixelFormat pixelFormat;
        
        ZegoMediaPlayerVideoDataFormat()
        {
            width = 0;
            height = 0;
            strides[0] = strides[1] = strides[2] = strides[3] = 0;
            rotation = 0;
            pixelFormat = ZegoMediaPlayerVideoPixelFormatUnknown;
        }
        
        ZegoMediaPlayerVideoDataFormat(int width, int height, ZegoMediaPlayerVideoPixelFormat pixelFormat)
        {
            this->width = width;
            this->height = height;
            this->pixelFormat = pixelFormat;
            this->strides[0] = this->strides[1] = this->strides[2] = this->strides[3] = 0;
            this->rotation = 0;
        }
    };

    struct ZegoMediaPlayerHttpHeader
    {
        char szKey[512];
        char szValue[512];

        ZegoMediaPlayerHttpHeader()
        {
            szKey[0] = '\0';
            szValue[0] = '\0';
        }
    };

    
    class IZegoMediaPlayerEventWithIndexCallback
    {
    public:
        /**
         开始播放
         */
        virtual void OnPlayStart(ZegoMediaPlayerIndex index) = 0;
        /**
         播放出错
         @param errCode 错误码, 详见 ZegoMediaPlayerError
         */
        virtual void OnPlayError(const int errCode, ZegoMediaPlayerIndex index) = 0;
        /**
         视频开始播放
         */
        virtual void OnVideoBegin(ZegoMediaPlayerIndex index) {}
        /**
         音频开始播放
         */
        virtual void OnAudioBegin(ZegoMediaPlayerIndex index) {}
        /**
         播放结束
         */
        virtual void OnPlayEnd(ZegoMediaPlayerIndex index) = 0;
        /**
         快进到指定时刻
         
         @param state >=0 成功，其它表示失败
         @param duration 实际快进的进度，单位毫秒
         */
        virtual void OnSeekComplete(const int state, const long duration, ZegoMediaPlayerIndex index) {}
        /**
         暂停播放
         */
        virtual void OnPlayPause(ZegoMediaPlayerIndex index) {}
        /**
         恢复播放
         */
        virtual void OnPlayResume(ZegoMediaPlayerIndex index) {}
        /**
         主动停止播放
         */
        virtual void OnPlayStop(ZegoMediaPlayerIndex index) {}
        /**
         开始缓冲
         */
        virtual void OnBufferBegin(ZegoMediaPlayerIndex index) {}
        /**
         结束缓冲
         */
        virtual void OnBufferEnd(ZegoMediaPlayerIndex index) {}
        
        /**
         截图
         */
        virtual void OnSnapshot(void *image, ZegoMediaPlayerIndex index) {}
        
        /**
         调用 Load 接口的回调
         */
        virtual void OnLoadComplete(ZegoMediaPlayerIndex index) {}
        
        /**
         播放进度回调
         
         @param timestamp 当前播放进度，单位毫秒
         @param index   播放器序号
         */
        virtual void OnProcessInterval(long timestamp, ZegoMediaPlayerIndex index) {}

        /**
         网络文件读完结尾的回调
         */
        virtual void OnReadEOF(ZegoMediaPlayerIndex index) {}
    };
    
    /**
     * 视频帧数据回调接口, 带有播放器序号, 用于设置多实例播放器的回调
     * 当格式为ARGB32/ABGR32/RGBA32/BGRA32，数据通过OnPlayVideoData回调。
     * 当格式为I420/NV12/NV21，数据通过OnPlayVideoData2回调。
     * 其他非法格式都判定为I420
     */
    class IZegoMediaPlayerVideoDataWithIndexCallback
    {
    public:
        /**
         视频帧数据回调，格式为ARGB32/ABGR32/RGBA32/BGRA32
         
         @param data 视频帧数据
         @param len 视频帧数据长度
         @param format 视频帧格式信息
         @param index 播放器序号
         @note 同步回调，不要在回调中处理数据或进行耗时操作
         */
        virtual void OnPlayVideoData(const char* data, int len, ZegoMediaPlayerVideoDataFormat& format, ZegoMediaPlayerIndex index) {}
        
        /**
         视频帧数据回调，格式为I420/NV12/NV21
         
         @param pData 视频帧数据
         @param len 视频帧数据长度
         @param format 视频帧格式信息
         @param index 播放器序号
         @note 同步回调，不要在回调中处理数据或进行耗时操作
         */
        virtual void OnPlayVideoData2(const char **pData, int* len, ZegoMediaPlayerVideoDataFormat& format, ZegoMediaPlayerIndex index) {}
    };

    /**
     * 音频数据回调
     */
    class IZegoMediaPlayerAudioDataCallback
    {
    public:
        /**
         播放器将解码后的音频数据回调出来，SDK 会同步等待调用者修改完毕，再将修改后的音频数据与当前流混流。

         @param data 解码后的 pcm 音频数据
         @param length  数据长度
         @param sample_rate 采样率
         @param channels 通道数（单通道还是双通道）
         @param bit_depth 位深
         @parma index 播放器序号
         @note 同步回调
         @note 调用者应直接修改此段内存中的数据 
         */
        virtual void OnPlayAudioData(unsigned char *const data, int length, int sample_rate, int channels, int bit_depth, ZegoMediaPlayerIndex index) = 0;
    };

    /**
     播放文件的 SEI 信息回调
     */
    class IZegoMediaPlayerMediaSideInfoCallback
    {
    public:
        /**
         播放文件的 SEI 信息回调
         
         @param data 数据
         @param length 数据长度
         @param index 播放器序号
         */
        virtual void OnMediaSideInfo(const unsigned char *data, int length, ZegoMediaPlayerIndex index) = 0;
    };
    
}   // MEDIAPLAYER
}   // ZEGO


#endif /* zego_api_mediaplayer_defines_h */
