//
//  zego-api-mix-stream.h
//
//  Copyright © 2018年 Zego. All rights reserved.
//

#ifndef zego_api_mix_stream_h
#define zego_api_mix_stream_h

#include "./zego-api-mix-stream-defines.h"

namespace ZEGO
{
namespace MIXSTREAM
{
    /**
     混流配置信息的回调接口
     @note Deprecated, 请使用 IZegoMixStreamExCallback
     */
    class IZegoMixStreamCallback
    {
    public:
        /**
         混流请求结果及配置信息的回调
         
         * 调用 SetMixStreamCallback 设置了回调监听，并调用 MixStream 设置混流配置后，SDK 通过此 API 通知调用方混流配置信息。
         
         @param result 混流结果
         @param pszMixStreamID 混流任务 ID，与 AV::ZegoCompleteMixStreamConfig 中的 szOutputStream 参数一致。
         @param seq 请求 seq
         */
        virtual void OnMixStream(const AV::ZegoMixStreamResult& result, const char* pszMixStreamID, int seq) = 0;
        
        virtual ~IZegoMixStreamCallback() {}
    };
    
    /**
     混流配置信息的回调接口
     */
    class IZegoMixStreamExCallback
    {
    public:
        /**
         混流请求结果及配置信息的回调
         
         @param result 混流结果
         @param pszMixStreamID 混流任务ID，与 MixStreamEx 中的 mixStreamID 参数一致。
         @param seq 请求 seq
         */
        virtual void OnMixStreamEx(const AV::ZegoMixStreamResultEx& result, const char* mixStreamID, int seq) = 0;
        
        
        /**
         混流转推CDN状态回调

         @param mixStreamID 混流任务ID
         @param statesInfo 混流转推CDN信息
         @param statesInfoCount 混流转推CDN信息个数
         */
        virtual void OnMixStreamRelayCDNStateUpdate(const char *mixStreamID, AV::ZegoStreamRelayCDNInfo *statesInfo, unsigned int statesInfoCount) {}
        
        virtual ~IZegoMixStreamExCallback() {}
    };
    
    /**
     混流中的发言者及其说话音量的回调通知接口
     */
    class IZegoSoundLevelInMixedStreamCallback
    {
    public:
        /**
         混流中的发言者及其说话音量信息的回调
         
         @param volume_list 混流中各单流的音量信息列表
         @param list_size 音量信息列表个数
         @note 此接口是高频率同步回调，每秒钟10次通知，不拉流没有通知；请勿在该回调中处理耗时任务。
         */
        virtual void OnSoundLevelInMixedPlayStream(AV::SoundLevelInfo *volume_list, int list_size) = 0;
        
        virtual ~IZegoSoundLevelInMixedStreamCallback() {}
    };
    
    /**
     设置对应 MixStream 的回调
     
     @warning Deprecated, 请使用 SetMixStreamExCallback 代替
     */
    ZEGOAVKIT_API bool SetMixStreamCallback(IZegoMixStreamCallback* pCB);
    
    /**
     混流接口，支持混流单路输出
     
     @warning Deprecated, 请使用 MixStreamEx 代替
     
     @param seq 请求序号，回调会带回次 seq
     @return true 成功，等待回调，false 失败
     @note 每次需要更新混流配置时，都可以调用此接口；如果需要多次调用，可以通过传入不同的 seq 区分回调
     */
    ZEGOAVKIT_API bool MixStream(const AV::ZegoCompleteMixStreamConfig& config, int seq);
    
    /**
     设置接收混流配置更新结果的回调监听，对应于 MixStreamEx 接口的回调监听。
     
     @param pCB 实现了 IZegoMixStreamExCallback 回调的方法，用于混流时接收混流请求结果及配置更新信息。
     @note 若不再需要接收混流配置更新信息，调用 SetMixStreamExCallback(null) 去除回调监听。
     @see 相关接口请查看 MixStreamEx
     */
    ZEGOAVKIT_API bool SetMixStreamExCallback(IZegoMixStreamExCallback* pCB);
    
    /**
     混流接口，支持输出单路或者多路混流。
    
     @param mixStreamID 混流任务ID
     @param config 混流配置信息，详细配置信息请查看 ZegoMixStreamConfig。
     @return 大于 0 表示调用成功，且返回值为调用序号（seq），用以区分 OnMixStreamEx 回调；小于等于 0 表示调用失败。
     @note 1. 混流任务ID，表示混流任务的唯一ID，调用方应该保证 mixStreamID 的唯一性。如果 mixStreamID 相同，服务端就认为是更新同一个混流。
     
     * 2. 此 API 既是开始混流、更新混流接口，也是停止混流接口。
     
     * 3.需要停止混流时，将 ZegoMixStreamConfig 参数中的 pInputStreamList 置为空列表（即清空输入流列表），将 mixStreamID 参数设置为和开始或更新混流的一致。
     
     * 4. 当混流信息变更（例如：混流的输入流列表发生增减、调整混流视频的输出码率等）时，需要调用此接口更新 ZEGO 混流服务器上的混流配置信息，且注意每次调用时此 API 的 mixStreamID 参数需保证一致。
     
     * 5. 如果需要启动多个不同的混流，可以传入不同的 mixStreamID，通过返回的 seq 来区分接收的 -OnMixStreamEx 回调。     
     */
    ZEGOAVKIT_API int MixStreamEx(const char* mixStreamID, const ZegoMixStreamConfig& config);
    
    /**
     设置拉取混流时对混流中音量的回调监听
     
     @param pCB 实现了 IZegoSoundLevelInMixedStreamCallback 回调的方法，用于拉取混流时接收混流中各单流的音量信息，可以根据此回调实现音浪。
     @return true 调用成功，false 调用失败，将收不到音量回调。
     @note  1. 此方法由拉取混流方调用。
     
     * 2.若不再需要接收混流中各单流的音量信息，调用 SetSoundLevelInMixedStreamCallback(null) 去除回调监听。
     */
    ZEGOAVKIT_API bool SetSoundLevelInMixedStreamCallback(IZegoSoundLevelInMixedStreamCallback* pCB);
    
}
}

#endif /* zego_api_mix_stream_h */
