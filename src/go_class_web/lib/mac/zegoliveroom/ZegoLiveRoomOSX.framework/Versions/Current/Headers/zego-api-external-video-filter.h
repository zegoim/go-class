//
//  zego-api-external-video-filter.hpp
//  zegoavkit
//
//  Copyright © 2017年 Zego. All rights reserved.
//

#ifndef zego_api_external_video_filter_h
#define zego_api_external_video_filter_h


namespace AVE
{
    class VideoFilterFactory;
}

namespace ZEGO
{
namespace VIDEOFILTER
{
    
    /// \brief 设置外部滤镜工厂；当置空时，关闭外部滤镜功能。
    /// \param factory 工厂对象
    /// \param idx 推流通道
    /// \note 必须在 推/拉流、预览 前设置；
    /// \note 在 推/拉流、预览 过程中不要改变该工厂实例。
    ZEGOAVKIT_API void SetVideoFilterFactory(AVE::VideoFilterFactory* factory, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
    
}
}

#endif /* zego_api_external_video_filter_h */
