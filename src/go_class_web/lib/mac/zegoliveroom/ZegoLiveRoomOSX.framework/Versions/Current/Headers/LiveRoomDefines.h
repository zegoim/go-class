//
//  ZegoLiveRoomDefines.h
//  zegoliveroom
//
//  Copyright © 2017年 ZEGO. All rights reserved.
//

#ifndef ZegoLiveRoomDefines_h
#define ZegoLiveRoomDefines_h

#include "./AVDefines.h"
#include "./RoomDefines.h"


namespace ZEGO
{
    namespace LIVEROOM
    {
        using namespace COMMON;
        using COMMON::ZEGONetType;
        
        using COMMON::ZegoRoomRole;
        
        using COMMON::ZegoStreamInfo;
        
        using COMMON::ZegoStreamUpdateType;
        
        const int kInvalidSeq = -1;
        
        /** 本地预览视频视图的模式 */
        enum ZegoVideoViewMode
        {
            ZegoVideoViewModeScaleAspectFit = 0,    /**< 等比缩放，可能有黑边 */
            ZegoVideoViewModeScaleAspectFill = 1,   /**< 等比缩放填充整View，可能有部分被裁减 */
            ZegoVideoViewModeScaleToFill = 2,       /**< 填充整个View */
        };
        
        struct ZegoPublishQuality
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

            double totalBytes; ///< 已发送的总字节数，包括音频、视频及媒体次要信息等
            double audioBytes; ///< 已发送的音频字节数
            double videoBytes; ///< 已发送的视频字节数
            
            double cpuAppUsage;    ///< 当前 APP 的 CPU 使用率
            double cpuTotalUsage;  ///< 当前系统的 CPU 使用率
            
            double memoryAppUsage;         ///< 当前 APP 的内存使用率
            double memoryTotalUsage;       ///< 当前系统的内存使用率
            double memoryAppUsed;          ///< 当前 APP 的内存使用量, 单位 MB(win返回的是app实际占用内存工作集=专用内存工作集+共享内存工作集)

            ZegoPublishQuality()
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
        
        struct ZegoPlayQuality
        {
            double fps;              ///< 视频帧率(网络接收)
            double vdjFps;           ///< 视频帧率(dejitter)
            double vdecFps;          ///< 视频帧率(解码)
            double vrndFps;          ///< 视频帧率(渲染)
            double kbps;             ///< 视频码率(kb/s)
            
            double afps;             ///< 音频帧率(网络接收)
            double adjFps;           ///< 音频帧率(dejitter)
            double adecFps;          ///< 音频帧率(解码)
            double arndFps;          ///< 音频帧率(渲染)
            double akbps;            ///< 音频码率(kb/s)
            
            double audioBreakRate;   ///< 音频卡顿次数
            double videoBreakRate;   ///< 视频卡顿次数
            int rtt;                 ///< 延时(ms)
            int pktLostRate;         ///< 丢包率(0~255)
            int peerToPeerDelay;     ///< 端到端延迟
            int peerToPeerPktLostRate; ///< 端到端丢包率(0~255)
            int quality;             ///< 质量(0~3)
            int delay;               ///< 语音延时(ms)
            
            bool isHardwareVdec;     ///< 是否硬解
            int videoCodecId;        ///< 视频解码格式(参考ZegoVideoCodecAvc)
            int width;               ///< 视频宽度
            int height;              ///< 视频高度

            double totalBytes; ///< 已接收的总字节数，包括音频、视频及媒体次要信息等
            double audioBytes; ///< 已接收的音频字节数
            double videoBytes; ///< 已接收的视频字节数
            
            double cpuAppUsage;        ///< 当前 APP 的 CPU 使用率
            double cpuTotalUsage;      ///< 当前系统的 CPU 使用率
            
            double memoryAppUsage;         ///< 当前 APP 的内存使用率
            double memoryTotalUsage;       ///< 当前系统的内存使用率
            double memoryAppUsed;          ///< 当前 APP 的内存使用量, 单位 MB

            int avTimestampDiff;       ///< 音画不同步, 单位毫秒, 小于0表示视频超前音频的毫秒数, 大于0表示视频滞后音频的毫秒数, 等于0表示无差别. 当绝对值小于200，可基本认为音画同步，当绝对值连续10秒大于200可以认为异常

            ZegoPlayQuality()
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

		enum ZegoMixSysPlayoutPropertyMask
		{
			MIX_PROP_NONE = 0,
			MIX_PROP_ENABLE_AGC_FOR_SYS_PLAYOUT = 1, //当开启采集系统声卡声音时，传递此参数启用自动增益(仅支持win) 
		};
    }
}

#endif /* ZegoLiveRoomDefines_h */
