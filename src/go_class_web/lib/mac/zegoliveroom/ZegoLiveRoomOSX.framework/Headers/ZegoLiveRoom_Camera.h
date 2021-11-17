#ifndef ZegoLiveRoom_Camera_h
#define ZegoLiveRoom_Camera_h

#include "video_capture.h"

#ifndef ZEGO_API
    #ifdef WIN32
        #ifdef ZEGO_EXPORTS
            #define ZEGO_API __declspec(dllexport)
        #else
            #define ZEGO_API __declspec(dllimport)
        #endif
    #else
        #define ZEGO_API __attribute__((visibility("default")))
    #endif
#endif

#ifdef __cplusplus
extern "C" {
#endif
    
    ZEGO_API AVE::Camera* zego_liveroom_create_camera();
    
    ZEGO_API void zego_liveroom_destroy_camera(AVE::Camera *pCamera);
    
#ifdef __cplusplus
}
#endif

#endif
