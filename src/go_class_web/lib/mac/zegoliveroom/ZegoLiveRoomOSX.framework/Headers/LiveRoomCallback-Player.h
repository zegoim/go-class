//
//  LiveRoomCallback-Player.h
//  zegoliveroom
//
//  Created by Randy Qiu on 2017/1/23.
//
//

#ifndef LiveRoomCallback_Player_h
#define LiveRoomCallback_Player_h

#include "./LiveRoomDefines.h"
#include "video_capture.h"

namespace ZEGO
{
    namespace LIVEROOM
    {
        class ILivePlayerCallback
        {
        public:
            /**
             播放流状态更新通知
             
             @note
             * 1. 调用拉流接口 StartPlayingStream 或 StartPlayingStream2 后会收到此回调通知。
             
             @param stateCode 状态码，0 为无错误。更多错误码请参考 zego-api-error.h 下的错误码定义
             @param pszStreamID 播放流 ID
             */
            virtual void OnPlayStateUpdate(int stateCode, const char* pszStreamID) = 0;

            /**
             播放流质量更新通知
             
             @note
             * 1. 拉流成功后会多次收到此回调通知；
             * 2. 默认回调频率为 3000ms 一次，通过 SetPlayQualityMonitorCycle 可自定义回调频率。
             
             @param pszStreamID 观看流 ID
             @param quality 0~3 分别对应优、良、中、差
             @param videoFPS 帧率
             @param videoKBS 码率
             */
            virtual void OnPlayQualityUpdate(const char* pszStreamID, int quality, double videoFPS, double videoKBS) {};
            
            /**
             播放流质量更新通知
             @note
             * 1. 拉流成功后会多次收到此回调通知；
             * 2. 默认回调频率为 3000ms 一次，通过 SetPlayQualityMonitorCycle 可自定义回调频率。
             
             @param pszStreamID 观看流 ID
             @param playQuality ZegoPlayQuality 对象，内部包含了各项质量数据
             */
            virtual void OnPlayQualityUpdate(const char* pszStreamID, ZegoPlayQuality playQuality) {};
            
            /**
             收到请求连麦的响应结果

             @note
             * 1. 一般来说收到主播同意连麦后(result 为 0)，主动调用开始推流与主播进行连麦。

             @param result 结果， 0 为同意连麦
             @param pszFromUserId 来源用户 Id
             @param pszFromUserName 来源用户名
             @param seq 请求 seq
             */
            virtual void OnJoinLiveResponse(int result, const char* pszFromUserId, const char* pszFromUserName, int seq) {};
            
            /**
             收到主播要求结束连麦的指令
             
             @note
             * 1. 一般来说连麦用户收到此通知后，主动调用停止推流结束连麦。
             
             @param pszFromUserId 来源用户 Id
             @param pszFromUserName 来源用户名
             @param pszRoomID 房间 ID
             */
            virtual void OnRecvEndJoinLiveCommand(const char *pszFromUserId, const char* pszFromUserName, const char* pszRoomID) {};

            /**
             收到来自房间内主播的连麦邀请
             
             @note
             * 1. 一般来说观众用户收到此通知后，主动调用开始推流与主播进行连麦。
             
             @param seq 连麦邀请序列号，标识当次连麦请求
             @param pszFromUserId 来源用户 Id
             @param pszFromUserName 来源用户名
             @param pszRoomID 房间 ID
             */
            virtual void OnInviteJoinLiveRequest(int seq, const char* pszFromUserId, const char* pszFromUserName, const char* pszRoomID) {};
            
            /**
             视频尺寸变更通知
             
             @attention
             * 1. 调用 StartPlayingStream 或 StartPlayingStream2 之后，在 SDK 获取到第一帧数据时，会收到该 API 回调通知；
             * 2. 直播过程中，视频宽高发生变化，会收到该 API 回调通知。
             
             @note
             * 1. 从调用开始拉流接口到显示第一帧数据的过程中可能存在一个短暂的时间差（具体时长取决于当前的网络状态），推荐在进入直播页面时加载一张预览图以提升用户体验，然后在收到本回调后去掉预览图。
             
             @param pStreamID 发生视频尺寸变更的流 ID
             @param nWidth 视频宽度
             @param nHeight 视频高度
             */
            virtual void OnVideoSizeChanged(const char* pStreamID, int nWidth, int nHeight) {};
            
            /**
             远端摄像头状态通知
             
             @attention
             * 1. 仅拉 UDP 流有效；
             * 2. 当房间内其他流的摄像头状态发生改变，如其他用户调用了 EnableCamera (true/false) 后，会收到该 API 回调通知。
             
             @param pStreamID 流 ID
             @param nStatus，参考 zego-api-defines.h 中 DeviceStatus 的定义
             @param nReason，参考 zego-api-defines.h 中 ZegoDeviceErrorReason 的定义
             */
            virtual void OnRemoteCameraStatusUpdate(const char* pStreamID, int nStatus, int nReason) {};
            
            /**
             远端麦克风状态通知
             
             @attention
             * 1. 仅拉 UDP 流有效；
             * 2. 当房间内其他流的麦克风状态发生改变，如其他用户调用了 EnableMic (true/false) 后，会收到该 API 回调通知。
             
             @param pStreamID 流 ID
             @param nStatus，参考 zego-api-defines.h 中 DeviceStatus 的定义
             @param nReason，参考 zego-api-defines.h 中 ZegoDeviceErrorReason 的定义
             */
            virtual void OnRemoteMicStatusUpdate(const char* pStreamID, int nStatus, int nReason) {};
            
            /**
             接收到远端音频的首帧通知
             
             @attention
             * 1. 当远端音频的首帧到达后，会收到该 API 回调通知。

             @param pStreamID 流 ID
             */
            virtual void OnRecvRemoteAudioFirstFrame(const char* pStreamID) {};
            
            /**
             接收到远端视频的首帧通知
             
             @attention
             * 1. 当远端视频频的首帧到达后，会收到该 API 回调通知。
             
             @note
             * 1. 从调用开始拉流接口到显示第一帧数据的过程中可能存在一个短暂的时间差（具体时长取决于当前的网络状态），推荐在进入直播页面时加载一张预览图以提升用户体验，然后在收到本回调后去掉预览图。
             

             @param pStreamID 流 ID
             */
            virtual void OnRecvRemoteVideoFirstFrame(const char* pStreamID) {};
            
            /**
             远端视频渲染首帧通知
             
             @attention
             * 1. 当开始要渲染远端的视频首帧时，会收到该 API 回调通知。
            
             @param pStreamID 渲染视频的流 ID
             */
            virtual void OnRenderRemoteVideoFirstFrame(const char* pStreamID) {};
            
            /**
             对观看视频流截屏的截屏结果
             
             @note
             * 1. 当用户调用 TakeSnapshot 后，会收到该 API 回调通知。
             
             @param pImage 截屏图片，Windows平台下类型为HBITMAP，Mac平台下类型为CGImageRef
             @param pszStreamID 流 ID
             */
            virtual void OnSnapshot(void *pImage, const char* pszStreamID) {};

            /**
             视频解码器错误通知
             @param codecID 编解码器
             @param  errorCode 错误码, 详见 zego-api-defines.h 中的 ZegoCodecError 定义
             @param pszStreamID 流 ID
             */
            virtual void OnVideoDecoderError(AV::ZegoVideoCodecAvc codecID, int errorCode, const char* pszStreamID) {}
            
            virtual ~ILivePlayerCallback() {}
        };
        
    }
}


#endif /* LiveRoomCallback_Player_h */
