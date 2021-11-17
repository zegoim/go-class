#ifndef zego_api_audio_processing_h
#define zego_api_audio_processing_h

namespace ZEGO
{
    namespace AUDIOPROCESSING
    {
        /** 音频混响模式
         * @deprecated 请参考 ZegoAVAPIVoiceReverbType 及 SetReverbPreset(ZegoAVAPIVoiceReverbType)
        */
        enum ZegoAVAPIAudioReverbMode
        {
            /** 房间模式 */
            ZEGO_AUDIO_REVERB_MODE_SOFT_ROOM = 0,
            /** 俱乐部（大房间）模式 */
            ZEGO_AUDIO_REVERB_MODE_WARM_CLUB = 1,
            /** 音乐厅模式 */
            ZEGO_AUDIO_REVERB_MODE_CONCERT_HALL = 2,
            /** 大教堂模式 */
            ZEGO_AUDIO_REVERB_MODE_LARGE_AUDITORIUM = 3,
        };

        /**
         预设的音频混响效果
         @see SetReverbPreset(ZegoAVAPIVoiceReverbType)
         */
        enum ZegoAVAPIVoiceReverbType
        {
            /** 关闭混响 */
            ZEGO_AUDIO_REVERB_TYPE_OFF = 0,
            /** 房间模式 */
            ZEGO_AUDIO_REVERB_TYPE_SOFT_ROOM = 1,
            /** 俱乐部（大房间）模式 */
            ZEGO_AUDIO_REVERB_TYPE_WARM_CLUB = 2,
            /** 音乐厅模式 */
            ZEGO_AUDIO_REVERB_TYPE_CONCERT_HALL = 3,
            /** 大教堂模式 */
            ZEGO_AUDIO_REVERB_TYPE_LARGE_AUDITORIUM = 4,
            /** 录音棚 */
            ZEGO_AUDIO_REVERB_TYPE_RECORDING_STUDIO = 5,
            /** 地下室 */
            ZEGO_AUDIO_REVERB_TYPE_BASEMENT = 6,
            /** KTV */
            ZEGO_AUDIO_REVERB_TYPE_KTV = 7,
            /** 流行 */
            ZEGO_AUDIO_REVERB_TYPE_POPULAR = 8,
            /** 摇滚 */
            ZEGO_AUDIO_REVERB_TYPE_ROCK = 9,
            /** 演唱会 */
            ZEGO_AUDIO_REVERB_TYPE_VOCAL_CONCERT = 10,
        };

        /**
         变声器类型
         @see SetVoicePreset(ZegoAVAPIVoiceChangerType)
         */
        enum ZegoAVAPIVoiceChangerType
        {
            /** 恢复原声 */
            ZEGO_VOICE_CHANGER_TYPE_CHANGER_OFF = 0,
            /** 擎天柱音效 */
            ZEGO_VOICE_CHANGER_TYPE_OPTIMUS_PRIME = 1,
            /** AI机器人音效 */
            ZEGO_VOICE_CHANGER_TYPE_AI_ROBOT = 2,
            /** 外国人音效 */
            ZEGO_VOICE_CHANGER_TYPE_FOREIGNER = 3,
            /** 空灵音效 */
            ZEGO_VOICE_CHANGER_TYPE_ELUSIVE = 4,
            /** 磁性男声音效 */
            ZEGO_VOICE_CHANGER_TYPE_MALE_MAGNETIC = 5,
            /** 清新女声音效 */
            ZEGO_VOICE_CHANGER_TYPE_FEMALE_FRESH = 6,
            /** 男声变童声 */
            ZEGO_VOICE_CHANGER_TYPE_MEN_TO_CHILD = 7,
            /** 男声变女声 */
            ZEGO_VOICE_CHANGER_TYPE_MEN_TO_WOMEN = 8,
            /** 女声变童声 */
            ZEGO_VOICE_CHANGER_TYPE_WOMEN_TO_CHILD = 9,
            /** 女声变男声 */
            ZEGO_VOICE_CHANGER_TYPE_WOMEN_TO_MEN = 10,
        };

        /**
         * 无变声音效 值: 0.0
         * @deprecated see ZegoAVAPIVoiceChangerType::ZEGO_VOICE_CHANGER_TYPE_CHANGER_OFF
         */
        extern const float ZEGO_VOICE_CHANGER_NONE;
        
        /**
         * 女声变男声 值: -3.0
         * @deprecated see ZegoAVAPIVoiceChangerType::ZEGO_VOICE_CHANGER_TYPE_WOMEN_TO_MEN
         */
        extern const float ZEGO_VOICE_CHANGER_WOMEN_TO_MEN;

        /**
         * 男声变女声 值: 4.0
         * @deprecated see ZegoAVAPIVoiceChangerType::ZEGO_VOICE_CHANGER_TYPE_MEN_TO_WOMEN
         */
        extern const float ZEGO_VOICE_CHANGER_MEN_TO_WOMEN;

        /**
         * 女声变童声 值: 6.0
         * @deprecated see ZegoAVAPIVoiceChangerType::ZEGO_VOICE_CHANGER_TYPE_WOMEN_TO_CHILD
         */
        extern const float ZEGO_VOICE_CHANGER_WOMEN_TO_CHILD;

        /**
         * 男声变童声 值: 8.0
         * @deprecated see ZegoAVAPIVoiceChangerType::ZEGO_VOICE_CHANGER_TYPE_MEN_TO_CHILD
         */
        extern const float ZEGO_VOICE_CHANGER_MEN_TO_CHILD;
        
        /**
         音频混响参数
         */
        struct ZegoAVAPIReverbParams
        {
            /** 房间大小，取值范围[0.0, 1.0]，用于控制产生混响"房间"的大小，房间越大，混响越强 */
            float roomSize;
            
            /** 余响，取值范围[0.0, 0.5]，用于控制混响的拖尾长度 */
            float reverberance;
            
            /** 混响阻尼， 取值范围[0.0， 2.0]，控制混响的衰减程度，阻尼越大，衰减越大 */
            float damping;
            
            /** 干湿比，取值范围 >= 0.0。 控制混响与直达声和早期反射声之间的比例，干(dry)的部分默认定为1，当干湿比设为较小时，湿(wet)的比例较大，此时混响较强 */
            float dryWetRatio;

            ZegoAVAPIReverbParams()
            {
                roomSize = 0;
                reverberance = 0;
                damping = 0;
                dryWetRatio = 0;
            }
        };

        struct ZegoAVAPIAdvancedReverbParams
        {
            /** Room Size (%): [0,100].Sets the size of the simulated room. 0% is like a closet, 100% is like a huge cathedral or large auditorium. A high value will simulate the reverberation effect of a large room and a low value will simulate the effect of a small room. */
            float roomSize;
            /** Pre-delay (ms):[0~200]. Delays the onset of the reverberation for the set time after the start of the original input. This also delays the onset of the reverb tail. Careful adjustment of this parameter can improve the clarity of the result. */
            float preDelay;
            /** Reverberance (%):[0,100]. Sets the length of the reverberation tail. This determines how long the reverberation continues for after the original sound being reverbed comes to an end, and so simulates the "liveliness" of the room acoustics. For any given reverberance value, the tail will be greater for larger room sizes. */
            float reverberance;
            /** Damping (%):[0,100]. Increasing the damping produces a more "muted" effect. The reverberation does not build up as much, and the high frequencies decay faster than the low frequencies. Simulates the absorption of high frequencies in the reverberation. */
            float hfDamping;
            /** ToneLow(%):[0,100]. Setting this control below 100% reduces the low frequency components of the reverberation, creating a less "boomy" effect. */
            float toneLow;
            /** ToneHigh(%):[0,100].Setting this control below 100% reduces the high frequency components of the reverberation, creating a less "bright" effect. */
            float toneHigh;
            /** Wet Gain (dB):[-20,10]. Applies volume adjustment to the reverberation ("wet") component in the mix. Increasing this value relative to the "Dry Gain" (below) increases the strength of the reverb. */
            float wetGain;
            /** Dry Gain (dB):[-20,10]. Applies volume adjustment to the original ("dry") audio in the mix. Increasing this value relative to the "Wet Gain" (above) reduces the strength of the reverb. If the Wet Gain and Dry Gain values are the same, then the mix of wet effect and dry audio to be output to the track will be made louder or softer by exactly this value. */
            float dryGain;
            /** Stereo Width (%): [0,100]. Sets the apparent "width" of the Reverb effect for stereo tracks only. Increasing this value applies more variation between left and right channels, creating a more "spacious" effect. When set at zero, the effect is applied independently to left and right channels. */
            float stereoWidth;
            /** Wet Only */
            bool  wetOnly;

            ZegoAVAPIAdvancedReverbParams()
            {
                roomSize = 0;
                preDelay = 0;
                reverberance = 0;
                hfDamping = 0;
                toneLow = 0;
                toneHigh = 0;
                wetGain = 0;
                dryGain = 0;
                stereoWidth = 0;
                wetOnly = false;
            }
        };

        /**
         回声效果参数
         */
        struct ZegoAVAPIReverbEchoParams
        {
            /** 回声数，取值范围[0, 7] */
            int    numDelays;

            /** 输入音频信号的增益，取值范围[0.0, 1.0] */
            float  inGain;

            /** 输出音频信号的增益，取值范围[0.0, 1.0] */
            float  outGain;

            /** 回声信号分别的延时，取值范围[0, 5000] ms */
            int    delay[7];

            /** 回声信号分别的增益值，取值范围[0.0, 1.0] */
            float  decay[7];
        };
        
        /**
         设置虚拟立体声

         @param enable true 开启，false 关闭
         @param angle 虚拟立体声中声源的角度，范围为0～180，90为正前方，0和180分别对应最右边和最左边
         @return true 成功，false 失败
         @discussion  必须在初始化 SDK 后调用，并且需要设置双声道 ZEGO::LIVEROOM::SetAudioChannelCount,
                      推流成功后动态设置不同的 angle 都会生效
         */
        ZEGOAVKIT_API bool EnableVirtualStereo(bool bEnable, int angle);
    
        /**
         设置音频混响
         
         @param enable true 开启，false 关闭
         @param mode 混响模式，参考 ZegoAVAPIAudioReverbMode
         @return true 成功，false 失败
         @discussion 必须在初始化 SDK 后调用，推流成功后动态设置不同的 mode 都会生效
         @deprecated 请使用 SetReverbPreset(ZegoAVAPIVoiceReverbType)
         */
        ZEGOAVKIT_API bool EnableReverb(bool bEnable, ZegoAVAPIAudioReverbMode mode);
        
        /**
         设置音频混响参数

         @param roomSize 房间大小，取值范围 0.0 ~ 1.0。 值越大说明混响时间越长，产生的混响拖尾效应越大
         @param dryWetRatio 干湿比，取值范围 >= 0.0。 干湿比的值越小，wet的值越大，产生的混响效果越大
         @return true 成功，false 失败
         @discussion 任意一个参数设置为0.0时，混响关闭
         @discussion 必须在初始化 SDK 后调用，推流成功后动态设置不同的 mode 都会生效
         @deprecated 请使用 SetAdvancedReverbParam(bool, ZegoAVAPIAdvancedReverbParams)
         */
        ZEGOAVKIT_API bool SetReverbParam(float roomSize, float dryWetRatio);
        
        
        /**
         设置音频混响参数

         @param params 混响参数，各个参数含义参考 ZegoAVAPIReverbParams 的定义
         @return true 成功，false 失败
         @discussion 必须在初始化 SDK 后调用，推流成功后可动态修改
         */
        ZEGOAVKIT_API bool SetReverbParam(ZegoAVAPIReverbParams params);

        /**
         设置音频混响高级参数

         @param bEnable true 开启混响功能; false 关闭混响功能, 此时会忽略 config 参数
         @param config 混响参数，各变量含义参考 ZegoAVAPIAdvancedReverbParams 定义
         @return true 设置成功，false 设置失败
         @discussion 必须在初始化 SDK 后调用，推流成功后可动态修改参数值
         @discussion 理论上所有混响效果都可以通过调整此参数的组合值得到
         */
        ZEGOAVKIT_API bool SetAdvancedReverbParam(bool bEnable, ZegoAVAPIAdvancedReverbParams config);

        /**
         预设混响效果

         @param type 预设的混响效果，参考 ZegoAVAPIVoiceReverbType 定义
         @return true 设置成功，false 设置失败
         @discussion 必须在初始化 SDK 后调用，推流成功后可动态修改混响效果
         */
        ZEGOAVKIT_API bool SetReverbPreset(ZegoAVAPIVoiceReverbType type);
        
        /**
         设置变声器参数

         @param param 变声器参数
         @return true 成功，false 失败
         @discussion 必须在初始化 SDK 后调用
         @discussion 变声音效只针对采集的声音有效
         @discussion 取值[-8.0, 8.0]，几种典型的变声音效(男变女，女变男等)定义见上文
         */
        ZEGOAVKIT_API bool SetVoiceChangerParam(float param);

        /**
         设置音频回声参数

         @param params 音频回声参数，参考ZegoAVAPIReverbEchoParams
         @return true 成功，false 失败
         @discussion 必须在初始化 SDK 后调用，支持推流成功后动态设置
         */
        ZEGOAVKIT_API bool SetReverbEchoParam(ZegoAVAPIReverbEchoParams params);
    
        /**
        预设变声配置

        @param type 变声器类型，参考ZegoAVAPIVoiceChangerType
        @return true 成功，false 失败
        @discussion 必须在初始化 SDK 后调用
        @discussion 变声音效只针对采集的声音有效
        @discussion 该接口的效果可由SetReverbParam、SetVoiceChangerParam、SetReverbEchoParam组合实现，
                    调用该接口后，若想有单独调用上述接口的效果，需先调用
                    SetVoicePreset(ZEGO_VOICE_CHANGER_TYPE_CHANGER_OFF)还原配置
        */
        ZEGOAVKIT_API bool SetVoicePreset(ZegoAVAPIVoiceChangerType type);

        /**
         调整音效均衡器参数

         @param bandIndex 取值范围[0, 9]。分别对应10个频带，其中心频率分别是[31, 62, 125, 250, 500, 1K, 2K, 4K, 8K, 16K]Hz
         @param bandGain 取值范围[-15, 15]。默认值是0，如果所有频带的增益值全部为0，则会关闭EQ功能
         @note 在 InitSDK 之后调用有效。使用此接口前请与即构技术支持联系确认是否支持此功能
         */
        ZEGOAVKIT_API bool SetAudioEqualizerGain(int bandIndex, float bandGain);
    }
}

#endif /* zego_api_audio_processing_h */
