const kLiveRoomErrorBase = 0x01000000;
const SEG_PUBLISH_FATAL_ERROR = 0x0001 << 16; ///< 推流严重错误段
const SEG_PUBLISH_NORMAL_ERROR = 0x0002 << 16; ///< 推流普通错误段
const SEG_PLAY_FATAL_ERROR = 0x0003 << 16; ///< 拉流严重错误段
const SEG_PLAY_NORMAL_ERROR = 0x0004 << 16; ///< 拉流普通错误段

let ZEGOCONSTANTS = {
    ZegoLogLevel: {
        Grievous: 0,
        Error: 1,
        Warning: 2,
        Generic: 3, ///< 通常在发布产品中使用
        Debug: 4 ///< 调试阶段使用
    },
    ZegoRoomRole: {
        /**< 主播 */
        Anchor: 1,
        /**< 观众 */
        Audience: 2,
    },
    /** 用户更新类型 */
    ZegoUserUpdateType: {
        /**< 全量更新 */
        UPDATE_TOTAL: 1,
        /**< 增量更新 */
        UPDATE_INCREASE: 2,
    },
    /** 用户更新属性 */
    ZegoUserUpdateFlag: {
        /**< 新增 */
        USER_ADDED: 1,
        /**< 删除 */
        USER_DELETED: 2,
    },
    /** 消息类型 */
    ZegoMessageType: {
        /**< 文字 */
        Text: 1,
        /**< 图片 */
        Picture: 2,
        /**< 文件 */
        File: 3,
        /**< 其他 */
        OtherType: 100,
    },
    /** 消息优先级 */
    ZegoMessagePriority: {
        /**< 默认优先级 */
        Default: 2,
        /**< 高优先级 */
        High: 3,
    },
    /** 消息类别 */
    ZegoMessageCategory: {
        /**< 聊天 */
        Chat: 1,
        /**< 系统 */
        System: 2,
        /**< 点赞 */
        Like: 3,
        /**< 送礼物 */
        Gift: 4,
        /**< 其他 */
        OtherCategory: 100,
    },
    PublishChannelIndex: {
        /**< 主推流通道，默认 */
        PUBLISH_CHN_MAIN: 0,
        /**< 第二路推流通道，无法推出声音 */
        PUBLISH_CHN_AUX: 1,
    },
    RemoteViewIndex: {
        RemoteViewIndex_First: 0,
        RemoteViewIndex_Second: 1,
        RemoteViewIndex_Third: 2,
    },
    ZegoPublishFlag: {
        ZEGO_JOIN_PUBLISH: 0, ///< 连麦
        ZEGO_MIX_STREAM: 1 << 1, ///< 混流，如果推出的流需要作为混流输入，请用这个模式
        ZEGO_SINGLE_ANCHOR: 1 << 2, ///< 单主播
    },
    /** 音频设备类型 */
    AudioDeviceType: {
        /**< 输入设备 */
        AudioDevice_Input: 0,
        /**< 输出设备 */
        AudioDevice_Output: 1,
    },
    /** 设备状态 */
    DeviceState: {
        /**< 添加设备 */
        Device_Added: 0,
        /**< 删除设备 */
        Device_Deleted: 1,
    },
    /** 音量类型 */
    VolumeType: {
        /**< 设备音量 */
        Volume_EndPoint: 0,
        /**< App 音量 */
        Volume_Simple: 1,
    },
    ZegoAVAPIState: {
        AVStateBegin: 0, ///< 直播开始
        AVStateEnd: 1, ///< 直播正常停止
        TempBroken: 2, ///< 直播异常中断
        FatalError: 3, ///< 直播遇到严重的问题（如出现，请联系 ZEGO 技术支持）

        CreateStreamError: 4, ///< 创建直播流失败
        FetchStreamError: 5, ///< 获取流信息失败
        NoStreamError: 6, ///< 无流信息
        MediaServerNetWorkError: 7, ///< 媒体服务器连接失败
        DNSResolveError: 8, ///< DNS 解释失败

        NotLoginError: 9, ///< 未登陆
        LogicServerNetWrokError: 10, ///< 逻辑服务器网络错误

        PublishBadNameError: 105,
        HttpDNSResolveError: 106,

        PublishForbidError: (SEG_PUBLISH_FATAL_ERROR | 0x03f3), ///< 禁止推流, 低8位为服务端返回错误码：1011

        PublishDeniedError: (SEG_PUBLISH_NORMAL_ERROR | 0x1), ///< 推流被拒绝

        PlayStreamNotExistError: (SEG_PLAY_FATAL_ERROR | 0x03ec), ///< 拉的流不存在, 低8位为服务端返回错误码：1004
        PlayForbidError: (SEG_PLAY_FATAL_ERROR | 0x03f3), ///< 禁止拉流, 低8位为服务端返回错误码：1011

        PlayDeniedError: (SEG_PLAY_NORMAL_ERROR | 0x1), ///< 拉流被拒绝
    },
    EventType: {
        /**< 开始重试拉流 */
        Play_BeginRetry: 1,
        /**< 重试拉流成功 */
        Play_RetrySuccess: 2,

        /**< 开始重试推流 */
        Publish_BeginRetry: 3,
        /**< 重试推流成功 */
        Publish_RetrySuccess: 4,

        /**< 拉流临时中断 */
        Play_TempDisconnected: 5,
        /**< 推流临时中断 */
        Publish_TempDisconnected: 6,

        /**< 拉流卡顿(视频) */
        Play_VideoBreak: 7,
    },
    /** 音频设备模式 */
    ZegoAVAPIAudioDeviceMode: {
        /**< 开启硬件回声消除 */
        ZEGO_AUDIO_DEVICE_MODE_COMMUNICATION: 1,
        /**< 关闭硬件回声消除 */
        ZEGO_AUDIO_DEVICE_MODE_GENERAL: 2,
        /**< 根据场景自动选择是否开启硬件回声消除 */
        ZEGO_AUDIO_DEVICE_MODE_AUTO: 3 
    },
    /** 流量控制属性 */
    ZegoTrafficControlProperty: {
        /**< 无 */
        ZEGO_TRAFFIC_NONE: 0,
        /**< 帧率 */
        ZEGO_TRAFFIC_FPS: 1,
        /**< 分辨率 */
        ZEGO_TRAFFIC_RESOLUTION: 1 << 1,
    },
    ZEGONetType: {
        /**< 无网络 */
        ZEGO_NT_NONE: 0,
        /**< 有线网络 */
        ZEGO_NT_LINE: 1,
        /**< 无线网络 */
        ZEGO_NT_WIFI: 2,
        /**< 2G网络 */
        ZEGO_NT_2G: 3,
        /**< 3G网络 */
        ZEGO_NT_3G: 4,
        /**< 4G网络 */
        ZEGO_NT_4G: 5,
        /**< 未知网络 */
        ZEGO_NT_UNKNOWN: 32
    },
    ZegoStreamUpdateType: {
        /**< 新增流 */
        StreamAdded: 2001,
        /**< 删除流 */
        StreamDeleted: 2002,
    },
    LiveRoomState: {
        /**< 开始 */
        Begin: 0,

        /**< 直播遇到严重的问题（如出现，请联系 ZEGO 技术支持 */
        FatalError: 3,

        /**< 创建直播流失败 */
        CreateStreamError: 4,
        /**< 获取流信息失败 */
        FetchStreamError: 5,
        /**< 无流信息 */
        NoStreamError: 6,
        /**< 媒体服务器连接失败 */
        MediaServerNetWorkError: 7,
        /**< DNS 解释失败 */
        DNSResolveError: 8,

        /**< 未登陆 */
        NotLoginError: 9,
        /**< 逻辑服务器网络错误 */
        LogicServerNetWrokError: 10,

        /**< 推流名称错误 */
        PublishBadNameError: 105,
        AddStreamError: 0x1 | kLiveRoomErrorBase,
        ParameterError: 0x2 | kLiveRoomErrorBase,
        MultiLoginError: 0x3 | kLiveRoomErrorBase,
    },
    /** Relay类别 */
    ZegoRelayType: {
        RelayTypeNone: 1,
        RelayTypeDati: 2,
    },
    /** 本地预览视频视图的模式 */
    ZegoVideoViewMode: {
        /**< 等比缩放，可能有黑边 */
        ZegoVideoViewModeScaleAspectFit: 0,
        /**< 等比缩放填充整View，可能有部分被裁减 */
        ZegoVideoViewModeScaleAspectFill: 1,
        /**< 填充整个View */
        ZegoVideoViewModeScaleToFill: 2,
    },
    /** 录制源类型 */
    RecordSourceType: {
        LocalVideo: 0,
        RemoteVideo: 1,
        Image: 2
    },
    /** 延迟模式 */
    ZegoAVAPILatencyMode:
    {
        ZEGO_LATENCY_MODE_NORMAL:0,                   /**< 普通延迟模式 */
        ZEGO_LATENCY_MODE_LOW:1,                      /**< 低延迟模式，无法用于 RTMP 流 */
        ZEGO_LATENCY_MODE_NORMAL2:2,                  /**< 普通延迟模式，最高码率可达 192K */
        ZEGO_LATENCY_MODE_LOW2:3,                     /**< 低延迟模式，无法用于 RTMP 流。相对于 ZEGO_LATENCY_MODE_LOW 而言，CPU 开销稍低 */
        ZEGO_LATENCY_MODE_LOW3:4,                     /**< 低延迟模式，无法用于 RTMP 流。支持WebRTC必须使用此模式 */
        ZEGO_LATENCY_MODE_NORMAL3:5                  /**< 普通延迟模式，使用此模式前先咨询即构技术支持 */
    },
    ZegoMediaPlayerType:
    {
        ZegoMediaPlayerTypePlayer:0, // 本地播放模式，不会将音频混入推流中，只有调用端可以听到播放的声音。
        ZegoMediaPlayerTypeAux:1     // 推流播放模式，会将音频混流推流中，调用端和拉流端都可以听到播放的
    },
    ZegoMediaPlayerIndex:
    {
        ZegoMediaPlayerIndexFirst:0,
        ZegoMediaPlayerIndexSecond:1,
        ZegoMediaPlayerIndexThird:2
    },
    ZegoCustomCaptureType:
    {
        IMAGE_TYPE :0,
        CAMERA_TYPE:1,
        VIDEO_FILE_TYPE:2,
        SCREEN_TYPE:3
    },
    ZegoMediaRecordType:
    {
        ZEGO_MEDIA_RECORD_NONE:0,      /**< 不录制任何数据 */
        ZEGO_MEDIA_RECORD_AUDIO:1,     /**< 只录制音频 */
        ZEGO_MEDIA_RECORD_VIDEO:2,     /**< 只录制视频 */
        ZEGO_MEDIA_RECORD_BOTH:3       /**< 同时录制音频、视频 */       
    },
    ZegoAuxPublishChannelAudioSrcType:
    {
        kZegoAuxPublishChannelAudioSrcTypeNone                      : -1,   /**< 无声 */
        kZegoAuxPublishChannelAudioSrcTypeSameAsMainPublishChannel  : 0,    /**< 和主推流通道一样 */
        kZegoAuxPublishChannelAudioSrcTypeExternalCapture           : 1,    /**< 使用外部采集 */
        kZegoAuxPublishChannelAudioSrcTypePlayer                    : 2,     /**< 使用媒体播放器的音源 */ 
        kZegoAuxPublishChannelAudioSrcTypeMic                       :10     /**< 来源于麦克风声音 */
    },
    ZegoDeviceErrorReason:
    {
        /** 一般性错误 */
        ZEGO_DEVICE_ERROR_REASON_GENERIC: -1,
        /** 无效设备 ID */
        ZEGO_DEVICE_ERROR_REASON_INVALID_ID: -2,
        /** 没有权限 */
        ZEGO_DEVICE_ERROR_REASON_NO_AUTHORIZATION: -3,
        /** 采集帧率为0 */
        ZEGO_DEVICE_ERROR_REASON_ZERO_FPS: -4,
        /** 设备被占用 */
        ZEGO_DEVICE_ERROR_REASON_IN_USE_BY_OTHER: -5,
        /** 设备未插入 */
        ZEGO_DEVICE_ERROR_REASON_UNPLUGGED: -6,
        /** 需要重启系统 */
        ZEGO_DEVICE_ERROR_REASON_REBOOT_REQUIRED: -7,
        /** 媒体服务无法恢复 */
        ZEGO_DEVICE_ERROR_REASON_MEDIA_SERVICES_LOST: -8,
        /** 没有错误 */
        ZEGO_DEVICE_ERROR_REASON_NONE: 0,
        /** 禁用 */
        ZEGO_DEVICE_ERROR_REASON_DISABLED: 2,
        /** 屏蔽采集 */
        ZEGO_DEVICE_ERROR_REASON_MUTE: 3,
        /** 中断 */
        ZEGO_DEVICE_ERROR_REASON_INTERRUPTION: 4,
        /** 在后台 */
        ZEGO_DEVICE_ERROR_REASON_IN_BACKGROUND: 5,
        /** 前台有多个 APP 运行 */
        ZEGO_DEVICE_ERROR_REASON_MULTI_FOREGROUND_APP: 6,
        /** 系统压力过大 */
        ZEGO_DEVICE_ERROR_REASON_SYSTEM_PRESSURE: 7
    },
    /** 白板模式 */
    ZegoWhiteboardMode: {
        /**< 单个图元绘制完毕后才全量同步该图元 */
        kZegoWhiteboardModeFullUpdate: 0x1,
        /**< 实时模式，边绘制边同步，适用于人数较少的环境 */
        kZegoWhiteboardModeRealTime: 0x2,
        /**< 1对多非互动模式 */
        kZegoWhiteboardModeSingleOperator: 0x3
    },
    /** 白板画布滑动、滚动方向 */
    ZegoWhiteboardCanvasScrollDirection: {
        /**< 水平方向 */
        kZegoWhiteboardCanvasScrollDirectionHorizontal: 0x1,
        /**< 竖直方向 */
        kZegoWhiteboardCanvasScrollDirectionVertical: 0x2
    },
    /** 白板画布上简单图元类型 */
    ZegoWhiteboardGraphic: {
        /**< 空图元 */
        kZegoWhiteboardGraphicNone: 0x0,
        /**< 涂鸦 */
        kZegoWhiteboardGraphicPath: 0x1,
        /**< 文本 */
        kZegoWhiteboardGraphicText: 0x2,
        /**< 直线 */
        kZegoWhiteboardGraphicLine: 0x4,
        /**< 矩形 */
        kZegoWhiteboardGraphicRect: 0x8,
        /**< 圆或椭圆 */
        kZegoWhiteboardGraphicEllipse: 0x10
    },
    /** 白板画布上简单图元粗细（在画布视口宽度为1280px情况下的推荐标准值，画布大小变化时请自行缩放图元） */
    ZegoWhiteboardGraphicSizeLevel: {
        /**< 单位px */
        kZegoWhiteboardGraphicSizeLevel1: 2,
        kZegoWhiteboardGraphicSizeLevel2: 4,
        kZegoWhiteboardGraphicSizeLevel3: 10,
        kZegoWhiteboardGraphicSizeLevel4: 20
    },
    /** 白板画布上文本图元字体大小（在画布视口宽度为1280px情况下的推荐标准值，画布大小变化时请自行缩放图元） */
    ZegoWhiteboardGraphicFontLevel: {
        /**< 单位px */
        kZegoWhiteboardGraphicFontLevel1: 16,
        kZegoWhiteboardGraphicFontLevel2: 24,
        kZegoWhiteboardGraphicFontLevel3: 36,
        kZegoWhiteboardGraphicFontLevel4: 48
    },
    ZegoSeiMediaInfoType:{
        /** ZEGO 定义的打包类型，跟视频编码器产生的信息不存兼容性问题, 但是在其它 CDN 上转码视频的时候，其它 CDN 基本上不支持提取这种方式打包的信息数据，转码完成后再从其它 CDN 拉流时，可能就丢失了这些次媒体信息 */
        MEDIAINFOTYPE_SIDEINFO_ZEGODEFINED:0,
        /** 采用 H264 的 SEI (nalu type = 6,payload type = 243) 类型打包，此类型是 SEI 标准未规定的类型，跟视频编码器或者视频文件中的 SEI 不存在冲突性，用户不需要根据 SEI 的内容做过滤 */
        MEDIAINFOTYPE_SIDEINFO_SEIZEGODEFINED:1,
        /**  采用 H264 的 SEI (nalu type = 6,payload type = 5) 类型打包，H264 标准对于此类型有规定的格式：startcode + nalu type(6) + payload type(5) + len + pay load(uuid + context)+ trailing bits。*/
        /**  因为视频编码器自身会产生 payload type 为 5 的 SEI，或者使用视频文件推流时，视频文件中也可能存在这样的 SEI，所以使用此类型时，用户需要把 uuid + context 当作一段 buffer 塞给次媒体的发送接口 */
        /**  为了区别视频编码器自身产生的 SEI，所以对 uuid 有格式要求，即 uuid 16字节的前四个字节固定为 'Z' 'E' 'G' 'O' 四个字符（全部大写），后面12字节用户任意填写 */
        /**  在 SDK 接收端，对于 payload type = 5的 SEI 会根据'ZEGO'字样做过滤，识别出符合要求的 SEI 抛给用户，避免用户收到编码器自身产生的 SEI */
        MEDIAINFOTYPE_SIDEINFO_SEIUSERUNREGISTED:2
    },
    ZegoSeiSendType:{
        /**  SEI 单帧发送，此种发送方式下，ffmpeg 解码会产生类似“此帧无视频”的警告，可能会导致一些 CDN 兼容性问题，例如转码失败等。*/
        SEISEND_SINGLE_FRAME:0,
        /** SEI 随视频帧(I, B, P)发送，推荐采用此类型*/
        SEISEND_IN_VIDEO_FRAME:1
    }
}

module.exports = exports = ZEGOCONSTANTS;