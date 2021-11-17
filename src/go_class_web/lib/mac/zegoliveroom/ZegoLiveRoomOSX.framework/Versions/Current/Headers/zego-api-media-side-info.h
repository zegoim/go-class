//
//  zego-api-media-side-info.hpp
//  ZegoLiveRoom
//
//  Created by MarkWu on 2018/1/12.
//

#ifndef zego_api_media_side_info_h
#define zego_api_media_side_info_h
#include "zego-api-defines.h"

namespace ZEGO
{
    namespace MEDIASIDEINFO
    {
        /**
         流媒体次要信息回调
         */
		class IZegoMediaSideCallback
        {
        public:
            /**
             接收到媒体次要信息
             
             * 调用 SetMediaSideCallback 设置了回调监听，且主播端已成功发送了媒体次要信息，SDK 通过此 API 通知拉流方收到媒体次要信息。
             @param  pszStreamID  当前流ID信息，标记当前回调的信息属于哪条流。
             @param  pBuf  接收到的媒体信息数据（具体内容参考官网对应文档中的格式说明）
             @param dataLen  数据缓冲区长度
             */
            virtual void onRecvMediaSideInfo(const char * pszStreamID, const unsigned char *pBuf, int dataLen) = 0;
			virtual ~IZegoMediaSideCallback() {}
        };
        
        /**
         发送媒体次要信息开关，支持发送 SEI 的设置。
         
         @attention 1. 必须在调用初始化 SDK 接口之后、推流接口之前设置。
         
         * 2.如果只有音频直播，必须将 onlyAudioPublish 置为 true，此时将会由音频来驱动次要信息的传输，同时忽略视频流传输。
         
         @param bStart  开启/关闭媒体次要信息传输，true 表示开启媒体次要信息传输，false 表示关闭媒体次要信息传输。start 为 true 时，onlyAudioPublish 参数开关才有效。
         @param bOnlyAudioPublish   是否为纯音频直播，true 表示纯音频直播，不传输视频数据；false 表示音视频直播，传输音频和视频数据；默认为 false。
         @param mediaInfoType   媒体次要信息类型，请参考 MediaInfoType 定义，建议使用 SeiZegoDefined 类型。
         @param seiSendType    SEI 发送类型，请参考 SeiSendType 定义，此参数只对发送 SEI 时有效，当 mediaInfoType 参数为 SideInfoZegoDefined 时此参数无效；当发送 SEI 时建议使用 SeiSendInVideoFrame 类型。
         @param idx   推流通道 index，请参考 AV::PublishChannelIndex
         */
        ZEGOAVKIT_API void SetMediaSideFlags(bool bStart, bool bOnlyAudioPublish, int mediaInfoType = AV::SideInfoZegoDefined, int seiSendType = AV::SeiSendSingleFrame, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         发送媒体次要信息
         
         @attention 1. 必须在推流成功之后调用。
         
         * 2.SetMediaSideFlags 接口设置为音视频直播时，关闭摄像头将导致无法发送媒体次要信息。
         * 3.不需要发送媒体次要信息时，可调用 SetMediaSideFlags 来关闭媒体次要信息传输，第一个参数填 false 就代表关闭，关闭后即使调用 SendMediaSideInfo 也不能再发送媒体次要信息。
         * 4.SendMediaSideInfo 的调用频率不能超过帧率，假设推流采用默认帧率15 fps，即调用频率不能超过 1000/15=66.7 ms/次。
         
         @param inData    需要传输的音视频次要信息数据，外部输入。
         @param bPacket    是否采用外部打包好的包头，填写 false。
         @param idx   推流通道 index，请参考 AV::PublishChannelIndex
         @see 相关接口请查看 SetMediaSideFlags
         */
        ZEGOAVKIT_API void SendMediaSideInfo(const unsigned char *inData, int dataLen, bool bPacket, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        
        /**
         设置媒体次要信息的回调监听，以接收媒体次要信息。
         @attention  1. 在调用初始化 SDK 接口之后、拉流接口之前设置。
         
         * 2.观众端若想在此 API 设置的回调中获取主播端发送的媒体次要信息，需要主播端已开启发送媒体次要信息开关，并调用 SendMediaSideInfo 发送媒体次要信息。
         * 3.主播端采用音视频直播驱动媒体次要信息传输时，拉流时使用 ActivateVideoPlayStream 接口设置了只拉音频时，将无法接收到媒体次要信息。
         * 4.当不需要接收数据时，调用 SetMediaSideCallback(null) 去除回调监听，避免内存泄漏。
         
         @param pCB 实现了 IZegoMediaSideCallback 回调的方法，用于拉流时接收媒体次要信息。
         */
        ZEGOAVKIT_API void SetMediaSideCallback(IZegoMediaSideCallback* pCB);
    }
}



#endif /* zego_api_media_side_info_hpp */
