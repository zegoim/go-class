//
// 音频播放器
// 
//
// Copyright © 2019年 Zego. All rights reserved.
//

#ifndef zego_api_audio_player_h
#define zego_api_audio_player_h

#include <zego-api-defines.h>

namespace ZEGO
{
namespace AUDIOPLAYER
{

class IZegoAudioPlayerCallback
{
public:
    /*
     * 播放音效
     * 
     * @param nSoundID 音效 ID
     * @param nErrorCode 0 成功，-1 失败
     */
    virtual void OnPlayEffect(unsigned int nSoundID, int nErrorCode) {};

    /**
     * 播放音效完成
     * 
     * @param nSoundID 音效 ID
     */
    virtual void OnPlayEnd(unsigned int nSoundID) {};

    /*
     * 预加载音效
     * 
     * @param nSoundID 音效 ID
     * @param nErrorCode 0 成功，-1 失败
     */
    virtual void OnPreloadEffect(unsigned int nSoundID, int nErrorCode) {};

    /**
     * 预加载音效完成
     * 
     * @param nSoundID 音效 ID
     */
    virtual void OnPreloadComplete(unsigned int nSoundID) {};
};

/**
 * 创建音效播放器
 */
ZEGOAVKIT_API void CreateAudioPlayer();

/**
 * 销毁音效播放器
 */
ZEGOAVKIT_API void DestroyAudioPlayer();

/**
 * 设置音效播放器的回调
 * 
 * @param pCallback 回调
 * @return true 设置成功，false 设置失败
 */
ZEGOAVKIT_API bool SetAudioPlayerCallback(IZegoAudioPlayerCallback *pCallback);

/**
 * 播放音效
 * 
 * @param pszPath 音效资源文件的本地路径
 * @param nSoundID 音效 ID
 * @param nLoopCount 循环次数
 * @param bPublish 是否放入推流中
 * 
 * @attention 如果是播放预加载的音效，指定音效 ID, 音效资源文件填 nullptr。
 */
ZEGOAVKIT_API void PlayEffect(const char *pszPath, unsigned int nSoundID, int nLoopCount, bool bPublish);

/**
 * 停止播放音效
 * 
 * @param nSoundID 音效 ID
 */
ZEGOAVKIT_API void StopEffect(unsigned int nSoundID);

/**
 * 暂停播放音效
 * 
 * @param nSoundID 音效 ID
 */
ZEGOAVKIT_API void PauseEffect(unsigned int nSoundID);

/**
 * 恢复播放音效
 * 
 * @param nSoundID 音效 ID
 */
ZEGOAVKIT_API void ResumeEffect(unsigned int nSoundID);

/**
 * 设置单个音效的音量
 * 
 * @param nSoundID 音效 ID
 * @param nVolume 音量，取值范围[0, 200]，默认 100
 */
ZEGOAVKIT_API void SetVolume(unsigned int nSoundID, int nVolume);
    
/**
 * 设置所有音效的音量
 *
 * @param nVolume 音量，取值范围[0, 200]，默认 100
 */
ZEGOAVKIT_API void SetVolumeAll(int nVolume);

/**
 * 暂停全部音效
 */
ZEGOAVKIT_API void PauseAll();

/**
 * 恢复全部音效
 */
ZEGOAVKIT_API void ResumeAll();

/**
 * 停止全部音效
 */
ZEGOAVKIT_API void StopAll();

/**
 * 预加载音效
 * 
 * @param pszPath 音效资源文件的本地路径
 * @param nSoundID 音效 ID
 */
ZEGOAVKIT_API void PreloadEffect(const char *pszPath, unsigned int nSoundID);

/**
 * 删除预加载音效
 * 
 * @param nSoundID 音效 ID
 */
ZEGOAVKIT_API void UnloadEffect(unsigned int nSoundID);

/**
 设置进度
 
 @param nSoundID 音效 ID
 @param timestamp 进度, 单位毫秒
 @return 返回 -1 表示失败, 返回 0 表示成功
 */
ZEGOAVKIT_API int SeekTo(unsigned int nSoundID, long timestamp);
    
/**
 获取音效的总时长
 
 @param nSoundID 音效 ID
 @return 返回音效的总时长, 失败返回 0
 */
ZEGOAVKIT_API long GetDuration(unsigned int nSoundID);
    
/**
 获取音效的当前进度
 
 @param nSoundID 音效 ID
 @return 返回音效的当前进度, 失败返回 -1
 */
ZEGOAVKIT_API long GetCurrentDuration(unsigned int nSoundID);
    
}
}

#endif /* zego_api_audio_player_h */
