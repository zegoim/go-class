//
//  zego-api-audio-aux.h
//

#ifndef zego_api_audio_aux_h
#define zego_api_audio_aux_h

namespace ZEGO
{
    namespace AUDIOAUX
    {
        /**
         混音音频数据输入回调（可输入媒体次要信息）
         */
        class IZegoAuxCallback
        {
        public:
            /**
             混音音频数据的输入回调，当开启混音后，用户调用该 API 将混音数据传递给 SDK。
             
             @attention  1. 针对混音数据，目前 SDK 仅支持位深为 16bit，16k、32k、44.1k、48k 采样率，单声道或者双声道的 PCM 音频数据格式。
             
             * 2.用户根据实际的 PCM 音频填写采样率及声道数。
             * 3.为确保混音效果，请不要在此 API 中执行耗时操作。
             @note 1. 发送媒体次要信息前需要调用 SetMediaSideFlags:onlyAudioPublish 开启媒体次要信息传输功能。
             
             * 2.此接口带媒体次要信息时必须要带有混音音频数据(不能只有媒体次要信息)才能发送媒体次要信息，如果不带混音音频数据则会丢掉媒体次要信息。
             @param pData 待混音的音频数据
             @param pDataLen 一次传入的音频数据长度；SDK会提供好长度值，用户按照这个长度写入音频数据即可；如果填写的音频数据长度大于等于 *pDataLen，则无需更改 pDataLen 的值;如果填写的音频数据长度小于 *pDataLen，将 pDataLen 的值更改为0；当音频最后的尾音不足 SDK 提供的长度值时，又需要向 SDK 传入完整的音频数据，可以用静音数据补齐后再传给 SDK。
             @param pSampleRate 混音数据采样率，支持16k、32k、44.1k、48k
             @param pChannelCount 混音数据声道数，支持1、2
             @param pSideInfo 媒体次要信息数据缓冲区地址,若不需要带媒体次要信息
             @param pSideInfoLength 媒体次要信息数据缓冲区长度
             @param bPacket  媒体次要信息数据是否外部已经打包好包头，YES 表示采用外部打包的包头， NO 表示采用 ZEGO 内部打包的包头。
             @see 相关接口请查看 EnableAux
             */
            virtual void OnAuxCallbackEx(unsigned char *pData, int *pDataLen, int *pSampleRate, int *pNumChannels,unsigned char *pSideInfo, int *pSideInfoLen, bool *bPacket) = 0;
            
            virtual ~IZegoAuxCallback() {}
        };
    
        /**
         混音开关
         @note 1. 必须在初始化 SDK 后调用，可在需要混音的任一时间开启混音开关。
         
         * 2.当开启混音后，SDK 会在 OnAuxCallbackEx 中获取用于混音的音频数据，即需要开发者在此接口中塞音频数据给 SDK。
         @param bEnable 开启/关闭混音开关，true 表示开启混音，false 表示关闭混音；默认为 false（关闭混音）。
         @return true 表示调用成功，能收到混音回调；false 表示调用失败，不能收到混音回调。
         @see 相关接口请查看 OnAuxCallbackEx
         */
        ZEGOAVKIT_API bool EnableAux(bool bEnable);
        
        /**
         设置对混音数据的输入回调的监听
         
         @param pCB  实现了 IZegoAuxCallback 回调的方法，用于混音时向 SDK 传入待混音的音频数据。
         @return true 表示设置成功，能收到混音回调；false 表示设置失败，不能收到混音回调。
         @note 若不再需要混音，调用 SetAuxCallback(null) 去除回调监听。
         @see 相关接口请查看 EnableAux
         */
        ZEGOAVKIT_API bool SetAuxCallback(IZegoAuxCallback* pCB);
        
        /**
         设置混音本地播放音量和推流音量
         
        @param volume 音量 0 ~ 200，默认为 100
         */
        ZEGOAVKIT_API void SetAuxVolume(int volume);
        
        /**
         设置混音本地播放音量
         
         @param volume 音量 0 ~ 200，默认为 100
         */
        ZEGOAVKIT_API void SetAuxPlayVolume(int volume);
        
        /**
         设置混音推流音量
         
         @param volume 音量 0 ~ 200，默认为 100
         */
        ZEGOAVKIT_API void SetAuxPublishVolume(int volume);
        
        /**
         混音静音开关
         
         @param bMute true: aux 输入播放静音，false: 不静音。默认 false
         @return true 成功，false 失败
         */
        ZEGOAVKIT_API bool MuteAux(bool bMute);
    }
}

#endif /* zego_api_audio_aux_h */
