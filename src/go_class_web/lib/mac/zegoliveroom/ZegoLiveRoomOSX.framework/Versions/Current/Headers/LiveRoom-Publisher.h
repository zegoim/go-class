//
//  LiveRoom-Publisher.h
//  zegoliveroom
//
//  Created by Randy Qiu on 2017/1/23.
//
//

#ifndef LiveRoom_Publisher_h
#define LiveRoom_Publisher_h

#include "./LiveRoomDefines-Publisher.h"
#include "./LiveRoomCallback-Publisher.h"

namespace AVE
{
    class VideoCaptureFactory;
    class MediaCaptureFactory;
    class VideoFilterFactory;
    struct AudioFrame;
    struct ExtAudioProcSet;
    typedef ExtAudioProcSet ExtPrepSet;

    /**
     音频前处理回调函数定义

     @param inFrame 待处理音频数据
     @param outFrame 处理后的音频数据
     @attention 请确保在当前线程完成，且不要做耗时操作
     */
    typedef void (*OnPrepCallback)(const AudioFrame& inFrame, AudioFrame& outFrame);
}

namespace ZEGO
{
    namespace LIVEROOM
    {
		/**
		获取 SDK 支持的最大同时支持的推流路数

		@return 最大支持推流路数
		*/
        ZEGO_API int GetMaxPublishChannelCount();

        /**
         设置直播主播相关信息通知的回调

         @param pCB 回调对象指针
         @return true 成功，false 失败
         */
        ZEGO_API bool SetLivePublisherCallback(ILivePublisherCallback* pCB);
        
        /**
         设置本地预览视图

         @param pView 用于渲染本地预览视频的视图
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         */
        ZEGO_API bool SetPreviewView(void* pView, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         启动本地预览
         
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         @attention 启动本地预览前，要调用 LIVEROOM::SetPreviewView 设置本地预览视图
         */
        ZEGO_API bool StartPreview(AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         结束本地预览
         
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         @attention 建议停止推流，或本地预览结束后，调用该 API 停止本地预览
         */
        ZEGO_API bool StopPreview(AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         设置或更新推流的附加信息

         @param pszStreamExtraInfo 流附加信息, 最大为 1024 字节
         @param idx 推流 channel Index. 默认为主Channel
         @return 更新流附加信息成功后，同一房间内的其他人会收到 OnStreamExtraInfoUpdated 通知
         */
        ZEGO_API bool SetPublishStreamExtraInfo(const char *pszStreamExtraInfo, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         自定义转推目的地

         @param pszCustomPublishTarget 目的 rmtp 推流地址
         @param idx 推流 channel Index. 默认为主Channel
         */
        ZEGO_API void SetCustomPublishTarget(const char *pszCustomPublishTarget, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         添加转推地址
         
         @param strTarget 转推地址（支持rtmp/avertp）
         @param pszStreamID 推流ID
         @attention 在InitSDK之后调用
         */
        ZEGO_API int AddPublishTarget(const char *strTarget, const char* pszStreamID);
        
        /**
         删除转推地址
         
         @param strTarget 转推地址（支持rtmp/avertp）
         @param pszStreamID 推流ID
         @attention 在InitSDK之后调用
         */
        ZEGO_API int DeletePublishTarget(const char *strTarget, const char* pszStreamID);
        
        /**
         单主播模式下，自定义直推CDN的地址
         
         @param pszCDNPublishTarget 目的 rtmp 推流地址
         @param idx 推流 channel Index. 默认为主Channel
         */
        ZEGO_API void SetCDNPublishTarget(const char *pszCDNPublishTarget, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         设置推流加密密钥
         
         @param pszKey 加密密钥
         @param nkeyLen 密钥长度（支持16/24/32字节）
         @param idx 推流 channel Index. 默认为主Channel
         @attention 在InitSDK之后调用
         */
        ZEGO_API void SetPublishEncryptKey(const unsigned char *pKey, int nkeyLen, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         开始直播

         @attention 调用此 API 推直播流，必须在调用初始化 SDK 接口之后调用。

         @note
          1. 推流成功后，等待 ILivePublisherCallback::OnPublishStateUpdate 回调
          2. 若中途收到 IRoomCallback::OnDisconnect 回调，则不会再收到 ILivePublisherCallback::OnPublishStateUpdate 回调。

         @param pszTitle 直播名称
         @param pszStreamID 流 ID
         @param flag 直播属性，参考 ZegoPublishFlag
         @param pszParams 推流参数
         @return true 成功，false 失败
         */
        ZEGO_API bool StartPublishing(const char* pszTitle, const char* pszStreamID, int flag, const char* pszParams = 0);
        
        /**
         开始直播

         @attention 调用此 API 推直播流，必须在调用初始化 SDK 接口之后调用。

         @note 
            1. 推流成功后，等待 ILivePublisherCallback::OnPublishStateUpdate 回调
            2. 若中途收到 IRoomCallback::OnDisconnect 回调，则不会再收到 ILivePublisherCallback::OnPublishStateUpdate 回调
            3. 调用此接口 SetMixStreamConfig 无效，混流需要调用 MixStream。
         
         @param pszTitle 直播名称
         @param pszStreamID 流 ID
         @param flag 直播属性，参考 ZegoPublishFlag
         @param pszParams 推流参数
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         */
        ZEGO_API bool StartPublishing2(const char* pszTitle, const char* pszStreamID, int flag, const char* pszParams = 0, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);

        /**
         推流时是否发送视频数据。

         @param mute true 不发送（仅预览），false 发送
         @param idx 推流通道索引. 默认为主Channel
         @return 0 代表设置成功成功，否则设置失败
         @attention 拉流端通过 OnRemoteCameraStatusUpdate 回调监听此状态是否改变;
         @attention 仅拉 UDP 流时，才能接收到状态变更通知;
        */
        ZEGO_API int MuteVideoPublish(bool mute, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         推流时是否发送音频数据。
         
         @param mute true 不发送，false 发送
         @param idx 推流通道索引. 默认为主Channel
         @return 0 代表设置成功成功，否则设置失败
         @attention 可以通过 OnAudioRecordCallback 回调获取本地音频数据
         */
        ZEGO_API int MuteAudioPublish(bool mute, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);

        /**
         停止直播

         @param flag 保留字段
         @param pszMsg 自定义信息，server 对接流结束回调包含此字段内容
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         */
        ZEGO_API bool StopPublishing(int flag = 0, const char* pszMsg = 0, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         回应连麦申请

         @param seq 收到的连麦申请 seq (通过 ILivePublisherCallback::OnJoinLiveRequest 收到申请)
         @param rspResult 回应，0 表示同意
         @return true 成功，false 失败
         @note 申请者会收到 OnJoinLiveResponse 回调
         */
        ZEGO_API bool RespondJoinLiveReq(int seq, int rspResult);
        
        /**
         邀请连麦

         @param pszUserID 准备邀请的用户 ID
         @return 请求 seq，正值为成功，其他为失败
         @attention 邀请成功后，等待 ILivePublisherCallback::OnInviteJoinLiveResponse 回调
         @note 被邀请的用户会收到 OnInviteJoinLiveRequest 回调
         */
        ZEGO_API int InviteJoinLive(const char* pszUserID);

        /**
         结束连麦

         @param pszUserID 指定结束连麦的用户 ID
         @return 请求seq，正值为有效，等待 ILivePublisherCallback::OnEndJoinLive 回调
         */
        ZEGO_API int EndJoinLive(const char* pszUserID);
        
        /**
         硬件编码开关

         @param bRequired true 开启，false 关闭。默认 false
         @return true 成功，false 失败
         @attention 如果要打开，需要在推流前设置
         @note 打开硬编硬解开关需后台可控，避免碰到版本升级或者硬件升级时出现硬编硬解失败的问题
         */
        ZEGO_API bool RequireHardwareEncoder(bool bRequired);
        
        /**
         设置视频码率

         @param nBitrate 码率，单位为bps
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         */
        ZEGO_API bool SetVideoBitrate(int nBitrate, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);

        /**
         设置视频帧率

         @param nFps 帧率
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         */
        ZEGO_API bool SetVideoFPS(int nFps, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         设置视频编码输出分辨率

         @param nWidth 宽
         @param nHeight 高
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         */
        ZEGO_API bool SetVideoEncodeResolution(int nWidth, int nHeight, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         设置视频采集分辨率

         @param nWidth 宽
         @param nHeight 高
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         */
        ZEGO_API bool SetVideoCaptureResolution(int nWidth, int nHeight, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         设置视频关键帧间隔
         
         @param nIntervalSecond 关键帧间隔，单位为秒，默认2秒
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         @attention 推流开始前调用本 API 进行参数配置
         */
        ZEGO_API bool SetVideoKeyFrameInterval(int nIntervalSecond, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         主播开启美颜功能

         @param nFeature 美颜特性。默认无美颜
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         @attention 推流时可调用本 API 进行参数配置
         */
        ZEGO_API bool EnableBeautifying(int nFeature, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         设置美颜磨皮的采样步长

         @param step 采样步长，取值范围[1,16]。默认 4.0
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         @attention 推流时可调用本 API 进行参数配置。设置时需确保对应美颜特性开启
         */
        ZEGO_API bool SetPolishStep(float step, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         设置美颜采样颜色阈值

         @param factor 采样颜色阈值，取值范围[0,16]。默认 4.0
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         @attention 推流时可调用本 API 进行参数配置。设置时需确保对应美颜特性开启
         */
        ZEGO_API bool SetPolishFactor(float factor, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         设置美颜美白的亮度修正参数

         @param factor 亮度修正参数，取值范围[0,1]，值越大亮度越暗。默认 0.5
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         @attention 推流时可调用本 API 进行参数配置。设置时需确保对应美颜特性开启
         */
        ZEGO_API bool SetWhitenFactor(float factor, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         设置锐化参数

         @param factor 锐化参数，取值范围[0,2]，值越大锐化越强。默认 0.2
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         @attention 推流时可调用本 API 进行参数配置。设置时需确保对应美颜特性开启
         */
        ZEGO_API bool SetSharpenFactor(float factor, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         设置滤镜

         @param nIndex 滤镜索引。默认不使用滤镜
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         @attention 推流时可调用本 API 进行参数配置
         */
        ZEGO_API bool SetFilter(int nIndex, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         设置本地预览视频视图的模式

         @param mode 模式
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         @attention 推流开始前调用本 API 进行参数配置
         */
        ZEGO_API bool SetPreviewViewMode(ZegoVideoViewMode mode, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         是否启用预览镜像
         
         @param bEnable true 启用，false 不启用。默认 true
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         @note 默认启用预览镜像
         */
        ZEGO_API bool EnablePreviewMirror(bool bEnable, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         是否启用预览和推流镜像
         
         @param mode 镜像模式
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         @note 默认启用预览镜像，不启用推流镜像
         */
        ZEGO_API bool SetVideoMirrorMode(AV::ZegoVideoMirrorMode mode, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         设置预览视频控件的背景颜色
         
         @param  color 颜色,取值为0x00RRGGBB
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         */
        ZEGO_API bool SetPreviewViewBackgroundColor(int color, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         设置预览渲染朝向

         @param nRotation 旋转角度(0/90/180/270)。默认 0
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         @attention 推流时可调用本 API 进行参数配置
         */
        ZEGO_API bool SetPreviewRotation(int nRotation, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         开启麦克风

         @param bEnable true 打开，false 关闭。默认 true
         @return true 成功，false 失败
         @attention 推流时可调用本 API 进行参数配置
         */
        ZEGO_API bool EnableMic(bool bEnable);
        
        /**
         设置音频码率

         @param bitrate 码率
         @return true 成功，false 失败
         */
        ZEGO_API bool SetAudioBitrate(int bitrate);
        
        /**
         设置音频设备模式

         @param mode 模式, 默认 ZEGO_AUDIO_DEVICE_MODE_AUTO
         @attention 确保在 Init 前调用
         */
        ZEGO_API void SetAudioDeviceMode(AV::ZegoAVAPIAudioDeviceMode mode);
        
        /**
         音频采集自动增益开关。windows默认开启；android/ios默认关闭；mac默认音频设备模式为ZEGO_AUDIO_DEVICE_MODE_COMMUNICATION或ZEGO_AUDIO_DEVICE_MODE_COMMUNICATION2时开启，否则关闭

         @param bEnable true 开启，false 关闭
         @return true 成功，false 失败
         @discussion 建议在推流前调用设置
         */
        ZEGO_API bool EnableAGC(bool bEnable);

        /**
         回声消除开关

         @param bEnable true 开启，false 关闭
         @return true 成功，false 失败
         @discussion 建议在推流前调用设置
         */
        ZEGO_API bool EnableAEC(bool bEnable);
        
        
        /**
         设置回声消除模式

         @param mode 回声消除模式
         @discussion 建议在推流前调用设置
         */
        ZEGO_API void SetAECMode(AV::ZegoAECMode mode);
        
        /**
         开启摄像头

         @param bEnable true 开启，false 关闭。默认 true
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，false 失败
         */
        ZEGO_API bool EnableCamera(bool bEnable, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);

        /**
         截预览图
         
         @param idx 推流 channel Index. 默认为主Channel
         @return true 成功，通过回调返回结果，false 失败
         */
        ZEGO_API bool TakeSnapshotPreview(AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         开启采集监听

         @param bEnable true 打开，false 关闭。默认 false
         @return true 成功，false 失败
         @discussion 推流时可调用本 API 进行参数配置。连接耳麦时设置才实际生效。开启采集监听，主播方讲话后，会听到自己的声音。
         */
        ZEGO_API bool EnableLoopback(bool bEnable);
        
        /**
         设置监听音量

         @param volume 音量大小，取值范围 [0, 200], 默认 100
         @attention 推流时可调用本 API 进行参数配置
         */
        ZEGO_API void SetLoopbackVolume(int volume);
        
        /**
         设置采集音量
         
         @param volume 音量大小，取值范围 [0, 200], 默认 100
         @attention SDK初始化成功后调用
         */
        ZEGO_API void SetCaptureVolume(int volume);
        
        /**
         获取当前采集的音量

         @return 当前采集音量大小
         */
        ZEGO_API float GetCaptureSoundLevel();
        
        /**
         设置水印的图片路径

         @param filePath 图片路径
         @param idx 推流 channel Index. 默认为主Channel
         @attention 推流开始前调用本 API 进行参数配置
         */
        ZEGO_API void SetWaterMarkImagePath(const char *filePath, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         设置水印在采集视频中的位置

         @param left 左上角坐标的第一个元素
         @param top 左上角坐标的第二个元素，即左上角坐标为 (left, top)
         @param right 右下角坐标的第一个元素
         @param bottom 右下角坐标的第二个元素，即右下角坐标为 (right, bottom)
         @param idx 推流 channel Index. 默认为主Channel
         @note 左上角为坐标系原点，区域不能超过编码分辨率设置的大小
         */
        ZEGO_API void SetPublishWaterMarkRect(int left, int top, int right, int bottom, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);

        /**
         设置水印在预览视频中的位置

         @param left 左上角坐标的第一个元素
         @param top 左上角坐标的第二个元素，即左上角坐标为 (left, top)
         @param right 右下角坐标的第一个元素
         @param bottom 右下角坐标的第二个元素，即右下角坐标为 (right, bottom)
         @param idx 推流 channel Index. 默认为主Channel
         @note 左上角为坐标系原点，区域不能超过 preview 的大小
         */
        ZEGO_API void SetPreviewWaterMarkRect(int left, int top, int right, int bottom, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         设置选用分层编码
         @param codecId 设备 ID
         @return true 成功，false 失败
         */
        ZEGO_API bool SetVideoCodecId(AV::ZegoVideoCodecAvc codecId, AV::PublishChannelIndex nChannel = AV::PUBLISH_CHN_MAIN);

        /**
         设置音频前处理函数, 并开启/关闭音频前处理特性

         @param callback 音频前处理函数指针
         @param config 预处理的采样率等参数设置
         @attention 必须在 InitSDK 后且在推流前调用
         */
        ZEGO_API void SetAudioPrepCallback(AVE::OnPrepCallback callback, const AVE::ExtPrepSet& config);
        
        /**
         设置编码器码率控制策略

         @param strategy 策略配置，参考 ZegoVideoEncoderRateControlStrategy
         @param encoderCRF 当策略为恒定质量（ZEGO_RC_VBR/ZEGO_RC_CRF）有效，取值范围 [0~51]，越小质量越好，但是码率会相应变大。建议取值范围 [18, 28]
         @param idx 推流 channel Index. 默认为主Channel
         */
        ZEGO_API void SetVideoEncoderRateControlConfig(AV::ZegoVideoEncoderRateControlStrategy strategy, int encoderCRF, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);
        
        /**
         帧顺序检测开关
         
         @param bEnalbe true 检测帧顺序，不支持B帧； false 不检测帧顺序，支持B帧，可能出现短暂花屏
         */
        ZEGO_API void EnableCheckPoc(bool bEnable);
        
        /**
         设置视频采集缩放时机
         
         @param mode 视频采集缩放时机，请参考 AV::ZegoCapturePipelineScaleMode 定义。默认为 ZegoCapturePipelinePreScale
         @discussion 初始化 SDK 后，StartPreview, StartPublish 前调用。摄像头启动之后设置不会立即生效，而是在下次摄像头启动时生效。
         */
        ZEGO_API void SetCapturePipelineScaleMode(AV::ZegoCapturePipelineScaleMode mode);
        
        /**
         设置所有推流通道的延迟模式
         
         @param mode 延迟模式，默认 ZEGO_LATENCY_MODE_NORMAL
         @attention 确保在推流前调用
         */
        ZEGO_API void SetLatencyMode(AV::ZegoAVAPILatencyMode mode);
        
        /**
         设置指定推流通道的延迟模式

         @param mode 延迟模式，默认 ZEGO_LATENCY_MODE_NORMAL
         @param idx 推流 channel Index. 详见 AV::PublishChannelIndex
         @attention 确保在推流前调用
         */
        ZEGO_API void SetLatencyModeByChannel(AV::ZegoAVAPILatencyMode mode, AV::PublishChannelIndex idx);
        
        /**
         设置所有推流通道的推流音频声道数
         
         @param count 声道数，1 或 2，默认为 1（单声道）
         @attention 必须在推流前设置
         @note SetLatencyMode 设置为 ZEGO_LATENCY_MODE_NORMAL, ZEGO_LATENCY_MODE_NORMAL2, ZEGO_LATENCY_MODE_LOW3 才能设置双声道
         @note 在移动端双声道通常需要配合音频前处理才能体现效果。
         */
        ZEGO_API void SetAudioChannelCount(int count);
        
        /**
         设置指定推流通道的推流音频声道数
         
         @param count 声道数，1 或 2，默认为 1（单声道）
         @param idx 推流 channel Index. 详见 AV::PublishChannelIndex
         @attention 必须在推流前设置
         @note SetLatencyMode 设置为 ZEGO_LATENCY_MODE_NORMAL, ZEGO_LATENCY_MODE_NORMAL2, ZEGO_LATENCY_MODE_LOW3 才能设置双声道
         @note 在移动端双声道通常需要配合音频前处理才能体现效果。
         */
        ZEGO_API void SetAudioChannelCountByChannel(int count, AV::PublishChannelIndex idx);
        
        /**
         是否开启离散音频包发送

         @param bEnable true 开启，此时关闭麦克风后，不会发送静音包；false 关闭，此时关闭麦克风后会发送静音包
         @attention 确保在推流前调用，只有纯 UDP 方案才可以调用此接口
         */
        ZEGO_API void EnableDTX(bool bEnable);
        
        /**
         是否开启语音活动检测
         
         @param bEnable true 开启；false 关闭，默认关闭
         @attention 确保在推流前调用，只有纯 UDP 方案才可以调用此接口
         */
        ZEGO_API void EnableVAD(bool bEnable);
        
        /**
         是否开启流量控制

         @param properites 流量控制属性 (帧率，分辨率），参考 ZegoTrafficControlProperty 定义。默认 ZEGO_TRAFFIC_CONTROL_ADAPTIVE_FPS
         @param bEnable true 开启，false 关闭。默认开启
         @attention bEnable设置为false时，properties参数无效
         @attention 确保在推流前调用，在纯 UDP 方案才可以调用此接口
         */
        ZEGO_API void EnableTrafficControl(int properites, bool bEnable);
        
        /**
         设置TrafficControl视频码率最小值
         
         @param nBitrate 码率，单位为bps
         @param mode 低于最低码率时的视频发送模式
         @attention InitSDK 之后调用有效
         @note 设置一个在traffic control中video码率的一个最小值，当网络不足以发送这个最小值的时候视频会被卡住，而不是以低于该码率继续发送。初始化SDK后默认情况下没有设置该值，即尽可能的保持视频流畅，InitSDK之后可以随时修改，未重新InitSDK之前如果需要取消该设置值的限制可以设置为0
         */
        ZEGO_API void SetMinVideoBitrateForTrafficControl(int nBitrate, AV::ZegoTrafficControlMinVideoBitrateMode mode = AV::ZEGO_TRAFFIC_CONTROL_MIN_VIDEO_BITRATE_NO_VIDEO);
        
        /**
        音频采集噪声抑制开关
         
        @param bEnalbe true 开启，false 关闭
        @return true 调用成功，false 调用失败
         */
        ZEGO_API bool EnableNoiseSuppress(bool bEnable);

        /**
          设置音频采集降噪等级
          @param mode 降噪等级，详见 ZegoANSMode 定义
          @return true 成功，false 失败
          @note 仅在 EnableNoiseSuppress 为 true 时有效, 默认为 MEDIUM
         */
        ZEGO_API bool SetNoiseSuppressMode(AV::ZegoANSMode mode);

        /**
         音频采集的瞬态噪声抑制开关（消除键盘、敲桌子等瞬态噪声）

         @param bEnable true 开启，false 关闭
         @return true 调用成功，false 调用失败
         */
        ZEGO_API bool EnableTransientNoiseSuppress(bool bEnable);

        /**
         设置推流质量监控周期
         
         @param timeInMS 时间周期，单位为毫秒，取值范围为(500, 60000)。大于3000必须为3000整数倍，否则sdk会自动向上取整（比如设置为5000，sdk内部会取整为6000），默认为 3000
         @return true 成功，false 失败
         @attention 必须在推流前调用才能生效。该设置会影响 ILivePublisherCallback::OnPublishQualityUpdate 的回调频率
         */
        ZEGO_API bool SetPublishQualityMonitorCycle(unsigned int timeInMS);
        
        /**
         音效均衡器

         @param bandIndex 取值范围[0, 9]。分别对应10个频带，其中心频率分别是[31, 62, 125, 250, 500, 1K, 2K, 4K, 8K, 16K]Hz
         @param bandGain 取值范围[-15, 15]。默认值是0，如果所有频带的增益值全部为0，则会关闭EQ功能
         @return true 调用成功，false 调用失败
         @attention 在InitSDK之后调用有效。使用此接口前请与即构技术支持联系确认是否支持此功能
         @deprecated 请使用 AUDIOPROCESSING::SetAudioEqualizerGain(int, float)
         */
        ZEGO_API bool SetAudioEqualizerGain(int bandIndex, float bandGain);

        /**
         给推流通道设置扩展参数，一般不建议修改

         @param param_config 参数配置信息
         @param idx 推流通道索引，默认主通道

         @attention 配置项写法，例如 "zego_channel_param_key_video_swencoder_usage=camera", 等号后面值的类型要看下面每一项的定义
         @attention "zego_channel_param_key_video_swencoder_usage", string value: camera|screen，设置编码时使用场景模式，仅使用 OpenH264 编码时有效
         @attention "zego_channel_param_key_video_x264_config_tune", string value: animation, 设置编码的 tune 值，目前只支持 animation，仅使用 X264 编码时有效
         @attention 初始化 SDK 之后推流前设置才生效，推流过程中设置无效
         */
        ZEGO_API void SetChannelExtraParam(const char *param_config, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);

        /**
         获取推流通道扩展参数

         @param key 需要获取的参数类型，目前仅支持 AVCaptureDevice
         @param idx 推流通道索引，默认主通道

         @attention 初始化 SDK 之后调用
         @attention 目前仅支持 Mac/iOS 平台
         */
        ZEGO_API void* GetChannelExtraParam(AV::ChannelExtraParamKey key, AV::PublishChannelIndex idx = AV::PUBLISH_CHN_MAIN);

        /**
        获取设备编码格式的能力，外部拿到信息 建议立即调用FreeVideoCodecCapabilityList 销毁SDK申请的内存。

        @param len 设备支持编码格式个数
        @return 设备编码格式的能力列表
        @attention 初始化 SDK 之后调用
        @attention 建议在回调初始化 SDK 成功之后调用该接口
        */
        ZEGO_API AV::ZegoCodecCapabilityInfo* GetVideoCodecCapabilityList(int& len);

        /**
        释放设备编码格式的能力列表

        @param parrCodecCapability 设备编码格式的能力列表
        */
        ZEGO_API void FreeVideoCodecCapabilityList(AV::ZegoCodecCapabilityInfo* parrCodecCapability);
    }
}
#endif /* LiveRoom_Publisher_h */
