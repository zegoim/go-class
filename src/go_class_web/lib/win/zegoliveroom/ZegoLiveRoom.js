/**
 * @file ZegoLiveRoom.js
 * @copyright Zego @ 2018
 */
function ZegoLiveRoom() {
    const path = require('path')
    const WebGLRender = require(path.join(__dirname, './WebglRender.js'))
    const ZegoAddon = require(path.join(__dirname, './ZegoLiveRoom.node'))
    const ZEGOCONSTANTS = require(path.join(__dirname, './ZegoConstant.js'))

    const local_main_channel_render_ = new WebGLRender()
    const local_aux_channel_render_ = new WebGLRender()

    let main_video_width_ = 0
    let main_video_height_ = 0

    let aux_video_width_ = 0
    let aux_video_height_ = 0

    let main_video_capture_buffer = null
    let aux_video_capture_buffer = null

    const zego_base_ = new ZegoAddon.ZegoBase()
    const zego_room_ = new ZegoAddon.ZegoRoom()
    const zego_multi_room_ = new ZegoAddon.ZegoMutiRoom()
    const zego_publish_stream_ = new ZegoAddon.ZegoPublishStream()
    const zego_play_stream_ = new ZegoAddon.ZegoPlayStream()
    const zego_im_ = new ZegoAddon.ZegoIM()
    const zego_device_ = new ZegoAddon.ZegoDevice()
    const zego_audio_player_ = new ZegoAddon.ZegoAudioPlayer()

    const zego_white_board_ = new ZegoAddon.ZegoWhiteBoard()

    try {
        const zego_docs_ = new ZegoAddon.ZegoDocs()
    } catch (err) {
        //console.log('zego not supported. please update version')
    }

    const zego_window_thumbnail_ = new ZegoAddon.ZegoWindowThumbnail()
    const zego_network_trace_ = new ZegoAddon.ZegoNetworkTrace()
    const zego_network_probe_ = new ZegoAddon.ZegoNetworkProbe()

    let zego_custom_capture_ = null;
    try {
        zego_custom_capture_ = new ZegoAddon.ZegoCustomCapture()
    } catch (err) {
        console.log('custom capture not supported. please update version')
    }

    let zego_media_player_ = null
    try {
        zego_media_player_ = new ZegoAddon.ZegoMediaPlayer()
    } catch (err) {
        console.log('media player not supported. please update version')
    }

    this.isToCoverView = void 0
    this.viewMode = 0
    this.remoteViewModes = {}
    const play_list_ = []
    const media_player_list_ = []
    let on_paint_list_ = []

    let on_video_data_cb_ = null;
    let external_render_ = false;

    let main_preview_bk_color = null
    let aux_preview_bk_color = null

    let play_bk_color_list_ = []

    zego_base_.registerEventHandler('onCaptureVideoSizeChanged', function (rs) {
        //console.log("onCaptureVideoSizeChanged", rs);
        // main index
        if (rs.index == 0) {
            if (main_video_width_ != rs.width || main_video_height_ != rs.height) {
                main_video_width_ = rs.width
                main_video_height_ = rs.height
                main_video_capture_buffer = Buffer.alloc(rs.width * rs.height * 4) // rgba buffer len
                zego_base_.initVideoCaptureBuffer(main_video_capture_buffer, rs.index, rs.width, rs.height)
            }
        } else if (rs.index == 1) {
            // aux index
            if (aux_video_width_ != rs.width || aux_video_height_ != rs.height) {
                aux_video_width_ = rs.width
                aux_video_height_ = rs.height
                aux_video_capture_buffer = Buffer.alloc(rs.width * rs.height * 4) // rgba buffer len
                zego_base_.initVideoCaptureBuffer(aux_video_capture_buffer, rs.index, rs.width, rs.height)
            }
        }
    })

    zego_base_.registerEventHandler('onVideoSizeChanged', function (rs) {
        //console.log("onVideoSizeChanged", rs, play_list_);
        for (let i = 0; i < play_list_.length; ++i) {
            //console.log("in play_list_ ", play_list_[i].stream_id, rs.stream_id);
            if (play_list_[i].stream_id == rs.stream_id && (play_list_[i].width != rs.width || play_list_[i].height != rs.height)) {
                //console.log("alloc buffer for play stream");
                play_list_[i].width = rs.width
                play_list_[i].height = rs.height
                play_list_[i].video_buffer = Buffer.alloc(rs.width * rs.height * 4) // rgba buffer len
                zego_base_.initVideoPlayBuffer(rs.stream_id, play_list_[i].video_buffer, play_list_[i].width, play_list_[i].height)
                break
            }
        }
    })

    zego_base_.registerEventHandler('onMediaPlayerVideoSizeChanged', function (rs) {
        //console.log("onMediaPlayerVideoSizeChanged", rs);
        for (let i = 0; i < media_player_list_.length; ++i) {
            if (media_player_list_[i].player_index == rs.player_index && (media_player_list_[i].width != rs.width || media_player_list_[i].height != rs.height)) {
                //console.log("alloc buffer for media player stream");
                media_player_list_[i].width = rs.width
                media_player_list_[i].height = rs.height
                media_player_list_[i].video_buffer = Buffer.alloc(rs.width * rs.height * 4) // rgba buffer len
                zego_base_.initMediaPlayerBuffer(rs.player_index, media_player_list_[i].video_buffer, media_player_list_[i].width, media_player_list_[i].height)
                break
            }
        }
    })

    this.onPaint = function (rs) {
        if (rs && rs.is_local_stream) {
            if (rs.local_stream_channel == ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN) {
                if (rs.width == main_video_width_ && rs.height == main_video_height_ && main_video_capture_buffer) {
                    //console.log("update main channel video");
                    if (on_video_data_cb_) {
                        if (!rs.data) {
                            rs.data = main_video_capture_buffer;
                        }

                        on_video_data_cb_(rs)
                    }
                    if (!external_render_) {
                        local_main_channel_render_.setViewMode(this.viewMode)
                        local_main_channel_render_.setFlipMode(rs.flip_mode)
                        local_main_channel_render_.draw(main_video_capture_buffer, main_video_width_, main_video_height_)
                    }
                } else {
                    //console.log('not init buffer, can not draw')
                }

            } else if (rs.local_stream_channel == ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_AUX) {
                if (rs.width == aux_video_width_ && rs.height == aux_video_height_ && aux_video_capture_buffer) {
                    //console.log("update aux channel video");
                    if (on_video_data_cb_) {
                        if (!rs.data) {
                            rs.data = aux_video_capture_buffer;
                        }

                        on_video_data_cb_(rs)
                    }
                    if (!external_render_) {
                        local_aux_channel_render_.setViewMode(this.viewMode)
                        local_aux_channel_render_.setFlipMode(rs.flip_mode)
                        local_aux_channel_render_.draw(aux_video_capture_buffer, aux_video_width_, aux_video_height_)
                    }

                } else {
                    //console.log('not init buffer, can not draw')
                }
            }
        } else {
            if (rs && rs.is_media_player_stream) {
                for (let i = 0; i < media_player_list_.length; ++i) {
                    //console.log("in media_player_list_ player index = ", media_player_list_[i].player_index);
                    if (media_player_list_[i].player_index == rs.player_index) {
                        if (rs.width == media_player_list_[i].width && rs.height == media_player_list_[i].height) {
                            if (on_video_data_cb_) {
                                if (!rs.data) {
                                    rs.data = media_player_list_[i].video_buffer;
                                }

                                on_video_data_cb_(rs)
                            }
                            if (!external_render_ && media_player_list_[i].gl_render) {
                                let previewMode = this.remoteViewModes[media_player_list_[i].stream_id]
                                previewMode = previewMode === void 0 ? 0 : previewMode
                                media_player_list_[i].gl_render.setViewMode(previewMode)
                                media_player_list_[i].gl_render.draw(media_player_list_[i].video_buffer, rs.width, rs.height)
                            }

                            break
                        }
                    }
                }
            } else {
                //console.log("is not local stream", rs);
                for (let i = 0; i < play_list_.length; ++i) {
                    //console.log("in play_list_ ", play_list_[i].stream_id, rs.stream_id);
                    if (play_list_[i].stream_id == rs.stream_id) {
                        if (rs.width == play_list_[i].width && rs.height == play_list_[i].height) {
                            if (on_video_data_cb_) {
                                if (!rs.data) {
                                    rs.data = play_list_[i].video_buffer;
                                }

                                on_video_data_cb_(rs)
                            }
                            if (!external_render_ && play_list_[i].gl_render) {
                                let previewMode = this.remoteViewModes[play_list_[i].stream_id]
                                previewMode = previewMode === void 0 ? 0 : previewMode
                                play_list_[i].gl_render.setViewMode(previewMode)
                                play_list_[i].gl_render.draw(play_list_[i].video_buffer, rs.width, rs.height)
                            }

                            break
                        }
                    }
                }
            }
        }
    }

    this.onPaintAll = function () {
        //console.log("on_paint_list_ len ", on_paint_list_.length);
        for (let i = 0; i < on_paint_list_.length; ++i) {
            this.onPaint(on_paint_list_[i])
        }
        on_paint_list_ = []
    }

    zego_base_.registerEventHandler('onVideoRefresh', rs => {
        //console.log("onVideoRefresh",rs);
        //this.onPaint(rs,0);
        let i = 0
        for (; i < on_paint_list_.length; ++i) {
            if (on_paint_list_[i].stream_id == rs.stream_id) {
                on_paint_list_[i] = rs
                break
            }
        }
        if (on_paint_list_.length == i) {
            on_paint_list_.push(rs)
            window.requestAnimationFrame(this.onPaintAll.bind(this))
        }
    })

    zego_base_.registerEventHandler('onMediaPlayerVideoRefresh', rs => {
        let i = 0
        for (; i < on_paint_list_.length; ++i) {
            if (on_paint_list_[i].player_index == rs.player_index) {
                on_paint_list_[i] = rs
                break
            }
        }
        if (on_paint_list_.length == i) {
            on_paint_list_.push(rs)
            window.requestAnimationFrame(this.onPaintAll.bind(this))
        }
    })

    /**
     * 注册事件监听
     * @param {string} event_name - 事件名称
     * @param {function} cb 可以注册的事件有：
     * @param {onAVKitEvent}  cb.cb SDK 引擎事件通知
     * @param {onPlayStateUpdate}  cb.cb 拉流状态通知
     * @param {onPlayQualityUpdate}  cb.cb 拉流质量更新事件通知
     * @param {onPublishStateUpdate}  cb.cb 推流状态更新返回
     * @param {onStreamUpdated}  cb.cb 流更新事件通知添加或者删除流的事件
     * @param {onPublishQualityUpdate}  cb.cb 推流质量通知
     * @param {onUserUpdate}  cb.cb 房间用户信息更新
     * @param {onUpdateOnlineCount}  cb.cb 房间在线人数更新
     * @param {onSendRoomMessage}  cb.cb 发送房间消息结果返回
     * @param {onRecvRoomMessage}  cb.cb 收到房间消息通知
     * @param {onSendBigRoomMessage}  cb.cb 发送大房间消息结果返回
     * @param {onRecvBigRoomMessage}  cb.cb 收到大房间消息通知
     * @param {onSetRoomExtraInfo} cb.cb 设置房间附加消息结果返回
     * @param {onRoomExtraInfoUpdated} cb.cb 收到房间附加消息更新通知
     * @param {onCustomCommand}  cb.cb 发送自定义消息结果返回
     * @param {onRecvCustomCommand}  cb.cb 收到自定义消息通知
     * @param {onStreamExtraInfoUpdated}  cb.cb 流额外信息更新通知
     * @param {onAudioDeviceStateChanged}  cb.cb 音频设备状态更新通知
     * @param {onVideoDeviceStateChanged}  cb.cb 视频设备状态更新通知
     * @param {onAudioVolumeChanged}  cb.cb 音量变更事件通知
     * @param {onDeviceError}  cb.cb 设备状态错误事件通知
     * @param {onRetryDevice}  cb.cb 当前正在尝试使用的设备回调
     * @param {onKickOut}  cb.cb 被挤掉线通知
     * @param {onDisconnect}  cb.cb 已从房间断开连接
     * @param {onReconnect}  cb.cb 与 server 重连成功通知
     * @param {onTempBroken}  cb.cb 与 server 连接中断通知
     * @param {onAVEngineStart}  cb.cb 音视频引擎启动时通知
     * @param {onAVEngineStop}  cb.cb 音视频引擎停止时通知
     * @param {onRecvMediaSideInfo} cb.cb 收到媒体次要信息通知
     * @param {onMixStreamEx} cb.cb 混流结果回调通知
     * @param {onSoundLevelInMixedPlayStream} cb.cb 混流音浪回调通知，在回调中可以拿到混流中每条的音量大小信息
     * @param {onSoundLevelUpdate} cb.cb 拉流音浪回调通知，调用startSoundLevelMonitor后生效
     * @param {onCaptureSoundLevelUpdate} cb.cb 采集音浪回调通知，调用startSoundLevelMonitor后生效
     * @param {onVideoData} cb.cb 渲染前的视频数据回调
     * @param {onMediaPlayerPlayStart} cb.cb MediaPlayer 开始播放通知，注意：所有mediaplayer事件的通知，播放前必须调用mediaPlayerInitWithType进行初始化播放器才会有回调
     * @param {onMediaPlayerPlayError} cb.cb MediaPlayer 播放出错通知
     * @param {onMediaPlayerVideoBegin} cb.cb MediaPlayer 视频开始播放通知
     * @param {onMediaPlayerAudioBegin} cb.cb MediaPlayer 音频开始播放通知
     * @param {onMediaPlayerPlayEnd} cb.cb MediaPlayer 播放结束通知
     * @param {onMediaPlayerSeekComplete} cb.cb MediaPlayer 快进到指定时刻的回调
     * @param {onMediaPlayerPlayPause} cb.cb MediaPlayer 暂停播放的回调
     * @param {onMediaPlayerPlayResume} cb.cb MediaPlayer 恢复播放的回调
     * @param {onMediaPlayerPlayStop} cb.cb MediaPlayer 主动停止播放的回调
     * @param {onMediaPlayerBufferBegin} cb.cb MediaPlayer 开始缓冲通知
     * @param {onMediaPlayerBufferEnd} cb.cb MediaPlayer 结束缓冲通知
     * @param {onMediaPlayerLoadComplete} cb.cb MediaPlayer 调用 mediaPlayerLoad 接口加载完成的回调
     * @param {onAudioPlayerPlayEffect} cb.cb AudioPlayer 调用 audioPlayerPlayEffect 的回调
     * @param {onAudioPlayerPlayEnd} cb.cb AudioPlayer 音效播放结束的回调
     * @param {onAudioPlayerPreloadEffect} cb.cb AudioPlayer 调用 audioPlayerPreloadEffect 预加载音效的回调
     * @param {onAudioPlayerPreloadComplete} cb.cb AudioPlayer 预加载音效完成的回调
     * @param {onRemoteCameraStatusUpdate} cb.cb 远端摄像头状态通知
     * @param {onRemoteMicStatusUpdate} cb.cb 远端麦克风状态通知
     * @param {onRecvRemoteAudioFirstFrame} cb.cb 接收到远端音频的首帧通知
     * @param {onRecvRemoteVideoFirstFrame} cb.cb 接收到远端视频的首帧通知
     * @param {onRenderRemoteVideoFirstFrame} cb.cb 远端视频渲染首帧通知
     * @param {onMultiRoomStreamUpdated} cb.cb 第二套房间流更新事件通知
     * @param {onMultiRoomUserUpdate} cb.cb 第二套房间用户信息更新通知
     * @param {onMultiRoomUpdateOnlineCount} cb.cb 第二套房间在线人数更新通知
     * @param {onMultiRoomStreamExtraInfoUpdated} cb.cb 第二套房间流附加信息更新
     * @param {onMultiRoomDisconnect} cb.cb 第二套房间断开连接的通知
     * @param {onMultiRoomReconnect} cb.cb 第二套房间与 server 重连成功通知
     * @param {onMultiRoomTempBroken} cb.cb 第二套房间与 server 连接中断通知，SDK会尝试自动重连
     * @param {onSendMultiRoomMessage} cb.cb 第二套房间发送房间消息结果返回
     * @param {onRecvMultiRoomMessage} cb.cb 第二套房间收到房间消息通知
     * @param {onSendMultiRoomBigRoomMessage} cb.cb 第二套房间发送大房间消息结果返回通知
     * @param {onRecvMultiRoomBigRoomMessage} cb.cb 第二套房间收到大房间消息通知
     * @param {onSendMultiRoomCustomCommand} cb.cb 第二套发送自定义消息结果返回
     * @param {onRecvMultiRoomCustomCommand} cb.cb 第二套房间收到自定义消息
     * @param {onWhiteBoardUploadFile} cb.cb 注册上传文件进度通知
     * @param {onWhiteBoardDownloadFile} cb.cb 注册上传文件进度通知
     * @param {onWhiteBoardCreate}  cb.cb 注册 创建白板 的回调
     * @param {onWhiteBoardAdded}  cb.cb 注册 有白板新增 的通知
     * @param {onWhiteBoardDestroy}  cb.cb 注册 销毁白板 的回调
     * @param {onWhiteBoardRemoved}  cb.cb 注册 有白板被销毁 的通知
     * @param {onWhiteBoardGetList}  cb.cb 注册 互动白板拉取结果 的回调
     * @param {onWhiteBoardCanvasItemZOrderChanged}  cb.cb  注册 图元 zOrder 发生变化 的通知
     * @param {onWhiteBoardSetAspectRatio}  cb.cb 注册 设置白板等比宽高 的回调
     * @param {onWhiteBoardAspectRatioChanged}  cb.cb 注册 白板比例发生变化 的通知
     * @param {onWhiteBoardScrollCanvas}  cb.cb 注册 滑动、滚动白板画布 的回调
     * @param {onWhiteBoardCanvasLoad}  cb.cb 注册 所有图元加载结果 的回调
     * @param {onWhiteBoardCanvasScrolled}  cb.cb 注册 白板画布发生滑动、滚动 的通知
     * @param {onWhiteBoardCanvasItemMoved}  cb.cb 注册 图元有移动 的通知
     * @param {onWhiteBoardCanvasItemDeleted}  cb.cb 注册 图元被删除 的通知
     * @param {onWhiteBoardCanvasPathUpdate}  cb.cb 注册 path图元类型的数据发生变化的 通知
     * @param {onWhiteBoardCanvasTextUpdate}  cb.cb 注册 text图元类型的数据发生变化的 通知
     * @param {onWhiteBoardCanvasLineUpdate}  cb.cb 注册 line图元类型的数据发生变化的 通知
     * @param {onWhiteBoardCanvasRectUpdate}  cb.cb 注册 rect图元类型的数据发生变化的 通知
     * @param {onWhiteBoardCanvasEllipseUpdate}  cb.cb 注册 ellipse图元类型的数据发生变化的 通知
     * @param {onWhiteBoardCanvasClear}  cb.cb 注册 所有图元被清除 的通知
     * @param {onWhiteBoardCanvasLaserUpdate} cb.cb 注册激光笔图元数据发生变化的通知
     * @param {onWhiteBoardCanvasImageUpdate} cb.cb 注册图片图元发生变化的通知
     * @param {onFrequencySpectrumUpdate} cb.cb 拉流的频域功率谱信息回调
     * @param {onCaptrueFrequencySpectrumUpdate} cb.cb 采集的频域功率谱信息回调
     * @param {onCaptureVideoFirstFrame} cb.cb 视频采集首帧回调
     * @param {onCaptureAudioFirstFrame} cb.cb 音频采集首帧回调
     *
     * @return {boolean} - 是否注册成功
     */
    this.onEventHandler = function (event_name, cb) {
        if (event_name == "onVideoData") {
            on_video_data_cb_ = cb;
            return true;
        }
        return zego_base_.registerEventHandler(event_name, cb)
    }

    /**
     * 视频外部自定义渲染开关
     * @param {object} option - 对象参数
     * @param {string} option.enable - true - 使用外部自定义渲染，设置为true之后，在 onVideoData 事件回调里获取视频数据，false - 使用sdk渲染视频
     */
    this.enableExternalRender = function ({ enable }) {
        external_render_ = enable
    }

    /**
     * 设置外部滤镜
     *  @param {objct} option - 对象参数
     *  @param {number} option.factory - 在initsdk之前调用 用户需要自己编写外部滤镜扩展
     */
    this.setVideoFilterFactory = function ({ factory }) {
        zego_base_.setVideoFilterFactory(factory)
    }
    /**
     * 设置用户信息
     *  @param {objct} option - 对象参数
     *  @param {number} option.user_id - 用户唯一 ID，业务上要保证appid下唯一，否则同个用户登陆另外一个用户会onKickOut被踢出
     *  @param {number} option.user_name - 用户名字
     *  @return {boolean} - true - 成功，false - 失败
     */
    this.setUser = function({
        user_id,
        user_name
    }){
        return zego_base_.setUser(user_id, user_name)
    }

    /**
     * 初始化sdk
     * @param {object} option - 初始化对象参数
     * @param {string} option.app_id - app id ，需要向zego申请获取
     * @param {(number|Array)} option.sign_key - sign key , 需要向zego申请获取
     * @param {string} option.user_id - 唯一用户id
     * @param {string} option.user_name - 用户名
	 * @param {boolean} option.enable_mediaplayer_publish - 是否开启mediaplayer的推流功能，开启后，使用主通道来推流mediaplayer播放的数据
     * @param {onInitSDK} cb - 初始化结果回调
     * @return {boolean} 返回true表示正在初始化，false初始化失败
     */
    this.initSDK = function ({
        app_id,
        sign_key,
        user_id,
        user_name,
        enable_mediaplayer_publish = false,
        enable_record = false
    }, cb) {
        let ret = zego_base_.setUser(user_id, user_name)
        if (ret) {
            if (enable_mediaplayer_publish && typeof (zego_base_.enableMediaPlayerPublish) === 'function') {
                zego_base_.enableMediaPlayerPublish(true)
            }
            if (enable_record && typeof (zego_base_.enableRecord) === 'function') {
                zego_base_.enableRecord(true)
            }
            ret = zego_base_.initSDK(app_id, sign_key, cb, enable_mediaplayer_publish, enable_record)
        }
        return ret
    }
    /**
     * 反初始化sdk
     */
    this.unInitSDK = function () {
        return zego_base_.unInitSDK()
    }
    /**
     * 获取sdk版本信息
     * @return {string} sdk 版本信息
     */
    this.getSDKVersion = function () {
        return zego_base_.getSDKVersion()
    }
    /**
     * 获取引擎版本信息
     * @return {string} 引擎版本信息
     */
    this.getEngineVersion = function () {
        return zego_base_.getEngineVersion()
    }
    /**
     * 配置sdk环境，测试环境、正式环境
     * @param {object} option 参数对象
     * @param {boolean} option.use_test_env - 是否使用测试环境
     * @param {boolean} option.use_alpha_env - 是否使用alpha环境
     */
    this.setUseEnv = function ({
        use_test_env,
        use_alpha_env
    }) {
        zego_base_.setUseEnv(use_test_env, use_alpha_env)
    }
    /**
     * 设置是否打印SDK控制台信息
     * @param {object} option 参数对象
     * @param {boolean} option.is_verbose - true - 打印， false - 不打印
     */
    this.setVerbose = function ({
        is_verbose
    }) {
        zego_base_.setVerbose(is_verbose);
    }

    /**
     * 设置日志存储路径
     * @param {object} option - 参数对象
     * @param {string} option.log_dir - 配置sdk日志存储路径
     * @param {number} option.log_level - 配置sdk日志等级， 3 - 通常在发布产品中使用， 4 - 调试阶段使用
     * @return {boolean} 设置结果是否成功
     */
    this.setLogDir = function ({
        log_dir,
        log_level
    }) {
        return zego_base_.setLogDir(log_dir, log_level)
    }
    /**
     * 配置日志最大文件大小
     * @param {object} option - 参数对象
     * @param {number} option.log_size - 日志文件最大大小值
     */
    this.setLogSize = function ({
        log_size
    }) {
        zego_base_.setLogSize(log_size)
    }
    /**
     * 上传sdk日志
     */
    this.uploadLog = function () {
        zego_base_.uploadLog()
    }

    this.enableAddonLog = function ({ enable }) {
        zego_base_.enableAddonLog(enable)
    }

    /**
     * 本地预览截图
     * @param {object} option - 参数对象
     * @param {number} option.channel_index - 通道索引，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     * @param {onTakeSnapshotPreview} cb 本地预览截图回调
     */
    this.takeSnapshotPreview = function ({ channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN }, cb) {
        zego_base_.takeSnapshotPreview(channel_index, cb);
    }
    /**
     * 拉流截图
     * @param {object} option - 参数对象
     * @param {string} option.stream_id - 流id
     * @param {onTakeSnapshot} cb 拉流截图回调
     */
    this.takeSnapshot = function ({ stream_id }, cb) {
        zego_base_.takeSnapshot(stream_id, cb);
    }

    /**
     * 选择辅助推流通道的音频来源
     * @param {object} option - 参数对象
     * @param {number} option.type - 辅助推流通道音频来源类别，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoAuxPublishChannelAudioSrcType</a>
     * @return 0 - 成功
     */
    this.setAudioSrcForAuxiliaryPublishChannel = function ({ type }) {
        return zego_publish_stream_.setAudioSrcForAuxiliaryPublishChannel(type)
    }

    /**
     * 开始录制
     * @param {object} option - 参数对象
     * @param {number} option.channel - 录制通道, 0 - 第一路媒体录制通道, 1 - 第二路媒体录制通道
     * @param {number} option.record_type - 录制类型, 查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoMediaRecordType</a>
     * @param {string} option.storage_path - 录制文件存储路径
     * @param {boolean} option.enable_status_callback - 是否开启录制状态回调，true - 表示会以指定的interval间隔回调onRecordStatusUpdate, false - 表示不回调
     * @param {number} option.interval - 录制信息更新频率，单位毫秒，有效范围：1000-10000，默认值3000
     * @param {number} option.record_format - 录制格式, 1 - flv, 2 - mp4
     * @param {boolean} option.is_fragment - 录制文件是否分片，MP4格式才有效
     * @return {boolean} true 开始异步录制，通过onMediaRecord回调获取是否录制成功， false 失败
     */
    this.startRecord = function ({
        channel_index = 0,
        record_type = ZEGOCONSTANTS.ZegoMediaRecordType.ZEGO_MEDIA_RECORD_BOTH,
        storage_path,
        enable_status_callback = true,
        interval = 3000,
        record_format = 2,
        is_fragment = false
    }) {
        return zego_publish_stream_.startRecord(channel_index, record_type, storage_path, enable_status_callback, interval, record_format, is_fragment)
    }

    /**
     * 停止录制
     *  @param {object} option - 参数对象
     *  @param {number} option.channel_index - 录制通道, 0 - 第一路媒体录制通道, 1 - 第二路媒体录制通道
     */
    this.stopRecord = function ({ channel_index = 0 }) {
        zego_publish_stream_.stopRecord(channel_index)
    }

    /**
     * 激活使用媒体次要信息功能
     * @param {object} option - 参数对象
     * @param {number} option.channel_index - 通道索引，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     * @param {boolean} option.only_audio_publish - true - 纯音频直播，不传输视频数据, false 音视频直播，传输视频数据
	 * @param {number} option.media_info_type - sei类型, 查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoSeiMediaInfoType</a>
     * @param {number} option.sei_send_type - sei发送类型,查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoSeiSendType</a>
     */
    this.activateMediaSideInfo = function ({ channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN, only_audio_publish = false, media_info_type = ZEGOCONSTANTS.ZegoSeiMediaInfoType.MEDIAINFOTYPE_SIDEINFO_ZEGODEFINED, sei_send_type = ZEGOCONSTANTS.ZegoSeiSendType.SEISEND_IN_VIDEO_FRAME}) {
        zego_base_.activateMediaSideInfo(channel_index, only_audio_publish, media_info_type, sei_send_type)
    }

    /**
     * 发送媒体次要信息，使用前先调用activateMediaSideInfo
     * @param {object} option - 参数对象
     * @param {string} option.side_info - 要发送的媒体次要信息
     * @param {number} option.channel_index - 通道索引，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     *
     */
    this.sendMediaSideInfo = function ({ side_info, channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN }) {
        zego_base_.sendMediaSideInfo(channel_index, side_info)
    }
    /**
     * 设置选用分层编码
     * @param {object} option - 参数对象
     * @param {string} option.codec_id - 1为开启，0为关闭
     * @param {number} option.channel_index - 通道索引，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     * @return {boolean} true-成功，false-失败
     */
    this.setVideoCodecId = function ({ codec_id, channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN }) {
        zego_base_.setVideoCodecId(codec_id, channel_index)
    }
    /**
     * 拉流是否接收音频数据,仅拉 UDP 流有效，必须在拉流后调用才有效
     * @param {object} option - 参数对象
     * @param {string} option.stream_id - 播放流 ID
     * @param {boolean} option.is_active - true 接收，false 不接收
     * @return {boolean} true-成功，false-失败
     */
    this.activateAudioPlayStream = function ({
        stream_id,
        is_active
    }) {
        return zego_base_.activateAudioPlayStream(stream_id, is_active)
    }

    /**
     * 拉流是否接收视频数据
     * @param {object} option - 参数对象
     * @param {string} option.stream_id - 播放流 ID
     * @param {boolean} option.is_active - true 接收，false 不接收
     * @param {number} option.video_layer - 视频分层类型, -1 - 根据网络状态选择图层, 0 - 指定拉基本层（小分辨率）, 1 - 指定拉扩展层（大分辨率)
     * @return {boolean} true-成功，false-失败
     */
    this.activateVideoPlayStream = function ({
        stream_id,
        is_active,
        video_layer
    }) {
        return zego_base_.activateVideoPlayStream(stream_id, is_active, video_layer)
    }

    // ZegoRoom
    /**
     * 设置房间配置信息
     * @param {object} option - 参数对象
     * @param {bool} option.audience_create_room - 观众是否可以创建房间。true 可以，false 不可以。默认 true
     * @param {bool} option.user_state_update - 用户状态（用户进入、退出房间）是否广播。true 广播，false 不广播。默认 false 在登录房间前调用有效，退出房间后失效
     */
    this.setRoomConfig = function ({
        audience_create_room,
        user_state_update,
    }) {
        zego_room_.setRoomConfig(audience_create_room, user_state_update)
    }

    /**
     * 设置自定义token信息
     * @param {object} option - 参数对象
     * @param {string} option.third_party_token - 第三方传入的token 使用此函数验证登录时用户的合法性，登录房间前调用，token的生成规则请联系即构。若不需要验证用户合法性，不需要调用此函数 在登录房间前调用有效，退出房间后失效
     */
    this.setCustomToken = function ({ third_party_token }) {
        zego_publish_stream_.setCustomToken(third_party_token);
    }

    /**
     * 登录房间
     * @param {object} option - 参数对象
     * @param {string} option.room_id - 房间id
     * @param {string} option.room_name - 房间名字
     * @param {number} option.role - 角色，取值查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoRoomRole</a>
     * @param {onLoginRoom} cb - 登录房间结果回调
     * @return {boolean} true-正在异步登陆，false-失败
     */
    this.loginRoom = function ({
        room_id,
        room_name,
        role
    }, cb) {
        return zego_room_.loginRoom(room_id, role, room_name, cb)
    }
    /**
     * 登出房间
     * @param {onLogoutRoom} cb - 登出房间结果回调
     * @return {boolean} true-正在异步退出，false-失败
     */
    this.logoutRoom = function (cb) {
        return zego_room_.logoutRoom(cb)
    }

    // ZegoPublishStream
    /**
     * 设置本地摄像头预览目标
     * @param {object} option - 参数对象
     * @param {object} option.canvas_view - 预览的canvas标签对象，例如：document.getElementById("localVideo")
     * @param {number} option.channel_index - 摄像头通道索引，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     * @return {boolean} true-成功，false-失败
     */
    this.setPreviewView = function ({
        canvas_view,
        channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN
    }) {
        if (channel_index == ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN) {
            // console.log("main channel");
            if (main_preview_bk_color != null) {
                local_main_channel_render_.initBkColor(main_preview_bk_color)
            }
            return local_main_channel_render_.initGLfromCanvas(canvas_view)
        } else if (channel_index == ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_AUX) {
            // console.log("aux channel");
            if (aux_preview_bk_color != null) {
                local_aux_channel_render_.initBkColor(aux_preview_bk_color)
            }
            return local_aux_channel_render_.initGLfromCanvas(canvas_view)
        }
    }

    /**
     * 设置推流端预览控件的背景颜色,在调用setPreviewView 之前调用才会生效
     * @param {object} option - 参数对象
     * @param {number} option.color - 颜色，取值为0xFFRRGGBB
     * @param {number} option.channel_index - 摄像头通道索引，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     */
    this.setPreviewViewBackgroundColor = function ({
        color,
        channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN
    }) {
        //        const alpha = color >> 24 & 0xff;
        //        const red = color >> 16 & 0xff;
        //        const green = color >> 8 & 0xff;
        //        const blue = color & 0xff;
        if (channel_index == ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN) {
            main_preview_bk_color = color
        } else if (channel_index == ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_AUX) {
            aux_preview_bk_color = color
        }
    }

    /**
     * 设置拉流播放控件的背景颜色,在startPlayingStream接口前调用才会生效
     * @param {object} option - 参数对象
     * @param {number} option.color - 颜色，取值为0xFFRRGGBB
     * @param {string} option.stream_id - 拉流的流id
     */
    this.setViewBackgroundColor = function ({
        color,
        stream_id
    }) {
        for (let i = 0; i < play_bk_color_list_.length; ++i) {
            if (play_bk_color_list_[i].stream_id == stream_id) {
                play_bk_color_list_[i].color = color
                return
            }
        }
        play_bk_color_list_.push({ color: color, stream_id: stream_id })
    }

    /**
     * 开始预览
     * @param {object} option - 参数对象
     * @param {number} option.channel_index - 摄像头通道索引，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     * @return {boolean} true-成功，false-失败
     */
    this.startPreview = function ({ channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN }) {
        return zego_publish_stream_.startPreview(channel_index)
    }
    /**
     * 停止预览
     * @param {object} option - 参数对象
     * @param {number} option.channel_index - 摄像头通道索引，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     * @return {boolean} true-成功， false-失败
     */
    this.stopPreview = function ({
        channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN
    }) {
        return zego_publish_stream_.stopPreview(channel_index)
    }



    /**
     * 开始推流
     * @param {object} option - 参数对象
     * @param {string} option.title - 推流标题
     * @param {string} option.stream_id - 推流流id
     * @param {number} option.publish_flag - 推流flag，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoPublishFlag</a>
     * @param {string} option.params - 推流附带参数
     * @param {number} option.channel_index - 摄像头通道索引，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     * @param {number} option.media_player_index - 多实例mediaplayer下，需要推流哪个实例的播放器
     * @return {boolean} true - 开始异步推流， false - 失败
     */
    this.startPublishing = function ({
        title,
        stream_id,
        publish_flag,
        params,
        channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN,
        media_player_index = 0
    }) {
        if (media_player_index != 0 && typeof (zego_base_.setPublishMediaPlayerIndex) === 'function') {
            zego_publish_stream_.setPublishMediaPlayerIndex(media_player_index)
        }
        return zego_publish_stream_.startPublishing(title, stream_id, publish_flag, params, channel_index)
    }
    /**
     * 停止推流
     * @param {object} option - 参数对象
     * @param {string} option.msg 停止推流额外信息
     * @param {number} option.channel_index 推流通道，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     */
    this.stopPublishing = function ({
        msg = 0,
        channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN
    }) {
        return zego_publish_stream_.stopPublishing(msg, channel_index)
    }
    /**
     * 是否使用摄像头
     * @param {object} option - 参数对象
     * @param {boolean} option.enable - true-开启， false-关闭
     * @param {number} option.channel_index - 摄像头通道索引，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     */
    this.enableCamera = function ({
        enable = true,
        channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN
    }) {
        return zego_publish_stream_.enableCamera(enable, channel_index)
    }
    /**
     * 是否开启本地摄像头镜像模式
     * @param {object} option -  参数对象
     * @param {boolean} option.enable - true-使用镜像， false-不使用镜像模式
     * @param {number} option.channel_index - 摄像头通道索引，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     */
    this.enableCaptureMirror = function ({
        enable = true,
        channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN
    }) {
        return zego_publish_stream_.enableCaptureMirror(enable, channel_index)
    }

    /**
     * 是否启用预览和推流镜像
     * @param {object} option -  参数对象
     * @param {boolean} option.mode - 镜像模式， 0 - 预览启用镜像，推流不启用镜像；1 - 预览启用镜像，推流启用镜像；2 - 预览不启用镜像，推流不启用镜像；3 - 预览不启用镜像，推流启用镜像；
     * @param {number} option.channel_index - 摄像头通道索引，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     */
    this.setVideoMirrorMode = function ({
        mode,
        channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN
    }) {
        return zego_publish_stream_.setVideoMirrorMode(mode, channel_index)
    }

    /**
     * 设置摄像头采集分辨率
     * @param {object} option - 参数对象
     * @param {number} option.width - 宽
     * @param {number} option.height - 高
     * @param {number} option.channel_index - 通道索引，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     */
    this.setVideoCaptureResolution = function ({
        width,
        height,
        channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN
    }) {
        return zego_publish_stream_.setVideoCaptureResolution(width, height, channel_index)
    }
    /**
     * 设置音频设备模式，确保在 initSDK 前调用
     * @param {object} option  - 参数对象
     * @param {number} option.device_mode - 模式，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoAVAPIAudioDeviceMode</a>
     */
    this.setAudioDeviceMode = function ({
        device_mode
    }) {
        zego_publish_stream_.setAudioDeviceMode(device_mode)
    }
    /**
     * 回声消除开关，建议在推流前调用设置
     * @param {object} option - 参数对象
     * @param {boolean} option.enable - true 开启，false 关闭
     */
    this.enableAEC = function ({
        enable
    }) {
        return zego_publish_stream_.enableAEC(enable)
    }
    /**
     * 音频采集自动增益开关
     * @param {object} option - 参数对象
     * @param {boolean} option.enable - true 开启，false 关闭
     */
    this.enableAGC = function ({
        enable
    }) {
        return zego_publish_stream_.enableAGC(enable)
    }
    /**
     * 音频采集噪声抑制开关
     * @param {object} option - 参数对象
     * @param {boolean} option.enable - true 开启，false 关闭
     */
    this.enableANS = function ({
        enable
    }) {
        return zego_publish_stream_.enableANS(enable)
    }
    /**
     * 开启采集监听
     * @param {object} option - 参数对象
     * @param {boolean} option.enable - true 开启，false 关闭
     * @return {boolean} true 成功，false 失败
     */
    this.enableLoopback = function ({
        enable
    }) {
        return zego_publish_stream_.enableLoopback(enable)
    }
    /**
     * 设置监听音量,推流时可调用本 API 进行参数配置
     * @param {object} option - 参数对象
     * @param {number} option.volume - 音量大小，取值（0, 100）。默认 100
     */
    this.setLoopbackVolume = function ({
        volume
    }) {
        return zego_publish_stream_.setLoopbackVolume(volume)
    }
    /**
     * 设置采集音量,SDK初始化成功后调用
     * @param {object} option - 参数对象
     * @param {number} option.volume - volume	音量大小，取值（0, 100）。默认 100
     */
    this.setCaptureVolume = function ({
        volume
    }) {
        return zego_publish_stream_.setCaptureVolume(volume)
    }
    /**
     * 硬件编码开关,如果要打开，需要在推流前设置,打开硬编硬解开关需后台可控，避免碰到版本升级或者硬件升级时出现硬编硬解失败的问题
     * @param {object} option - 参数对象
     * @param {boolean} option.enable - true 开启，false 关闭。默认 false
     */
    this.requireHardwareEncoder = function ({
        enable
    }) {
        return zego_publish_stream_.requireHardwareEncoder(enable)
    }
    /**
     * 设置视频带宽比特率
     * @param {object} option - 参数对象
     * @param {number} option.bitrate - 比特率
     * @param {number} option.channel_index - 通道索引 , 查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     */
    this.setVideoBitrate = function ({ bitrate, channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN }) {
        return zego_publish_stream_.setVideoBitrate(bitrate, channel_index)
    }
    /**
     * 设置视频帧率
     * @param {object} option - 参数对象
     * @param {number} option.fps - 帧率
     * @param {number} option.channel_index - 通道索引 , 查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     */
    this.setVideoFPS = function ({
        fps,
        channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN
    }) {
        return zego_publish_stream_.setVideoFPS(fps, channel_index)
    }
    /**
     * 设置视频编码分辨率
     * @param {object} option - 参数对象
     * @param {number} option.width - 宽
     * @param {number} option.height - 高
     * @param {number} option.channel_index - 通道索引, 查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     */
    this.setVideoEncodeResolution = function ({
        width,
        height,
        channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN
    }) {
        return zego_publish_stream_.setVideoEncodeResolution(width, height, channel_index)
    }
    /**
     * 设置音频比特率
     * @param {object} option - 参数对象
     * @param {number} option.bitrate - 比特率值
     */
    this.setAudioBitrate = function ({
        bitrate
    }) {
        return zego_publish_stream_.setAudioBitrate(bitrate)
    }
    /**
     * 设置配置信息
     * @param {object} option - 参数对象
     * @param {string} option.config - 配置信息
     *   配置项的写法，例如 "keep_audio_session_active=true", 等号后面值的类型要看下面每一项的定义
     *   "prefer_play_ultra_source", int value, 确保在 InitSDK 前调用，但开启拉流加速(config为“prefer_play_ultra_source=1”)可在 InitSDK 之后，拉流之前调用
     *   "camera_orientation_mode", string value: auto/hardcode/0/90/180/270. for Android, Windows。
     *   "alsa_capture_device_name" string value: plughw:[card_id],[device_id], eg: plughw:1,0, default is plug:default. view the device list with arecord. for Linux。
     *   "alsa_playback_device_name" string value: plughw:[card_id],[device_id], eg: plughw:1,0, default is plug:default. view the device list with aplay. for Linux。
     */
    this.setGeneralConfig = function ({
        config
    }) {
        return zego_publish_stream_.setGeneralConfig(config)
    }
    /**
     * 设置或更新推流的附加信息,更新流附加信息成功后，同一房间内的其他人会收到 onStreamExtraInfoUpdated 通知
     * @param {object} option - 参数对象
     * @param {string} option.extra_info - 流附加信息
     * @param {number} option.channel_index - 推流 channel Index, 查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     */
    this.setPublishStreamExtraInfo = function ({
        extra_info,
        channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN
    }) {
        return zego_publish_stream_.setPublishStreamExtraInfo(extra_info, channel_index)
    }
    /**
     * 自定义转推目的地
     * @param {object} option - 参数对象
     * @param {string} option.target_addr - 目的 rmtp 推流地址
     * @param {number} option.channel_index - 推流 channel Index, 查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     */
    this.setCustomPublishTarget = function ({
        target_addr,
        channel_index
    }) {
        return zego_publish_stream_.setCustomPublishTarget(target_addr, channel_index)
    }
    /**
     * 设置推流音频声道数,必须在推流前设置
     * @param {object} option - 参数对象
     * @param {number} option.channel_count - 声道数，1 或 2，默认为 1（单声道）
     */
    this.setAudioChannelCount = function ({
        channel_count
    }) {
        return zego_publish_stream_.setAudioChannelCount(channel_count)
    }
    /**
     * 是否开启离散音频包发送,确保在推流前调用，只有纯 UDP 方案才可以调用此接口
     * @param {object} option - 参数对象
     * @param {boolean} option.enable - true 开启，此时关闭麦克风后，不会发送静音包；false 关闭，此时关闭麦克风后会发送静音包
     */
    this.enableDTX = function ({
        enable
    }) {
        return zego_publish_stream_.enableDTX(enable)
    }
    /**
     * 是否开启流量控制,确保在推流前调用，在纯 UDP 方案才可以调用此接口
     * @param {object} option - 参数对象
     * @param {number} option.control_property - 流量控制属性 (帧率，分辨率）
     * @param {boolean} option.enable - true 开启，false 关闭。默认开启
     */
    this.enableTrafficControl = function ({
        control_property,
        enable
    }) {
        return zego_publish_stream_.enableTrafficControl(control_property, enable)
    }
    /**
     * 帧顺序检测开关
     * @param {object} option - 参数对象
     * @param {boolean} option.enable true 检测帧顺序，不支持B帧； false 不检测帧顺序，支持B帧，可能出现短暂花屏
     */
    this.enableCheckPoc = function ({
        enable
    }) {
        return zego_publish_stream_.enableCheckPoc(enable)
    }

    /**
     * @param {object} option - 参数对象
     * @param {number} option.mode - 延时模式,取值查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoAVAPILatencyMode</a>
     * 0 - 普通延迟模式；
     * 1 - 低延迟模式，无法用于 RTMP 流；
     * 2 - 普通延迟模式，最高码率可达 192K；
     * 3 - 低延迟模式，无法用于 RTMP 流。相对于 ZEGO_LATENCY_MODE_LOW 而言，CPU 开销稍低；
     * 4 - 低延迟模式，无法用于 RTMP 流。支持WebRTC必须使用此模式；
     * 5 - 普通延迟模式，使用此模式前先咨询即构技术支持；
     */
    this.setLatencyMode = function ({
        mode
    }) {
        return zego_publish_stream_.setLatencyMode(mode)
    }

    /**
     * 设置视频采集缩放时机,初始化 SDK 后，startPreview 前调用。
     * @param {object} option - 参数对象
     * @param {number} option.mode - 视频采集缩放时机
     * 0 - 采集后立即进行缩放，默认，效果：当设置采集分辨率和编码分辨率不一致时，本地预览画面跟编码分辨率一致；
     * 1 - 编码时进行缩放，效果：当设置采集分辨率和编码分辨率不一致时，本地预览画面跟采集分辨率一致，在编码时才进行缩放；
     */
    this.setCapturePipelineScaleMode = function ({
        mode
    }) {
        return zego_publish_stream_.setCapturePipelineScaleMode(mode)
    }

    /**
     * 推流时是否发送音频数据
     * @param {object} option - 参数对象
     * @param {boolean} option.is_mute true 不发送，false 发送
     * @param {number} option.channel_index - 推流 channel Index, 查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     * @return {number} 0 代表设置成功成功，否则设置失败
     */
    this.muteAudioPublish = function ({
        is_mute,
        channel_index
    }) {
        return zego_publish_stream_.muteAudioPublish(is_mute, channel_index)
    }

    /**
     * 推流时是否发送视频数据,拉流端通过 onRemoteCameraStatusUpdate 回调监听此状态是否改变
     * @param {object} option - 参数对象
     * @param {boolean} option.is_mute true 不发送（仅预览），false 发送
     * @param {number} option.channel_index - 推流 channel Index, 查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     * @return {number} 0 代表设置成功成功，否则设置失败
     */
    this.muteVideoPublish = function ({
        is_mute,
        channel_index
    }) {
        return zego_publish_stream_.muteVideoPublish(is_mute, channel_index)
    }

    /**
     * 把引擎播放的声音混到推流中
     * @param {object} option - 参数对象
     * @param {boolean} option.enable true 混到推流中，false 不混到推流中，默认为false
	 * @return {number} 0 代表设置成功成功，否则设置失败
     */
    this.mixEnginePlayout = function ({
        enable
    }) {
        return zego_publish_stream_.mixEnginePlayout(enable)
    }

    /**
     * 设置引擎播放的声音混到推流中的音量
     * @param {object} option - 参数对象
     * @param {number} option.volume 音量，0-100
     */
    this.setMixEnginePlayoutVolume = function ({
        volume
    }) {
        return zego_publish_stream_.setMixEnginePlayoutVolume(enable)
    }

     /**
     * 音频采集的瞬态噪声抑制开关（消除键盘、敲桌子等瞬态噪声）
     * @param {object} option - 参数对象
     * @param {boolean} option.enable  true 开启，false 关闭
     * @return {number} 0 代表设置成功成功，否则设置失败
     */
    this.enableTransientNoiseSuppress = function ({
        enable
    }) {
        return zego_publish_stream_.enableTransientNoiseSuppress(enable)
    }
	/**
	* 设置混音音量
	* @note 1. 此 API 可以在混音之前或者混完音之后调用，取决于用户需求。
	* 2.SetAuxVolume 的工作逻辑都是基于对引擎的输入输出数据进行处理，即对输入 SDK 的音频数据的音量大小进行设置，与进行混音的推流设备的系统音量没有关系。
	* @param volume 音量值范围 0 ~ 200，默认为 100。
	*/
    this.setAuxVolume = function ({
        volume
    }) {
        zego_publish_stream_.setAuxVolume(volume)
    }
	/**
	* 设置混音推流音量
	* @param volume 音量 0 ~ 200，默认为 100
	*/
    this.setAuxPublishVolume = function ({
        volume
    }) {
        zego_publish_stream_.setAuxPublishVolume(volume)
    }

	/**
	* 设置混音本地播放音量
	* @param volume 音量 0 ~ 200，默认为 100
	*/
    this.setAuxPlayVolume = function ({
        volume
    }) {
        zego_publish_stream_.setAuxPlayVolume(volume)
    }

    // ZegoPlayStream

    /**
     * 拉流播放
     * @param {object} option - 参数对象
     * @param {string} option.stream_id - 流id
     * @param {string} option.canvas_view - 要显示的 canvas 对象
     * @param {string} option.params - 拉流参数，要与推流参数一致
     */
    this.startPlayingStream = function ({
        stream_id,
        canvas_view,
        params
    }) {
        for (let i = 0; i < play_list_.length; ++i) {
            if (play_list_[i].stream_id == stream_id) {
                //console.log("have aready in list");
                return zego_play_stream_.startPlayingStream(stream_id, params)
            }
        }
        let render = null;
        if (canvas_view != null) {
            render = new WebGLRender()
            for (let i = 0; i < play_bk_color_list_.length; ++i) {
                if (play_bk_color_list_[i].stream_id == stream_id) {
                    render.initBkColor(play_bk_color_list_[i].color)
                }
            }
            render.initGLfromCanvas(canvas_view)
        }
        play_list_.push({
            stream_id,
            canvas_view,
            gl_render: render
        })
        //console.log("startPlayingStream play_list_ = ", play_list_);
        return zego_play_stream_.startPlayingStream(stream_id, params)
    }

    /**
     * 拉流播放
     * @param {object} option - 参数对象
     * @param {string} option.stream_id - 流id
     * @param {string} option.canvas_view - 要显示的 canvas 对象
     * @param {string | array} option.urls - rtmp flv播放地址数组列表，尝试播放第一个地址，播放失败会按顺序往下播放
     * @param {string} option.params - 拉流参数，要与推流参数一致
     * @param {boolean} option.should_switch_server - 连麦时是否切换服务器
     */
    this.startPlayingStream2 = function ({
        stream_id,
        canvas_view,
        urls = [],
        params = "",
        should_switch_server = true
    }) {

        zego_play_stream_.zegoStreamExtraInfoCreate();
        for (let i = 0; i < urls.length; ++i) {
            zego_play_stream_.zegoStreamExtraInfoAddUrl(urls[i]);
        }
        zego_play_stream_.zegoStreamExtraInfoSetParams(params);
        zego_play_stream_.zegoStreamExtraInfoShouldSwitchServer(should_switch_server);


        for (let i = 0; i < play_list_.length; ++i) {
            if (play_list_[i].stream_id == stream_id) {
                //console.log("have aready in list");
                return zego_play_stream_.startPlayingStream(stream_id, params)
            }
        }
        let render = null;
        if (canvas_view != null) {
            render = new WebGLRender()
            render.initGLfromCanvas(canvas_view)
        }
        play_list_.push({
            stream_id,
            canvas_view,
            gl_render: render
        })
        //console.log("startPlayingStream play_list_ = ", play_list_);
        return zego_play_stream_.startPlayingStream(stream_id, params)
    }


    /**
     * 停止拉流
     * @param {object} option - 参数对象
     * @param {string} option.stream_id - 流id
     */
    this.stopPlayingStream = function ({
        stream_id
    }) {
        for (let i = 0; i < play_list_.length; ++i) {
            if (play_list_[i].stream_id == stream_id) {
                play_list_.splice(i, 1)
                //console.log("remove from play list");
                break
            }
        }
        return zego_play_stream_.stopPlayingStream(stream_id)
    }

    /**
     * 释放webgl context
     * 停止拉流后，如果不需要再使用该canvas，使用该接口进行释放webgl context
     * 注意：此接口只能在停止拉流后使用，使用此接口释放canvas后，不能再次使用该canvas进行拉流和显示，除非通过restoreCanvasContext恢复成功后，才能再次调用拉流接口显示
     *
     * @param {object} option - 参数对象
     * @param {string} option.canvas - canvas
     * @param {onLostContext} cb - function(lose_context){} 释放回调，lose_context - 释放上下文，成功不等于null，失败为null。
     * 需要再次使用该canvas时，通过lose_context 和 接口restoreCanvasContext 来恢复上下文
     *
     */
    this.loseCanvasContext = function ({ canvas }, cb) {
        let gl_will_release = canvas.getContext('webgl')
        if (gl_will_release.isContextLost()) {
            if (cb) {
                cb(null)
            }
            return
        }

        let lose_ext = gl_will_release.getExtension('WEBGL_lose_context')
        canvas.addEventListener("webglcontextlost", function (e) {
            e.preventDefault();
            if (cb) {
                cb(lose_ext)
            }
        }, { once: true });

        if (lose_ext) {
            lose_ext.loseContext();
        } else {
            if (cb) {
                cb(null)
            }
        }
    }
    /**
     * 恢复canvas的 webgl context，仅在使用loseCanvasContext后，还需要重新使用该canvas时才要调用本接口
     * @param {object} option - 参数对象
     * @param {string} option.canvas - canvas
     * @param {string} option.lose_context - 通过restoreCanvasContext释放canvas成功后返回的释放上下文
     * @param {onLostContext} cb - function(error_code){} 恢复回调，error_code， 0 - 成功，-1 - 失败
     *
     */
    this.restoreCanvasContext = function ({ canvas, lose_context }, cb) {
        let gl_will_restore = canvas.getContext('webgl')
        if (!gl_will_restore.isContextLost()) {
            if (cb) {
                cb(-1)
            }
            return
        }

        canvas.addEventListener("webglcontextrestored", function (e) {
            console.log("webglcontextrestored")
            if (cb) {
                cb(0)
            }
        }, { once: true });

        if (lose_context && gl_will_restore.isContextLost()) {
            lose_context.restoreContext();
        } else {
            if (cb) {
                cb(-1)
            }
        }
    }

    /**
     * 硬件解码,如果要打开，需要在拉流前设置,打开硬编硬解开关需后台可控，避免碰到版本升级或者硬件升级时出现硬编硬解失败的问题
     * @param {object} option - 参数对象
     * @param {boolean} option.required - true 打开，false 关闭。默认 false
     */
    this.requireHardwareDecoder = function ({
        required
    }) {
        return zego_play_stream_.requireHardwareDecoder(required)
    }
    /**
     * （声音输出）静音开关, 设置为关闭后，默认扬声器和耳机均无声音输出
     * @param {object} option - 参数对象
     * @param {boolean} option.enable - true 不静音，false 静音。默认 true
     * @return {boolean} true 成功，false 失败
     */
    this.enableSpeaker = function ({
        enable
    }) {
        return zego_play_stream_.enableSpeaker(enable)
    }
    /**
     * 设置播放音量
     * @param {object} option - 参数对象
     * @param {number} option.volume - 音量取值范围为(0, 200)，数值越大，音量越大。默认 100
     * @param {string} option.stream_id - 流id
     */
    this.setPlayVolume = function ({
        volume,
        stream_id
    }) {
        return zego_play_stream_.setPlayVolume(volume, stream_id)
    }
    /**
     * 获取 SDK 支持的最大同时播放流数
     * @return {number} 最大支持播放流数
     */
    this.getMaxPlayChannelCount = function () {
        return zego_play_stream_.getMaxPlayChannelCount()
    }
    /**
     * 设置拉流质量监控周期
     * @param {object} option - 参数对象
     * @param {number} option.cycle_ms - 时间周期，单位为毫秒，取值范围为(500, 60000)。默认为 3000
     * @return {boolean} true 成功，false 失败
     */
    this.setPlayQualityMonitorCycle = function ({
        cycle_ms
    }) {
        return zego_play_stream_.setPlayQualityMonitorCycle(cycle_ms)
    }

    // ZegoIM
    /**
     * 发送聊天室消息
     * @param {object} option - 参数对象
     * @param {number} option.msg_type - 消息类型，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoMessageType</a>
     * @param {number} option.msg_category - 消息分类， 查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoMessageCategory</a>
     * @param {string} option.msg_content - 消息内容
     * @return {number} 返回消息的seq
     */
    this.sendRoomMessage = function ({
        msg_type,
        msg_category,
        msg_content
    }) {
        return zego_im_.sendRoomMessage(msg_type, msg_category, msg_content)
    }
    /**
     * 发送不可靠信道消息，主要用于大并发的场景，发送一些非必须到达的消息
     * @param {object} option - 参数对象
     * @param {number} option.msg_type - 消息类型，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoMessageType</a>
     * @param {number} option.msg_category - 消息分类， 查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoMessageCategory</a>
     * @param {string} option.msg_content - 消息内容
     * @return {number} 返回消息的seq
     */
    this.sendBigRoomMessage = function ({
        msg_type,
        msg_category,
        msg_content
    }) {
        return zego_im_.sendBigRoomMessage(msg_type, msg_category, msg_content)
    }
    /**
     * 发送自定义消息
     * @param {object} option - 参数对象
     * @param {object|array}  option.member_list - 发送目标列表，数据格式为：[{user_id:'1', user_name:'1'},{user_id:'2', user_name:'3'}]
     * @param {string} option.msg_content - 消息内容
     */
    this.sendCustomCommand = function ({
        member_list,
        msg_content
    }) {
        return zego_im_.sendCustomCommand(member_list, msg_content)
    }


    /**
     * 已废弃的接口：发送可靠业务消息
     * @param {object} option - 参数对象
     * @param {object|array}  option.msg_type 业务类型，不能超过 128 字节, 不允许为空字符串, 一个房间内只允许不超过10个不同的消息类型
     * @param {string} option.msg_content - 可靠业务消息内容，不能超过 2048 字节, 允许为空字符串
     * @param {number} option.latest_msg_seq - 当前此业务类型的最新server seq
     * @return {number} 发送序号seq
     */
    this.sendReliableMessage = function ({
        msg_type,
        msg_content,
        latest_msg_seq
    }) {
        return zego_im_.sendReliableMessage(msg_type, msg_content, latest_msg_seq)
    }

    /**
     * 更新房间属性 登录房间成功后使用，通过onSetRoomExtraInfo回调判断是否设置成功，设置成功后，房间内的其它人通过onRoomExtraInfoUpdated回调获取到更新通知
     * @param {object} option - 参数对象
     * @param {string} option.msg_key - 房间额外信息key值，不能超过 10字节, 不允许为空字符串, 一个房间内只允许1个消息类型
     * @param {string} option.msg_value - 房间属性内容，不能超过 128 字节, 允许为空字符串
     * @return {number} 发送序号seq
     */
    this.setRoomExtraInfo = function ({
        msg_key,
        msg_value
    }) {
        return zego_room_.setRoomExtraInfo(msg_key, msg_value)
    }


    /**
     * 更新多房间属性 登录多房间成功后使用，通过onSetMultiRoomExtraInfo回调判断是否设置成功，设置成功后，房间内的其它人通过onMultiRoomExtraInfoUpdated回调获取到更新通知
     * @param {object} option - 参数对象
     * @param {string} option.msg_key - 房间额外信息key值，不能超过 10字节, 不允许为空字符串, 一个房间内只允许1个消息类型
     * @param {string} option.msg_value - 房间属性内容，不能超过 100 字节, 允许为空字符串
     * @return {number} 发送序号seq
     */
    this.setMultiRoomExtraInfo = function ({
        msg_key,
        msg_value
    }) {
        return zego_room_.setMultiRoomExtraInfo(msg_key, msg_value)
    }




    // ZegoMultiRoom
    /**
     * 设置第二套房间配置信息,在登录房间前调用有效，退出房间后失效
     * @param {object} option - 参数对象
     * @param {boolean} option.audience_create_room - 观众是否可以创建房间
     * @param {object} option.user_state_update - 用户状态（用户进入、退出房间）是否广播。true 广播，false 不广播。默认 false
     */
    this.setMultiRoomConfig = function ({ audience_create_room, user_state_update }) {
        return zego_multi_room_.setMultiRoomConfig(audience_create_room, user_state_update)
    }
    /**
     * 设置第二套房间自定义token信息，使用此函数验证登录时用户的合法性，登录房间前调用，token的生成规则请联系即构。若不需要验证用户合法性，不需要调用此函数
     * 在登录房间前调用有效，退出房间后失效
     * @param {object} option - 参数对象
     * @param {string} option.third_part_token -  第三方传入的token
     */
    this.setMultiRoomCustomToken = function ({ third_part_token }) {
        zego_multi_room_.setMultiRoomCustomToken(third_part_token)
    }
    /**
     * 设置第二套房间最大在线人数,在登录房间前调用有效，退出房间后失效
     * @param {object} option - 参数对象
     * @param {number} option.max_count - 最大人数
     */
    this.setMultiRoomMaxUserCount = function ({ max_count }) {
        zego_multi_room_.setMultiRoomMaxUserCount(max_count)
    }
    /**
     * 登录第二套房间接口
     * @param {object} option - 参数对象
     * @param {boolean} option.room_id - 房间id
     * @param {number} option.role - 角色，取值查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoRoomRole</a>
     * @param {string} option.room_name - 房间名字
     * @param {onLoginMultiRoom} cb - onLoginMultiRoom 登陆回调
     * @return {boolean} true - 正在异步登陆，false - 失败
     */
    this.loginMultiRoom = function ({ room_id, role, room_name }, cb) {
        return zego_multi_room_.loginMultiRoom(room_id, role, room_name, cb);
    }
    /**
     * 退出第二套房间
     * @param {OnLogoutMultiRoom} cb - OnLogoutMultiRoom 退出第二套房间回调
     * @return {boolean} true - 正在异步退出，false - 失败
     */
    this.logoutMultiRoom = function (cb) {
        return zego_multi_room_.logoutMultiRoom(cb)
    }

    // ZegoDevice
    /**
     * 获取音频设备列表
     * @param {object} option - 参数对象
     * @param {number} option.device_type - 设备类型，查看<a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.AudioDeviceType</a>
     * @return {object|array} 返回音频设备id和名字的对象列表
     */
    this.getAudioDeviceList = function ({
        device_type
    }) {
        return zego_device_.getAudioDeviceList(device_type)
    }
    /**
     * 设置音频设备模式
     * @param {object} option - 参数对象
     * @param {number} option.device_type - 设备类型，查看<a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.AudioDeviceType</a>
     * @param {string} option.device_id - 设备id
     */
    this.setAudioDevice = function ({
        device_type,
        device_id
    }) {
        return zego_device_.setAudioDevice(device_type, device_id)
    }
    /**
     * 获取视频设备列表
     * @return {object | array} - 返回视频设备id和名字的对象列表
     */
    this.getVideoDeviceList = function () {
        return zego_device_.getVideoDeviceList()
    }
    /**
     * 设置选用视频设备
     * @param {object} option - 参数对象
     * @param {string} option.device_id - 设备id
     * @param {number} option.channel_index - 通道索引，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     */
    this.setVideoDevice = function ({
        device_id,
        channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN
    }) {
        return zego_device_.setVideoDevice(device_id, channel_index)
    }
    /**
     * 开启系统声卡声音采集
     * @param {object} option - 参数对像
     * @param {boolean} option.enable - true - 开启， false - 关闭
     */
    this.enableMixSystemPlayout = function ({ enable }) {
        return zego_device_.enableMixSystemPlayout(enable)
    }
    /**
     * 开启系统声卡声音采集，mac 上使用
     * @param {object} option - 参数对像
     * @param {boolean} option.enable - true - 开启， false - 关闭
     * @param {number} option.properties - 0 - MIX_PROP_NONE, 1 - MIX_PROP_ENABLE_AGC_FOR_SYS_PLAYOUT
     */
    this.mixSysPlayoutWithProperty = function ({ enable, properties }) {
        zego_device_.mixSysPlayoutWithProperty(enable, properties);
    }

    /**
     * 获取麦克风音量，切换麦克风后需要重新获取麦克风音量
     * @param {object} option - 参数对像
     * @param {string} option.device_id - 设备id
     * @return {number} -1: 获取失败，0~100 麦克风音量
     */
    this.getMicDeviceVolume = function ({
        device_id
    }) {
        return zego_device_.getMicDeviceVolume(device_id)
    }
    /**
     * 设置麦克风音量
     * @param {object} option - 参数对像
     * @param {string} option.device_id - 麦克风 deviceId
     * @param {number} option.volume - 音量，取值(0,100)
     */
    this.setMicDeviceVolume = function ({
        device_id,
        volume
    }) {
        return zego_device_.setMicDeviceVolume(device_id, volume)
    }
    /**
     * 获取麦克风是否静音
     * @param {object} option - 参数对像
     * @param {string} option.device_id - 麦克风 deviceId
     */
    this.getMicDeviceMute = function ({
        device_id
    }) {
        return zego_device_.getMicDeviceMute(device_id)
    }
    /**
     * 设置麦克风静音
     * @param {object} option - 参数对像
     * @param {string} option.device_id - 麦克风 deviceId
     * @param {boolean} option.is_mute - true 静音，false 不静音
     */
    this.setMicDeviceMute = function ({
        device_id,
        is_mute
    }) {
        return zego_device_.setMicDeviceMute(device_id, is_mute)
    }

    /**
     * 获取扬声器音量
     * @param {object} option - 参数对像
     * @param {string} option.device_id - 扬声器 deviceId
     * @return {number} - -1: 获取失败，0~100 麦克风音量
     */
    this.getSpeakerDeviceVolume = function ({
        device_id
    }) {
        return zego_device_.getSpeakerDeviceVolume(device_id)
    }

    /**
     * 设置扬声器音量
     * @param {object} option - 参数对象
     * @param {string} option.device_id - 扬声器 deviceId
     * @param {number} option.volume - 音量，取值 (0，100)
     */
    this.setSpeakerDeviceVolume = function ({
        device_id,
        volume
    }) {
        return zego_device_.setSpeakerDeviceVolume(device_id, volume)
    }

    /**
     * 获取 App 中扬声器音量
     * 该接口只支持Windows平台，Mac下调用无效
     * @param {object} option - 参数对象
     * @param {string} option.device_id - 扬声器 deviceId
     * @return {number} -1: 获取失败，0~100 扬声器音量
     */
    this.getSpeakerSimpleVolume = function ({
        device_id
    }) {
        return zego_device_.getSpeakerSimpleVolume(device_id)
    }

    /**
     * 设置 App 中扬声器音量，
     * 该接口只支持Windows平台，Mac下调用无效
     * @param {string} option.device_id - 扬声器 deviceId
     * @param {number} option.volume - 音量，取值 (0，100)
     */
    this.setSpeakerSimpleVolume = function ({
        device_id,
        volume
    }) {
        return zego_device_.setSpeakerSimpleVolume(device_id, volume)
    }

    /**
     * 获取扬声器是否静音
     * @param {object} option - 参数对象
     * @param {string} option.device_id - 扬声器 deviceId
     * @return {boolean} - true 静音，false 不静音
     */
    this.getSpeakerDeviceMute = function ({
        device_id
    }) {
        return zego_device_.getSpeakerDeviceMute(device_id)
    }

    /**
     * 设置扬声器静音
     * @param {object} option - 参数对象
     * @param {string} option.device_id - 扬声器 deviceId
     * @param {boolean} option.is_mute - 静音，false 不静音
     */
    this.setSpeakerDeviceMute = function ({
        device_id,
        is_mute
    }) {
        return zego_device_.setSpeakerDeviceMute(device_id, is_mute)
    }

    /**
     * 获取 App 中扬声器是否静音，
     * 该接口只支持Windows平台，Mac下调用无效
     * @param {object} option - 参数对象
     * @param {string} option.device_id - 扬声器 deviceId
     * @return {boolean} true - 静音，false 不静音
     */
    this.getSpeakerSimpleMute = function ({
        device_id
    }) {
        return zego_device_.getSpeakerSimpleMute(device_id)
    }

    /**
     * 设置 App 中扬声器静音，
     * 该接口只支持Windows平台，Mac下调用无效
     * @param {object} option - 参数对象
     * @param {string} option.device_id - 扬声器 deviceId
     * @param {boolean} option.is_mute - true 静音，false 不静音
     */
    this.setSpeakerSimpleMute = function ({
        device_id,
        is_mute
    }) {
        return zego_device_.setSpeakerSimpleMute(device_id, is_mute)
    }

    /**
     * 获取默认的音频设备
     * @param {object} option - 参数对象
     * @param {number} option.device_type - 设备类型，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.AudioDeviceType</a>
     * @param {string} - 设备id
     */
    this.getDefaultAudioDeviceId = function ({
        device_type
    }) {
        return zego_device_.getDefaultAudioDeviceId(device_type)
    }

    /**
     * 获取默认的摄像头设备
     */
    this.getDefaultVideoDeviceId = function () {
        return zego_device_.getDefaultVideoDeviceId()
    }

    /**
     * 监听设备的音量变化，设置后如果有音量变化（包括 app 音量）通过 onAudioVolumeChanged 事件通知
     * @param {object} option - 参数对象
     * @param {number} option.device_type - 设备类型，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.AudioDeviceType</a>
     * @param {string} option.device_id - 设备id
     */
    this.setAudioVolumeNotify = function ({
        device_type,
        device_id
    }) {
        return zego_device_.setAudioVolumeNotify(device_type, device_id)
    }
    /**
     * 停止监听设备的音量变化
     * @param {object} option - 参数对象
     * @param {number} option.device_type - 设备类型，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.AudioDeviceType</a>
     * @param {string} option.device_id - 设备id
     */
    this.stopAudioVolumeNotify = function ({
        device_type,
        device_id
    }) {
        return zego_device_.stopAudioVolumeNotify(device_type, device_id)
    }
    /**
     * 开启麦克风
     * @param {object} option - 参数对象
     * @param {boolean} option.enable true 打开，false 关闭。麦克风默认是打开
     * @returns {boolean} true - 成功， false - 失败
     */
    this.enableMic = function ({ enable }) {
        return zego_device_.enableMic(enable);
    }
    /**
     * 是否开启语音活动检测, 确保在推流前调用，只有纯 UDP 方案才可以调用此接口,在有音频的条件下检测到语音时才发送语音包，有效减少流量消耗降低成本
     * @param {object} option - 参数对象
     * @param {boolean} option.enable 开启；false 关闭，默认关闭
     * @returns {boolean} true - 成功， false - 失败
     */
    this.enableVAD = function ({ enable }) {
        return zego_device_.enableVAD(enable);
    }

    /**
     * 获取当前采集的音量
     * @returns {float} 当前采集音量大小
     */
    this.getCaptureSoundLevel = function () {
        return zego_device_.getCaptureSoundLevel();
    }

    /**
     * 设置双声道采集，仅windows平台支持
     * @param {object} option - 参数对象
     * @param {number} option.capture_type - default is 0. 0:capture mono any time; 1: capture stereo any time;2: capture mono when voice chat(publish and play at the same time), capture stereo when only publish.PS: Do not do inner processing when capture stereo.
     * @returns {boolean} true-设置成功，false-设置失败
     */
    this.enableCaptureStereo = function ({ capture_type }) {
        return zego_device_.enableCaptureStereo(capture_type);
    }

    /**
     * 初始化播放器，如果不调用本函数进行初始化，mediaplayer将收不到回调通知事件
     * @param {object} option - 参数对象
     * @param {number} option.type - 媒体播放器类型, 0 - 本地播放模式，不会将音频混入推流中，只有调用端可以听到播放的声音，1 - 推流播放模式，会将音频混流推流中，调用端和拉流端都可以听到播放的。 查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoMediaPlayerType</a>
     * @param {number} option.player_index - 播放器序号, 默认为0，多实例下用来区分哪个播放器,目前支持0，1，或者2
     */
    this.mediaPlayerInitWithType = function ({
        type,
        player_index = 0
    }) {
        zego_media_player_.mediaPlayerInitWithType(type, player_index)
    }
    /**
     * 设置音量
     * @param {object} option - 参数对象
     * @param {number} option.volume - 音量
     * @param {number} option.player_index - 播放器序号, 默认为0，多实例下用来区分哪个播放器,目前支持0，1，或者2
     */
    this.mediaPlayerSetVolume = function ({
        volume,
        player_index = 0
    }) {
        zego_media_player_.mediaPlayerSetVolume(volume, player_index)
    }

    /**
     * 开始播放
     * @param {object} option - 参数对象
     * @param {string} option.path - 媒体文件的路径
     * @param {number} option.repeat - 是否重复播放
     * @param {number} option.player_index - 播放器序号, 默认为0，多实例下用来区分哪个播放器,目前支持0，1，或者2
     */
    this.mediaPlayerStart = function ({
        path,
        repeat,
        player_index = 0
    }) {
        zego_media_player_.mediaPlayerStart(path, repeat, player_index)
    }

    /**
     * 停止播放
     * @param {object} option - 参数对象
     * @param {number} option.player_index - 播放器序号, 默认为0，多实例下用来区分哪个播放器,目前支持0，1，或者2
     */
    this.mediaPlayerStop = function ({
        player_index = 0
    }) {
        zego_media_player_.mediaPlayerStop(player_index)
    }

    /**
     * 暂停播放
     * @param {object} option - 参数对象
     * @param {number} option.player_index - 播放器序号, 默认为0，多实例下用来区分哪个播放器,目前支持0，1，或者2
     */
    this.mediaPlayerPause = function ({
        player_index = 0
    }) {
        zego_media_player_.mediaPlayerPause(player_index)
    }

    /**
     * 恢复播放
     * @param {object} option - 参数对象
     * @param {number} option.player_index - 播放器序号, 默认为0，多实例下用来区分哪个播放器,目前支持0，1，或者2
     */
    this.mediaPlayerResume = function ({
        player_index = 0
    }) {
        zego_media_player_.mediaPlayerResume(player_index)
    }

    /**
     * 设置指定的进度进行播放
     * @param {object} option - 参数对象
     * @param {number} option.duration - 指定的进度，单位毫秒
     * @param {number} option.player_index - 播放器序号, 默认为0，多实例下用来区分哪个播放器,目前支持0，1，或者2
     */
    this.mediaPlayerSeekTo = function ({
        duration,
        player_index = 0
    }) {
        zego_media_player_.mediaPlayerSeekTo(duration, player_index)
    }

    /**
     * 获取整个文件的播放时长
     * @param {object} option - 参数对象
     * @param {number} option.player_index - 播放器序号, 默认为0，多实例下用来区分哪个播放器,目前支持0，1，或者2
     * @return {number} 文件的播放时长，单位毫秒
     */
    this.mediaPlayerGetDuration = function ({
        player_index = 0
    }) {
        return zego_media_player_.mediaPlayerGetDuration(player_index)
    }

    /**
     * 获取当前播放的进度
     * @param {object} option - 参数对象
     * @param {number} option.player_index - 播放器序号, 默认为0，多实例下用来区分哪个播放器,目前支持0，1，或者2
     * @return {number} 当前播放进度，单位毫秒
     */
    this.mediaPlayerGetCurrentDuration = function ({
        player_index = 0
    }) {
        return zego_media_player_.mediaPlayerGetCurrentDuration(player_index)
    }

    /**
     * 设置本地静默播放
     * @param {object} option - 参数对象
     * @param {boolean} option.mute - 是否静默播放, 如果mediaPlayerInitWithType设置了 1 模式, 推出的流是有声音的
     * @param {number} option.player_index - 播放器序号, 默认为0，多实例下用来区分哪个播放器,目前支持0，1，或者2
     */
    this.mediaPlayerMuteLocal = function ({
        mute,
        player_index = 0
    }) {
        zego_media_player_.mediaPlayerMuteLocal(mute, player_index)
    }

    /**
     * 预加载资源
     * @param {object} option - 参数对象
     * @param {boolean} option.path - 媒体文件的路径
     * @param {number} option.player_index - 播放器序号, 默认为0，多实例下用来区分哪个播放器,目前支持0，1，或者2
     */
    this.mediaPlayerLoad = function ({
        path,
        player_index = 0
    }) {
        zego_media_player_.mediaPlayerLoad(path, player_index)
    }

    /**
     * 设置显示视频的view
     * @param {object} option - 参数对象
     * @param {boolean} option.canvas_view - 要显示的canvas
     * @param {number} option.player_index - 播放器序号, 默认为0，多实例下用来区分哪个播放器,目前支持0，1，或者2
     */
    this.mediaPlayerSetView = function ({
        canvas_view,
        player_index = 0
    }) {
        for (let i = 0; i < media_player_list_.length; ++i) {
            if (media_player_list_[i].player_index == player_index) {
                let render = null
                if (canvas_view != null) {
                    render = new WebGLRender()
                    render.initGLfromCanvas(canvas_view)
                }
                media_player_list_[i].canvas_view = canvas_view
                media_player_list_[i].gl_render = render
                return
            }
        }
        let render = null
        if (canvas_view != null) {
            render = new WebGLRender()
            render.initGLfromCanvas(canvas_view)
        }

        media_player_list_.push({
            player_index,
            canvas_view,
            gl_render: render
        })
    }

    /**
     * 设置播放文件的音轨
     * @param {object} option - 参数对象
     * @param {boolean} option.stream_index - 音轨序号，可以通过 mediaPlayerGetAudioStreamCount 接口获取音轨个数
     * @param {number} option.player_index - 播放器序号, 默认为0，多实例下用来区分哪个播放器,目前支持0，1，或者2
     */
    this.mediaPlayerSetAudioStream = function ({
        stream_index,
        player_index = 0
    }) {
        zego_media_player_.mediaPlayerSetAudioStream(stream_index, player_index)
    }

    /**
     * 设置播放器类型
     * @param {object} option - 参数对象
     * @param {boolean} option.type - 媒体播放器类型, 0 - 本地播放模式，不会将音频混入推流中，只有调用端可以听到播放的声音，1 - 推流播放模式，会将音频混流推流中，调用端和拉流端都可以听到播放的。 查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoMediaPlayerType</a>
     * @param {number} option.player_index - 播放器序号, 默认为0，多实例下用来区分哪个播放器,目前支持0，1，或者2
     */
    this.mediaPlayerSetPlayerType = function ({
        type,
        player_index = 0
    }) {
        zego_media_player_.mediaPlayerSetPlayerType(type, player_index)
    }

    /**
     * 获取音轨个数
     * @param {object} option - 参数对象
     * @param {number} option.player_index - 播放器序号, 默认为0，多实例下用来区分哪个播放器,目前支持0，1，或者2
     * @return {number} 音轨个数
     */
    this.mediaPlayerGetAudioStreamCount = function ({
        player_index = 0
    }) {
        return zego_media_player_.mediaPlayerGetAudioStreamCount(player_index)
    }

    /**
     * 设置是否循环播放
     * @param {object} option - 参数对象
     * @param {boolean} option.enable - true: 循环播放，false: 不循环播放
     * @param {number} option.player_index - 播放器序号, 默认为0，多实例下用来区分哪个播放器,目前支持0，1，或者2
     */
    this.mediaPlayerEnableRepeatMode = function ({
        enable,
        player_index = 0
    }) {
        zego_media_player_.mediaPlayerEnableRepeatMode(enable, player_index)
    }

    /**
     * 设置预览视频渲染模式
     * @param {object} option - 参数对象
     * @param {0|1|2}  option.mode - 0 为 等比缩放，不足部分会有黑边；1 为等比缩放填充整个 view；多余部分会被裁剪；2 为完全填充整个 view，不会多余和裁剪
     */
    this.setPreviewViewMode = function ({ mode }) {
        this.viewMode = mode === void 0 ? 1 : mode
    }


    /**
     * 设置拉流视频渲染模式
     * @param {object} option - 参数对象
     * @param {0|1|2}  option.mode - 0 为 等比缩放，不足部分会有黑边；1 为等比缩放填充整个 view；多余部分会被裁剪；2 为完全填充整个 view，不会多余和裁剪
     * @param {string}  option.stream_id - 流id
     */
    this.setViewMode = function ({ mode, stream_id }) {
        if (stream_id !== void 0) {
            this.remoteViewModes[stream_id] = mode === void 0 ? 0 : mode
        }
    }



    /**
     *  混流接口，支持混流一路或者多路输出
     * @param {object} option - 参数对象
     * @param {string} option.mix_stream_id - 混流任务id，标识唯一混流任务，调用方应该保证 mix_stream_id 的唯一性。如果 mix_stream_id 相同，服务端就认为是更新同一个混流。
     * @param {number} option.output_fps - 混流输出帧率,值范围：[1,30]，根据网络情况设定值，帧率越高画面越流畅
     * @param {number} option.output_width - 混流输出视频分辨率宽，不确定用什么分辨率时可采用16:9的规格设置，此值必须大于等于 输入流列表中所有输入流中最大的分辨率宽，即right布局值，且输入流的布局位置不能超出此值规定的范围
     * @param {number} option.output_height - 混流输出视频分辨率高，不确定用什么分辨率时可采用16:9的规格设置，此值大于等于 输入流列表中所有输入流中最大的分辨率高，即bottom布局值，，且输入流的布局位置不能超出此值规定的范围
     * @param {number} option.output_rate_control_mode - 混流输出码率控制模式，0 表示 CBR 恒定码率，1 表示 CRF 恒定质量，默认为 0；CRF 恒定质量 表示保证视频的清晰度在固定水平上，因此若采用此控制模式，码率会根据网速的变化波动。；比如游戏类直播时，为了让观众看到比较流畅的操作类画面会使用恒定质量模式，提升视频质量
     * @param {number} option.output_bitrate - 混流输出码率，输出码率控制模式设置为 CBR恒定码率时有效, 视频码率值范围： <= 10M，此参数单位是 bps，1M = 1 * 1000 * 1000 bps
     * @param {number} option.output_quality - 混流输出质量，输出码率控制模式设置为 CRF恒定质量时有效，有效范围 0-51，默认值是 23；若想视频质量好点，在23的基础上降低质量值测试调整；若想文件大小小一点，在23的基础上升高质量值测试调整，以 x 值下的文件大小为例， x + 6 下的文件大小是 x 值下文件大小的一半，x - 6 下的文件大小是 x 值下 文件大小的两倍
     * @param {number} option.channels - 混流声道数，默认为单声道
     * @param {number} option.output_audio_config - 混流输出音频格式，0--默认编码 在低码率下，编码后的音质要明显好于 1--可选编码，在码率较大后，达到128kbps及以上，两种编码后的音质近乎相同；1--可选编码 的优点在于低复杂性，能兼容更多的设备播放；但是目前经过 0--默认编码 编码后的音频不能正常播放的情况很少
     * @param {number} option.output_audio_bitrate - 混流输出音频码率，码率范围值是[10000, 192000]。若音频编码格式采用默认音频编码--output_audio_config 参数填0，采用 1/2声道时，建议码率值是 48k/64k，可根据需要在此基础上调整；若音频编码格式采用可选音频编码--output_audio_config 参数填1，采用 1/2声道时，建议码率值是 80k/128k，可根据需要在此基础上调整
     * @param {number} option.output_background_color - 混流背景颜色，前三个字节为 RGB 颜色值，即 0xRRGGBBFF。如 0x0000FFFF 为黄色
     * @param {string} option.output_background_image - 混流背景图，支持预设图片，如 (preset-id://zegobg.png) ，此值由zego提供，开发者先将背景图提供给zego，zego设置后再反馈背景图片的设置参数
     * @param {boolean} option.with_sound_level - 是否开启音浪。true：开启，false：关闭。开启音浪后，拉混流时可以收到混流前的每条流的音量信息回调。
     * @param {boolean} option.single_stream_pass_through - 混流输入为一条流时，混流输出的属性与单流一致(分辨率，编码格式等)，若需要开启此功能，请与即构技术支持联系
     * @param {string} option.user_data - 用户自定义数据，接收端通过媒体次要信息onRecvMediaSideInfo 接口回调
     * @param {number} option.extra - 扩展信息，备用
     * @param {string} option.extra_params - 高级配置选项，适用于某些定制化的需求，格式 "config1=xxx;config2=xxx"。
     * @param {object|array} option.input_stream_list - 混流输入流对象数组列表，SDK 根据输入流列表中的流进行混流，输入流信息对象的属性如下：
     * @param {string} option.input_stream_list.stream_id - 流id
     * @param {number} option.input_stream_list.sound_level_id - 音浪id，用于标识用户，注意大小是32位无符号数，sound_level_id必须 >= 0 且 <= 4294967295L（即2^32-1）
     * @param {number} option.input_stream_list.content_control - 推流内容控制，0表示音视频都要，1表示只要音频，2表示只要视频。默认值：0
     * @param {object} option.input_stream_list.layout - 流的布局对象，布局对象属性如下：
     * @param {number} option.input_stream_list.layout.left - 左上角点x坐标
     * @param {number} option.input_stream_list.layout.top - 左上角点y坐标
     * @param {number} option.input_stream_list.layout.right - 右下角点x坐标
     * @param {number} option.input_stream_list.layout.bottom - 右下角点y坐标
     * @param {object|array} option.output_stream_list - 混流输出目标对象数组列表，目标输出流对象属性如下：
     * @param {boolean} option.output_stream_list.is_url -  true: target 为完整 RTMP URL，false: target 为流名
     * @param {string} option.output_stream_list.target - 当is_url为true 时， target 为完整 RTMP URL，当is_url为false时，target 为混流流id ，拉混流时要通过该id进行拉混流
     * @param {object} option.output_watermark - 混流水印对象，水印对象属性如下：
     * @param {string} option.output_watermark.image - 水印图片，支持预设图片，如 (preset-id://zegowp.png) ，此值由zego提供，开发者先将图片提供给zego，zego设置后再反馈水印图片的设置参数
     * @param {object} option.output_watermark.layout - 混流水印布局，布局对象属性如下：
     * @param {number} option.output_watermark.layout.left - 左上角点x坐标
     * @param {number} option.output_watermark.layout.top - 左上角点y坐标
     * @param {number} option.output_watermark.layout.right - 右下角点x坐标
     * @param {number} option.output_watermark.layout.bottom - 右下角点y坐标
     * @return {number} 返回 seq ，如果seq > 0 表示调用成功，而且这个返回值会和 onMixStreamEx 的参数 seq 一一匹配。
     *
     */
    this.mixStreamEx = function ({
        mix_stream_id = "",
        output_fps = 15,
        output_width = 1920,
        output_height = 1080,
        output_rate_control_mode = 0,
        output_bitrate = 12000,
        output_quality = 23,
        channels = 1,
        output_audio_config = 0,
        output_audio_bitrate = 80,
        output_background_color = 0x000000ff,
        output_background_image = "",
        with_sound_level = true,
        single_stream_pass_through = false,
        user_data = "",
        extra = 0,
        extra_params = "",
        input_stream_list = [],
        output_stream_list = [],
        output_watermark
    }) {
        try {
            zego_base_.initMixStreamConfig();

            zego_base_.setMixStreamOutputFps(output_fps);
            zego_base_.setMixStreamOutputResolution(output_width, output_height);
            zego_base_.setMixStreamOutputQualityControl(output_rate_control_mode, output_bitrate, output_quality);
            zego_base_.setMixStreamOutputAudioConfig(channels, output_audio_config, output_audio_bitrate);
            zego_base_.setMixStreamOutputBackground(output_background_color, output_background_image);
            zego_base_.enableMixStreamOutputWithSoundLevel(with_sound_level);
            zego_base_.enableMixStreamOutputWithSigleStreamPassThrough(single_stream_pass_through);
            zego_base_.setMixStreamOutputUserData(user_data);
            zego_base_.setMixStreamOutputExtraData(extra);

            if (output_watermark) {
                zego_base_.setMixStreamWaterMark(output_watermark.image, output_watermark.layout.top, output_watermark.layout.left, output_watermark.layout.bottom, output_watermark.layout.right);
            } else {
                zego_base_.setMixStreamWaterMark("", 0, 0, 0, 0);
            }

            for (let i = 0; i < input_stream_list.length; ++i) {
                zego_base_.addInputStreamForMixStream(input_stream_list[i].stream_id, input_stream_list[i].sound_level_id, input_stream_list[i].content_control, input_stream_list[i].layout.top, input_stream_list[i].layout.left, input_stream_list[i].layout.bottom, input_stream_list[i].layout.right);
            }

            for (let i = 0; i < output_stream_list.length; ++i) {
                zego_base_.addMixStreamOutputTarget(output_stream_list[i].is_url, output_stream_list[i].target);
            }

            return zego_base_.startMixStream(mix_stream_id, extra_params);
        } catch (err) {
            console.log("mixStreamEx error:", err);
        }
    }
    /**
     * 启动 soundLevel 监听
     * @param {boolean} true - 成功， false - 失败
     */
    this.startSoundLevelMonitor = function () {
        return zego_base_.startSoundLevelMonitor();
    }

    /**
     * 停止 soundLevel 监听
     * @param {boolean} true - 成功， false - 失败
     */
    this.stopSoundLevelMonitor = function () {
        return zego_base_.stopSoundLevelMonitor();
    }

    /**
     * 设置是否循环播放
     * @param {object} option - 设置 soundLevel 的监控周期
     * @param {boolean} option.time_ms - 时间周期，单位为毫秒，取值范围 [100, 3000], 默认 200 ms
     */
    this.setSoundLevelMonitorCycle = function ({ time_ms }) {
        return zego_base_.setSoundLevelMonitorCycle(time_ms);
    }

    /**
     * 设置音频前处理函数,  必须在 InitSDK 后且在推流前调用
     *  @param {objct} option - 对象参数
     *  @param {number} option.call_back -     AVE::OnPrepCallback,音频前回调函数
     *  @param {number} option.encode -      是否编码  默认false, 输出 PCM 数据， true，输出AAC编码数据
     *  @param {number} option.samplerate -  采样率，为0时， 默认用SDK设置参数
     *  @param {number} option.channel -     通道数，为0时， 默认用SDK设置参数
     *  @param {number} option.samples -     采样点数，为0时，默认用SDK设置参数
    */
    this.setAudioPrepCallback = function ({call_back,
        encode = false,
        samplerate = 0,
        channel = 0,
        samples = 0
    }){
        zego_base_.setAudioPrepCallback(call_back, encode, samplerate, channel, samples);
    }

    /**
     * 设置获取 频域功率谱 的监控周期
     * @param timeInMS 时间间隔，最小值为10ms,默认为500ms
     * @return true 成功；false 失败
     */
    this.setFrequencySpectrumMonitorCycle = function ({time_ms}){
        return zego_base_.setFrequencySpectrumMonitorCycle(time_ms);
    }

    /**
    * 启动 频域功率谱 监听
    * @return true 成功；false 失败
    */
    this.startFrequencySpectrumMonitor = function (){
        return zego_base_.startFrequencySpectrumMonitor();
    }

    /**
    * 停止 频域功率谱 监听
    * @return true 成功；false 失败
    */
    this.stopFrequencySpectrumMonitor = function (){
        return zego_base_.stopFrequencySpectrumMonitor();
    }

    /**
     * 开启自定义采集，必须在initSDK之前调用
     * @param {object} option - 参数对象
     * @param {number} option.channel_index - 推流 channel Index, 查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     */
    this.enableCustomCapture = function ({ channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN }) {
        zego_custom_capture_.enableCustomCapture(channel_index);
    }
    /**
     * 创建自定义采集源，在初始化sdk成功之后调用
     * @param {object} option - 参数对象
     * @param {number} option.capture_type - 自定义采集源的类型，支持自定义图片、摄像头、视频文件、屏幕分享，查看定义 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoCustomCaptureType</a>
     * @return {number} -1 - 失败， 结果大于0 返回自定义采集源句柄
     */
    this.createCustomCaptureSource = function ({ capture_type }) {
        return zego_custom_capture_.createCustomCaptureSource(capture_type);
    }
    /**
     * 设置当前采集源，需要在startPreview预览前调用
	 *
     * @param {object} option - 参数对象
     * @param {number} option.capture_src - 采集源，填写通过createCustomCaptureSource 返回的采集源
     * @param {number} option.channel_index - 推流 channel Index, 查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.PublishChannelIndex</a>
     * @return {boolean} true - 成功， false - 失败，输入的源无效
     */
    this.setCustomCaptureSource = function ({ capture_src, channel_index = ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN }) {
        return zego_custom_capture_.setCustomCaptureSource(capture_src, channel_index);
    }
    /**
     * 配置图像源参数，可用于切换图片，更新图片路径即可
     * @param {object} option - 参数对象
     * @param {number} option.capture_src - 采集源，填写通过createCustomCaptureSource接口创建返回的图像源
     * @param {string} option.image_path - 图像路径，图像支持bmp图像
     * @return {boolean} true - 成功， false - 失败，输入的源无效
     */
    this.setImageCaptureSourceParam = function ({ capture_src, image_path }) {
        return zego_custom_capture_.setImageCaptureSourceParam(capture_src, image_path);
    }
    /**
     * 配置摄像头源参数，可用于切换摄像头，更新摄像头设备id即可
     * @param {object} option - 参数对象
     * @param {number} option.capture_src - 采集源，填写通过createCustomCaptureSource接口创建返回的摄像头源
     * @param {string} option.device_id - 摄像头设备id，可以通过getVideoDeviceList接口获取得到video_devices_list，取video_devices_list项中的device_id
     * @return {boolean} true - 成功， false - 失败，输入的源无效
     */
    this.setCameraCaptureSourceParam = function ({ capture_src, device_id }) {
        return zego_custom_capture_.setCameraCaptureSourceParam(capture_src, device_id);
    }
    /**
     * 配置视频文件源参数，可用于切换视频文件，更新视频文件路径即可，视频文件路径传入空字符串，可停止当前播放。
     * @param {object} option - 参数对象
     * @param {number} option.capture_src - 采集源，填写通过createCustomCaptureSource接口创建返回的视频文件源
     * @param {string} option.video_file_path - 视频文件路径
     * @param {boolean} option.is_repeat - 是否重复播放，true - 播放完从头开始重复播放，false - 播放完则停止
     * @param {number} option.media_player_type - 媒体播放器的类型，当调用startPublishing 推流时，0 - 本地播放模式，不会将音频混入推流中，只有调用端可以听到播放的声音，1 - 推流播放模式，会将音频混流推流中，调用端和拉流端都可以听到播放的。
     * @param {number} option.media_player_index - 媒体播放器的索引，sdk内部支持多路播放器同时播放，最多支持4路媒体文件同时播放
     * @return {boolean} true - 成功， false - 失败，输入的源无效
     */
    this.setVideoFileCaptureSourceParam = function ({ capture_src, video_file_path, is_repeat = false, media_player_type = 1, media_player_index = 0 }) {
        return zego_custom_capture_.setVideoFileCaptureSourceParam(capture_src, video_file_path, is_repeat, media_player_type, media_player_index);
    }
    /**
     * 设置屏幕分享源的参数
     * @param {object} option - 参数对象
     * @param {number} option.capture_src - 屏幕采集源，填写通过createCustomCaptureSource接口创建返回的屏幕采集源
     * @param {boolean} option.full_screen -设置采集主屏幕全屏，true - 采集全屏
     * @param {boolean} option.virtual_full_screen - 设置采集虚拟桌面全屏，true - 采集虚拟全屏。在full_screen为false时有效
     * @param {boolean} option.cursor_visible - 是否显示光标，true - 显示，false - 不显示
     * @param {boolean} option.click_animation - 是否显示鼠标点击动画，true - 显示鼠标点击动画, false - 不显示鼠标点击动画
     * @param {boolean} option.activate_window_when_capturing - 在目标窗口模式下，初次选择窗口时，设置是否激活窗口，true - 激活窗口，false - 不激活窗口
     * @param {string} option.target_screen - 设置采集目标屏幕名，从接口screenCaptureEnumScreenList 返回的对象数组列表中每项的screen_name字段
     * @param {number} option.target_window - 设置采集目标窗口句柄，从接口screenCaptureEnumWindowList 返回的对象数组列表中每项的handle字段
     * @param {number} option.target_window_model - 1 - 窗口截屏，带窗口标题栏， 2 - 窗口客户区截屏，不带窗口标题栏，仅windows 支持
     * @param {number} option.target_rect_left - 设置采集目标区域，单位为像素，支持高DPI，目标区域左上角横坐标
     * @param {number} option.target_rect_top - 目标区域左上角纵坐标
     * @param {number} option.target_rect_width - 目标区域宽
     * @param {number} option.target_rect_height - 目标区域高
     *
     */
    this.setScreenCaptureSourceParam = function ({ capture_src,
        full_screen = false,
        virtual_full_screen = false,
        cursor_visible = true,
        click_animation = true,
        activate_window_when_capturing = true,
        target_screen = "",
        target_window = 0,
        target_window_model = 0,
        target_rect_left = 0,
        target_rect_top = 0,
        target_rect_width = 0,
        target_rect_height = 0
    }) {
        zego_custom_capture_.setScreenCaptureSourceParam(capture_src,
            full_screen,
            virtual_full_screen,
            cursor_visible,
            click_animation,
            activate_window_when_capturing,
            target_screen,
            target_window,
            target_window_model,
            target_rect_left,
            target_rect_top,
            target_rect_width,
            target_rect_height);
    }
    /**
     * 枚举屏幕列表
     * @return {object|array} 返回{is_primary, screen_name} 的对象数组列表
     */
    this.screenCaptureEnumScreenList = function () {
        return zego_custom_capture_.screenCaptureEnumScreenList();
    }
    /**
     * 枚举窗口列表
     * @param {object} option - 参数对象
     * @param {number} option.is_include_iconic - 枚举时是否包括最小化的窗口。true - 表示包括最小化窗口；false - 不包括最小化窗口。
     * @return {object|array} 返回{handle, title, image_path} 的对象数组列表, mac 下image_path 无效，返回空
     */
    this.screenCaptureEnumWindowList = function ({ is_include_iconic = false }) {
        return zego_custom_capture_.screenCaptureEnumWindowList(is_include_iconic);
    }

    /**
     * 检测mac是否有屏幕捕捉的权限
     * @param {object} option - 参数对象
     * @param {number} option.handle - 窗口句柄，目标窗口句柄，从接口screenCaptureEnumWindowList 返回的对象数组列表中每项的handle字段
     * @return {boolean} 是否拥有屏幕检测权限，若还未获取该权限则触发获取权限弹窗
     */
    this.checkScreenCaptureAuthority = function ({ handle }) {
        return zego_custom_capture_.checkScreenCaptureAuthority(handle);
    }



    /**
     * 获取窗口所在的屏幕
     * @param {object} option - 参数对象
     * @param {number} option.window_handle - 窗口句柄
     * @return {string} 返回所在屏幕的name
     */
    this.screenCaptureGetWindowScreen = function ({ window_handle }) {
        return zego_custom_capture_.screenCaptureGetWindowScreen(window_handle);
    }
    /**
     * 获取虚拟桌面的大小
     * @return {object} 返回{left, top, width, height} 的对象
     */
    this.screenCaptureGetVirtualDesktopRect = function ({}) {
        return zego_custom_capture_.screenCaptureGetVirtualDesktopRect();
    }

    /**
     * 获取窗口大小
     * @return {object} 返回{left, top, width, height} 的对象
     */
    this.screenscreenCaptureGetWindowSize = function ({window_handle}) {
        return zego_custom_capture_.screenscreenCaptureGetWindowSize(window_handle);
    }


    /**
     * 异步获取窗口列表的缩略图
     */
    this.windowthumbnail_find_windows_async = function ({aysnc}) {
        return zego_custom_capture_.windowthumbnail_find_windows_async(aysnc);
    }


    /**
     * 枚举可建立缩略图的窗口列表,包括窗口标题和窗口句柄
     * @param {object} 所有窗口列表信息，包括缩略图和图标
     */
    this.windowthumbnail_find_windows = function ({}) {
        return zego_custom_capture_.windowthumbnail_find_windows();
    }
    /**
     * 注册缩略图同时注册窗口状态检测
     * @param {object} option - 参数对象
     * @param {number} option.window_handle - 目的窗口的句柄,必须是顶层窗口(如果为空,只注册状态检测)
     * @param {number} option.thumbnail_id - 缩略图标志 为zego_thumbnail_find_windows或者zego_windowthumbnail_window_status_change_notify_func返回的窗口列表中的thumbnail_id
     * @param {number} destination_rect_left,destination_rect_top, destination_rect_right, destination_rect_bottom - 目的窗口缩略图显示区域,目的窗口坐标系
     * @param {number} destination_client_rect_left, destination_client_rect_top, destination_client_rect_right, destination_client_rect_bottom 目的窗口客户区区域,目的窗口坐标系
     * @return 所有窗口列表的对象
     */
    this.windowthumbnail_register = function ({window_handle, thumbnail_id, destination_rect_left,destination_rect_top, destination_rect_right, destination_rect_bottom, destination_client_rect_left, destination_client_rect_top, destination_client_rect_right, destination_client_rect_bottom}) {
        return zego_custom_capture_.windowthumbnail_register(window_handle, thumbnail_id, destination_rect_left,destination_rect_top, destination_rect_right, destination_rect_bottom, destination_client_rect_left, destination_client_rect_top, destination_client_rect_right, destination_client_rect_bottom);
    }



    /**
     * 更新缩略图位置
     * @param {object}
     * @param {number} option.thumbnail_id - 缩略图标志 为zego_thumbnail_find_windows或者zego_windowthumbnail_window_status_change_notify_func返回的窗口列表中的thumbnail_id
     * @param {number} destination_rect_left,destination_rect_top, destination_rect_right, destination_rect_bottom - 目的窗口缩略图显示区域,目的窗口坐标系
     * @param {number} destination_client_rect_left, destination_client_rect_top, destination_client_rect_right, destination_client_rect_bottom 目的窗口客户区区域,目的窗口坐标系
     */
    this.windowthumbnail_update = function ({thumbnail_id,destination_rect_left,destination_rect_top, destination_rect_right, destination_rect_bottom, destination_client_rect_left, destination_client_rect_top, destination_client_rect_right, destination_client_rect_bottom}) {
        return zego_custom_capture_.windowthumbnail_update(thumbnail_id,destination_rect_left,destination_rect_top, destination_rect_right, destination_rect_bottom, destination_client_rect_left, destination_client_rect_top, destination_client_rect_right, destination_client_rect_bottom);
    }


    /**
     * 检测是否能够开始共享
     * @param {object}
     * @param {number} option.window_handle - handle 缩略图标志 为zego_thumbnail_find_windows或者zego_windowthumbnail_window_status_change_notify_func返回的窗口列表中的handle
     * @return 是否能够共享窗口
     */
    this.windowthumbnail_window_checkStatus = function ({window_handle}) {
        return zego_custom_capture_.windowthumbnail_window_checkStatus(window_handle);
    }

    /**
     * 反注册缩略图同时反注册状态监测
     * @param {object}
     * @param {number} option.thumbnail_id - 缩略图标志 为zego_thumbnail_find_windows或者zego_windowthumbnail_window_status_change_notify_func返回的窗口列表中的thumbnail_id
     * @return 成功或失败
     */
    this.windowthumbnail_unregister = function ({thumbnail_id}) {
        return zego_custom_capture_.windowthumbnail_unregister(thumbnail_id);
    }

    /**
     * 显示或隐藏源窗口
     * @param {object}
     * @param {number} option.window_handle - 窗口句柄
     * @param {number} option.window_cmd - 1、置顶显示，2：隐藏，3：最大化窗口，4：最小化窗口，5：激活窗口
     * @return 成功或失败
     */
    this.windowthumbnail_show_source_window = function ({thumbnail_id, window_cmd}) {
        return zego_custom_capture_.windowthumbnail_show_source_window(thumbnail_id,window_cmd);
    }


    /**
     * 创建音效播放器，使用AudioPlayer模块进行播放音效时，确保有先调用过audioPlayerCreateAudioPlayer
     */
    this.audioPlayerCreateAudioPlayer = function () {
        zego_audio_player_.createAudioPlayer();
    }

    /**
     * 销毁音效播放器
     */
    this.audioPlayerDestroyAudioPlayer = function () {
        zego_audio_player_.destroyAudioPlayer();
    }
    /**
     * 播放音效。
     * 使用AudioPlayer模块进行播放音效时，确保有先调用过audioPlayerCreateAudioPlayer
     * @param {object} option - 参数对象
     * @param {string} option.path - 音效资源文件的本地路径
     * @param {number} option.sound_id - 音效 ID
     * @param {number} option.loop_count - 循环次数
     * @param {boolean} option.is_publish - 是否放入推流中
     */
    this.audioPlayerPlayEffect = function ({ path, sound_id, loop_count, is_publish }) {
        zego_audio_player_.audioPlayerPlayEffect(path, sound_id, loop_count, is_publish);
    }
    /**
     * 停止播放音效
     * @param {object} option - 参数对象
     * @param {number} option.sound_id - 音效 ID
     */
    this.audioPlayerStopEffect = function ({ sound_id }) {
        zego_audio_player_.audioPlayerStopEffect(sound_id);
    }
    /**
     * 暂停播放音效
     * @param {object} option - 参数对象
     * @param {number} option.sound_id - 音效 ID
     */
    this.audioPlayerPauseEffect = function ({ sound_id }) {
        zego_audio_player_.audioPlayerPauseEffect(sound_id);
    }

    /**
     * 恢复播放音效
     * @param {object} option - 参数对象
     * @param {number} option.sound_id - 音效 ID
     */
    this.audioPlayerResumeEffect = function ({ sound_id }) {
        zego_audio_player_.audioPlayerResumeEffect(sound_id);
    }

    /**
     * 设置单个音效的音量
     * @param {object} option - 参数对象
     * @param {number} option.sound_id - 音效 ID
     * @param {number} option.volume - 音量，有效范围 0 到 100，默认 100
     */
    this.audioPlayerSetVolume = function ({ sound_id, volume }) {
        zego_audio_player_.audioPlayerSetVolume(sound_id, volume);
    }

    /**
     * 设置所有音效的音量
     * @param {object} option - 参数对象
     * @param {number} option.volume - 音量，有效范围 0 到 100，默认 100
     */
    this.audioPlayerSetVolumeAll = function ({ volume }) {
        zego_audio_player_.audioPlayerSetVolumeAll(volume);
    }

    /**
     * 暂停全部音效
     */
    this.audioPlayerPauseAll = function () {
        zego_audio_player_.audioPlayerPauseAll();
    }

    /**
     * 恢复全部音效
     */
    this.audioPlayerResumeAll = function () {
        zego_audio_player_.audioPlayerResumeAll();
    }

    /**
     * 停止全部音效
     */
    this.audioPlayerStopAll = function () {
        zego_audio_player_.audioPlayerStopAll();
    }

    /**
     * 预加载音效，只支持预加载不超过30秒的音频文件。预加载完成后，通过audioPlayerPlayEffect接口使用同个sound_id播放即可
     * 使用AudioPlayer模块时，确保有先调用过audioPlayerCreateAudioPlayer
     * @param {object} option - 参数对象
     * @param {string} option.path - 音效资源文件的本地路径
     * @param {number} option.sound_id - 音效 ID
     */
    this.audioPlayerPreloadEffect = function ({ path, sound_id }) {
        zego_audio_player_.audioPlayerPreloadEffect(path, sound_id);
    }

    /**
     * 删除预加载音效
     * @param {object} option - 参数对象
     * @param {number} option.sound_id - 音效 ID
     */
    this.audioPlayerUnloadEffect = function ({ sound_id }) {
        zego_audio_player_.audioPlayerUnloadEffect(sound_id);
    }

    /**
     *  设置进度
     * @param {object} option - 参数对象
     * @param {number} option.sound_id - 音效 ID
     * @param {number} option.timestamp - 进度, 单位毫秒
     * @return {number} 返回 -1 表示失败, 返回 0 表示成功
     *
     */
    this.audioPlayerSeekTo = function ({ sound_id, timestamp }) {
        return zego_audio_player_.audioPlayerSeekTo(sound_id, timestamp);
    }

    /**
     *  获取音效的总时长
     * @param {object} option - 参数对象
     * @param {number} option.sound_id - 音效 ID
     * @return {number} 返回音效的总时长, 失败返回 0
     */
    this.audioPlayerGetDuration = function ({ sound_id }) {
        return zego_audio_player_.audioPlayerGetDuration(sound_id);
    }

    /**
     *  获取音效的当前进度
     * @param {object} option - 参数对象
     * @param {number} option.sound_id - 音效 ID
     * @return {number} 返回音效的当前进度, 失败返回 -1
     */
    this.audioPlayerGetCurrentDuration = function ({ sound_id }) {
        return zego_audio_player_.audioPlayerGetCurrentDuration(sound_id);
    }





    /**
     *  屏幕分享初始化
     */
    this.screenCaptureInit = function () {
        zego_window_thumbnail_.screenCaptureInit();
    }


    /**
    * 枚举缩略图的窗口列表
    * @param cb 缩略图回调 ， 返回thumb_windows_list（{object|array}），是 {id, handle,title,isScreen,iconBit,imageBit} 的对象数组列表, iconBit,imageBit是{width,height,format,len,image_data}的对象  iconBit ：缩略图标数据， imageBit :  缩略图数据
    * @param image_data 是 png图像的base64字符串；设置如下标签属性即可显示图像：img.setAttribute('src', "data:image/png;base64," + rs.image_data)
    */
    this.windowThumbnailEnumWindowlist = function (cb) {
        zego_window_thumbnail_.windowThumbnailEnumWindowlist(cb);
    }

    // whiteboard
    this.whiteboardInit = function () {
        return zego_white_board_.zego_whiteboard_init();
    }

    this.whiteboardUninit = function () {
        return zego_white_board_.zego_whiteboard_uninit();
    }

    /**
         开启网络模块测试
         @param  traceroute  参见NetworkTraceConfig
    */
    this.startNetworkTrace = function(traceroute){

        zego_network_trace_.startNetworkTrace(traceroute);
    }

    /**
        停止网络模块测试
    */
    this.stopNetworkTrace = function()
    {
        zego_network_trace_.stopNetworkTrace();
    }

    /**
       启动连通性测试 InitSDK 后调用 同一时间内与StartSpeedTest只有一个生效 推拉流会中断此操作
       此接口仅仅只会检测与zego服务的连通性，不会产生媒体数据
    */

    this.startConnectivityTest = function(){

        zego_network_probe_.startConnectivityTest();
    }


    /**
     停止连通性测试
    */

    this.stopConnectivityTest = function(){

        zego_network_probe_.stopConnectivityTest();
    }

    /**
     开始网络测速 InitSDK 后调用 同一时间内与StartConnectivityTest只有一个生效，启动推拉流会中断此操作
     不建议长时间测速，可能会影响推拉流体验

     @param bitrate 测速推流时的比特率 单位bps
    */

    this.startUplinkSpeedTest = function(bitrate){

        zego_network_probe_.startUplinkSpeedTest(bitrate);
    }


    /**
     设置网络测速时回调质量的时间间隔

     @param interval 测速时回调质量的时间间隔 单位ms
    */

    this.setQualityCallbackInterval = function(interval){

        zego_network_probe_.setQualityCallbackInterval(interval);
    }


    /*
     停止测速模块
    */

    this.stopUplinkSpeedTest = function(){

        zego_network_probe_.stopUplinkSpeedTest();
    }

    /**
    开始下行网络测速 InitSDK 后调用 同一时间内与StartConnectivityTest只有一个生效，启动推拉流会中断此操作
    不建议长时间测速，可能会影响推拉流体验

    @param bitrate 测速推流时的比特率 单位bps
    */

    this.startDownlinkSpeedTest = function(bitrate){

        zego_network_probe_.startDownlinkSpeedTest(bitrate);
    }

    /*
     停止下行测速模块
    */

    this.stopDownlinkSpeedTest = function(){

        zego_network_probe_.stopDownlinkSpeedTest();
    }


	/**
    * 设置组合源输出大小
    * @param {object} option - 参数对象
	* @param {number} option.combined_source_id - 组合源
	* @param {number} option.width - 组合源输出的宽
	* @param {number} option.height - 组合源输出的高
	* @return {boolean} true - 成功， false - 失败
    */
	   this.setCombinedSourceParam = function({combined_source_id, width, height} ) {
        return zego_custom_capture_.setCombinedSourceParam(combined_source_id, width, height);
   }



    /**
    * 设置组合源的背景色
    * @param {object} option - 参数对象
    * @param {number} option.combined_source_id - 混合源的id
    * @param {number} option.rgba - 混合源的背景色
	* @return {boolean} true - 成功， false - 失败
    */
   this.setCombinedBackgroundColor = function({combined_source_id, rgba} ) {
        return zego_custom_capture_.setCombinedBackgroundColor(combined_source_id, rgba);
   }

    /**
    * 向组合源添加采集源
    * @param {object} option - 参数对象
    * @param {number} option.combined_source_id - 组合源的id
    * @param {number} option.custom_cap_sourceid - 采集源对象
    * @return {boolean} true - 成功， false - 失败
    */
   this.addCustomCaptureSource = function({combined_source_id, custom_cap_sourceid} ) {
       return zego_custom_capture_.addCustomCaptureSource(combined_source_id, custom_cap_sourceid);
   }

    /**
    * 删除组合源中的采集源
    * @param {object} option - 参数对象
    * @param {number} option.combined_source_id - 组合源的id
    * @param {number} option.customer_cap_sourceid - 采集源对象id
    * @return {boolean} true - 成功， false - 失败
    */
   this.delCustomCaptureSource= function ({combined_source_id, custom_cap_sourceid} ) {
       return zego_custom_capture_.delCustomCaptureSource(combined_source_id, custom_cap_sourceid);
   }

    /**
    * 设置组合源中指定采集源的平面Z轴顺序
    * @param {object} option - 参数对象
    * @param {number} option.combined_source_id - 组合源的id
    * @param {number} option.custom_cap_sourceid - 采集源对象id
    * @param {number} option.zorder - 采集源的平面Z轴顺序
    * @return {boolean} true - 成功， false - 失败
    */
   this.setCustomCaptureSourceZOrder= function({combined_source_id, custom_cap_sourceid, zorder} ) {
       return zego_custom_capture_.setCustomCaptureSourceZOrder(combined_source_id, custom_cap_sourceid, zorder);
   }

    /**
    * 设置组合源中指定采集源是否可见
    * @param {object} option - 参数对象
    * @param {number} option.combined_source_id - 组合源的id
    * @param {number} option.custom_cap_sourceid - 采集源的id
    * @param {boolean} option.visable - 混合源是否可见
    * @return {boolean} true - 成功， false - 失败
    */
   this.setCustomCaptureSourceVisable= function({combined_source_id, custom_cap_sourceid, visable} )
   {
       return zego_custom_capture_.setCustomCaptureSourceVisable(combined_source_id, custom_cap_sourceid, visable);
   }

    /**
    * 设置组合源中指定采集源的布局
    * @param {object} option - 参数对象
    * @param {number} option.combined_source_id - 组合源的id
    * @param {number} option.custom_cap_sourceid - 采集源的id
    * @param {number} option.x - 采集源相对于画布左上角的x
    * @param {number} option.y - 采集源相对于画布左上角的y
    * @param {number} option.w - 采集源的宽
    * @param {number} option.h - 采集源的高
	* @param {number} option.viewMode - 采集源的视图模式：0：等比缩放，可能有黑边； 1：等比缩放填充整View，可能有部分被裁减 2：填充整个View
    * @return {boolean} true - 成功， false - 失败
    */
   this.setCustomCaptureSourceLayout= function({combined_source_id, custom_cap_sourceid, x,y,w,h,viewMode} )
   {
       return zego_custom_capture_.setCustomCaptureSourceLayout(combined_source_id, custom_cap_sourceid, x,y,w,h,viewMode);
   }

    /**
    * 获取组合源中指定采集源的参数
    * @param {object} option - 参数对象
    * @param {number} option.combined_source_id - 组合源的id
    * @param {number} option.custom_cap_sourceid - 采集源的id
    * @return {object} 返回{width, height} 的对象
    */
   this.getCustomCaptureSourceParam= function({combined_source_id, custom_cap_sourceid})
   {
       return zego_custom_capture_.getCustomCaptureSourceParam(combined_source_id, custom_cap_sourceid);
   }

    /**
     *  设置缓存路径
     * @param {object} option - 参数对象
     * @param {string} option.directory - 本地路径，在初始化白板之前调用
     */
    this.whiteboardSetCacheDirectory = function ({
        directory
    }) {
        zego_white_board_.zego_whiteboard_set_cache_directory(directory);
    }

    /*
     获取当前缓存路径
    */
    this.whiteboardGetCacheDirectory = function () {
        return zego_white_board_.zego_whiteboard_get_cache_directory();
    }

    /*
     清空缓存
    */
    this.whiteboardClearCache = function () {
        zego_white_board_.zego_whiteboard_clear_cache();
    }

    /**
     *  上传图片
     * @param {object} option - 参数对象
     * @param {string} option.path - 本地路径
     * @return {number} 0为调用失败，非0为请求序号
     */
    this.whiteboardUploadFile = function ({
        path
    }) {
        return zego_white_board_.zego_whiteboard_upload_file(path);
    }

    /**
     *  取消上传
     * @param {object} option - 参数对象
     * @param {number} option.seq - whiteboardUploadFile返回的调用序号
     */
    this.whiteboardCancelUploadFile = function ({
        seq
    }) {
        zego_white_board_.zego_whiteboard_cancel_upload_file(seq);
    }

    /**
     *  下载图片
     * @param {object} option - 参数对象
     * @param {string} option.url - url路径
     * @param {string} option.hash - 文件hash
     * @param {number} option.type - 文件类型 0图片图元 1自定义教具
     * @return {number} 0为调用失败，非0为请求序号
     */
    this.whiteboardDownloadFile = function ({
        url,
        hash,
        type
    }) {
        return zego_white_board_.zego_whiteboard_download_file(path,hash,type);
    }

    /**
     *  取消下载
     * @param {object} option - 参数对象
     * @param {number} option.seq - whiteboardDownloadFile返回的调用序号
     */
    this.whiteboardCancelDownloadFile = function ({
        seq
    }) {
        zego_white_board_.zego_whiteboard_cancel_download_file(seq);
    }

    /**
     *  创建互动白板模型, 与whiteboardModelDelete 配对使用
     * @param {object} option - 参数对象
     * @param {number} option.mode - 互动白板模式, 查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoWhiteboardMode</a>
     * @return {number} 返回互动白板模型对象
     */
    this.whiteboardModelMake = function ({
        mode
    }) {
        return zego_white_board_.zego_whiteboard_model_make(mode);
    }
    /**
     *  创建互动白板模型
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_model - 释放由whiteboardModelMake产生的互动白板对象
     */
    this.whiteboardModelDelete = function ({
        whiteboard_model
    }) {
        zego_white_board_.zego_whiteboard_model_delete(whiteboard_model);
    }

    /**
     * 获取白板唯一标识符
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_model - 白板模型对象
     * @return {number} 返回白板唯一标识符
     */
    this.whiteboardModelGetId = function ({
        whiteboard_model
    }) {
        return zego_white_board_.zego_whiteboard_model_get_id(whiteboard_model);
    }

    /**
     * 获取白板模式
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_model - 白板模型对象
     * @return {number} 返回白板模式，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoWhiteboardMode</a>
     */
    this.whiteboardModelGetMode = function ({
        whiteboard_model
    }) {
        return zego_white_board_.zego_whiteboard_model_get_mode(whiteboard_model);
    }

    /**
     * 获取白板名字
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_model - 白板模型对象
     * @return {string} 返回白板名字
     */
    this.whiteboardModelGetName = function ({
        whiteboard_model
    }) {
        return zego_white_board_.zego_whiteboard_model_get_name(whiteboard_model);
    }

    /**
     * 获取白板宽高比
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_model - 白板模型对象
     * @return {object} 返回宽高比对象{width:number, height:number}
     */
    this.whiteboardModelGetAspectRatio = function ({
        whiteboard_model
    }) {
        return zego_white_board_.zego_whiteboard_model_get_aspect_ratio(whiteboard_model);
    }
    /**
     * 获取白板画布的滚动、滑动百分比
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_model - 白板模型对象
     * @param {number} option.direction - 白板画布滑动、滚动方向,查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoWhiteboardCanvasScrollDirection</a>
     * @return {float} 返回滚动、滑动百分比
     */
    this.whiteboardModelGetScrollPercent = function ({
        whiteboard_model,
        direction
    }) {
        return zego_white_board_.zego_whiteboard_model_get_scroll_percent(whiteboard_model, direction);
    }
    /**
     * 设置白板名
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_model - 白板模型对象
     * @param {number} option.name - 白板名字
     */
    this.whiteboardModelSetName = function ({
        whiteboard_model,
        name
    }) {
        zego_white_board_.zego_whiteboard_model_set_name(whiteboard_model, name);
    }
    /**
     * 设置白板长宽比例
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_model - 白板模型对象
     * @param {number} option.width - 宽
     * @param {number} option.height - 高
     * @return {number} 0 - 设置成功
     *
     */
    this.whiteboardModelSetAspectRatio = function ({
        whiteboard_model,
        width,
        height
    }) {
        zego_white_board_.zego_whiteboard_model_set_aspect_ratio(whiteboard_model, width, height);
    }
    /**
     * 创建白板时，是否更新计数器
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_model - 白板模型对象
     * @param {boolean} option.enable - true - 更新计数器， false - 不更新
     *
     */
    this.whiteboardModelUpdateCounterWhenCreated = function ({
        whiteboard_model,
        enable
    }) {
        zego_white_board_.zego_whiteboard_model_update_counter_when_created(whiteboard_model, enable);
    }
    /**
     * 设置指定白板对应view的当前实际尺寸，有其他人绘制的图元到达时，将根据设置的当前宽高算出合适坐标再通知UI层更新。
     * 这里的UI宽高 ！不仅仅是 ！可视区域（即视口 viewport）的宽高，而应为包括滚动轴覆盖范围的宽高
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     * @param {number} option.width -  白板关联的UI宽
     * @param {number} option.height -  白板关联的UI高
     * @return {number} 0 - 成功
     */
    this.whiteboardSetSize = function ({
        whiteboard_id,
        width,
        height
    }) {
        return zego_white_board_.zego_whiteboard_set_size(whiteboard_id, width, height);
    }

    /**
     * 指定白板模型，创建互动白板
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_model - 模块模型，可由whiteboardModelMake生成
     * @param {boolean} option.is_public - 是否公开创建。如为true，所有人可见；如为false，仅白板操作者可见
     * @param {number} option.width -  白板关联的UI宽
     * @param {number} option.height -  白板关联的UI高
     * @return {number} 0为调用失败，非0为请求序号
     */
    this.whiteboardCreate = function ({
        whiteboard_model,
        is_public,
        width,
        height
    }) {
        return zego_white_board_.zego_whiteboard_create(whiteboard_model, is_public, width, height);
    }

    /**
     * 销毁指定互动白板
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     * @return {number} 0为调用失败，非0为请求序号
     */
    this.whiteboardDestroy = function ({
        whiteboard_id
    }) {
        return zego_white_board_.zego_whiteboard_destroy(whiteboard_id);
    }


    /**
     * 获取白板列表
     * @return {number} 0为调用失败，非0为请求序号
     */
    this.whiteboardGetList = function () {
        return zego_white_board_.zego_whiteboard_get_list();
    }

    /**
     * 滑动、翻滚白板画布（仅用于通知界面层）
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     * @param {float} option.horizontal_percent -
     * @param {float} option.vertical_percent -
     * @return {number} 0为调用失败，非0为请求序号
     */
    this.whiteboardScrollCanvas = function ({
        whiteboard_id,
        horizontal_percent,
        vertical_percent,
        step
    }) {
        return zego_white_board_.zego_whiteboard_scroll_canvas(whiteboard_id, horizontal_percent, vertical_percent, step);
    }

    /**
     * 获取图元粗细
     * @param {object} option - 参数对象
     * @param {number} option.graphic_properties - 白板画布上的图元模型
     * @return {number} 图元粗细
     */
    this.whiteboardGraphicItemGetSize = function ({
        graphic_properties
    }) {
        return zego_white_board_.zego_whiteboard_graphic_item_get_size(graphic_properties);
    }

    /**
     * 获取图元颜色
     * @param {object} option - 参数对象
     * @param {number} option.graphic_properties - 白板画布上的图元模型
     * @return {number} 图元颜色
     */
    this.whiteboardGraphicItemGetColor = function ({
        graphic_properties
    }) {
        return zego_white_board_.zego_whiteboard_graphic_item_get_color(graphic_properties);
    }

    /**
     * 获取图元坐标
     * @param {object} option - 参数对象
     * @param {number} option.graphic_properties - 白板画布上的图元模型
     * @return {object} 图元坐标 {x:number, y:number}
     */
    this.whiteboardGraphicItemGetPos = function ({
        graphic_properties
    }) {
        return zego_white_board_.zego_whiteboard_graphic_item_get_pos(graphic_properties);
    }

    /**
     * 获取图元 zOrder
     * @param {object} option - 参数对象
     * @param {number} option.graphic_properties - 白板画布上的图元模型
     * @return {number} 图元的zOrder
     */
    this.whiteboardGraphicItemGetZOrder = function ({
        graphic_properties
    }) {
        return zego_white_board_.zego_whiteboard_graphic_item_get_zorder(graphic_properties);
    }
    /**
     * 获取图元操作者 ID
     * @param {object} option - 参数对象
     * @param {number} option.graphic_properties - 白板画布上的图元模型
     * @return {string} 操作者 ID
     */
    this.whiteboardGraphicItemGetOperatorId = function ({
        graphic_properties
    }) {
        return zego_white_board_.zego_whiteboard_graphic_item_get_operator_id(graphic_properties);
    }
    /**
     * 获取图元操作者昵称
     * @param {object} option - 参数对象
     * @param {number} option.graphic_properties - 白板画布上的图元模型
     * @return {string} 操作者昵称
     */
    this.whiteboardGraphicItemGetOperatorName = function ({
        graphic_properties
    }) {
        return zego_white_board_.zego_whiteboard_graphic_item_get_operator_name(graphic_properties);
    }

    /**
     * 加载指定白板关联画布上的所有图元。
     * 加载完最后一个图元后，将从 onWhiteBoardCanvasLoad 反馈结束。
     * 具体的图元数据，根据加载过程中的实际操作类型，从各通知接口（onWhiteBoardCanvasXXX）通知
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     */
    this.whiteboardCanvasLoad = function ({
        whiteboard_id
    }) {
        zego_white_board_.zego_whiteboard_canvas_load(whiteboard_id);
    }

    /**
     * 加载指定白板关联画布上，缓存在 SDK 中的所有图元
     * 加载完最后一个图元后，将从 onWhiteBoardCanvasLoad 反馈结束。
     * 具体的图元数据，根据加载过程中的实际操作类型，从各通知接口（onWhiteBoardCanvasXXX）通知
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     */
    this.whiteboardCanvasLoadCache = function ({
        whiteboard_id
    }) {
        zego_white_board_.zego_whiteboard_canvas_load_cache(whiteboard_id);
    }

    /**
     * 撤销指定白板画布的上一次图元操作，绘制过程中调用无效
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     */
    this.whiteboardCanvasUndo = function ({
        whiteboard_id
    }) {
        zego_white_board_.zego_whiteboard_canvas_undo(whiteboard_id);
    }
    /**
     * 重做指定白板画布上一次撤销的图元操作，绘制过程中调用无效
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     */
    this.whiteboardCanvasRedo = function ({
        whiteboard_id
    }) {
        zego_white_board_.zego_whiteboard_canvas_redo(whiteboard_id);
    }
    /**
     * 重做指定白板画布上一次撤销的图元操作，绘制过程中调用无效
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     * @param {number} option.graphic_type - 白板画布上简单图元类型, 查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoWhiteboardGraphic</a>
     * @param {number} option.x - 传入起始坐标（UI层原始坐标即可），比如鼠标右键按下、触碰屏幕时的点击坐标。
     * @param {number} option.y - 传入起始坐标（UI层原始坐标即可），比如鼠标右键按下、触碰屏幕时的点击坐标。
     * @return {number} 新图元id
     */
    this.whiteboardCanvasBeginDraw = function ({
        whiteboard_id,
        graphic_type,
        x,
        y
    }) {
        return zego_white_board_.zego_whiteboard_canvas_begin_draw(whiteboard_id, graphic_type, x, y);
    }
    /**
     * 通知指定白板的虚拟画布图元绘制结束, 与whiteboardCanvasBeginDraw配对使用
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     */
    this.whiteboardCanvasEndDraw = function ({
        whiteboard_id
    }) {
        return zego_white_board_.zego_whiteboard_canvas_end_draw(whiteboard_id);
    }

    /**
     * 向指定白板的虚拟画布绘制涂鸦点
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     * @param {number} option.x - 涂鸦点 坐标 x
     * @param {number} option.y - 涂鸦点 坐标 y
     */
    this.whiteboardCanvasDrawPath = function ({
        whiteboard_id,
        x,
        y
    }) {
        return zego_white_board_.zego_whiteboard_canvas_draw_path(whiteboard_id, x, y);
    }
    /**
     * 向指定白板的虚拟画布绘制简单文本
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     * @param {string} option.text - 简单文本内容
     */
    this.whiteboardCanvasDrawText = function ({
        whiteboard_id,
        text
    }) {
        return zego_white_board_.zego_whiteboard_canvas_draw_text(whiteboard_id, text);
    }
    /**
     * 编辑指定白板虚拟画布上的已存在文本图元，即修改文本内容
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     * @param {number} option.graphic_id - 图元id
     * @param {string} option.text - 新的文本内容
     */
    this.whiteboardCanvasEditText = function ({
        whiteboard_id,
        graphic_id,
        text
    }) {
        return zego_white_board_.zego_whiteboard_canvas_edit_text(whiteboard_id, graphic_id, text);
    }
    /**
     * 向指定白板的虚拟画布绘制直线终点
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     * @param {number} option.x - 直线终点x坐标
     * @param {number} option.y - 直线终点y坐标
     */
    this.whiteboardCanvasDrawLine = function ({
        whiteboard_id,
        x,
        y
    }) {
        return zego_white_board_.zego_whiteboard_canvas_draw_line(whiteboard_id, x, y);
    }
    /**
     * 向指定白板的虚拟画布绘制矩形的右下角点
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     * @param {number} option.x - 矩形右下角点x坐标
     * @param {number} option.y - 矩形右下角点y坐标
     */
    this.whiteboardCanvasDrawRect = function ({
        whiteboard_id,
        x,
        y
    }) {
        return zego_white_board_.zego_whiteboard_canvas_draw_rect(whiteboard_id, x, y);
    }
    /**
     * 向指定白板的虚拟画布绘制椭圆矩形外框的右下角点
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     * @param {number} option.x - 椭圆矩形外框右下角点x坐标
     * @param {number} option.y - 椭圆矩形外框右下角点y坐标
     */
    this.whiteboardCanvasDrawEllipse = function ({
        whiteboard_id,
        x,
        y
    }) {
        return zego_white_board_.zego_whiteboard_canvas_draw_ellipse(whiteboard_id, x, y);
    }

    /**
     * 向指定白板的虚拟画布绘制图片
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     * @param {string} option.path - 图片本地路径或url
     * @param {string} option.hash - 图片hash（可填空）
     * @param {number} option.pos_x - 结束位置 x
     * @param {number} option.pos_y - 结束位置 y
     */
    this.whiteboardCanvasAddImage = function ({
        whiteboard_id,
        path,
        hash,
        pos_x,
        pos_y
    }) {
        return zego_white_board_.zego_whiteboard_canvas_add_image(whiteboard_id, path, hash, pos_x, pos_y);
    }

    /**
     * 编辑图片
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     * @param {number} option.graphic_id - 图片图元id
     * @param {number} option.pos_x - 图片图元的左上角x坐标
     * @param {number} option.pos_y - 图片图元的左上角y坐标
     * @param {number} option.epos_x - 图片图元的右下角x坐标
     * @param {number} option.epos_y - 图片图元的右下角y坐标
     */
    this.whiteboardCanvasEditImage = function ({
        whiteboard_id,
        graphic_id,
        pos_x,
        pos_y,
        epos_x,
        epos_y
    }) {
        return zego_white_board_.zego_whiteboard_canvas_edit_image(whiteboard_id, graphic_id, pos_x, pos_y, epos_x, epos_y);
    }

    /**
     * 向指定白板的虚拟画布绘制椭圆矩形外框的右下角点
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     * @param {number} option.graphic_id - 图元id
     * @param {number} option.x - 要移动的目标位置坐标，相对图元来说是左上角x坐标
     * @param {number} option.y - 要移动的目标位置坐标，相对图元来说是左上角y坐标
     */
    this.whiteboardCanvasMoveItem = function ({
        whiteboard_id,
        graphic_id,
        x,
        y
    }) {
        return zego_white_board_.zego_whiteboard_canvas_move_item(whiteboard_id, graphic_id, x, y);
    }

    /**
     * 批量移动图元
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     * @param {array} option.move_info_list - 要批量移动的图元信息列表，图元信息对象属性如下：
     * @param {number} option.move_info_list.graphic_id - 图元id
     * @param {number} option.move_info_list.x - 要移动的目标位置坐标，相对图元来说是左上角x坐标
     * @param {number} option.move_info_list.y - 要移动的目标位置坐标，相对图元来说是左上角y坐标
     */
    this.whiteboardCanvasMoveItems = function ({
        whiteboard_id,
        move_info_list=[]
    }) {

        zego_white_board_.zego_whiteboard_init_move_items();

        for (let i = 0; i < move_info_list.length; ++i) {
            zego_white_board_.zego_whiteboard_add_move_item(move_info_list[i].graphic_id, move_info_list[i].x, move_info_list[i].y);
        }

        zego_white_board_.zego_whiteboard_start_move_items(whiteboard_id);
    }

    /**
     * 向指定白板的虚拟画布绘制椭圆矩形外框的右下角点
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     * @param {number} option.graphic_id - 图元id
     */
    this.whiteboardCanvasDeleteItem = function ({
        whiteboard_id,
        graphic_id
    }) {
        return zego_white_board_.zego_whiteboard_canvas_delete_item(whiteboard_id, graphic_id);
    }

    /**
     * 批量删除图元
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     * @param {array} option.delete_list - 图元id列表
     * @param {number} option.delete_list.graphic_id - 图元id
     */
    this.whiteboardCanvasDeleteItems = function ({
        whiteboard_id,
        delete_list=[]
    }) {

        zego_white_board_.zego_whiteboard_init_delete_items();

        for (let i = 0; i < delete_list.length; ++i) {
            zego_white_board_.zego_whiteboard_add_delete_item(delete_list[i].graphic_id);
        }

        zego_white_board_.zego_whiteboard_start_delete_items(whiteboard_id);
    }

    /**
     * 清除指定白板关联画布上的所有图元，所有人或白板操作者会收到该指令
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     */
    this.whiteboardCanvasClear = function ({
        whiteboard_id
    }) {
        return zego_white_board_.zego_whiteboard_canvas_clear(whiteboard_id)
    }

    this.whiteboardModelGetContent = function ({
        whiteboard_model
    }) {
        return zego_white_board_.zego_whiteboard_model_get_content(whiteboard_model)
    }

    this.whiteboardModelSetContent = function ({
        whiteboard_model,
        content
    }) {
        return zego_white_board_.zego_whiteboard_model_set_content(whiteboard_model, content)
    }

    this.whiteboardSetViewportSize = function ({
        whiteboard_id,
        width,
        height
    }) {
        return zego_white_board_.zego_whiteboard_set_viewport_size(whiteboard_id, width, height)
    }

    this.whiteboardLoadCurrentGraphics = function ({
        whiteboard_id, horizontal_percent, vertical_percent
    }) {
        return zego_white_board_.zego_whiteboard_load_current_graphics(whiteboard_id, horizontal_percent, vertical_percent)
    }

    this.whiteboardSetContent = function ({ whiteboard_id, content })
    {
        return zego_white_board_.zego_whiteboard_set_content(whiteboard_id, content)
    }

    this.whiteboardSettingsGetGraphicSize = function ({ graphic_type})
    {
        return zego_white_board_.zego_whiteboard_settings_get_graphic_size(graphic_type)
    }

    this.whiteboardSettingsSetGraphicSize = function ({ graphic_type, size_level }) {
        return zego_white_board_.zego_whiteboard_settings_set_graphic_size(graphic_type, size_level)
    }

    this.whiteboardSettingsGetGraphicColor = function ({ graphic_type }) {
        return zego_white_board_.zego_whiteboard_settings_get_graphic_color(graphic_type)
    }

    this.whiteboardSettingsGetGraphicColorString = function ({ graphic_type }) {
        return zego_white_board_.zego_whiteboard_settings_get_graphic_color_string(graphic_type)
    }

    this.whiteboardSettingsSetGraphicColor = function ({ graphic_type, color }) {
        return zego_white_board_.zego_whiteboard_settings_set_graphic_color(graphic_type, color)
    }

    this.whiteboardSettingsGetGraphicBold = function ({ graphic_type }) {
        return zego_white_board_.zego_whiteboard_settings_get_graphic_bold(graphic_type)
    }

    this.whiteboardSettingsSetGraphicBold = function ({ graphic_type, is_bold }) {
        zego_white_board_.zego_whiteboard_settings_set_graphic_bold(graphic_type, is_bold)
    }

    this.whiteboardSettingsGetGraphicItalic = function ({ graphic_type }) {
        return zego_white_board_.zego_whiteboard_settings_get_graphic_italic(graphic_type)
    }

    this.whiteboardSettingsSetGraphicItalic = function ({ graphic_type, is_italic }) {
        zego_white_board_.zego_whiteboard_settings_set_graphic_italic(graphic_type, is_italic)
    }

    /**
     * 设置指定白板的扩展信息
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_id - 白板id
     * @param {string} option.extra - 拓展信息内容
     * @return {number} 0为调用失败，非0为请求序号
     */
    this.whiteboardAppendH5Extra = function({whiteboard_id, extra}){
        return zego_white_board_.zego_whiteboard_append_h5_extra(whiteboard_id, extra)
    }

    /**
     * 获取白板模型拓展扩展信息
     * @param {object} option - 参数对象
     * @param {number} option.whiteboard_model - 白板模型
     * @param {number} option.extra - 内容
     * @return {string} 白板模型拓展信息
     */
    this.whiteboardModelGetH5Extra = function({whiteboard_model}){
        return zego_white_board_.zego_whiteboard_model_get_h5_extra(whiteboard_model)
    }

    this.docsSetTestConfig = function ({
        config
    }) {
        return zego_docs_.zego_docs_set_test_config(config);
    }


    this.docsSetTestEnv = function ({
        is_test_env
    }) {
        return zego_docs_.zego_docs_set_test_env(is_test_env);
    }
    this.docsSetLogFolder = function ({
        log_path,
        log_level
    }) {
        return zego_docs_.zego_docs_set_log_folder(log_path, log_level);
    }
    this.docsSetExternVersion = function ({
        room_version,
        engine_version
    }) {
        return zego_docs_.zego_docs_set_extern_version(room_version, engine_version);
    }
    this.docsSetDeviceId = function ({
        device_id
    }) {
        return zego_docs_.zego_docs_set_device_id(device_id);
    }
    this.docsSetCertificateUrl = function ({
        cert_url
    }) {
        return zego_docs_.zego_docs_set_certificate_url(cert_url);
    }
    this.docsInit = function ({
        app_id,
        app_sign,
        app_data_folder
    }) {
        return zego_docs_.zego_docs_init(app_id, app_sign, app_data_folder);
    }
    this.docsInitWithToken = function ({
        token,
        app_data_folder
    }) {
        return zego_docs_.zego_docs_init_with_token(token, app_data_folder);
    }
    this.docsUinit = function () {
        return zego_docs_.zego_docs_uninit();
    }

    this.docsSetSplitSize = function ({
        width,
        height
    }) {
        return zego_docs_.zego_docs_set_split_size(width, height);
    }

    this.docsUpload = function ({
        file_path,
        pwd
    }) {
        return zego_docs_.zego_docs_upload(file_path, pwd);
    }

    this.docsCancelUpload = function ({
        seq
    }) {
        return zego_docs_.zego_docs_cancel_upload(seq);
    }

    this.docsSetCacheDirectory = function ({
        directory
    }) {
        return zego_docs_.zego_docs_set_cache_directory(directory);
    }

    this.docsLoad = function ({
        file_id,
        auth_key
    }) {
        return zego_docs_.zego_docs_load(file_id, auth_key);
    }

    this.docsGetPageImage = function ({
        file_id,
        virtual_page_number,
        rate,
        rotation
    }) {
        return zego_docs_.zego_docs_get_page_image(file_id, virtual_page_number, rate, rotation);
    }

    this.docsUnload = function ({
        file_id
    }) {
        return zego_docs_.zego_docs_unload(file_id);
    }

    this.docsQueryFileInfo = function ({
        file_id
    }) {
        return zego_docs_.zego_docs_query_file_info(file_id);
    }

    this.docsSetUserId = function ({
        user_id
    }) {
        return zego_docs_.zego_docs_set_user_id(user_id);
    }

    this.docsSetDisplayType = function ({
        type
    }) {
        return zego_docs_.zego_docs_set_display_type(type);
    }

    this.docsDownloadFile = function ({
        file_id,
        file_path,
        creator_id
    }) {
        return zego_docs_.zego_docs_download_file(file_id, file_path, creator_id);
    }

    this.docsCancelDownloadCache = function ({
        file_id
    }) {
        return zego_docs_.zego_docs_cancel_download_cache(file_id)
    }

    this.docsCacheExist = function ({
        file_id
    }) {
        return zego_docs_.zego_docs_cache_exist(file_id)
    }
}


/**
 * 初始化sdk回调
 * @callback onInitSDK
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码,0-成功，其它值，查看<a href="https://doc.zego.im/API/HideDoc/ErrorCodeTable.html" target="_blank">官网错误码列表</a>
 */

/**
 * 登陆房间返回
 * @callback onLoginRoom
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0-成功，其它值，查看<a href="https://doc.zego.im/API/HideDoc/ErrorCodeTable.html" target="_blank">官网错误码列表</a>
 * @param {string} result.room_id - 房间id
 * @param {number} result.stream_count - 房间媒体流的数量
 * @param {string} result.stream_list - 流信息对象数组，流信息对象属性如下：
 * @param {string} result.stream_list.stream_id - 流id
 * @param {string} result.stream_list.user_name - 用户名
 * @param {string} result.stream_list.user_id - 用户id
 * @param {string} result.stream_list.extra_info - 流额外信息
 */

/**
 * 登陆第二套房间返回
 * @callback onLoginMultiRoom
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0-成功，其它值，查看<a href="https://doc.zego.im/API/HideDoc/ErrorCodeTable.html" target="_blank">官网错误码列表</a>
 * @param {string} result.room_id - 房间id
 * @param {number} result.stream_count - 房间媒体流的数量
 * @param {string} result.stream_list - 流信息对象数组，流信息对象属性如下：
 * @param {string} result.stream_list.stream_id - 流id
 * @param {string} result.stream_list.user_name - 用户名
 * @param {string} result.stream_list.user_id - 用户id
 * @param {string} result.stream_list.extra_info - 流额外信息
 */

/**
 * 退出第二套房间返回
 * @callback onLogoutMultiRoom
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码,0-成功
 * @param {string} result.room_id - 房间id
 */

/**
 * 登出房间返回
 * @callback onLogoutRoom
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码,0-成功
 * @param {string} result.room_id - 房间id
 */

/**
 * SDK 引擎事件通知
 * @callback onAVKitEvent
 * @param {object} result - 结果数据对象
 * @param {number} result.event_code - 事件码，1-开始重试拉流，2-重试拉流成功，3-开始重试推流，4-重试推流成功，5-拉流临时中断，6-推流临时中断，7-拉流卡顿(视频)。
 * @param {object|array} result.event_info - 事件信息对象数组，事件信息对象属性如下：
 * @param {string} result.event_info.event_key - 事件名称
 * @param {string} result.event_info.event_value - 事件值
 */

/**
 * 拉流状态通知
 * @callback onPlayStateUpdate
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0-成功，其它值查看官网<a href="https://doc.zego.im/API/HideDoc/ErrorCodeTable.html" target="_blank">3 onPlayStateUpdate的错误码说明</a>
 * @param {string} result.stream_id - 流id
 */

/**
 * 拉流质量更新事件通知
 * @callback onPlayQualityUpdate
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 事件码
 * @param {string} result.stream_id - 流id
 * @param {number} result.fps - 视频帧率(网络接收)
 * @param {number} result.vdj_fps - 视频帧率(dejitter)
 * @param {number} result.vdec_fps - 视频帧率(解码)
 * @param {number} result.vrnd_fps - 视频帧率(渲染)
 * @param {number} result.kbps - 视频码率(kb/s)
 * @param {number} result.afps - 音频帧率(网络接收)
 * @param {number} result.adj_fps - 音频帧率(dejitter)
 * @param {number} result.adec_fps - 音频帧率(解码)
 * @param {number} result.arnd_fps - 音频帧率(渲染)
 * @param {number} result.akbps - 音频码率(kb/s)
 * @param {number} result.audio_break_rate - 音频卡顿次数
 * @param {number} result.video_break_rate - 视频卡顿次数
 * @param {number} result.rtt - 延时(ms)
 * @param {number} result.pkt_lost_rate - 丢包率(0~255)
 * @param {number} result.quality - 质量(0~3)
 * @param {number} result.delay - 语音延时(ms)
 * @param {number} result.is_hardware_vdec - 是否硬解
 * @param {number} result.width - 视频宽度
 * @param {number} result.height - 视频高度
 * @param {number} result.total_bytes - 已接收的总字节数，包括音频、视频及媒体次要信息等
 * @param {number} result.audio_bytes - 已接收的音频字节数
 * @param {number} result.video_bytes - 已接收的视频字节数
 */

/**
 * 推流状态更新
 * @callback onPublishStateUpdate
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0-成功，其它值查看官网<a href="https://doc.zego.im/API/HideDoc/ErrorCodeTable.html" target="_blank">2 onPublishStateUpdate的错误码说明</a>
 * @param {string} result.stream_id - 流id
 * @param {string|array} result.rtmp_urls - rtmp url数组
 * @param {string|array} result.flv_urls - flv url 数组
 * @param {string|array} result.hls_urls - hls url 数组
 */

/**
 * 推流质量通知
 * @callback onPublishQualityUpdate
 * @param {object} result - 结果数据对象
 * @param {string} result.stream_id - 流id
 * @param {number} result.cfps - 视频帧率(采集)
 * @param {number} result.venc_fps - 视频帧率(编码)
 * @param {number} result.fps - 视频帧率(网络发送)
 * @param {number} result.kbps - 视频码率(kb/s)
 * @param {number} result.acap_fps - 音频帧率（采集）
 * @param {number} result.afps - 音频帧率（网络发送）
 * @param {number} result.akbps - 音频码率(kb/s)
 * @param {number} result.rtt - 延时(ms)
 * @param {number} result.pkt_lost_rate - 丢包率(0~255)
 * @param {number} result.quality - 质量(0~3)
 * @param {number} result.is_hardware_venc - 是否硬编
 * @param {number} result.width - 视频宽度
 * @param {number} result.height - 视频高度
 * @param {number} result.total_bytes - 已发送的总字节数，包括音频、视频及媒体次要信息等
 * @param {number} result.audio_bytes - 已发送的音频字节数
 * @param {number} result.video_bytes - 已发送的视频字节数
 * @param {number} result.cpu_app_usage - 当前 APP 的 CPU 使用率
 * @param {number} result.cpu_total_usage - 当前系统的 CPU 使用率
 * @param {number} result.memory_app_usage - 当前 APP 的内存使用率
 * @param {number} result.memory_total_usage - 当前系统的内存使用率
 * @param {number} result.memory_app_used - 当前系统的内存使用率
 */


/**
 * 流更新事件通知，房间内增加流、删除流，均会触发此更新。主播推流，自己不会收到此回调，房间内其他成员会收到。建议对流增加和流删除分别采取不同的处理。
 * @callback onStreamUpdated
 * @param {object} result - 结果数据对象
 * @param {string} result.room_id - 房间id
 * @param {number} result.stream_update_type - 2001-新增流，2002-删除流
 * @param {number} result.stream_count - 流数量
 * @param {object|array} result.stream_list - 流信息对象数组，流信息对象属性如下：
 * @param {string} result.stream_list.user_id - 用户id
 * @param {string} result.stream_list.user_name - 用户名字
 * @param {string} result.stream_list.stream_id - 流id
 * @param {string} result.stream_list.extra_info - 流额外信息
 */

/**
 * 第二套房间流更新事件通知，房间内增加流、删除流，均会触发此更新。主播推流，自己不会收到此回调，房间内其他成员会收到。建议对流增加和流删除分别采取不同的处理。
 * @callback onMultiRoomStreamUpdated
 * @param {object} result - 结果数据对象
 * @param {string} result.room_id - 房间id
 * @param {number} result.stream_update_type - 2001-新增流，2002-删除流
 * @param {number} result.stream_count - 流数量
 * @param {object|array} result.stream_list - 流信息对象数组，流信息对象属性如下：
 * @param {string} result.stream_list.user_id - 用户id
 * @param {string} result.stream_list.user_name - 用户名字
 * @param {string} result.stream_list.stream_id - 流id
 * @param {string} result.stream_list.extra_info - 流额外信息
 */


/**
 * 房间用户信息更新
 * @callback onUserUpdate
 * @param {object} result - 结果数据对象
 * @param {number} result.update_type - 更新类型，1-全量更新，2-增量更新
 * @param {object|array} result.users - 用户信息对象数组，用户信息对象属性如下：
 * @param {string} result.users.user_id - 用户id
 * @param {string} result.users.user_name - 用户名字
 * @param {number} result.users.update_flag - 更新属性，1-新增，2-删除
 * @param {number} result.users.role - 成员角色，1-主播，2-观众
 */

/**
 * 第二套房间用户信息更新
 * @callback onMultiRoomUserUpdate
 * @param {object} result - 结果数据对象
 * @param {number} result.update_type - 更新类型，1-全量更新，2-增量更新
 * @param {object|array} result.users - 用户信息对象数组，用户信息对象属性如下：
 * @param {string} result.users.user_id - 用户id
 * @param {string} result.users.user_name - 用户名字
 * @param {number} result.users.update_flag - 更新属性，1-新增，2-删除
 * @param {number} result.users.role - 成员角色，1-主播，2-观众
 */

/**
 * 房间在线人数更新
 * @callback onUpdateOnlineCount
 * @param {object} result - 结果数据对象
 * @param {string} result.room_id - 房间id
 * @param {number} result.online_count - 在线人数
 */

/**
 * 第二套房间在线人数更新
 * @callback onMultiRoomUpdateOnlineCount
 * @param {object} result - 结果数据对象
 * @param {string} result.room_id - 房间id
 * @param {number} result.online_count - 在线人数
 */

/**
 * 发送房间消息结果返回
 * @callback onSendRoomMessage
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码
 * @param {string} result.room_id - 房间id
 * @param {number} result.send_seq - 发送的消息序号
 * @param {number} result.msg_id - 消息id
 */

/**
 * 第二套房间发送房间消息结果返回
 * @callback onSendMultiRoomMessage
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码
 * @param {string} result.room_id - 房间id
 * @param {number} result.send_seq - 发送的消息序号
 * @param {number} result.msg_id - 消息id
 */

/**
 * 收到房间消息通知
 * @callback onRecvRoomMessage
 * @param {object} result - 结果数据对象
 * @param {string} result.room_id - 房间id
 * @param {object|array} result.msg_list - 消息信息对象数组，消息信息对象属性如下：
 * @param {string} result.msg_list.user_id - 用户id
 * @param {string} result.msg_list.user_name - 用户名字
 * @param {number} result.msg_list.role - 成员角色，1-主播，2-观众
 * @param {string} result.msg_list.content - 消息内容
 * @param {string} result.msg_list.msg_id - 消息id
 * @param {string} result.msg_list.msg_type - 消息类型
 * @param {number} result.msg_list.msg_priority - 消息优先级，2-默认优先级，3-高优先级
 * @param {number} result.msg_list.msg_category - 消息类别，1-聊天，2-系统，3-点赞，4-送礼物，100-其它
 * @param {number} result.msg_list.send_time - 消息发送时间
 *
 */

/**
 * 第二套房间收到房间消息通知
 * @callback onRecvMultiRoomMessage
 * @param {object} result - 结果数据对象
 * @param {string} result.room_id - 房间id
 * @param {object|array} result.msg_list - 消息信息对象数组，消息信息对象属性如下：
 * @param {string} result.msg_list.user_id - 用户id
 * @param {string} result.msg_list.user_name - 用户名字
 * @param {number} result.msg_list.role - 成员角色，1-主播，2-观众
 * @param {string} result.msg_list.content - 消息内容
 * @param {string} result.msg_list.msg_id - 消息id
 * @param {string} result.msg_list.msg_type - 消息类型
 * @param {number} result.msg_list.msg_priority - 消息优先级，2-默认优先级，3-高优先级
 * @param {number} result.msg_list.msg_category - 消息类别，1-聊天，2-系统，3-点赞，4-送礼物，100-其它
 * @param {number} result.msg_list.send_time - 消息发送时间
 *
 */

/**
 * 发送大房间消息结果返回
 * @callback onSendBigRoomMessage
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码
 * @param {string} result.room_id - 房间id
 * @param {number} result.send_seq - 消息序号
 * @param {string} result.msg_id - 消息id
 */

/**
 * 第二套房间发送大房间消息结果返回
 * @callback onSendMultiRoomBigRoomMessage
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码
 * @param {string} result.room_id - 房间id
 * @param {number} result.send_seq - 消息序号
 * @param {string} result.msg_id - 消息id
 */

/**
 * 收到大房间消息通知
 * @callback onRecvBigRoomMessage
 * @param {object} result - 结果数据对象
 * @param {string} result.room_id - 房间id
 * @param {object|array} result.msg_list - 消息信息对象数组，消息信息对象属性如下：
 * @param {string} result.msg_list.user_id - 用户id
 * @param {string} result.msg_list.user_name - 用户名字
 * @param {number} result.msg_list.role - 成员角色，1-主播，2-观众
 * @param {string} result.msg_list.content - 消息内容
 * @param {string} result.msg_list.msg_id - 消息id
 * @param {string} result.msg_list.msg_type - 消息类型
 * @param {number} result.msg_list.msg_category - 消息类别，1-聊天，2-系统，3-点赞，4-送礼物，100-其它
 * @param {number} result.msg_list.send_time - 消息发送时间
 *
 */

/**
 * 第二套房间收到大房间消息通知
 * @callback onRecvMultiRoomBigRoomMessage
 * @param {object} result - 结果数据对象
 * @param {string} result.room_id - 房间id
 * @param {object|array} result.msg_list - 消息信息对象数组，消息信息对象属性如下：
 * @param {string} result.msg_list.user_id - 用户id
 * @param {string} result.msg_list.user_name - 用户名字
 * @param {number} result.msg_list.role - 成员角色，1-主播，2-观众
 * @param {string} result.msg_list.content - 消息内容
 * @param {string} result.msg_list.msg_id - 消息id
 * @param {string} result.msg_list.msg_type - 消息类型
 * @param {number} result.msg_list.msg_category - 消息类别，1-聊天，2-系统，3-点赞，4-送礼物，100-其它
 * @param {number} result.msg_list.send_time - 消息发送时间
 *
 */

/**
 * 发送自定义消息结果返回
 * @callback onCustomCommand
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码
 * @param {string} result.room_id - 字符串
 * @param {number} result.request_seq - 序号
 */

 /**
 * 发送自定义消息结果返回
 * @callback onSetRoomExtraInfo
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码
 * @param {string} result.room_id - 字符串
 * @param {string} result.key - 字符串
 * @param {number} result.request_seq - 序号
 */

 /**
 * 房间附加信息更新通知
 * @callback OnRoomExtraInfoUpdated
 * @param {object} result - 结果数据对象
 * @param {number} result.extra_info_count - 房间属性对象个数
 * @param {array} result.extra_info_list - 房间属性对象列表，每个房间属性对象的属性值如下：
 * @param {string} result.extra_info_list.key - 附加信息key
 * @param {string} result.extra_info_list.value - 附加信息值
 * @param {string} result.extra_info_list.user_id - 变更附加信息UserID
 * @param {string} result.extra_info_list.user_name - 变更附加信息UserName
 * @param {string} result.extra_info_list.update_time - 变更附加信息时间
 */

/**
 * 第二套发送自定义消息结果返回
 * @callback onSendMultiRoomCustomCommand
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码
 * @param {string} result.room_id - 字符串
 * @param {number} result.request_seq - 序号
 */

/**
 * 收到自定义消息
 * @callback onRecvCustomCommand
 * @param {object} result - 结果数据对象
 * @param {string} result.user_id - 消息来源用户id
 * @param {string} result.user_name - 消息来源用户名字
 * @param {string} result.room_id - 房间id
 * @param {string} result.content - 消息内容
 */

/**
 * 第二套房间收到自定义消息
 * @callback onRecvMultiRoomCustomCommand
 * @param {object} result - 结果数据对象
 * @param {string} result.user_id - 消息来源用户id
 * @param {string} result.user_name - 消息来源用户名字
 * @param {string} result.room_id - 房间id
 * @param {string} result.content - 消息内容
 */

/**
 * 流附加信息更新
 * @callback onStreamExtraInfoUpdated
 * @param {object} result - 结果数据对象
 * @param {string} result.room_id - 房间id
 * @param {number} result.stream_count - 流数量
 * @param {object | array} result.stream_list - 流信息对象数组，流信息对象属性如下：
 * @param {string} result.stream_list.user_id - 用户id
 * @param {string} result.stream_list.user_name - 用户名字
 * @param {string} result.stream_list.stream_id - 流id
 * @param {string} result.stream_list.extra_info - extra_info信息
 *
 */

/**
 * 第二套房间流附加信息更新
 * @callback onMultiRoomStreamExtraInfoUpdated
 * @param {object} result - 结果数据对象
 * @param {string} result.room_id - 房间id
 * @param {number} result.stream_count - 流数量
 * @param {object | array} result.stream_list - 流信息对象数组，流信息对象属性如下：
 * @param {string} result.stream_list.user_id - 用户id
 * @param {string} result.stream_list.user_name - 用户名字
 * @param {string} result.stream_list.stream_id - 流id
 * @param {string} result.stream_list.extra_info - extra_info信息
 *
 */

/**
 * 音频设备状态更新通知
 * @callback onAudioDeviceStateChanged
 * @param {object} result - 结果数据对象
 * @param {number} result.device_type - 0-输入设备，1-输出设备
 * @param {number} result.device_state - 0-添加设备，1-删除设备
 * @param {string} result.device_id - 设备id
 * @param {string} result.device_name - 设备名字
 */

/**
 * 视频设备状态更新通知
 * @callback onVideoDeviceStateChanged
 * @param {object} result - 结果数据对象
 * @param {number} result.device_state - 0-添加设备，1-删除设备
 * @param {string} result.device_id - 设备id
 * @param {string} result.device_name - 设备名字
 */

/**
 * 音量变更事件通知
 * @callback onAudioVolumeChanged
 * @param {object} result - 结果数据对象
 * @param {number} result.device_type - 0-输入设备，1-输出设备
 * @param {string} result.device_id - 设备id
 * @param {number} result.volume_type - 音量类型，0-设备音量，1-App音量
 * @param {number} result.volume - 音量值
 * @param {boolean} result.is_mute - 是否静音，true-静音，false-非静音
 *
 */

/**
 * 设备状态错误事件通知
 * @callback onDeviceError
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码, -1 - 一般性错误, -2 - 无效设备 ID, -3 - 没有权限, -4 - 采集帧率为0, -5 - 设备被占用, -6 - 设备未插入, -7 - 需要重启系统, -8 - 媒体服务无法恢复
 * @param {string} result.device_name - 设备名字，值为"camera"、"microphone"或者"speaker"
 */

/**
 * 当前正在尝试使用的设备回调，只有windows平台才支持
 * 在初始化SDK之前调用zegoClient.setGeneralConfig({config:"device_mgr_mode=3"});配置后，自动重试设备才会生效，
 * 建议业务层在该接口里获取当前尝试的设备信息后，更新相关的设备选择界面信息。
 * @callback onRetryDevice
 * @param {object} result - 结果数据对象
 * @param {number} result.device_id - 设备id
 * @param {string} result.device_name - 设备名字，值为"camera"、"microphone"或者"speaker"
 */

/**
 * 被踢掉线通知，可在该回调中处理用户被踢出房间后的下一步处理（例如报错、重新登录提示等）
 * @callback onKickOut
 * @param {object} result - 结果数据对象
 * @param {number} result.reason - 被踢出原因，查看<a href="https://doc.zego.im/API/HideDoc/ErrorCodeTable.html" target="_blank">官网错误码列表</a>
 * @param {string} result.room_id - 房间id
 */

/**
 * 第二套房间被踢掉线通知，可在该回调中处理用户被踢出房间后的下一步处理（例如报错、重新登录提示等）
 * @callback onKickOutMultiRoom
 * @param {object} result - 结果数据对象
 * @param {number} result.reason - 被踢出原因，查看<a href="https://doc.zego.im/API/HideDoc/ErrorCodeTable.html" target="_blank">官网错误码列表</a>
 * @param {string} result.room_id - 房间id
 */

/**
 * 已从房间断开连接的通知，建议开发者在此通知中进行重新登录、推/拉流、报错、友好性提示等其他恢复逻辑。与 server 断开连接后，SDK 会进行重试，重试失败抛出此错误。请注意，此时 SDK 与服务器的所有连接均会断开。
 * @callback onDisconnect
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0 表示无错误
 * @param {string} result.room_id - 房间id
 */

/**
 * 第二套房间断开连接的通知，建议开发者在此通知中进行重新登录、推/拉流、报错、友好性提示等其他恢复逻辑。与 server 断开连接后，SDK 会进行重试，重试失败抛出此错误。请注意，此时 SDK 与服务器的所有连接均会断开。
 * @callback onMultiRoomDisconnect
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0 表示无错误
 * @param {string} result.room_id - 房间id
 */

/**
 * 与 server 重连成功通知
 * @callback onReconnect
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0 表示无错误
 * @param {string} result.room_id - 房间id
 */

/**
 * 第二套房间与 server 重连成功通知
 * @callback onMultiRoomReconnect
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0 表示无错误
 * @param {string} result.room_id - 房间id
 */

/**
 * 与 server 连接中断通知，SDK会尝试自动重连
 * @callback onTempBroken
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0 表示无错误
 * @param {string} result.room_id - 房间id
 */

/**
 * 第二套房间与 server 连接中断通知，SDK会尝试自动重连
 * @callback onMultiRoomTempBroken
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0 表示无错误
 * @param {string} result.room_id - 房间id
 */

/**
 * 音视频引擎停止时回调
 * @callback onAVEngineStop
 */

/**
 * 音视频引擎启动时回调
 * @callback onAVEngineStart
 */

/**
 * 收到媒体次要信息时回调
 * @callback onRecvMediaSideInfo
 * @param {object} result - 结果数据对象
 * @param {string} result.stream_id - 流id
 * @param {string} result.side_info - 媒体次要信息内容
 */

/**
 * 本地预览截图回调
 * @callback onTakeSnapshotPreview
 * @param {object} result - 结果数据对象
 * @param {number} result.channel_index - 通道索引
 * @param {number} result.width - 图像宽
 * @param {number} result.height - 图像高
 * @param {string} result.image_data - 截图png图像的base64字符串；设置如下标签属性即可显示图像：img.setAttribute('src', "data:image/png;base64," + rs.image_data);
 */

/**
 * 拉流截图回调
 * @callback onTakeSnapshot
 * @param {object} result - 结果数据对象
 * @param {string} result.stream_id - 流id
 * @param {number} result.width - 图像宽
 * @param {number} result.height - 图像高
 * @param {string} result.image_data - 截图png图像的base64字符串；设置如下标签属性即可显示图像：img.setAttribute('src', "data:image/png;base64," + rs.image_data);
 */

/**
 * MediaPlayer开始播放
 * @callback onMediaPlayerPlayStart
 * @param {object} result - 结果数据对象
 * @param {number} result.player_index - 播放器索引
 */

/**
 * MediaPlayer播放出错
 * @callback onMediaPlayerPlayError
 * @param {object} result - 结果数据对象
 * @param {number} result.player_index - 播放器索引
 * @param {number} result.error_code - 0 - 没有错误， -1 - 文件格式不支持，-2 - 路径不存在，-3 - 文件无法解码， -4 - 文件中没有可播放的音视频流，-5 - 文件解析过程中出现错误
 *
 */

/**
 * MediaPlayer 视频开始播放
 * @callback onMediaPlayerVideoBegin
 * @param {object} result - 结果数据对象
 * @param {number} result.player_index - 播放器索引
 */

/**
 * MediaPlayer 音频开始播放
 * @callback onMediaPlayerAudioBegin
 * @param {object} result - 结果数据对象
 * @param {number} result.player_index - 播放器索引
 */


/**
 * MediaPlayer 播放结束
 * @callback onMediaPlayerPlayEnd
 * @param {object} result - 结果数据对象
 * @param {number} result.player_index - 播放器索引
 */

/**
 * MediaPlayer 快进到指定时刻
 * @callback onMediaPlayerSeekComplete
 * @param {object} result - 结果数据对象
 * @param {number} result.player_index - 播放器索引
 * @param {number} result.state - 状态 >=0 成功，其它表示失败
 * @param {number} result.duration - 实际快进的进度，单位毫秒
 */

/**
 * MediaPlayer 暂停播放
 * @callback onMediaPlayerPlayPause
 * @param {object} result - 结果数据对象
 * @param {number} result.player_index - 播放器索引
 */

/**
 * MediaPlayer 恢复播放
 * @callback onMediaPlayerPlayResume
 * @param {object} result - 结果数据对象
 * @param {number} result.player_index - 播放器索引
 */

/**
 * MediaPlayer 主动停止播放
 * @callback onMediaPlayerPlayStop
 * @param {object} result - 结果数据对象
 * @param {number} result.player_index - 播放器索引
 */

/**
 * MediaPlayer 开始缓冲
 * @callback onMediaPlayerBufferBegin
 * @param {object} result - 结果数据对象
 * @param {number} result.player_index - 播放器索引
 */

/**
 * MediaPlayer 结束缓冲
 * @callback onMediaPlayerBufferEnd
 * @param {object} result - 结果数据对象
 * @param {number} result.player_index - 播放器索引
 */

/**
 * MediaPlayer 调用 mediaPlayerLoad 接口加载完成的回调
 * @callback onMediaPlayerLoadComplete
 * @param {object} result - 结果数据对象
 * @param {number} result.player_index - 播放器索引
 */

/**
 * 混流回调接口
 * @callback onMixStreamEx
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 混流结果 ， 0 - 成功
 * @param {number} result.seq - 请求 seq，与mixStreamEx返回的结果一致，关联标识是哪次发起的混流任务的回调
 * @param {string} result.mix_stream_id - 混流任务id，标识唯一混流任务
 * @param {object|array} result.non_exists_stream_list - 不存在的输入流信息对象数组列表，流信息对象属性如下：
 * @param {string} result.non_exists_stream_list.stream_id - 不存在的流的流id
 * @param {object|array} result.output_stream_info_list - 混流输出对象数组列表，输出对象属性如下：
 * @param {string} result.output_stream_info_list.stream_id - 混流的流id
 * @param {string} result.output_stream_info_list.mix_stream_id - 混流任务id，标识一个混流任务
 * @param {string|array} result.output_stream_info_list.rtmp_url_list - RTMP 播放 URL 数组列表
 * @param {string|array} result.output_stream_info_list.flv_url_list - flv 播放 URL 数组列表
 * @param {string|array} result.output_stream_info_list.hls_url_list - hls 播放 URL 数组列表
 *
 */

/**
 * 混流中，音浪回调通知，显示发言者及音量大小的回调。每秒钟10次通知，不拉流没有通知
 * @callback onSoundLevelInMixedPlayStream
 * @param {object} result - 结果数据对象
 * @param {objct|array} result.volume_list - 音量数组对象列表，音量对象属性如下：
 * @param {number} result.volume_list.sound_level_id - 音浪id，对应混流输入流的音浪id
 * @param {number} result.volume_list.sound_level - 音浪值，标识音量的大小
 *
 */

/**
 * 渲染前的视频数据回调，可以在该回调中拿到视频RGBA数据并修改
 * @callback onVideoData
 * @param {object} result - 结果数据对象
 * @param {boolean} result.is_local_stream - 是否是本地采集的视频数据
 * @param {number} result.local_stream_channel - 当is_local_stream为true时有效，local_stream_channel 等于ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_MAIN 时是主通道视频数据，local_stream_channel 等于ZEGOCONSTANTS.PublishChannelIndex.PUBLISH_CHN_AUX 是辅通道数据
 * @param {boolean} result.is_media_player_stream - 是否是使用mediaplayer播放的视频数据
 * @param {number} result.player_index 当is_media_player_stream为true时有效，表示播放器索引，多实例播放器下区分哪个播放器播放的视频
 * @param {string} result.stream_id 流id，当is_local_stream、is_media_player_stream 都为false时生效，表示拉流的流id
 * @param {number} result.width 视频宽
 * @param {number} result.height 视频高
 * @param {byte | array} result.data 视频数据buffer，都为RGBA数据
 *
 */


/**
 * 第二套房间发送可靠业务消息的结果回调
 * @callback onSendMultiRoomReliableMessage
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0 表示无错误
 * @param {string} result.room_id - 房间 ID
 * @param {number} result.send_seq - 发送序号 seq
 * @param {string} result.msg_type - 消息类型
 * @param {number} result.latest_seq - 最新的消息 seq
 *
 */

/**
 * 收到可靠业务消息
 * @callback onRecvReliableMessage
 * @param {object} result - 结果数据对象
 * @param {string} result.room_id - 房间 ID
 * @param {string} result.msg_type - 消息类型
 * @param {number} result.latest_seq - 当前最新消息Seq
 * @param {string} result.msg_content - 消息内容
 * @param {string} result.user_id - 消息发送UserID
 * @param {string} result.user_name - 消息发送UserName
 * @param {number} result.send_time - 发送时间
 *
 */


/**
 * 第二套房间收到可靠业务消息
 * @callback onRecvMultiRoomReliableMessage
 * @param {object} result - 结果数据对象
 * @param {string} result.room_id - 房间 ID
 * @param {string} result.msg_type - 消息类型
 * @param {number} result.latest_seq - 当前最新消息Seq
 * @param {string} result.msg_content - 消息内容
 * @param {string} result.user_id - 消息发送UserID
 * @param {string} result.user_name - 消息发送UserName
 * @param {number} result.send_time - 发送时间
 *
 */



 /**
 * 房间发送业务消息回调
 * @callback OnSetMultiRoomExtraInfo
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0 表示无错误
 * @param {string} result.room_id - 房间 ID
 * @param {number} result.send_seq - 发送序号 seq
 * @param {string} result.pszKey - 消息key
 */

 /**
 * 收到业务消息
 * @callback OnMultiRoomExtraInfoUpdated
 * @param {object} result - 结果数据对象
 * @param {number} result.extra_info_count - 房间属性对象个数
 * @param {array} result.extra_info_list - 房间属性对象列表，每个房间属性对象的属性值如下：
 * @param {string} result.extra_info_list.key - 附加信息key
 * @param {string} result.extra_info_list.value - 附加信息值
 * @param {string} result.extra_info_list.user_id - 变更附加信息UserID
 * @param {string} result.extra_info_list.user_name - 变更附加信息UserName
 * @param {string} result.extra_info_list.update_time - 变更附加信息时间
 */




/**
 * 获取 soundLevel 更新的回调, 可以获取房间内所有流（非自己推的流）的 soundLevel 值
 * @callback onSoundLevelUpdate
 * @param {object} result - 结果数据对象
 * @param {string} result.stream_id - 流id
 * @param {number} result.sound_level - 音浪值
 *
 */

/**
 * 获取 captureSoundLevel 更新的回调
 * @callback onCaptureSoundLevelUpdate
 * @param {object} result - 结果数据对象
 * @param {string} result.stream_id - 流id
 * @param {number} result.sound_level - 房间内采集 soundLevel 值（自己推的流）
 *
 */


/**
 * 播放音效的回调
 * @callback onAudioPlayerPlayEffect
 * @param {object} result - 结果数据对象
 * @param {string} result.error_code - 0 成功，-1 失败
 * @param {number} result.sound_id - 音效 ID
 *
 */

/**
 * 播放音效完成的回调
 * @callback onAudioPlayerPlayEnd
 * @param {object} result - 结果数据对象
 * @param {string} result.error_code - 0 成功，-1 失败
 * @param {number} result.sound_id - 音效 ID
 *
 */


/**
 * 预加载音效的回调
 * @callback onAudioPlayerPreloadEffect
 * @param {object} result - 结果数据对象
 * @param {number} result.sound_id - 音效 ID
 *
 */

/**
 * 预加载音效完成的回调
 * @callback onAudioPlayerPreloadComplete
 * @param {object} result - 结果数据对象
 * @param {number} result.sound_id - 音效 ID
 *
 */

/**
 * 远端摄像头状态通知
 * @callback onRemoteCameraStatusUpdate
 * @param {object} result - 结果数据对象
 * @param {string} result.stream_id - 流id
 * @param {number} result.status - 0 - 设备已打开， 1 - 设备已关闭
 * @param {number} result.reason - 设备状态变化原因，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoDeviceErrorReason</a>
 *
 */


/**
 * 远端麦克风状态通知
 * @callback onRemoteMicStatusUpdate
 * @param {object} result - 结果数据对象
 * @param {string} result.stream_id - 流id
 * @param {number} result.status - 0 - 设备已打开， 1 - 设备已关闭
 * @param {number} result.reason - 设备状态变化原因，查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoDeviceErrorReason</a>
 *
 */

/**
 * 接收到远端音频的首帧通知
 * @callback onRecvRemoteAudioFirstFrame
 * @param {object} result - 结果数据对象
 * @param {number} result.stream_id - 流id
 *
 */

/**
 * 接收到远端视频的首帧通知
 * 当远端视频频的首帧到达后，会收到该 API 回调通知。
 * 从调用开始拉流接口到显示第一帧数据的过程中可能存在一个短暂的时间差（具体时长取决于当前的网络状态），推荐在进入直播页面时加载一张预览图以提升用户体验，然后在收到本回调后去掉预览图。
 * @callback onRecvRemoteVideoFirstFrame
 * @param {object} result - 结果数据对象
 * @param {number} result.stream_id - 流id
 *
 */

/**
 * 远端视频渲染首帧通知
 * 当开始要渲染远端的视频首帧时，会收到该 API 回调通知。
 * @callback onRenderRemoteVideoFirstFrame
 * @param {object} result - 结果数据对象
 * @param {number} result.stream_id - 流id
 *
 */

 /**
 * 文件上传 的回调
 * @callback onWhiteBoardUploadFile
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0为成功
 * @param {number} result.seq - 调用序号
 * @param {boolean} result.finish - 是否上传完成
 * @param {float} result.rate - 上传进度
 * @param {string} result.file_id - 文件ID
 * @param {string} result.url - 文件url
 * @param {string} result.hash - 文件hash
 *
 */

/**
 * 文件下载 的回调
 * @callback onWhiteBoardDownloadFile
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0为成功
 * @param {number} result.seq - 调用序号
 * @param {boolean} result.finish - 是否上传完成
 * @param {float} result.rate - 上传进度
 * @param {string} result.path - 文件本地地址
 *
 */

/**
 * 创建白板 的回调
 * @callback onWhiteBoardCreate
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0为成功
 * @param {number} result.seq - 调用序号
 * @param {number} result.whiteboard_model - 创建的白板模型，如失败则该值为空
 *
 */
/**
 * 有白板新增 的回调
 * @callback onWhiteBoardAdded
 * @param {object} result - 结果数据对象
 * @param {number} result.whiteboard_model - 新增的白板模型
 *
 */
/**
 * 销毁白板 的回调
 * @callback onWhiteBoardDestroy
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0为成功
 * @param {number} result.seq - 调用序号
 * @param {number} result.whiteboard_id - 被销毁的白板id
 *
 */
/**
 * 有白板被销毁 的通知
 * @callback onWhiteBoardRemoved
 * @param {object} result - 结果数据对象
 * @param {number} result.whiteboard_id - 被销毁的白板id
 *
 */
/**
 * 互动白板拉取结果 的回调
 * @callback onWhiteBoardGetList
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0为成功
 * @param {number} result.seq - 调用序号
 * @param {object | array} result.whiteboard_model_list - 白板模型对象数组，白板模型对象属性如下：
 * @param {number} result.whiteboard_model_list.whiteboard_model - 白板模型
 *
 */

/**
 * 图元 zOrder 发生变化 的回调
 * @callback onWhiteBoardCanvasItemZOrderChanged
 * @param {object} result - 结果数据对象
 * @param {number} result.whiteboard_id - 图元所在的白板id
 * @param {number} result.graphic_id - 要调整 zorder 的图元id
 * @param {number} result.zorder - 要调整的新 zorder 值
 *
 */
/**
 * 设置白板等比宽高 的回调
 * @callback onWhiteBoardSetAspectRatio
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0为成功
 * @param {number} result.seq - 调用序号
 * @param {number} result.width - 白板宽高比
 * @param {number} result.height - 白板宽高比
 * @param {number} result.whiteboard_id - 待修改的白板id
 *
 */
/**
 * 白板比例发生变化 的通知
 * @callback onWhiteBoardAspectRatioChanged
 * @param {object} result - 结果数据对象
 * @param {number} result.width - 白板宽高比
 * @param {number} result.height - 白板宽高比
 * @param {number} result.whiteboard_id -  宽高比发生变化的白板id
 *
 */

/**
 * 滑动、滚动白板画布 的回调
 * @callback onWhiteBoardScrollCanvas
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0为成功
 * @param {number} result.seq - 调用序号
 * @param {number} result.direction - 滚动、滑动方向,查看 <a href="./ZegoConstant.js.html" target="_blank">ZEGOCONSTANTS.ZegoWhiteboardCanvasScrollDirection</a>
 * @param {number} result.scroll_percent - 滚动的相对位置百分比
 * @param {number} result.whiteboard_id - 要滚动、滑动的白板id（关联画布）
 *
 */

/**
 * 所有图元加载结果 的回调
 * @callback onWhiteBoardCanvasLoad
 * @param {object} result - 结果数据对象
 * @param {number} result.error_code - 错误码，0为成功
 * @param {number} result.whiteboard_id - 白板id
 *
 */

/**
 * 白板画布发生滑动、滚动 的通知
 * @callback onWhiteBoardCanvasScrolled
 * @param {object} result - 结果数据对象
 * @param {number} result.horizontal_scroll_percent - 横向滚动的相对位置百分比（可以理解为滚动条Handle在滚动条Bar中的百分比）
 * @param {number} result.vertical_scroll_percent - 纵向滚动的相对位置百分比
 * @param {number} result.whiteboard_id - 滚动、滑动的白板id（关联画布）
 *
 */
/**
 * 图元有移动 的通知
 * @callback onWhiteBoardCanvasItemMoved
 * @param {object} result - 结果数据对象
 * @param {number} result.whiteboard_id - 白板id
 * @param {number} result.graphic_id - 图元id
 * @param {string} result.operator_id - 移动该图元的用户id
 * @param {string} result.operator_name - 移动该图元的用户昵称
 * @param {object} result.dest_pos - 要移动的左上角目标位置，目标位置属性如下：
 * @param {number} result.dest_pos.x - 左上角目标位置x坐标
 * @param {number} result.dest_pos.y - 左上角目标位置y坐标
 *
 */
/**
 * 图元被删除 的通知
 * @callback onWhiteBoardCanvasItemDeleted
 * @param {object} result - 结果数据对象
 * @param {number} result.whiteboard_id - 单个图元被删除的白板id
 * @param {number} result.graphic_id - 被删除的图元id
 * @param {string} result.operator_id - 删除该图元的用户id
 * @param {string} result.operator_name - 删除该图元的用户昵称
 *
 */
/**
 * path图元类型的数据发生变化的 通知
 * @callback onWhiteBoardCanvasPathUpdate
 * @param {object} result - 结果数据对象
 * @param {number} result.whiteboard_id - 图元被清除的白板id
 * @param {number} result.graphic_id - 涂鸦图元id
 * @param {number} result.graphic_properties - 图元属性信息，起始点\粗细\颜色\绘制人等
 * @param {object|array} result.points - 涂鸦线条上所有点的数组, 每个点对象属性如下：
 * @param {number} result.points.x - x 坐标
 * @param {number} result.points.y - y 坐标
 *
 */

/**
 * text图元类型的数据发生变化的 通知
 * @callback onWhiteBoardCanvasTextUpdate
 * @param {object} result - 结果数据对象
 * @param {number} result.whiteboard_id - 白板id
 * @param {number} result.graphic_id - 文本图元id
 * @param {number} result.graphic_properties - 图元属性信息，粗细\颜色\绘制人等
 * @param {string} result.text - 文本内容
 * @param {object} result.point_begin - 文本起始位置，起始点属性如下：
 * @param {number} result.point_begin.x - 起始点坐标x
 * @param {number} result.point_begin.y - 起始点坐标y
 *
 */
/**
 * line图元类型的数据发生变化的 通知
 * @callback onWhiteBoardCanvasLineUpdate
 * @param {object} result - 结果数据对象
 * @param {number} result.whiteboard_id - 白板id
 * @param {number} result.graphic_id - 线条图元id
 * @param {number} result.graphic_properties - 图元属性信息，起始点\粗细\颜色\绘制人等
 * @param {object} result.point_begin - 起始点，起始点属性如下：
 * @param {number} result.point_begin.x - 起始点坐标x
 * @param {number} result.point_begin.y - 起始点坐标y
 * @param {object} result.point_end - 结束点，结束点属性如下：
 * @param {number} result.point_end.x - 结束点坐标x
 * @param {number} result.point_end.y - 结束点坐标y
 */
/**
 * rect图元类型的数据发生变化的 通知
 * @callback onWhiteBoardCanvasRectUpdate
 * @param {object} result - 结果数据对象
 * @param {number} result.whiteboard_id - 白板id
 * @param {number} result.graphic_id - 矩形图元id
 * @param {number} result.graphic_properties - 图元属性信息，起始点\粗细\颜色\绘制人等
 * @param {object} result.point_begin - 起始点（左上角），起始点属性如下：
 * @param {number} result.point_begin.x - 起始点坐标x
 * @param {number} result.point_begin.y - 起始点坐标y
 * @param {object} result.point_end - 结束点（右下角），结束点属性如下：
 * @param {number} result.point_end.x - 结束点坐标x
 * @param {number} result.point_end.y - 结束点坐标y
 *
 */
/**
 * ellipse图元类型的数据发生变化的 通知
 * @callback onWhiteBoardCanvasEllipseUpdate
 * @param {object} result - 结果数据对象
 * @param {number} result.whiteboard_id - 白板id
 * @param {number} result.graphic_id - 园和椭圆的图元id
 * @param {number} result.graphic_properties - 图元属性信息，起始点\粗细\颜色\绘制人等
 * @param {object} result.point_begin - 起始点（左上角），起始点属性如下：
 * @param {number} result.point_begin.x - 起始点坐标x
 * @param {number} result.point_begin.y - 起始点坐标y
 * @param {object} result.point_end - 结束点（右下角），结束点属性如下：
 * @param {number} result.point_end.x - 结束点坐标x
 * @param {number} result.point_end.y - 结束点坐标y
 */

 /**
 * 激光笔图元类型的数据发生变化的 通知
 * @callback onWhiteBoardCanvasLaserUpdate
 * @param {object} result - 结果数据对象
 * @param {number} result.whiteboard_id - 白板id
 * @param {number} result.graphic_id - 图元id
 * @param {number} result.graphic_properties - 图元属性信息，起始点\粗细\颜色\绘制人等
 * @param {object} result.point - point点属性如下：
 * @param {number} result.point.x - 点坐标x
 * @param {number} result.point.y - 点坐标y
 * @param {number} result.pos_x - pos 点坐标x
 * @param {number} result.pos_y - pos 点坐标y
 */

 /**
 * 图片图元类型的发生变化的 通知
 * @callback onWhiteBoardCanvasImageUpdate
 * @param {object} result - 结果数据对象
 * @param {number} result.whiteboard_id - 白板id
 * @param {number} result.graphic_id - 图元id
 * @param {number} result.graphic_properties - 图元属性信息，起始点\粗细\颜色\绘制人等
 * @param {string} result.path - 图元路径
 * @param {object} result.point - point点属性如下：
 * @param {number} result.point.x - 点坐标x
 * @param {number} result.point.y - 点坐标y
 * @param {number} result.pos_x - pos 点坐标x
 * @param {number} result.pos_y - pos 点坐标y
 * @param {boolean} result.is_finished - 是否上传完成
 * @param {float} result.progress - 上传或者下载进度
 */


/**
 * 所有图元被清除 的通知
 * @callback onWhiteBoardCanvasClear
 * @param {object} result - 结果数据对象
 * @param {number} result.whiteboard_id - 图元被清除的白板id
 * @param {string} result.operator_id - 清除画布的用户id
 * @param {string} result.operator_name - 清除画布的用户昵称
 *
 */


/**
 * 设置白板扩展字段whiteboardAppendH5Extra的结果回调
 * @callback onWhiteBoardAppendH5ExtraCallback
 * @param {object} result - 结果数据对象
 * @param {number} result.whiteboard_id - 白板id
 * @param {number} result.seq - 调用序号
 * @param {number} result.error_code - 错误码
 *
 */


/**
 * 收到远端白板扩展字段内容发生变化的通知
 * @callback onWhiteBoardH5ExtraAppendedNotify
 * @param {object} result - 结果数据对象
 * @param {number} result.whiteboard_id - 白板id
 * @param {string} result.extra - 白板扩展字段内容
 *
 */


/**
 * 拉流的 频域功率谱 信息的回调。
 * @callback onFrequencySpectrumUpdate
 * @param {object} result - 结果数据对象
 * @param {objct|array} result.spectrum_info_list - 房间内所有流 （非自己推的流）的 频域功率谱 信息
 * @param {number} result.spectrum_info_list.stream_id - 流id
 * @param {objct|array} result.spectrum_info_list.spectrum_list - 频域功率谱 信息数组
 *
 */

/**
 * 采集的 频域功率谱 信息的回调。
 * @callback onCaptrueFrequencySpectrumUpdate
 * @param {object} result - 结果数据对象
 * @param {number} result.stream_id - 流id
 * @param {objct|array} result.spectrum_list - 频域功率谱 信息数组
 *
 */

 /**
 * 视频采集首帧回调
 * @callback onCaptureVideoFirstFrame
 */

/**
* 音频采集首帧回调
* @callback onCaptureAudioFirstFrame
*/


/**
* 采集窗口状态发生改变
* @callback OnCaptureWindowStatusChange
* @param {object} result - 结果数据对象
* @param {number} result.window_id - 窗口句柄
* @param {number} result.status_code - 窗口状态
* @param {number} result.left   窗口矩形大小
* @param {number} result.top
* @param {number} result.right
* @param {number} result.bottom
*/


/**
 * 屏幕采集窗口状态发生变化的回调。
 * @callback onScreenCapWindowStateChange
 * @param {number} status_code - 窗口状态：0：窗口无变化;1：窗口销毁;2：窗口最大化;3:窗口最小化;4:窗口激活;5 窗口失去激活;6 窗口显示;7 窗口隐藏;8 窗口移动;9 窗口被覆盖;10 覆盖窗口被移开
 * @param {number} result.handle - 窗口句柄
 * @param {number} result.left、result.top、result.right、result.bottom窗口大小
 */


/**
* 网络模块测试回调值
* @callback OnNetworkTrace
* @param {object} result - 结果数据对象
* @param {object} result.httpResult htttp测试结果对象
* @param {number} result.httpResult.code 探测是否成功。0成功 非0失败
* @param {number} result.httpResult.request_ms 探测消耗时间 单位ms
* @param {object} tcpResult tcp测试结果对象
* @param {number} result.tcpResult.code 探测是否成功。0成功 非0失败
* @param {number} result.tcpResult.connect_ms 探测链接消耗时间 单位ms
* @param {number} result.tcpResult.rtt 探测rtt
* @param {object} udpResult udp测试结果对象
* @param {number} result.udpResult.code 探测是否成功。0成功 非0失败
* @param {number} result.udpResult.rtt 探测rtt
* @param {object} tracerouteResult traceroute测试结果对象
* @param {number} result.tracerouteResult.code 探测是否成功。0成功 非0失败
* @param {number} result.tracerouteResult.time 消耗时间 单位ms
*/

/**
* 网络测速模块连通回调 探测连接和测速都会回调此值
* @callback onConnectResult
* @param {object} result - 结果数据对象
* @param {number} result.error_code 错误码 0 成功操作
* @param {number} result.net_connectcost
*/

/**
* 网络测速模块连通回调 探测连接和测速都会回调此值
* @callback onUpdateSpeed
* @param {object} result - 结果数据对象
* @param {number} result.net_connectcost
* @param {number} result.net_rtt rtt
* @param {number} result.net_pktlostrate 丢包率
* @param {number} result.net_quality  网络质量等级
* @param {number} result.probe_type   1  连通性测试 2  上行测速  3 下行测速
*/

/**
* 网络测速模块连通回调 探测连接和测速都会回调此值
* @callback onTestStop
* @param {object} result - 结果数据对象
* @param {number} result.error_code 错误码 0 成功操作
* @param {number} result.probe_type   1  连通性测试 2  上行测速  3 下行测速
*/

module.exports = exports = ZegoLiveRoom
