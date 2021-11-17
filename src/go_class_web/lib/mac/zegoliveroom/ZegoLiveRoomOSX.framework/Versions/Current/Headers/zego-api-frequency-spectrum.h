
#ifndef zego_api_frequency_spectrum_hpp
#define zego_api_frequency_spectrum_hpp

#include <zego-api-defines.h>

namespace ZEGO
{
    namespace SPECTRUM
    {
        struct ZegoFrequencySpectrumInfo
        {
            ZegoFrequencySpectrumInfo()
            {
                szStreamID[0] = '\0';
                spectrumList = nullptr;
                spectrumCount = 0;
            }
            
            char szStreamID[ZEGO_MAX_COMMON_LEN];
            float *spectrumList;
            unsigned spectrumCount;
        };
        
        class IZegoFrequencySpectrumCallback
        {
        public:
            
            /**
             获取 拉流的 频域功率谱 信息

             @param pSpectrumInfoList 房间内所有流 （非自己推的流）的 频域功率谱 信息
             @param spectrumInfoCount 房间内采集的
             */
            virtual void OnFrequencySpectrumUpdate(ZegoFrequencySpectrumInfo *pSpectrumInfoList, unsigned int spectrumInfoCount) = 0;
            
            
            /**
             获取 采集的 频域功率谱 信息

             @param pCaptureSpectrumInfo 采集的 频率功率谱 信息
             */
            virtual void OnCaptrueFrequencySpectrumUpdate(ZegoFrequencySpectrumInfo *pCaptureSpectrumInfo) = 0;
            
            virtual ~IZegoFrequencySpectrumCallback() {}
        };
        
        
        /**
         设置获取 频域功率谱 的回调

         @param pCB 回调指针
         @return true 成功；false 失败
         */
        ZEGOAVKIT_API bool SetFrequencySpectrumCallback(IZegoFrequencySpectrumCallback *pCB);
        
        
        /**
         设置获取 频域功率谱 的监控周期

         @param timeInMS 时间间隔，最小值为10ms,默认为500ms
         
         @return true 成功；false 失败
         */
        ZEGOAVKIT_API bool SetFrequencySpectrumMonitorCycle(unsigned int timeInMS);
        
        
        /**
         启动 频域功率谱 监听

         @return true 成功；false 失败
         */
        ZEGOAVKIT_API bool StartFrequencySpectrumMonitor();
        
        
        /**
         停止 频域功率谱 监听

         @return true 成功；false 失败
         */
        ZEGOAVKIT_API bool StopFrequencySpectrumMonitor();
    }
}
#endif /* zego_api_frequency_spectrum_hpp */
