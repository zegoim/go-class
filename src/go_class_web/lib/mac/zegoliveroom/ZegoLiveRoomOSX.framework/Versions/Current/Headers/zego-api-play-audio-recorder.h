#ifndef zego_api_play_audio_recorder_h
#define zego_api_play_audio_recorder_h

#include "audio_in_output.h"
#include <zego-api-defines.h>

namespace ZEGO
{
    namespace AUDIORECORDER
    {
        class IZegoPlayAudioRecorderCallback
        {
        public:
            /**
             当前播放流的音频数据
             
             @param streamID 流 ID；
             @param frame 音频数据
             @discussion 音频数据在拉流线程回调，如果开发者自己渲染，需要立即执行选择; 如果开发者对数据处理，拷贝到其他线程处理，占用大量时间会导致拉流线程等待。
             */
            virtual void OnPlayAudioRecorder(const char *streamID, const AVE::AudioFrame frame) = 0;
            
            virtual ~IZegoPlayAudioRecorderCallback() {}
        };
        
        
        /**
         设置是否开启拉流音频数据回调

         @param enable 开启
         @param sampleRate 数据采样率，取值 0， 16000， 32000， 44100， 48000，0表示使用原数据采样率，不做采样转换
         @param channels 数据通道数，取值0，1，2，0表示使用原数据通道数
         */
        ZEGOAVKIT_API void EnablePlayAudioRecorder(bool enable, int sampleRate, int channels);
        
        /**
         设置音频数据的回调
         
         @param callback 音频数据回调
         @discussion 未设置回调，不会有音频数据回调
         */
        ZEGOAVKIT_API bool SetPlayAudioRecorderCallback(IZegoPlayAudioRecorderCallback *callback);
    }
}

#endif /* zego_api_play_audio_recorder_h */
