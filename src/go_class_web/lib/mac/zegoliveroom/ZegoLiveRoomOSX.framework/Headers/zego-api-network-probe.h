#ifndef zego_api_network_probe_h
#define zego_api_network_probe_h

#include "zego-api-network-probe-defines.h"

namespace ZEGO
{
    namespace NETWORKPROBE
    {
        class IZegoNetWorkProbeCallBack
        {
        public:
            /**
            网络测速模块连通回调 探测连接和测速都会回调此值

            @param errcode 0成功 非0失败
            @param info  链接的结果相关信息
            @param type  结果的类型
            */
            virtual void OnConnectResult(int errcode, const NetConnectInfo& info, PROBE_TYPE type) = 0;

            /**
            网络测速时的定时回调 

            @param netQuality为当前时刻的瞬时值
            @param type 该回调的类型
            */
            virtual void OnUpdateSpeed(const NetQuality& netQuality, PROBE_TYPE type) = 0;

            /**
            网络测速异常结束的回调。
            @param errcode  错误码
            @param type 该回调的类型
            */
            virtual void OnTestStop(int errcode, PROBE_TYPE type) = 0;

            virtual ~IZegoNetWorkProbeCallBack() {}

        };

        /**
         网络测速模块的回调值
         @param  callback 指针
        */
        ZEGOAVKIT_API void SetNetWorkProbeCallback(IZegoNetWorkProbeCallBack* pCallback);

        /**
         启动连通性测试 InitSDK 后调用 同一时间内与StartSpeedTest只有一个生效 推拉流会中断此操作
         此接口仅仅只会检测与zego服务的连通性，不会产生媒体数据
        */
        ZEGOAVKIT_API void StartConnectivityTest();

        /**
         停止连通性测试
        */
        ZEGOAVKIT_API void StopConnectivityTest();

        /**
         开始网络测速 InitSDK 后调用 同一时间内与StartConnectivityTest只有一个生效，启动推拉流会中断此操作
         不建议长时间测速，可能会影响推拉流体验

         @param bitrate 测速推流时的比特率 单位bps
        */
        ZEGOAVKIT_API void StartUplinkSpeedTest(int bitrate);

        /**
         设置网络测速时回调质量的时间间隔

         @param interval 测速时回调质量的时间间隔 单位ms
        */
        ZEGOAVKIT_API void SetQualityCallbackInterval(int interval);

        /*
         停止测速模块
        */
        ZEGOAVKIT_API void StopUplinkSpeedTest();

        /**
        开始下行网络测速 InitSDK 后调用 同一时间内与StartConnectivityTest只有一个生效，启动推拉流会中断此操作
        不建议长时间测速，可能会影响推拉流体验

        @param bitrate 测速推流时的比特率 单位bps
        */
        ZEGOAVKIT_API void StartDownlinkSpeedTest(int bitrate);

        /*
         停止下行测速模块
        */
        ZEGOAVKIT_API void StopDownlinkSpeedTest();
    }
}
#endif

