//
//  zego-api-mediaplayer.h
//  ZegoLiveRoom
//
//  Copyright © 2018年 Zego. All rights reserved.
//

#ifndef zego_api_mediaplayer_h
#define zego_api_mediaplayer_h

#include <memory>
#include "zego-api-defines.h"
#include "media_player.h"
#include "zego-api-mediaplayer-defines.h"


namespace ZEGO
{
namespace MEDIAPLAYER
{

    /**
     初始化播放器
     
     @deprecated 请使用 CreatePlayer 代替
     
     @param type @see ZegoMediaPlayerType
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void InitWithType(ZegoMediaPlayerType type, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     创建播放器
     
     @param type @see ZegoMediaPlayerType
     @param index 播放器序号, 详见 ZegoMediaPlayerIndex
     */
    ZEGOAVKIT_API void CreatePlayer(ZegoMediaPlayerType type, ZegoMediaPlayerIndex index);
    
    /**
     释放播放器

     @param index 播放器序号, 详见 ZegoMediaPlayerIndex
     */
    ZEGOAVKIT_API void DestroyPlayer(ZegoMediaPlayerIndex index);

    /**
     设置本地播放音量, 如果播放器设置了推流模式, 也会设置推流音量
     
     @param volume 音量，取值范围[0, 200]，默认 60
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void SetVolume(int volume, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     设置推流音量
     
     @param volume 音量，取值范围[0, 200]，默认 60
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void SetPublishVolume(int volume, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     设置本地播放音量
     
     @param volume 音量，取值范围[0, 200]，默认 60
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void SetPlayVolume(int volume, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);

    /**
     获取推流音量
     
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @return 返回推流音量
     */
    ZEGOAVKIT_API int GetPublishVolume(ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     获取本地播放音量
     
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @return 返回本地播放音量
     */
    ZEGOAVKIT_API int GetPlayVolume(ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     开始播放
     
     @param path 媒体文件的路径
     @param repeat 是否重复播放
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void Start(const char *path, bool repeat, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
    开始播放并指定开始播放的进度

     @param path 媒体文件的路径
     @param repeat 是否重复播放
     @param startPosition 指定开始播放的进度,单位毫秒
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @note 当 startPosition 超过播放总时长，将从头开始播放
     @note 当 repeat=true 时, startposition只在第一次播放时生效
     */
    ZEGOAVKIT_API void Start(const char *path, bool repeat, long startPosition, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);

    /**
     停止播放
     
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void Stop(ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     暂停播放
     
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void Pause(ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     恢复播放
     
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void Resume(ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     设置指定的进度进行播放
     
     @param duration 指定的进度，单位毫秒
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void SeekTo(long duration, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     获取整个文件的播放时长
     
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @return 文件的播放时长，单位毫秒
     
     */
    ZEGOAVKIT_API long GetDuration(ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     获取当前播放的进度
     
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @return 当前播放进度，单位毫秒
     */
    ZEGOAVKIT_API long GetCurrentDuration(ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     设置本地静默播放
     
     @param mute 是否静默播放
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @note 如果设置了 ZegoMediaPlayerTypeAux 模式, 推出的流是有声音的
     */
    ZEGOAVKIT_API void MuteLocal(bool mute, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     预加载资源
     
     @param path 媒体文件的路径
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @note 如果是视频, 会将首帧画面显示在显示控件上(通过 SetView 设置的). 之后需要播放资源时请调用 Resume 接口
     */
    ZEGOAVKIT_API void Load(const char* path, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
    预加载资源

     @param path 媒体文件的路径
     @param startPosition 指定开始播放的进度,单位毫秒
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @note 如果是视频, 会将首帧画面显示在显示控件上(通过 SetView 设置的). 之后需要播放资源时请调用 Resume 接口
     @note 当 startPosition 超过播放总时长，将从头开始播放
     */
    ZEGOAVKIT_API void Load(const char* path, long startPosition, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);

    /**
     设置显示视频的view
     
     @param view 播放的控件
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void SetView(void *view, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    
    /**
     设置播放文件的音轨
     
     @param streamIndex 音轨序号，可以通过 getAudioStreamCount 接口获取音轨个数
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API long SetAudioStream(long streamIndex, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     设置播放器类型
     
     @param type @see ZegoMediaPlayerType
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void SetPlayerType(ZegoMediaPlayerType type, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     获取音轨个数
     
     @return 音轨个数
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API long GetAudioStreamCount(ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     设置是否循环播放
     
     @param enable true: 循环播放，false: 不循环播放
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void EnableRepeatMode(bool enable, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     获取当前播放视频的截图

     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @note 只有在调用 setView 设置了显示控件，以及播放状态的情况下，才能正常截图。
     */
    ZEGOAVKIT_API void TakeSnapshot(ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     设置播放进度回调间隔。
     
     @param interval 回调间隔，单位毫秒。有效值为大于等于 0。默认值为 0。
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst。
     
     @note 设置 interval 大于 0 时，就会收到 OnPlaybackProgress 回调。interval = 0 时，停止回调。
     @note 回调不会严格按照设定的回调间隔值返回，而是以处理音频帧或者视频帧的频率来判断是否需要回调。
     */
    ZEGOAVKIT_API bool SetProcessInterval(long interval, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     设置使用硬件解码
     
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst。
     @return 设置是否成功
     
     @note 当前只支持 iOS 系统
     @note 需要在加载媒体资源之前设置，即在 Start 或者 Load 之前
     @note 即使设置了使用硬件解码，引擎也会根据当前硬件情况决定是否使用
     @note 多次调用没有影响
     */
    ZEGOAVKIT_API bool RequireHWDecoder(ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);

    /**
     设置播放控件显示模式

     @param mode 显示模式。详见 AV::ZegoVideoViewMode，默认为 ZegoVideoViewModeScaleAspectFit 模式
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void SetViewMode(AV::ZegoVideoViewMode mode, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);

    /**
     设置播放的背景颜色

     @param color 颜色,取值为0x00RRGGBB
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void SetBackgroundColor(int color, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     清除播放控件播放结束后, 在控件上保留的最后一帧画面
     
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void ClearView(ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);

    /**
     设置是否开启精准搜索

     @param enable 是否开启
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @note: 播放文件之前调用，即Start或Load前，播放过程中调用不起作用，但可能对下个文件的播放起作用.
     */
    ZEGOAVKIT_API void EnableAccurateSeek(bool enable, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);

    /**
     设置精确搜索的超时时间

     @param timeoutInMS 超时时间, 单位毫秒. 有效值区间 [2000, 10000]
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @note 如果不设置, SDK 内部默认是设置 5000 毫秒
     */
    ZEGOAVKIT_API void SetAccurateSeekTimeout(long timeoutInMS, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     设置播放声道
     
     @param channel 声道, 参见 ZegoMediaPlayerAudioChannel 定义. 播放器初始化时默认是 ZegoMediaPlayerAudioChannelAll
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void SetActiveAudioChannel(ZegoMediaPlayerAudioChannel channel, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     设置声道音调
     
     @param channel 声道, 参见 ZegoMediaPlayerAudioChannel 定义
     @param keyShiftValue 音调偏移值, 有效值范围 [-12.0, 12.0], 播放器初始化时默认是 0
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @note 可选择设置左声道、右声道、左右声道，当只设置一个声道时，另一个声道保持原值
     */
    ZEGOAVKIT_API void SetAudioChannelKeyShift(ZegoMediaPlayerAudioChannel channel, float keyShiftValue, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     设置网络素材最大的缓存时长和缓存数据大小, 以先达到者为准

     @param timeInMS 缓存最大时长, 单位 ms, 有效值为大于等于 2000, 如果填 0, 表示不限制
     @param sizeInByte 缓存最大尺寸, 单位 byte, 有效值为大于等于 5000000, 如果填 0, 表示不限制
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @note 不允许 timeInMS 和 sizeInByte 都为 0
     @note SDK 内部默认 timeInMS 为 5000, sizeInByte 为 15*1024*1024
     @note 在 Start 或者 Load 之前调用, 设置一次, 生命周期内一直有效
    */
    ZEGOAVKIT_API void SetOnlineResourceCache(int timeInMS, int sizeInByte, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     获取网络素材缓存队列的缓存数据可播放的时长和缓存数据大小
     @param timeInMS 缓存数据可播放的时长, 单位 ms
     @param sizeInByte 缓存数据大小, 单位 byte
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @return true 调用成功, false 调用失败
    */
    ZEGOAVKIT_API bool GetOnlineResourceCacheStat(int* timeInMS, int* sizeInByte, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     设置缓冲回调的阈值, 缓冲区可播放时长大于阈值时，开始播放, 并回调 OnBufferEnd

     @param thresholdInMS  阈值, 单位 ms, 有效值为大于等于 1000
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @note 在 Start 或者 Load 之前调用, 设置一次, 生命周期内一直有效
     @note SDK 默认值是 5000ms
    */
    ZEGOAVKIT_API void SetBufferThreshold(int thresholdInMS, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     设置加载资源的超时时间

     @param timeoutInMS 超时时间, 单位 ms, 有效值为大于等于 1000
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @note 在 Start 或者 Load 之前设置, 设置一次, 生命周期内一直有效, 
     @note 当打开文件超过设定超时时间，会失败并回调 onPlayError
     @note SDK 默认会一直等待
     */
    ZEGOAVKIT_API void SetLoadResourceTimeout(int timeoutInMS, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     设置 http 网络资源的http headers

     @param headers headers, 每一个 key 和 value 不大于 512 字节
     @param size headers size
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void SetHttpHeaders(ZegoMediaPlayerHttpHeader* headers, int headerSize, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    /**
     设置播放器事件回调
     
     @param callback 回调 IZegoMediaPlayerEventWithIndexCallback
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @note 使用多实例媒体播放器时，应该使用这个接口设置回调，便于在回调中区分是哪个播放器实例的回调
     */
    ZEGOAVKIT_API void SetEventWithIndexCallback(IZegoMediaPlayerEventWithIndexCallback *callback, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
    
    /**
     设置视频帧数据回调
     
     @param callback 回调
     @param format 需要返回的视频帧数据格式，@see ZegoMediaPlayerVideoPixelFormat
     @param index 播放器序号, 默认为 ZegoMediaPlayerIndexFirst
     @note 使用多实例媒体播放器时，应该使用这个接口设置回调，便于在回调中区分是哪个播放器实例的回调
     */
    ZEGOAVKIT_API void SetVideoDataWithIndexCallback(IZegoMediaPlayerVideoDataWithIndexCallback *callback, ZegoMediaPlayerVideoPixelFormat format, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);

    /**
     设置音频数据回调

     @param callback 回调
     @param index 播放器序号，默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void SetAudioDataCallback(IZegoMediaPlayerAudioDataCallback *callback, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);

    /**
     设置播放文件的 SEI 信息回调
     
     @param callback 回调
     @param index 播放器序号，默认为 ZegoMediaPlayerIndexFirst
     */
    ZEGOAVKIT_API void SetMediaSideInfoCallback(IZegoMediaPlayerMediaSideInfoCallback *callback, ZegoMediaPlayerIndex index = ZegoMediaPlayerIndexFirst);
    
}
}



#endif /* zego_api_mediaplayer_h */
