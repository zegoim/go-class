#ifndef zego_api_network_probe_defines_h
#define zego_api_network_probe_defines_h

#include "zego-api-defines.h"

namespace ZEGO
{
    namespace NETWORKPROBE
    {
        enum PROBE_TYPE
        {
            TYPE_CONNECT = 1,       //连通性测试
            TYPE_UPLINK_SPEED = 2,  //上行测速
            TYPE_DOWNLINK_SPEED = 3 //下行测速
        };

        struct NetConnectInfo
        {
            int connectcost;

            NetConnectInfo()
            {
                connectcost = 0;
            }
        };

        struct NetQuality
        {
            int connectcost; 
            int rtt;
            int pktlostrate;
            int quality;

            NetQuality()
            {
                connectcost = 0;
                rtt = 0;
                pktlostrate = 0;
                quality = 0;
            }
        };
    }
}

#endif
