//
//  zego-api-defines.h
//  zegoavkit
//
//  Copyright © 2017年 Zego. All rights reserved.
//

#ifndef zego_api_defines_h
#define zego_api_defines_h


#define ZEGO_MAX_COMMON_LEN         (512)
#define ZEGO_MAX_URL_COUNT          (10)
#define ZEGO_MAX_EVENT_INFO_COUNT   (10)
#define ZEGO_MAX_MIX_INPUT_COUNT    (12)
#define ZEGO_MAX_IDENTITY_LEN       (64)
#define ZEGO_MAX_ROOMMESSAGE_LEN (1024)

#define ZEGO_MAX_USERID_LEN         (64)
#define ZEGO_MAX_USERNAME_LEN       (256)
#define ZEGO_MAX_EXTRA_INFO_LEN     (1024)
#define ZEGO_DEFAULT_LOG_SIZE       (5242880)     // 5 * 1024 * 1024 bytes, default size for single log file
#define ZEGO_MIN_LOG_SIZE           (1048576)     // 1 * 1024 * 1024 bytes, min size for single log file
#define ZEGO_MAX_LOG_SIZE           (104857600)   // 100 * 1024 * 1024 bytes, max size for single log file

#define ZEGO_MAX_ROOM_EXTRA_INFO_KEY_LEN (128)
#define ZEGO_MAX_ROOM_EXTRA_INFO_VALUE_LEN (4096)

#if defined(_MSC_VER) || defined(__BORLANDC__)
#	define _I64_				"I64"
#	define _64u_				"%I64u"
#	define _I64uw_				L"%llu"L
#	define _i64uw_				L"%llu"L
#else
#	define _I64_				"ll"
#	define _64u_				"%llu"
#	define _I64uw_				L"%llu" L
#	define _i64uw_				L"%llu" L
#	define __int64				long long
#endif

#ifdef WIN32

    #ifdef ZEGOAVKIT_EXPORTS
        #define ZEGOAVKIT_API __declspec(dllexport)
    #elif defined(ZEGOAVKIT_STATIC)
        #define ZEGOAVKIT_API // * nothing
    #else
        #define ZEGOAVKIT_API __declspec(dllimport)
    #endif

#else

    #define ZEGOAVKIT_API __attribute__((visibility("default")))

#endif

#define ZEGO_DEPRECATED     ///< 废弃标记

#include <stddef.h>

namespace ZEGO
{
    namespace AV
    {
        enum RemoteViewIndex
        {
            RemoteViewIndex_First = 0,
            RemoteViewIndex_Second = 1,
            RemoteViewIndex_Third = 2,
        };
        
        enum ZegoVideoViewMode
        {
            ZegoVideoViewModeScaleAspectFit = 0,    ///< 等比缩放，可能有黑边
            ZegoVideoViewModeScaleAspectFill = 1,   ///< 等比缩放填充整View，可能有部分被裁减
            ZegoVideoViewModeScaleToFill = 2,       ///< 填充整个View
        };
        
        enum ZegoVideoMirrorMode
        {
            ZegoVideoMirrorModePreviewMirrorPublishNoMirror = 0,  ///< 预览启用镜像，推流不启用镜像
            ZegoVideoMirrorModePreviewCaptureBothMirror = 1,      ///< 预览启用镜像，推流启用镜像
            ZegoVideoMirrorModePreviewCaptureBothNoMirror = 2,    ///< 预览不启用镜像，推流不启用镜像
            ZegoVideoMirrorModePreviewNoMirrorPublishMirror = 3   ///< 预览不启用镜像，推流启用镜像
        };

        enum ZegoVideoCodecAvc
        {
            VIDEO_CODEC_DEFAULT = 0, ///< 默认编码,不支持分层编码
            VIDEO_CODEC_MULTILAYER = 1, ///< 分层编码 要达到和VIDEO_CODEC_DEFAULT相同的编码质量，建议码率和VIDEO_CODEC_DEFAULT相比增加20%左右
            VIDEO_CODEC_VP8 = 2,    ///< VP8编码
            VIDEO_CODEC_H265 = 3,   ///< H265

        };

        
        /** 音频设备类型 */
        enum AudioDeviceType
        {
            AudioDevice_Input = 0,      /**< 输入设备 */
            AudioDevice_Output,         /**< 输出设备 */
        };
        
		enum MixSysPlayoutPropertyMask
		{
			MIX_PROP_NONE = 0,
			MIX_PROP_ENABLE_AGC_FOR_SYS_PLAYOUT = 1, //当开启采集系统声卡声音时，传递此参数启用自动增益(仅支持win) 
		};

        struct DeviceInfo
        {
            char szDeviceId[ZEGO_MAX_COMMON_LEN];
            char szDeviceName[ZEGO_MAX_COMMON_LEN];

            DeviceInfo()
            {
                szDeviceId[0] = '\0';
                szDeviceName[0] = '\0';
            }
        };
        
        struct DeviceVideoCapabilityInfo
        {
            int height;
            int width;
            int fps;

            DeviceVideoCapabilityInfo()
            {
                height = 0;
                width = 0;
                fps = 0;
            }
        };

        /** 设备状态 */
        enum DeviceState
        {
            Device_Added = 0,           /**< 添加设备 */
            Device_Deleted,             /**< 删除设备 */
        };
        
        enum DeviceStatus
        {
            Device_Opened = 0,          /**< 设备已打开 */
            Device_Closed,              /**< 设备已关闭 */
        };
        
        /** 音量类型 */
        enum VolumeType
        {
            Volume_EndPoint = 0,        /**< 设备音量 */
            Volume_Simple,              /**< App 音量 */
        };
        
        struct ZegoUser
        {
            char szId[ZEGO_MAX_COMMON_LEN];
            char szName[ZEGO_MAX_COMMON_LEN];

            ZegoUser() 
            {
                szId[0] = '\0';
                szName[0] = '\0';
            }
        };
        
        struct ZegoStreamInfo
        {
            ZegoStreamInfo()
            {
                uiRtmpURLCount = 0;
                uiHlsURLCount = 0;
                uiFlvURLCount = 0;
                szStreamID[0] = '\0';
                szMixStreamID[0] = '\0';
                for (int i = 0; i < ZEGO_MAX_URL_COUNT; i++)
                {
                    arrRtmpURLs[i] = NULL;
                    arrFlvRULs[i] =NULL;
                    arrHlsURLs[i] = NULL;
                }
            }

            /**
             混流流 ID
             */
            char szStreamID[ZEGO_MAX_COMMON_LEN];
            /**
             混流任务 ID，与 OnMixStreamEx() 回调中的 pszMixStreamID 参数一致
             */
            char szMixStreamID[ZEGO_MAX_COMMON_LEN];
            /**
             RTMP 播放 URL 列表
             */
            char* arrRtmpURLs[ZEGO_MAX_URL_COUNT];
            /**
             RTMP URL 个数
             */
            unsigned int uiRtmpURLCount;
            /**
             Flv 播放 URL 列表
             */
            char* arrFlvRULs[ZEGO_MAX_URL_COUNT];
            /**
             Flv URL 个数
             */
            unsigned int uiFlvURLCount;
            /**
             Hls 播放 URL 列表
             */
            char* arrHlsURLs[ZEGO_MAX_URL_COUNT];
            /**
             Hls URL 个数
             */
            unsigned int uiHlsURLCount;
        };
        
        /** 转推CDN状态 */
        enum ZegoStreamRelayCDNState
        {
            RELAY_STOP = 0,                 /**< 转推停止 */
            RELAY_START = 1,                /**< 正在转推 */
            RELAY_RETRY = 2,                /**< 正在重试 */
        };
        
        enum ZegoStreamRelayCDNDetail
        {
            Relay_None = 0,                         ///< 无
            Relay_ServerError = 8,                  ///< 服务器错误
            Relay_HandShakeFailed = 9,              ///< 握手失败
            Relay_AccessPointError = 10,            ///< 接入点错误
            Relay_CreateStreamFailed = 11,          ///< 创建流失败
            Relay_BadName = 12,                     ///< BAD NAME
            Relay_CDNServerDisconnected = 13,       ///< CDN服务器主动断开
            Relay_Disconnected = 14,                ///< 主动断开
            
            MixStream_AllInputStreamClosed = 1214,   ///< 混流输入流会话关闭, 混流转推CDN时有效
            MixStream_AllInputStreamNoData = 1215,  ///< 混流输入流全部没有数据, 混流转推CDN时有效
            MixStream_ServerInternalError = 1230,   ///< 混流服务器内部错误，混流转推CDN时有效
        };
        
        struct ZegoStreamRelayCDNInfo
        {
            ZegoStreamRelayCDNInfo()
            {
                rtmpURL[0] = '\0';
                state = RELAY_STOP;
                stateTime = 0;
                detail = Relay_None;
            }
            
            char rtmpURL[ZEGO_MAX_COMMON_LEN];
            ZegoStreamRelayCDNState state;
            ZegoStreamRelayCDNDetail detail;   //转推停止或重试时有效
            unsigned int stateTime;
        };
        
        /** 网络类型 */
        enum ZEGONetType
        {
            /** 无网络 */
            ZEGO_NT_NONE = 0,
            /** 网线 */
            ZEGO_NT_LINE = 1,
            /** WIFI */
            ZEGO_NT_WIFI = 2,
            /** 2G */
            ZEGO_NT_2G = 3,
            /** 3G */
            ZEGO_NT_3G = 4,
            /** 4G */
            ZEGO_NT_4G = 5,
            /** 5G */
            ZEGO_NT_5G = 6,
            /** 未知类型 */
            ZEGO_NT_UNKNOWN = 32
        };
        
        enum ZegoPublishFlag
        {
            ZEGO_JOIN_PUBLISH   = 0,        ///< 连麦
            ZEGO_MIX_STREAM     = 1 << 1,   ///< 混流，如果推出的流需要作为混流输入，请用这个模式
            ZEGO_SINGLE_ANCHOR  = 1 << 2,   ///< 单主播
        };
        
		enum ZegoTaskType
		{
			TASK_NORMAL = 1, //正常任务
			TASK_DELAY = 2, //延时类任务(如定时器任务)
		};

        /// \brief 混流图层信息
        struct ZegoMixStreamConfig
        {
            char szStreamID[ZEGO_MAX_COMMON_LEN];   ///< 混流ID
            struct
            {
                int top;
                int left;
                int bottom;
                int right;
            } layout;
            unsigned int uSoundLevelID;             ///< 音浪ID，用于标识用户，注意大小是32位无符号数
            int nContentControl;                    ///< 推流内容控制，0表示音视频都要，1表示只要音频，2表示只要视频。默认值：0。
            int nVolume;                            ///< 输入流音量, 有效值范围 [0, 200], 默认值 100
            
            ZegoMixStreamConfig ()
            : uSoundLevelID(0)
            , nContentControl(0)
            , nVolume(100)
            {
                szStreamID[0] = '\0';
                layout.top = 0;
                layout.left = 0;
                layout.bottom = 0;
                layout.right = 0;
            }
            /**
             *  原点在左上角，top/bottom/left/right 定义如下：
             *
             *  (left, top)-----------------------
             *  |                                |
             *  |                                |
             *  |                                |
             *  |                                |
             *  -------------------(right, bottom)
             */
        };
        
        
        /** 完整混流配置 */
        struct ZegoCompleteMixStreamConfig
        {
            char szOutputStream[ZEGO_MAX_COMMON_LEN];   /**< 输出流名或 URL，参见 bOutputIsUrl */
            bool bOutputIsUrl;                          /**< true: szOutputStream 为完整 RTMP URL，false: szOutputStream 为流名 */
            
            int nOutputFps;                             /**< 混流输出帧率 */
            int nOutputBitrate;                         /**< 混流输出码率 */
            int nOutputAudioBitrate;                    /**< 混流输出音频码率 */
            
            int nOutputWidth;                           /**< 混流输出视频分辨率宽 */
            int nOutputHeight;                          /**< 混流输出视频分辨率高 */
            
            int nOutputAudioConfig;                     /**< 混流输出音频格式 */
            
            ZegoMixStreamConfig* pInputStreamList;      /**< 混流输入流列表 */
            int nInputStreamCount;                      /**< 混流输入流列表个数 */
            
            const unsigned char * pUserData;            /**< 用户自定义数据 */
            int nLenOfUserData;                         /**< 用户自定义数据的长度 */
            
            int nChannels;                              /**< 混流声道数，默认为单声道 */
            
            int nOutputBackgroundColor;                 /**< 混流背景颜色，前三个字节为 RGB 颜色值，即 0xRRGGBBxx */
            const char* pOutputBackgroundImage;         /**< 混流背景图，支持预设图片，如 (preset-id://xxx) */
            
            bool bWithSoundLevel;                       /**< 是否开启音浪。true：开启，false：关闭 */
            
            int nExtra;                                 /**< 扩展信息，备用 */
            
            ZegoCompleteMixStreamConfig ()
            : bOutputIsUrl(false)
            , nOutputFps(0)
            , nOutputBitrate(0)
            , nOutputAudioBitrate(0)
            , nOutputWidth(0)
            , nOutputHeight(0)
            , nOutputAudioConfig(0)
            , pInputStreamList(0)
            , nInputStreamCount(0)
            , pUserData(0)
            , nLenOfUserData(0)
            , nChannels(1)
            , nOutputBackgroundColor(0x00000000)
            , pOutputBackgroundImage(0)
            , bWithSoundLevel(false)
            , nExtra(0)
            {
                szOutputStream[0] = '\0';
            }
        };
        
        /**
         混流结果信息
         */
        struct ZegoMixStreamResult
        {
            /**
             错误码，0 表示混流启动成功，此时 oStreamInfo 参数中的信息有效；非 0 表示混流启动失败。
             */
            unsigned int uiErrorCode;
            /**
             不存在的输入流个数
             */
            int nNonExistsStreamCount;
            /**
             不存在的输入流 ID 列表
             */
            const char* ppNonExistsStreamIDList[ZEGO_MAX_MIX_INPUT_COUNT];
            /**
             输出混流的播放信息
             */
            ZegoStreamInfo oStreamInfo;
            
            ZegoMixStreamResult()
            : uiErrorCode(0)
            , nNonExistsStreamCount(0)
            {
                for (int i = 0; i < ZEGO_MAX_MIX_INPUT_COUNT; i++)
                {
                    ppNonExistsStreamIDList[i] = NULL;
                }
            }
        };
        
        /** 混流结果消息扩展 */
        struct ZegoMixStreamResultEx
        {
            /**
             错误码，0 表示混流启动成功，此时 oStreamInfo 参数中的信息有效；非 0 表示混流启动失败。
             */
            unsigned int uiErrorCode;
            /**
             不存在的输入流个数
             */
            int nNonExistsStreamCount;
            /**
             不存在的输入流 ID 列表
             */
            const char* ppNonExistsStreamIDList[ZEGO_MAX_MIX_INPUT_COUNT];
            /**
             混流输出流个数
             */
            int nStreamInfoCount;
            /**
             混流输出列表
             */
            ZegoStreamInfo *pStreamInfoList;
            
            ZegoMixStreamResultEx()
            : uiErrorCode(0)
            , nNonExistsStreamCount(0)
            , nStreamInfoCount(0)
            , pStreamInfoList(0)
            {
                for (int i = 0; i < ZEGO_MAX_MIX_INPUT_COUNT; i++)
                {
                    ppNonExistsStreamIDList[i] = NULL;
                }
            }
        };
        
        enum ZegoLogLevel
        {
            Grievous = 0,
            Error = 1,
            Warning = 2,
            Generic = 3,    ///< 通常在发布产品中使用
            Debug = 4       ///< 调试阶段使用
        };
        
        
        /** SDK 事件通知 */
        enum EventType
        {
            Play_BeginRetry = 1,        /**< 开始重试拉流 */
            Play_RetrySuccess = 2,      /**< 重试拉流成功 */
            
            Publish_BeginRetry = 3,     /**< 开始重试推流 */
            Publish_RetrySuccess = 4,   /**< 重试推流成功 */
            
            Play_TempDisconnected = 5,     /**< 拉流临时中断 */
            Publish_TempDisconnected = 6,  /**< 推流临时中断 */
            
            Play_VideoBreak = 7,           /**< 视频卡顿开始 */
            Play_VideoBreakEnd = 8,        /**< 视频卡顿结束 */
            Play_VideoBreakCancel = 13,    /**< 视频卡顿取消 */
            
            Play_AudioBreak = 9,           /**< 音频卡顿开始 */
            Play_AudioBreakEnd = 10,       /**< 音频卡顿结束 */
            Play_AudioBreakCancel = 14,    /**< 音频卡顿取消 */

            PublishInfo_RegisterFailed = 11,   /**< 注册推流信息失败 */
            PublishInfo_RegisterSuccess = 12, /**< 注册推流信息成功 */
        };
        
        struct EventInfo
        {
            unsigned int uiInfoCount;
            const char* arrKeys[ZEGO_MAX_EVENT_INFO_COUNT];
            const char* arrValues[ZEGO_MAX_EVENT_INFO_COUNT];

            EventInfo()
            : uiInfoCount(0)
            {
                for (int i = 0; i < ZEGO_MAX_EVENT_INFO_COUNT; i++)
                {
                    arrKeys[i] = NULL;
                    arrValues[i] = NULL;
                }
            }
        };
        
#if defined(WIN32) || defined(ANDROID)
        ZEGOAVKIT_API extern const char* kZegoDeviceCamera;
        ZEGOAVKIT_API extern const char* kZegoDeviceMicrophone;
        ZEGOAVKIT_API extern const char* kZegoStreamID;
#else
        extern const char* kZegoDeviceCamera;
        extern const char* kZegoDeviceMicrophone;
        extern const char* kZegoStreamID;
#endif
        
        /** 视频编码码率控制策略 */
        enum ZegoVideoEncoderRateControlStrategy
        {
            ZEGO_RC_ABR,                /**< 平均码率 */
            ZEGO_RC_CBR,                /**< 恒定码率 */
            ZEGO_RC_VBR,                /**< 可变码率 */
            ZEGO_RC_CRF,                /**< 恒定质量 */
        };
        
        /** 视频采集缩放时机 */
        enum ZegoCapturePipelineScaleMode
        {
            ZegoCapturePipelinePreScale = 0,        /**< 采集后立即进行缩放，默认 */
            ZegoCapturePipelinePostScale = 1,       /**< 编码时进行缩放 */
        };
        
        /** 音频设备模式 */
        enum ZegoAVAPIAudioDeviceMode
        {
            ZEGO_AUDIO_DEVICE_MODE_COMMUNICATION = 1,    /**< 开启系统回声消除 */
            ZEGO_AUDIO_DEVICE_MODE_GENERAL = 2,          /**< 关闭系统回声消除 */
            ZEGO_AUDIO_DEVICE_MODE_AUTO = 3,             /**< 根据场景自动选择是否开启系统回声消除 */
            ZEGO_AUDIO_DEVICE_MODE_COMMUNICATION2 = 4,   /**< 开启系统回声消除，与 ZEGO_AUDIO_DEVICE_MODE_COMMUNICATION 相比，该模式会始终占用麦克风设备 */
            ZEGO_AUDIO_DEVICE_MODE_COMMUNICATION3 = 5,   /**< 开启系统回声消除，与 ZEGO_AUDIO_DEVICE_MODE_COMMUNICATION 相比，该模式下麦后释放麦克风，切回媒体音量 */
            ZEGO_AUDIO_DEVICE_MODE_GENERAL2 = 6,                /*关闭系统回声消除  与ZEGO_AUDIO_DEVICE_MODE_GENERAL 相比 该模式使用麦克风设备后不会释放 */
        };
        
        /** 延迟模式 */
        enum ZegoAVAPILatencyMode
        {
            ZEGO_LATENCY_MODE_NORMAL = 0,               /**< 普通延迟模式 */
            ZEGO_LATENCY_MODE_LOW,                      /**< 低延迟模式，无法用于 RTMP 流 */
            ZEGO_LATENCY_MODE_NORMAL2,                  /**< 普通延迟模式，最高码率可达 192K */
            ZEGO_LATENCY_MODE_LOW2,                     /**< 低延迟模式，无法用于 RTMP 流。相对于 ZEGO_LATENCY_MODE_LOW 而言，CPU 开销稍低 */
            ZEGO_LATENCY_MODE_LOW3,                     /**< 低延迟模式，无法用于 RTMP 流。支持WebRTC必须使用此模式 */
            ZEGO_LATENCY_MODE_NORMAL3,                  /**< 普通延迟模式，使用此模式前先咨询即构技术支持 */
        };
        
        /** 流量控制属性 */
        enum ZegoTrafficControlProperty
        {
            /**< 基本流量控制，只有码率控制，不带自适应帧率和分辨率 */
            ZEGO_TRAFFIC_CONTROL_BASIC = 0,
            /**< 自适应帧率 */
            ZEGO_TRAFFIC_CONTROL_ADAPTIVE_FPS = 1,
            /**< 自适应分辨率 */
            ZEGO_TRAFFIC_CONTROL_ADAPTIVE_RESOLUTION = 1 << 1,
            
            /**< 音频流量控制*/
            ZEGO_TRAFFIC_CONTROL_ADAPTIVE_AUDIO_BITRATE = 1 << 2,
            
            /**< 废弃 */
            ZEGO_TRAFFIC_NONE = ZEGO_TRAFFIC_CONTROL_BASIC,
            ZEGO_TRAFFIC_FPS = ZEGO_TRAFFIC_CONTROL_ADAPTIVE_FPS,
            ZEGO_TRAFFIC_RESOLUTION = ZEGO_TRAFFIC_CONTROL_ADAPTIVE_RESOLUTION,
        };
        
        enum ZegoTrafficControlMinVideoBitrateMode
        {
            /** 低于设置的最低码率时，停止视频发送 */
            ZEGO_TRAFFIC_CONTROL_MIN_VIDEO_BITRATE_NO_VIDEO = 0,
            /** 低于设置的最低码率时，视频以极低的频率发送 （不超过3FPS) */
            ZEGO_TRAFFIC_CONTROL_MIN_VIDEO_BITRATE_ULTRA_LOW_FPS
        };
        
        /** 音频录制类型 */
        enum ZegoAVAPIAudioRecordMask
        {
            ZEGO_AUDIO_RECORD_NONE      = 0x0,  /**< 关闭音频录制 */
            ZEGO_AUDIO_RECORD_CAP       = 0x01, /**< 打开采集录制 */
            ZEGO_AUDIO_RECORD_RENDER    = 0x02, /**< 打开渲染录制 */
            ZEGO_AUDIO_RECORD_MIX       = 0x04  /**< 打开采集和渲染混音结果录制 */
        };
        
        enum LiveStreamQuality
        {
            Excellent   = 0,
            Good        = 1,
            Middle      = 2,
            Poor        = 3,
            Die         = 4,
            MaxGrade,
        };
        
        struct PublishQuality
        {
            double cfps;            ///< 视频帧率(采集)
            double vencFps;         ///< 视频帧率(编码)
            double fps;             ///< 视频帧率(网络发送)
            double kbps;            ///< 视频码率(kb/s)
          
            double acapFps;         ///< 音频帧率（采集）
            double afps;            ///< 音频帧率（网络发送）
            double akbps;           ///< 音频码率(kb/s)
            
            int rtt;                ///< 延时(ms)
            int pktLostRate;        ///< 丢包率(0~255)
            int quality;            ///< 质量(0~3)
            
            bool isHardwareVenc;    ///< 是否硬编
            int videoCodecId;       ///< 视频编码格式(参考ZegoVideoCodecAvc)
            int width;              ///< 视频宽度
            int height;             ///< 视频高度

            double totalBytes;      ///< 已发送的总字节数，包括音频、视频及媒体次要信息等
            double audioBytes;      ///< 已发送的音频字节数
            double videoBytes;      ///< 已发送的视频字节数
            
            double cpuAppUsage;     ///< 当前 APP 的 CPU 使用率
            double cpuTotalUsage;   ///< 当前系统的 CPU 使用率
            
            double memoryAppUsage;     ///< 当前 APP 的内存使用率
            double memoryTotalUsage;   ///< 当前系统的内存使用率
            double memoryAppUsed;      ///< 当前 APP 的内存使用量,单位 MB

            PublishQuality()
            {
                cfps = 0;
                vencFps = 0;
                fps = 0;
                kbps = 0;

                acapFps = 0;
                afps = 0;
                akbps = 0;

                rtt = 0;
                pktLostRate = 0;
                quality = 0;

                isHardwareVenc = false;
                videoCodecId = 0;
                width = 0;
                height = 0;

                totalBytes = 0;
                audioBytes = 0;
                videoBytes = 0;

                cpuAppUsage = 0;
                cpuTotalUsage = 0;

                memoryAppUsage = 0;
                memoryTotalUsage = 0;
                memoryAppUsed = 0;
            }
        };
        
        struct PlayQuality
        {
            double fps;                     ///< 视频帧率(网络接收)
            double vdjFps;                  ///< 视频帧率(dejitter)
            double vdecFps;                 ///< 视频帧率(解码)
            double vrndFps;                 ///< 视频帧率(渲染)
            double kbps;                    ///< 视频码率(kb/s)
            
            double afps;                    ///< 音频帧率(网络接收)
            double adjFps;                  ///< 音频帧率(dejitter)
            double adecFps;                 ///< 音频帧率(解码)
            double arndFps;                 ///< 音频帧率(渲染)
            double akbps;                   ///< 音频码率(kb/s)
            
            double audioBreakRate;          ///< 音频卡顿次数
            double videoBreakRate;          ///< 视频卡顿次数
            int rtt;                        ///< 延时(ms)
            int pktLostRate;                ///< 丢包率(0~255)
            int peerToPeerDelay;            ///< 端到端延迟
            int peerToPeerPktLostRate;      ///< 端到端丢包率(0~255)
            int quality;                    ///< 质量(0~3)
            int delay;                      ///< 语音延迟(ms)
            
            bool isHardwareVdec;            ///< 是否硬解
            int videoCodecId;               ///< 视频解码格式(参考ZegoVideoCodecAvc)
            int width;                      ///< 视频宽度
            int height;                     ///< 视频高度

            double totalBytes;         ///< 已接收的总字节数，包括音频、视频及媒体次要信息等
            double audioBytes;         ///< 已接收的音频字节数
            double videoBytes;         ///< 已接收的视频字节数
            
            double cpuAppUsage;        ///< 当前 APP 的 CPU 使用率
            double cpuTotalUsage;      ///< 当前系统的 CPU 使用率
            
            double memoryAppUsage;         ///< 当前 APP 的内存使用率
            double memoryTotalUsage;       ///< 当前系统的内存使用率
            double memoryAppUsed;          ///< 当前 APP 的内存使用量,单位 MB
            int avTimestampDiff;       ///< 音画不同步, 单位毫秒, 小于0表示视频超前音频的毫秒数, 大于0表示视频滞后音频的毫秒数, 等于0表示无差别. 当绝对值小于200，可基本认为音画同步，当绝对值连续10秒大于200可以认为异常
            

            PlayQuality()
            {
                fps = 0;                  
                vdjFps = 0;               
                vdecFps = 0;              
                vrndFps = 0;              
                kbps = 0;                 
                     
                afps = 0;                 
                adjFps = 0;               
                adecFps = 0;              
                arndFps = 0;              
                akbps = 0;                
                     
                audioBreakRate = 0;       
                videoBreakRate = 0;       
                rtt = 0;                     
                pktLostRate = 0;             
                peerToPeerDelay = 0;         
                peerToPeerPktLostRate = 0;   
                quality = 0;                 
                delay = 0;                   
                        
                isHardwareVdec = false; 
                videoCodecId = 0;
                width = 0;                   
                height = 0;  

                totalBytes = 0;      
                audioBytes = 0;      
                videoBytes = 0;      
                     
                cpuAppUsage = 0;     
                cpuTotalUsage = 0;   
                     
                memoryAppUsage = 0;  
                memoryTotalUsage = 0;
                memoryAppUsed = 0;
                
                avTimestampDiff = 0;
            }
        };
        
        /** 推流通道 */
        enum PublishChannelIndex
        {
            PUBLISH_CHN_MAIN = 0,                       /**< 主推流通道，默认 */
            PUBLISH_CHN_AUX,                            /**< 第二路推流通道，默认没有声音，需要指定音频源。 */
        };
        
        /** 视频分层类型 */
        enum VideoStreamLayer
        {
            VideoStreamLayer_Auto = -1,            /**< 根据网络状态选择图层  */
            VideoStreamLayer_BaseLayer = 0,        /**< 指定拉基本层（小分辨率） */
            VideoStreamLayer_ExtendLayer = 1       /**< 指定拉扩展层（大分辨率)  */
        };
        
        /**
         MediaInfo 类型
         */
        enum MediaInfoType
        {
            /**
             ZEGO 定义的打包类型，跟视频编码器产生的信息不存兼容性问题。
             <br>但是在其它 CDN 上转码视频的时候，其它 CDN 基本上不支持提取这种方式打包的信息数据，转码完成后再从其它 CDN 拉流时，可能就丢失了这些次媒体信息。
             <br>ZEGO CDN 转码支持提取此种方式打包的信息数据。
             */
            SideInfoZegoDefined = 0,
            /**
             采用 H264 的 SEI (nalu type = 6,payload type = 243) 类型打包，此类型是 SEI 标准未规定的类型，跟视频编码器或者视频文件中的 SEI 不存在冲突性，用户不需要根据 SEI 的内容做过滤。
             <br>若需要发送 SEI 推荐采用此种类型。
             */
            SeiZegoDefined = 1,
            /**
             采用 H264 的 SEI (nalu type = 6,payload type = 5) 类型打包，H264 标准对于此类型有规定的格式：startcode + nalu type(6) + payload type(5) + len + pay load(uuid + context)+ trailing bits；
             
             <br>因为视频编码器自身会产生 payload type 为 5 的 SEI，或者使用视频文件推流时，视频文件中也可能存在这样的 SEI，所以使用此类型时，用户需要把 uuid + context 当作一段 buffer 塞给次媒体的发送接口；
             
             <br>为了区别视频编码器自身产生的 SEI，所以对 uuid 有格式要求，即 uuid 16字节的前四个字节固定为 'Z' 'E' 'G' 'O' 四个字符（全部大写），后面12字节用户任意填写；
             
             <br>在 SDK 接收端，对于 payload type = 5的 SEI 会根据'ZEGO'字样做过滤，识别出符合要求的 SEI 抛给用户，避免用户收到编码器自身产生的 SEI。
             */
            SeiUserUnregisted = 2
        };

        /**
         SEI发送类型
         */
        enum SeiSendType
        {
            /**
             SEI 单帧发送，此种发送方式下，ffmpeg 解码会产生类似“此帧无视频”的警告，可能会导致一些 CDN 兼容性问题，例如转码失败等。
             */
            SeiSendSingleFrame = 0,
            /**
             SEI 随视频帧(I, B, P)发送，推荐采用此类型。
             */
            SeiSendInVideoFrame = 1           
        };
        
        struct SoundLevelInfo
        {
            /**
             音浪ID，用于标识流.
             手动混流时, 对应于输入流信息中的 soundLevelID 字段.
             自动混流时, 对应于房间流信息中的 streamNID 字段.
             */
            unsigned int soundLevelID;
            /**
             音量level
             */
            unsigned char soundLevel;

            SoundLevelInfo()
            {
                soundLevelID = 0;
                soundLevel = 0;
            }           
        };
        
        /** 回声消除模式 */
        enum ZegoAECMode
        {
            /**
             激进模式
             */
            AEC_MODE_AGGRESSIVE,
            /**
             中等模式
             */
            AEC_MODE_MEDIUM,
            /**
             轻度模式
             */
            AEC_MODE_SOFT
        };

        enum ZegoANSMode
        {
            /**
             * 轻度模式
             */
            ANS_MODE_LOW = 0,
            /**
             * 中等模式
             */
            ANS_MODE_MEDIUM = 1,
            /**
             * 激进模式
             */
            ANS_MODE_HIGH = 2,
        };
        
        /** 设备错误码 */
        enum ZegoDeviceErrorCode
        {
            /**
             一般性错误
             */
            ZEGO_DEVICE_ERROR_GENERIC = -1,
            /**
             无效设备 ID
             */
            ZEGO_DEVICE_ERROR_INVALID_ID = -2,
            /**
             没有权限
             */
            ZEGO_DEVICE_ERROR_NO_AUTHORIZATION = -3,
            /**
             采集帧率为0
             */
            ZEGO_DEVICE_ERROR_ZERO_FPS = -4,
            /**
             设备被占用
             */
            ZEGO_DEVICE_ERROR_IN_USE_BY_OTHER = -5,
            /**
             设备未插入 
             */
            ZEGO_DEVICE_ERROR_UNPLUGGED = -6,
            /**
             需要重启系统
             */
            ZEGO_DEVICE_ERROR_REBOOT_REQUIRED = -7,
            /**
             媒体服务无法恢复
             */
            ZEGO_DEVICE_ERROR_MEDIA_SERVICES_LOST = -8,
            /**
             设备被SIRI占用
             */
            ZEGO_DEVICE_ERROR_IN_USE_BY_SIRI = -9,
        };

        enum ZegoDeviceErrorReason
        {
            /** 一般性错误 */
            ZEGO_DEVICE_ERROR_REASON_GENERIC = -1,
            /** 无效设备 ID */
            ZEGO_DEVICE_ERROR_REASON_INVALID_ID = -2,
            /** 没有权限 */
            ZEGO_DEVICE_ERROR_REASON_NO_AUTHORIZATION = -3,
            /** 采集帧率为0 */
            ZEGO_DEVICE_ERROR_REASON_ZERO_FPS = -4,
            /** 设备被占用 */
            ZEGO_DEVICE_ERROR_REASON_IN_USE_BY_OTHER = -5,
            /** 设备未插入 */
            ZEGO_DEVICE_ERROR_REASON_UNPLUGGED = -6,
            /** 需要重启系统 */
            ZEGO_DEVICE_ERROR_REASON_REBOOT_REQUIRED = -7,
            /** 媒体服务无法恢复 */
            ZEGO_DEVICE_ERROR_REASON_MEDIA_SERVICES_LOST = -8,
            /** 设备被SIRI占用 */
            ZEGO_DEVICE_ERROR_REASON_IN_USE_BY_SIRI = -9,
            /** 没有错误 */
            ZEGO_DEVICE_ERROR_REASON_NONE = 0,
            /** 禁用 */
            ZEGO_DEVICE_ERROR_REASON_DISABLED = 2,
            /** 屏蔽采集 */
            ZEGO_DEVICE_ERROR_REASON_MUTE = 3,
            /** 中断 */
            ZEGO_DEVICE_ERROR_REASON_INTERRUPTION = 4,
            /** 在后台 */
            ZEGO_DEVICE_ERROR_REASON_IN_BACKGROUND = 5,
            /** 前台有多个 APP 运行 */
            ZEGO_DEVICE_ERROR_REASON_MULTI_FOREGROUND_APP = 6,
            /** 系统压力过大 */
            ZEGO_DEVICE_ERROR_REASON_SYSTEM_PRESSURE = 7,
        };

        enum ChannelExtraParamKey
        {
            /** 设置编码场景模式，仅 OpehH264 有效 */
            //ZEGO_CHANNEL_PARAM_KEY_VIDEO_SWENCODER_USAGE = 0,
            /** 设置 X264 编码特性，目前仅支持 tune */
            //ZEGO_CHANNEL_PARAM_KEY_VIDEO_X264_CONFIG = 1,
            /** 获取 AVCaptureDevice 对象 */
            ZEGO_CHANNEL_PARAM_KEY_AV_CAPTURE_DEVICE = 2,
        };
        
        enum ZegoAudioRoute
        {
            /** 扬声器 */
            ZEGO_AUDIO_ROUTE_SPEAKER = 0,
            /** 耳机 */
            ZEGO_AUDIO_ROUTE_HEADSET,
            /** 蓝牙 */
            ZEGO_AUDIO_ROUTE_BLUETOOTH,
            /** 听筒 */
            ZEGO_AUDIO_ROUTE_RECEIVER,
            /** USB 音频设备 */
            ZEGO_AUDIO_ROUTE_USB_AUDIO,
            /** air play */
            ZEGO_AUDIO_ROUTE_AIR_PLAY
        };

        struct ZegoCodecCapabilityInfo
        {
            /**
            编码格式
            */
            ZegoVideoCodecAvc codecId;
            /**
            是否硬编
            */
            int isHardware;

            ZegoCodecCapabilityInfo()
            {
                codecId = ZegoVideoCodecAvc::VIDEO_CODEC_DEFAULT;
                isHardware = 0;
            }
        };
        
        /**
         编解码错误
         */
        enum ZegoCodecError
        {
            /** 成功 */
            ZEGO_CODEC_ERROR_NONE = 0,
            /** 不支持 */
            ZEGO_CODEC_ERROR_NOT_SUPPORT = -1,
            /** 失败 */
            ZEGO_CODEC_ERROR_FAILED = -2,
            /** 软解性能不足 */
            ZEGO_CODEC_ERROR_LOW_FPS = -3,
        };

        enum ZegoStreamResourceMode
        {
            /** 默认模式,SDK会根据拉流设置的rtmpUrls/flvUrls/shouldSwitchServer参数和即构的后台配置自动选择拉流资源 */
            DEFAULT = 0,
            /** 只从CDN拉流 */
            CDN_ONLY = 1,
            /** 只从L3拉流, 会忽略rtmpUrls/flvUrls/shouldSwitchServer 参数 */
            L3_ONLY = 2,
            /** 只从RTC拉流 ,会忽略 rtmpUrls/flvUrls/shouldSwitchServer 参数 */
            RTC_ONLY = 3
        };
    }
}

#ifdef __cplusplus
extern "C" {
#endif
    struct ZegoStreamExtraPlayInfo;

    ZEGOAVKIT_API struct ZegoStreamExtraPlayInfo* zego_stream_extra_info_create();
    ZEGOAVKIT_API void zego_stream_extra_info_destroy(struct ZegoStreamExtraPlayInfo* info);
    
    ZEGOAVKIT_API void zego_stream_extra_info_add_rtmp_url(struct ZegoStreamExtraPlayInfo* info, const char* url);
    ZEGOAVKIT_API void zego_stream_extra_info_add_flv_url(struct ZegoStreamExtraPlayInfo* info, const char* url);
    ZEGOAVKIT_API void zego_stream_extra_info_set_params(struct ZegoStreamExtraPlayInfo* info, const char* params);
    ZEGOAVKIT_API void zego_stream_extra_info_set_decrypt_key(struct ZegoStreamExtraPlayInfo* info, const unsigned char* key, int keylen);
    ZEGOAVKIT_API void zego_stream_extra_info_should_switch_server(struct ZegoStreamExtraPlayInfo* info, bool should);
    ZEGOAVKIT_API void zego_stream_extra_info_set_play_mode(struct ZegoStreamExtraPlayInfo* info, ZEGO::AV::ZegoStreamResourceMode mode);
    
#ifdef __cplusplus
} // __cplusplus defined.
#endif

#endif /* zego_api_defines_h */
