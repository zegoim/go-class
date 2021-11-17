//
//  ZegoLiveRoom-mobile.h
//  ZegoLiveRoom
//
//  Created by Strong on 24/10/2017.
//

#ifndef ZegoLiveRoom_mobile_h
#define ZegoLiveRoom_mobile_h

#include "audio_in_output.h"
#include "RoomDefines.h"

#include <memory>
#include "LiveRoomDefines.h"

namespace AVE {
    class VideoCaptureFactory;
    class IAudioDataInOutput;
}


namespace ZEGO
{
    namespace AV
    {
        class IZegoAudioRouteCallback;
    }
    
    namespace LIVEROOM
    {        
        ZEGO_API bool SetAppOrientation(int nOrientation, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /// \brief 前摄像头开关
        /// \param bFront true 前摄像头, false 后摄像头
        /// \return true 成功，false 失败
        ZEGO_API bool SetFrontCam(bool bFront, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /// \brief 手机手电筒开关
        /// \param bEnable 是否开启
        /// \return true 成功，false 失败
        ZEGO_API bool EnableTorch(bool bEnable, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        ZEGO_API bool EnableCaptureMirror(bool bEnable, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);

        /// \brief 码率控制开关（在带宽不足的情况下码率自动适应当前带宽)
        /// \param bEnable 是否开启
        /// \param idx 推流通道 ID
        /// \return true 成功，false 失败
        /// \note 在推流之前设置有效。
        ZEGO_API bool EnableRateControl(bool bEnable, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        ZEGO_API void PauseModule(int moduleType);
        ZEGO_API void ResumeModule(int moduleType);
        
        ZEGO_API void SetAudioRouteCallback(AV::IZegoAudioRouteCallback* pCallback);


#if !defined(WIN32) && !defined(LINUX)
        ZEGO_API void EnableAECWhenHeadsetDetected(bool bEnable);
#endif // !WIN32
    }
}

#endif /* ZegoLiveRoom_mobile_h */
