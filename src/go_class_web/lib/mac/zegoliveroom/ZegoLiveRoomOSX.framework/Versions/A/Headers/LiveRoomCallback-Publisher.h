//
//  LiveRoomCallback-Publisher.h
//  zegoliveroom
//
//  Created by Randy Qiu on 2017/1/23.
//
//

#ifndef LiveRoomCallback_Publisher_h
#define LiveRoomCallback_Publisher_h

#include "./LiveRoomDefines-Publisher.h"
#include "./LiveRoomDefines.h"

namespace ZEGO
{
    namespace LIVEROOM
    {
        class ILivePublisherCallback
        {
        public:
            /**
             推流状态更新

             @param stateCode 状态码
             @param pszStreamID 流 ID
             @param oStreamInfo 推流信息
             */
            virtual void OnPublishStateUpdate(int stateCode, const char* pszStreamID, const ZegoPublishingStreamInfo& oStreamInfo) = 0;
            
            /**
             收到连麦请求

             @param seq 请求 seq
             @param pszFromUserId 来源用户 Id
             @param pszFromUserName 来源用户名
             @param pszRoomID 房间 ID
             */
            virtual void OnJoinLiveRequest(int seq, const char *pszFromUserId, const char *pszFromUserName, const char *pszRoomID) {}
            
            /**
             收到邀请连麦响应结果

             @param result 结果
             @param pszFromUserId 来源用户 Id
             @param pszFromUserName 来源用户名
             @param seq 请求 seq
             */
            virtual void OnInviteJoinLiveResponse(int result, const char *pszFromUserId, const char *pszFromUserName, int seq) {}
            
            /**
             结束连麦结果

             @param result 结果
             @param seq 请求 seq
             @param pszRoomID 房间 ID
             */
            virtual void OnEndJoinLive(int result, int seq, const char *pszRoomID) {}
            
            /**
             推流质量更新

             @param pszStreamID 流 ID
             @param quality 发布质量，0~3 分别对应优、良、中、差
             @param videoFPS 帧率
             @param videoKBS 码率
             */
            virtual void OnPublishQulityUpdate(const char* pszStreamID, int quality, double videoFPS, double videoKBS) {}
            
            /**
             推流质量更新

             @param pszStreamID 流 ID
             @param publishQuality ZegoPublishQuality 对象，内含各项推流质量数据
             */
            virtual void OnPublishQualityUpdate(const char* pszStreamID, ZegoPublishQuality publishQuality) {}
            
            /**
             采集视频的宽度和高度变化通知

             @param nWidth 视频宽度
             @param nHeight 视频高度
             @attention 发布直播成功后，当视频尺寸变化时，发布者会收到此通知
             */
            virtual void OnCaptureVideoSizeChanged(int nWidth, int nHeight) {}
            
            virtual void OnCaptureVideoSizeChanged(AV::PublishChannelIndex index, int nWidth, int nHegith) {}
            
            /**
             预览截图

             @param pImage 截图结果
             */
            virtual void OnPreviewSnapshot(void *pImage) {}
            
            virtual void OnPreviewSnapshot(AV::PublishChannelIndex index, void *pImage) {}
            
            /**
             转推CDN状态通知

             @param streamID 流ID
             @param statesInfo 转推CDN状态信息列表
             @param statesInfoCount 状态信息列表个数
             */
            virtual void OnRelayCDNStateUpdate(const char *streamID, AV::ZegoStreamRelayCDNInfo* statesInfo, unsigned int statesInfoCount) {}
            
            /**
             添加/删除转推地址状态回调
             
             @param pszStreamID 流 ID
             @param strTarget 转推地址（支持rtmp/avertp）
             @param errorCode 错误码
             */
            virtual void OnUpdatePublishTargetState(int errorCode, const char *streamID, int seq) {}
            
            /**
             采集视频的首帧通知
             */
            virtual void OnCaptureVideoFirstFrame() {}

            virtual void OnCaptureVideoFirstFrame(AV::PublishChannelIndex idx) {}

            /**
             预览视频的首帧通知
             */
            virtual void OnPreviewVideoFirstFrame(AV::PublishChannelIndex idx) {}
            
            /**
             采集音频的首帧通知
             */
            virtual void OnCaptureAudioFirstFrame() {}

            /**
             视频编码器错误通知
             
             @param codecID 编码器
             @param errorCode 错误码, 详见 zego-api-defines.h 中的 ZegoCodecError 定义
             @param index 推流通道
             */
            virtual void OnVideoEncoderError(AV::ZegoVideoCodecAvc codecID, int errorCode, AV::PublishChannelIndex index) {}
            
            virtual ~ILivePublisherCallback() {}
        };
    }
}
#endif /* LiveRoomCallback_Publisher_h */
