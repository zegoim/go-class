//
//  zego-api-mix-stream-defines.h
//
//  Copyright © 2018年 Zego. All rights reserved.
//

#ifndef zego_api_mix_stream_defines_h
#define zego_api_mix_stream_defines_h

#include "zego-api-defines.h"
#include <cstddef>

namespace ZEGO
{
namespace MIXSTREAM
{
    
    /**
     混流输入流配置信息
     */
    struct ZegoMixStreamInput
    {
        /**
         要混流的单流ID
         */
        char szStreamID[ZEGO_MAX_COMMON_LEN];
        struct
        {
            /**
             混流画布左上角坐标的第二个值，左上角坐标为 (left, top)
             */
            int top;
            /**
             混流画布左上角坐标的第一个值，左上角坐标为 (left, top)
             */
            int left;
            /**
             混流画布右下角坐标的第二个值，右下角坐标为 (right, bottom)
             */
            int bottom;
            /**
             混流画布右下角坐标的第一个值，右下角坐标为 (right, bottom)
             */
            int right;
        } layout;
        /**
         音浪ID，用于标识用户（比如拉取混流方可根据此标识明确到混流中的单条流是主播/观众/副主播），soundLevelID 必须大于等于 0 且小于等于 4294967295L（即2^32-1）
         */
        unsigned int uSoundLevelID;
        /**
         推流内容控制， 0 表示输出的混流包含音视频，1 表示只包含音频，2 表示只包含视频；默认值为 0。
         */
        int nContentControl;
        /**
         输入流音量, 有效范围 [0, 200], 默认是 100
         */
        int nVolume;
        
        ZegoMixStreamInput ()
        : uSoundLevelID(0)
        , nContentControl(0)
        , nVolume(100)
        {
            szStreamID[0] = '\0';
            layout.top = 0;
            layout.left = 0;
            layout.bottom = 0;
            layout.right = 0;
        }
        /**
         *  原点在左上角，top/bottom/left/right 定义如下：
         *
         *  (left, top)-----------------------
         *  |                                |
         *  |                                |
         *  |                                |
         *  |                                |
         *  -------------------(right, bottom)
         */
    };
    
    /**
     混流输出目的地
     */
    struct ZegoMixStreamOutput
    {
        /**
         输出流是否为 URL
         */
        bool isUrl;
        /**
         isUrl 参数为 true 时，则此值为 Url；否则为流名。
         */
        char target[ZEGO_MAX_COMMON_LEN];

        ZegoMixStreamOutput()
        {
            isUrl = false;
            target[0] = '\0';
        }
    };
    
    /**
     混流水印信息
     */
    struct ZegoMixStreamWatermark
    {
        /**
         水印图片 ，只支持png、jpg格式。
         
         * 此值由 ZEGO 提供，开发者先将图片提供给 ZEGO，ZEGO 设置后再反馈水印图片的设置参数。
         */
        char image[ZEGO_MAX_COMMON_LEN];
        
        struct
        {
            /**
             混流画布左上角坐标的第二个值，左上角坐标为 (left, top)
             */
            int top;
            /**
             混流画布左上角坐标的第一个值，即左上角坐标为 (left, top)
             */
            int left;
            /**
             混流画布右下角坐标的第二个值，右下角坐标为 (right, bottom)
             */
            int bottom;
            /**
             混流画布右下角坐标的第一个值，右下角坐标为 (right, bottom)
             */
            int right;
        } layout;
        /**
         *  原点在左上角，top/bottom/left/right 定义如下：
         *
         *  (left, top)-----------------------
         *  |                                |
         *  |                                |
         *  |                                |
         *  |                                |
         *  -------------------(right, bottom)
         */

        ZegoMixStreamWatermark()
        {
            image[0] = '\0';
            layout.top = 0;
            layout.left = 0;
            layout.bottom = 0;
            layout.right = 0;
        }
    };
    
    
    /**
     混流配置
     */
    struct ZegoMixStreamConfig
    {
        /**
         * 混流输出视频帧率，值范围：[1,30]，根据网络情况设定该值，帧率越高画面越流畅。
         */
        int nOutputFps;
        /**
         * 混流输出码率控制模式，0 表示 CBR 恒定码率，1 表示 CRF 恒定质量，默认值为 0。
         
         * CRF 恒定质量 表示保证视频的清晰度在固定水平上，因此若采用此控制模式，码率会根据网速的变化波动。
         
         * 比如游戏类直播时，为了让观众看到比较流畅的操作类画面会使用恒定质量模式，提升视频质量。
         */
        int nOutputRateControlMode;
        /**
         * 混流输出视频码率，输出码率控制模式参数设置为 CBR恒定码率 时此设置值生效。
         
         * 视频码率值范围：(0M,10M]，此参数单位是 bps，1M = 1 * 1000 * 1000 bps
         */
        int nOutputBitrate;
        /**
         * 混流输出质量，输出码率控制模式参数设置为 CRF恒定质量 时此设置值有效，有效值范围 [0,51]，默认值是 23。
       
         * 若想视频质量好点，在23的基础上降低质量值测试调整。
       
         * 若想文件大小小一点，在23的基础上升高质量值测试调整；
       
         * 以 x 值下的文件大小为例， x + 6 值下的文件大小是 x 值下文件大小的一半，x - 6 值下的文件大小是 x 值下文件大小的两倍。
         */
        int nOutputQuality;
        /**
         * 混流输出音频码率，码率范围值是[10000, 192000]。
         
         * 若音频编码格式采用 默认音频编码--即 nOutputAudioConfig 参数填 0，采用 1/2声道时，对应的建议码率值是 48k/64k，可根据需要在此基础上调整。
         
         * 若音频编码格式采用 可选音频编码--即 nOutputAudioConfig 参数填 1，采用 1/2声道时，对应的建议码率值是 80k/128k，可根据需要在此基础上调整。
         */
        int nOutputAudioBitrate;
        /**
         * 混流输出视频分辨率宽，不确定用什么分辨率时可采用16:9的规格设置。
         
         * 此值必须大于等于 输入流列表中所有输入流中最大的分辨率宽，即right布局值，且输入流的布局位置不能超出此值规定的范围。
         */
        int nOutputWidth;
        /**
         * 混流输出视频分辨率高，不确定用什么分辨率时可采用16:9的规格设置。
         
         * 此值必须大于等于 输入流列表中所有输入流中最大的分辨率高，即bottom布局值，且输入流的布局位置不能超出此值规定的范围。
         */
        int nOutputHeight;
        /**
         * 混流输出音频编码格式，可选值为 0--默认编码，1--可选编码；默认值为 0。
         
         * 0--默认编码：在低码率下，编码后的音质要明显好于 1--可选编码，在码率较大后，达到128kbps及以上，两种编码后的音质近乎相同。
         
         * 1--可选编码：优点在于低复杂性，能兼容更多的设备播放；但是目前经过 0--默认编码 编码后的音频不能正常播放的情况很少。
         */
        int nOutputAudioConfig;
        /**
         混流输入流列表，SDK 根据输入流列表中的流进行混流。
         */
        ZegoMixStreamInput* pInputStreamList;
        /**
         混流输入流列表个数
         */
        int nInputStreamCount;
        /**
         混流输出流列表
         */
        ZegoMixStreamOutput* pOutputList;
        /**
         混流输出流列表个数
         */
        int nOutputStreamCount;                     /**< 混流输出列表个数 */
        /**
         用户自定义数据
         @note 注意：pUserData自定义的数据通过媒体次要信息的 onRecvMediaSideInfo 接口回调出来。
         */
        const unsigned char * pUserData;
        /**
         用户自定义数据的长度
         */
        int nLenOfUserData;
        /**
         混流声道数，1-单声道，2-双声道，默认为单声道。
         */
        int nChannels;
        /**
         * 混流背景颜色，前三个字节为 RGB，即 0xRRGGBBxx。
         
         * 例如：选取RGB为 #87CEFA 作为背景色，此处写为 0x87CEFA00。
         */
        int nOutputBackgroundColor;
        /**
         * 混流背景图，支持预设图片，如 (preset-id://xxx)
         
         * 此值由 ZEGO 提供，开发者先将背景图提供给 ZEGO，ZEGO 设置后再反馈背景图片的设置参数。
         */
        const char* pOutputBackgroundImage;
        /**
         是否开启音浪。true：开启，false：关闭；默认值是false。
         */
        bool bWithSoundLevel;
        /**
         扩展信息，备用。
         */
        int nExtra;
        /**
         混流水印
         */
        ZegoMixStreamWatermark *pOutputWatermark;
        /**
         * 混流输入为一条流时，是否混流；非必填参数。true：不对单流混流，混流输出的流属性与单流一致(分辨率，编码格式等)，混流配置中设置的分辨率等配置无效；false：混单流，混流服务器会对此单流重新编解码，混流输出的流属性与混流配置相同。
         
         * 若需要开启此功能，请与即构技术支持联系。
         */
        bool bSingleStreamPassThrough;
        /**
         * 高级配置选项，适用于某些定制化的需求，格式 "config1=xxx;config2=xxx"。
         * 请与即构技术支持联系了解可支持字段。
         */
        const char *pAdvancedConfig;               
        
        ZegoMixStreamConfig ()
        : nOutputFps(0)
        , nOutputRateControlMode(0)
        , nOutputBitrate(0)
        , nOutputQuality(23)
        , nOutputAudioBitrate(0)
        , nOutputWidth(0)
        , nOutputHeight(0)
        , nOutputAudioConfig(0)
        , pInputStreamList(0)
        , nInputStreamCount(0)
        , pOutputList(0)
        , nOutputStreamCount(0)
        , pUserData(0)
        , nLenOfUserData(0)
        , nChannels(1)
        , nOutputBackgroundColor(0x00000000)
        , pOutputBackgroundImage(0)
        , bWithSoundLevel(false)
        , nExtra(0)
        , pOutputWatermark(0)
        , bSingleStreamPassThrough(false)
        , pAdvancedConfig(NULL)
        {
            
        }
    };
    
}
}

#endif /* zego_api_mix_stream_defines_h */
