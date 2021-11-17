#ifndef zego_api_network_trace_h
#define zego_api_network_trace_h

#include "zego-api-network-trace-defines.h"

namespace ZEGO
{
    namespace NETWORKTRACE
    {
        class IZegoNetworkTraceCallBack
        {
        public:
            IZegoNetworkTraceCallBack() {}
            virtual ~IZegoNetworkTraceCallBack() {}
            /**
            网络模块测试回调值
            @param code   错误码 0 成功操作
            @param result  链接的结果相关信息
            */
            virtual void OnNetworkTrace(unsigned int code, const NetworkTraceResult& result) = 0;

        };

        /**
         网络模块测试 回调值 调用时机InitSDK 后调用
         @param  callback 指针
        */
        ZEGOAVKIT_API void SetNetworkTraceCallback(IZegoNetworkTraceCallBack* pCallback);

        /**
         开启网络模块测试
         @param  config 指针 参见NetworkTraceConfig
        */
        ZEGOAVKIT_API void StartNetworkTrace(const NetworkTraceConfig& config);

        /**
         停止网络模块测试
        */
        ZEGOAVKIT_API void StopNetworkTrace();

    }
}
#endif

