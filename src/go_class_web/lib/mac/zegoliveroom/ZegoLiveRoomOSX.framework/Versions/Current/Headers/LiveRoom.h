//
//  ZegoLiveRoom.h
//  zegoliveroom
//
//  Copyright © 2017年 Zego. All rights reserved.
//

#ifndef ZegoLiveRoom_h
#define ZegoLiveRoom_h

#include "./LiveRoomDefines.h"
#include "./LiveRoomCallback.h"
#include "./LiveRoomDefines-IM.h"

namespace ZEGO
{
	namespace LIVEROOM
	{
        
        /**
         获取SDK版本号

         @return 版本号
         */
        ZEGO_API const char* GetSDKVersion();
        
        
        /**
         获取SDK版本号2

         @return 版本号2
         */
        ZEGO_API const char* GetSDKVersion2();

        /**
         日志hook 的回调函数

         @param logHook 日志的回调函数 建议外部static 函数，
         @attention  1、回调信息为加密信息(需要zego解密工具解密)
                             2、设置此日志回调之后sdk 将不会在写日志文件
                             3、调用时机,应该最早时机调用此接口 InitSDK之前
        */
        ZEGO_API void SetLogHook(void(*log_hook)(const char* message));

        
        /**
         设置日志路径和大小

         @param pszLogDir 日志路径
         @param lLogFileSize 单个日志文件大小, 有效范围[1*1024*1024, 100*1024*1024], 默认 5*1024*1024 字节。当设置为 0 时，不写日志（不推荐，当 SDK 出问题时无法定位原因）
         @param pszSubFolder 日志子目录，如果指定了子目录，则日志文件会存放在此子目录下
         @return true 成功；flase 失败.
         */
        ZEGO_API bool SetLogDirAndSize(const char* pszLogDir, unsigned long long lLogFileSize = ZEGO_DEFAULT_LOG_SIZE, const char* pszSubFolder = nullptr);
        
	
        /**
         上传日志
         */
        ZEGO_API void UploadLog();
        
        
        /**
         设置是否开启调试信息

         @param bVerbose 控制开关 
         @attention  建议SetLogDirAndSize后 initSDK前调用 , 启用后,控制台会输出用户调用信息，并且会在SDK日志目录生成 明文的用户可见的日志文件
         */
        ZEGO_API void SetVerbose(bool bVerbose);
        
        
        /**
         设置是否使用测试环境

         @param bTestEnv 测试环境
         */
        ZEGO_API void SetUseTestEnv(bool bTestEnv);
        

        /**
         设置业务类型

         @param nType 业务类型，取值 0（直播类型）或 2（实时音视频类型）。默认为 0
         @return true 成功，false 失败
         @attention 确保在创建接口对象前调用
         */
        ZEGO_API bool SetBusinessType(int nType);
        
        
        /**
         设置用户信息

         @param pszUserID 用户唯一 ID
         @param pszUserName 用户名字
         @return true 成功，false 失败
         */
        ZEGO_API bool SetUser(const char* pszUserID, const char* pszUserName);

        /**
         获取用户信息

         @return UserID
         */
        ZEGO_API const char* GetUserID();

        /**
         设置SDK线程回调observe，将会回调SDK 主线程执行相关耗时  建议 外部static 函数

        @param OnRunLoopObserveCallback observe回调的callback
        @param taskId sdk主线程taskid
        @param type 任务类型 参见ZegoTaskType
        @param taskDispatchTime 任务调度消耗时间 单位ms
        @param taskRunTime 任务执行消耗时间 单位ms
        @param taskTotalTime 任务总耗时，单位ms 一般情况只需关注此时间即可
		@attention 注意此非线程安全，外部不应该在回调线程做耗时操作。建议InitSDK 前调用 UnInitSDK会清除此回调 
        */
        ZEGO_API void SetRunLoopObserveCallback(void(*OnRunLoopObserveCallback)(unsigned int taskId, AV::ZegoTaskType type, int taskDispatchTime, int taskRunTime, int taskTotalTime));
        
        /**
         初始化引擎

         @param jvm jvm 仅用于 Android
         @param ctx ctx 仅用于 Android
         @param clsLoader 仅用于 Android
         @return true 成功，false 失败
        */
        ZEGO_API bool InitPlatform(void* jvm = 0, void* ctx = 0, void* clsLoader = 0);
        
        /**
         初始化 SDK

         @param uiAppID Zego 派发的数字 ID, 各个开发者的唯一标识
         @param pBufAppSignature Zego 派发的签名, 用来校验对应 appID 的合法性
         @param nSignatureSize 签名长度（字节）
         @return true 成功，false 失败
         @note 初始化 SDK 失败可能导致 SDK 功能异常
         */
        ZEGO_API bool InitSDK(unsigned int uiAppID, unsigned char* pBufAppSignature, int nSignatureSize);
        
        /**
         反初始化 SDK

         @return true 成功，false 失败
         */
        ZEGO_API bool UnInitSDK();
        
        /**
         设置直播房间相关信息通知的回调

         @param pCB 回调对象指针
         @return true 成功，false 失败
         */
        ZEGO_API bool SetRoomCallback(IRoomCallback* pCB);

        /**
         设置房间配置信息

         @param audienceCreateRoom 观众是否可以创建房间。true 可以，false 不可以。默认 true
         @param userStateUpdate 用户状态（用户进入、退出房间）是否广播。true 广播，false 不广播。默认 false
         @discussion 1、在登录房间前调用有效，退出房间后失效。
                     2、userStateUpdate为房间属性而非用户属性，设置的是该房间内是否会进行用户状态的广播。如果需要在房间内用户状态改变时，其他用户能收到通知，请为所有用户设置为true；反之，设置为false。设置为true后，方可从OnUserUpdate回调收到用户状态变更通知
         */
        ZEGO_API void SetRoomConfig(bool audienceCreateRoom, bool userStateUpdate);
        
        /**
         设置自定义token信息
         
         @param thirdPartyToken 第三方传入的token
         @discussion 使用此函数验证登录时用户的合法性，登录房间前调用，token的生成规则请联系即构。若不需要验证用户合法性，不需要调用此函数
         @discussion 在登录房间前调用有效，退出房间后失效
         */
        ZEGO_API void SetCustomToken(const char *thirdPartyToken);
        
        
        /**
         设置房间最大在线人数

         @param maxCount 最大人数
         @discussion 在登录房间前调用有效，退出房间后失效
         */
        ZEGO_API void SetRoomMaxUserCount(unsigned int maxCount);
        
        /**
         登录房间

         @param pszRoomID 房间 ID
         @param role 成员角色, 参见 ZegoRoomRole
         @param pszRoomName 房间名称
         @return true 成功，false 失败
         */
        ZEGO_API bool LoginRoom(const char* pszRoomID, int role, const char* pszRoomName = "");

        /**
         退出房间

         @return 成功，false 失败
         @attention 退出登录后，等待 IRoomCallback::OnLogoutRoom 回调
         @note 退出房间会停止所有的推拉流
         */
        ZEGO_API bool LogoutRoom();
        
        /**
        切换房间 调用成功会停止调用该接口之前的推拉流(注意：登录房间成功后，需要快速切换到其它房间时使用，切换结果回调OnLoginRoom,也会停止MultiRoom的拉流)  

        @param pszRoomID 房间 ID
        @param role 成员角色, 参见 ZegoRoomRole
        @param pszRoomName 房间名称
        @return true 成功，false 失败
        */
        ZEGO_API bool SwitchRoom(const char* pszRoomID, int role, const char* pszRoomName = "");

        /**
         发送自定义信令

         @param memberList 信令发送成员列表
         @param memberCount 成员个数
         @param content 信令内容
         @return 消息 seq
         */
        ZEGO_API int SendCustomCommand(ROOM::ZegoUser *memberList, unsigned int memberCount, const char *content);
        
        /**
         设置直播事件回调

         @param pCB 回调对象指针
         */
        ZEGO_API void SetLiveEventCallback(AV::IZegoLiveEventCallback* pCB);
        
        /**
         设置音频视频设备变化的回调

         @param pCB 回调对象指针
         */
        ZEGO_API void SetDeviceStateCallback(AV::IZegoDeviceStateCallback *pCB);

        /**
         设置网络类型回调

         @param pCB 回调对象指针
         */
        ZEGO_API void SetNetTypeCallback(AV::IZegoNetTypeCallback* pCB);
        
        //
        // * device
        //

        /**
         获取音频设备列表

         @param deviceType 设备类型
         @param device_count 设备数量
         @return 音频设备列表
         */
        ZEGO_API AV::DeviceInfo* GetAudioDeviceList(AV::AudioDeviceType deviceType, int& device_count);
        
        /**
         设置选用音频设备

         @param deviceType 设备类型
         @param pszDeviceID 设备 ID
         @return true 成功，false 失败
         */
        ZEGO_API bool SetAudioDevice(AV::AudioDeviceType deviceType, const char* pszDeviceID);
        
        /**
	      获取视频设备的分辨率列表,获取完成后，外部拿到信息 建议立即调用FreeVideoDevCapabilityList 销毁SDK申请的内存。
          mac 平台需在initsdk 回调后调用

         @param pszVideoDeviceID 视频设备 ID
         @param nVideoCapabilityInfoCount 支持分辨率列表个数
         @return true 视频设备支持分辨率列表
         */
        ZEGO_API AV::DeviceVideoCapabilityInfo* GetVideoDevCapabilityList(const char* pszVideoDeviceID,int & nVideoCapabilityInfoCount);

	    /**
          释放视频设备的分辨率列表

          @param parrVideoCapability 视频设备的分辨率列表
	     */
        ZEGO_API void FreeVideoDevCapabilityList(AV::DeviceVideoCapabilityInfo* parrVideoCapability);

        /**
         获取视频设备列表

         @param device_count 设备数量
         @return 视频设备列表
         */
        ZEGO_API AV::DeviceInfo* GetVideoDeviceList(int& device_count);
        
        /**
         释放设备列表

         @param parrDeviceList 设备列表
         */
        ZEGO_API void FreeDeviceList(AV::DeviceInfo* parrDeviceList);
        
        /**
         设置选用视频设备

         @param pszDeviceID 设备 ID
         @return true 成功，false 失败
         */
        ZEGO_API bool SetVideoDevice(const char* pszDeviceID, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
#if defined(WIN32) || TARGET_OS_OSX 
        /**
         系统声卡声音采集开关

         @param bEnable true 打开，false 失败
         */
        ZEGO_API void EnableMixSystemPlayout(bool bEnable);

        /**
        采集系统声卡的声音

        @param bEnable true 打开，false 关闭
        @param properties 详情见 ZegoMixSysPlayoutPropertyMask 
        */
        ZEGO_API void MixSysPlayoutWithProperty(bool bEnable, ZegoMixSysPlayoutPropertyMask properties = MIX_PROP_NONE);
        
        /**
         获取麦克风音量

         @param deviceId 麦克风 deviceId
         @return -1: 获取失败，0~100 麦克风音量
         @note 切换麦克风后需要重新获取麦克风音量
         */
        ZEGO_API int GetMicDeviceVolume(const char *deviceId);
        
        /**
         设置麦克风音量

         @param deviceId 麦克风 deviceId
         @param volume 音量，取值(0,100)
         */
        ZEGO_API void SetMicDeviceVolume(const char *deviceId, int volume);
        
        /**
         获取麦克风是否静音
         
         @param deviceId 麦克风 deviceId
         @return true 静音，false 不静音
         */
        ZEGO_API bool GetMicDeviceMute(const char *deviceId);
        
        /**
         设置麦克风静音
         
         @param deviceId 麦克风 deviceId
         @param mute true 静音，false 不静音
         */
        ZEGO_API void SetMicDeviceMute(const char *deviceId, bool mute);
        
        /**
         获取扬声器音量

         @param deviceId 扬声器 deviceId
         @return -1: 获取失败，0~100 扬声器音量
         @note 切换扬声器后需要重新获取音量
         */
        ZEGO_API int GetSpeakerDeviceVolume(const char *deviceId);
        
        /**
         设置扬声器音量

         @param deviceId 扬声器 deviceId
         @param volume 音量，取值 (0，100)
         */
        ZEGO_API void SetSpeakerDeviceVolume(const char *deviceId, int volume);
        
        /**
         获取 App 中扬声器音量

         @param deviceId 扬声器 deviceId
         @return -1: 获取失败，0~100 扬声器音量
         */
        ZEGO_API int GetSpeakerSimpleVolume(const char *deviceId);
        
        /**
         设置 App 中扬声器音量

         @param deviceId 扬声器 deviceId
         @param volume 音量，取值 (0，100)
         */
        ZEGO_API void SetSpeakerSimpleVolume(const char *deviceId, int volume);

        /**
         获取扬声器是否静音

         @param deviceId 扬声器 deviceId
         @return true 静音，false 不静音
         */
        ZEGO_API bool GetSpeakerDeviceMute(const char *deviceId);
        
        /**
         设置扬声器静音

         @param deviceId 扬声器 deviceId
         @param mute true 静音，false 不静音
         */
        ZEGO_API void SetSpeakerDeviceMute(const char *deviceId, bool mute);
        
        /**
         获取 App 中扬声器是否静音

         @param deviceId 扬声器 deviceId
         @return true 静音，false 不静音
         */
        ZEGO_API bool GetSpeakerSimpleMute(const char *deviceId);
        
        /**
         设置 App 中扬声器静音

         @param deviceId 扬声器 deviceId
         @param mute true 静音，false 不静音
         */
        ZEGO_API void SetSpeakerSimpleMute(const char *deviceId, bool mute);
        
        /**
         获取默认的视频设备
         
         @param deviceId 设备 Id
         @param deviceIdLength deviceId 字符串分配的长度
         @note 如果传入的字符串 buffer 长度小于默认 deviceId 的长度，则 deviceIdLength 返回实际需要的字符串长度
         */
        ZEGO_API void GetDefaultVideoDeviceId(char *deviceId, unsigned int *deviceIdLength);
        
        /**
         获取默认的音频设备

         @param deviceType 音频类型
         @param deviceId 设备 Id
         @param deviceIdLength deviceId 字符串分配的长度
         @note 如果传入的字符串 buffer 长度小于默认 deviceId 的长度，则 deviceIdLength 返回实际需要的字符串长度
         */
        ZEGO_API void GetDefaultAudioDeviceId(AV::AudioDeviceType deviceType, char *deviceId, unsigned int *deviceIdLength);

        /**
         监听设备的音量变化

         @param deviceType 音频类型
         @param deviceId 设备 Id
         @return true 成功，false 失败
         @note 设置后如果有音量变化（包括 app 音量）通过 IZegoDeviceStateCallback::OnAudioVolumeChanged 回调
         */
        ZEGO_API bool SetAudioVolumeNotify(AV::AudioDeviceType deviceType, const char *deviceId);
        
        /**
         停止监听设备的音量变化

         @param deviceType 设备类型
         @param deviceId 设备 Id
         @return true 成功，false 失败
         */
        ZEGO_API bool StopAudioVolumeNotify(AV::AudioDeviceType deviceType, const char *deviceId);

#endif // defined(WIN32) || TARGET_OS_OSX 
        /**
         设置“音视频引擎状态通知”的回调

         @param pCB 回调对象指针
         @return true 成功，false 失败
         */
        ZEGO_API bool SetAVEngineCallback(IAVEngineCallback* pCB);
        
        /**
         设置配置信息

         @param config config 配置信息
         
         @attention 具体配置信息请咨询技术支持
         @attention 配置项的写法，例如 "keep_audio_session_active=true", 等号后面值的类型要看下面每一项的定义
         @attention "prefer_play_ultra_source", int value, 确保在 InitSDK 前调用，但开启拉流加速(config为“prefer_play_ultra_source=1”)可在 InitSDK 之后，拉流之前调用
         @attention "keep_audio_session_active", bool value, default: false, must be setting before engine started. if set true, app need to set the session inactive yourself. just be available for iOS
         @attention "enforce_audio_loopback_in_sync", bool value, default: false. enforce audio loopback in synchronous method for iOS
         @attention "audio_session_mix_with_others", bool value, default: true. set AVAudioSessionCategoryOptionMixWithOthers for iOS
         @attention "camera_orientation_mode", string value: auto/hardcode/0/90/180/270. for Android, Windows
         @attention "camera_check_position", bool value, default: false. for Android
         @attention "lower_audio_cap_sample_rate", bool value, default: false. enforce to use lower audio capture sample. for Android
         @attention "alsa_capture_device_name" string value: plughw:[card_id],[device_id], eg: plughw:1,0, default is plug:default. view the device list with arecord. for Linux
         @attention "alsa_playback_device_name" string value: plughw:[card_id],[device_id], eg: plughw:1,0, default is plug:default. view the device list with aplay. for Linux
         @attention "room_retry_time", uint32 value, default:300S 设置房间异常后自动恢复最大重试时间，SDK尽最大努力恢复，单位为S，SDK默认为300s，设置为0时不重试
         @attention "av_retry_time", uint32 value, default:300S 设置推拉流异常后自动恢复最大重试时间，SDK尽最大努力恢复，单位为S，SDK默认为300s，设置为0时不重试
         @attention "device_mgr_mode=1"  设备管理模式 1：手动模式  2：半自动模式 3：全自动模式  默认选项 1
         @attention "play_clear_last_frame", bool value, default false. 停止拉流时，是否清除最后一帧内容
         @attention "preview_clear_last_frame", bool value, default false. 停止预览时，是否清除最后一帧内容
         @attention "vcap_external_handle_rotation", bool value, default true, 表示在推流端处理旋转；设置为 vcap_external_handle_rotation=false 时，会把旋转值传到拉流端（仅为 UDP 时有效）。这个配置目前只对外部采集的内存模式和 CVPixelBuffer 模式生效
         @attention "room_user_update_optimize", bool value, default:false 是否开启SDK 用户回调优化，登录房间之前设置，之后一直生效。设置room_user_update_optimize=true 时，后续SDK回调OnUserUpdate 将只会在首次登陆成功，房间内有用户时回调全量，后续都增量回调，SDK内部将会维护房间列表数据，外部不需再存储做比对逻辑.
         */
        ZEGO_API void SetConfig(const char *config);

        /**
         设置是否允许SDK使用麦克风设备
         
         @param enable true 表示允许使用麦克风，false 表示禁止使用麦克风，此时如果SDK在占用麦克风则会立即释放。
         @return bool true 调用成功，false 调用失败。
         @discussion 调用时机为引擎创建后的任意时刻。
         @note 接口由于涉及对设备的操作，极为耗时，不建议随便调用，只在真正需要让出麦克风给其他应用的时候才调用。
         */
        ZEGO_API bool EnableMicDevice(bool enable);

	}
}

#endif
