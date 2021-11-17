import { ElectronLiveInterface } from '@/service/zego/interface/live'

export default class extends ElectronLiveInterface {
  /**
   * 抹平回调接口
   * @param {事件名称} eventName
   * @param {回调方法} callback
   * @returns {*}
   */
  on(eventName, callback) {
    switch (eventName) {
      case 'roomUserUpdate':
        this._client.onEventHandler('onUserUpdate', res => {
          const { update_type, users } = res // update_type -> 1-全量更新 2-增量更新
          // tips: update_type无论全量更新还是增量更新都会在业务层去重，所以无需关心此参数
          console.log('roomUserUpdate', { update_type })
          const isAdd = flag => flag === 1
          const isDel = flag => flag === 2
          const formatUser = list => [].concat(list.map(item => ({ userID: item.user_id, userName: item.user_name })))
          const addUser = users.filter(user => isAdd(user.update_flag))
          const delUser = users.filter(user => isDel(user.update_flag))
          this.roomUserList = [...this.roomUserList, addUser]
          this.roomUserList = this.roomUserList.filter(user => delUser.some(u => u.user_id === user.user_id))
          callback && callback(this.room_id, 'ADD', formatUser(addUser))
          callback && callback(this.room_id, 'DELETE', formatUser(delUser))
        })
        break
      case 'roomStreamUpdate':
        this._client.onEventHandler('onStreamUpdated', res => {
          const { room_id, stream_update_type, stream_list } = res
          console.log('roomStreamUpdate', { res })
          const streamList = [].concat(
            stream_list.map(stream => ({
              streamID: stream.stream_id,
              extraInfo: stream.extra_info,
              user: {
                userID: stream.user_id,
                userName: stream.user_name
              }
            }))
          )
          const args = [room_id, stream_update_type == 2001 ? 'ADD' : 'DELETE', streamList]
          callback && callback(...args)
        })
        break
      case 'remoteCameraStatusUpdate':
        this._client.onEventHandler('onRemoteCameraStatusUpdate', res => {
          console.log('onRemoteCameraStatusUpdate', { res })
          const { stream_id, status } = res
          const args = [stream_id, status == 0 ? 'OPEN' : 'MUTE']
          callback && callback(...args)
        })
        break
      case 'remoteMicStatusUpdate':
        this._client.onEventHandler('onRemoteMicStatusUpdate', res => {
          console.log('onRemoteMicStatusUpdate', { res })
          const { stream_id, status } = res
          const args = [stream_id, status == 0 ? 'OPEN' : 'MUTE']
          callback && callback(...args)
        })
        break
      case 'publisherStateUpdate':
        this._client.onEventHandler('onPublishStateUpdate', res => {
          console.log('electron_publisherStateUpdate', { res })
          const { error_code, stream_id } = res
          this.stream_publish_state = 'PUBLISHING'
          const params = {
            state: this.stream_publish_state,
            streamID: stream_id,
            errorCode: error_code
          }
          callback && callback(params)
        })
        break
      case 'roomExtraInfoUpdate':
        // 通过自定义消息构造
        console.warn('liveroom express roomExtraInfoUpdate')
        this._client.onEventHandler('onSetRoomExtraInfo', res => {
          console.log('onSetRoomExtraInfo', { res })
        })
        this._client.onEventHandler('onRoomExtraInfoUpdated', res => {
          console.log('onRoomExtraInfoUpdated', { res })
          const { key, value } = res.extra_info_list[0] || {}
          if (key || value) {
            callback && callback(this.room_id, key, value)
          }
        })
        break
      case 'roomStateUpdate':
        // eslint-disable-next-line no-case-declarations
        this._client.onEventHandler('onDisconnect', res => {
          console.warn('onDisconnect', { res })
        })
        this._client.onEventHandler('onReconnect', res => {
          console.warn('onReconnect', { res })
        })
        this._client.onEventHandler('onTempBroken', res => {
          console.warn('onTempBroken', { res })
        })
        break
      case 'iMRecvCustomCommand':
        this._client.onEventHandler('onRecvCustomCommand', res => {
          const { content, user_id, user_name, room_id } = res
          const data = {
            roomID: room_id,
            fromUser: {
              userID: user_id,
              userName: user_name
            },
            command: content
          }
          res.command = res.content
          callback && callback(data)
        })
        break
      case 'IMRecvBarrageMessage':
        this._client.onEventHandler('onRecvBigRoomMessage', res => {
          console.warn('onRecvBigRoomMessage', { res })
          const { room_id, msg_list } = res
          if (this.room_id == room_id) {
            const { user_id, user_name, msg_type, msg_id } = msg_list[0]
            const data = {
              roomID: room_id,
              fromUser: {
                userID: user_id,
                userName: user_name
              },
              message: msg_type,
              messageID: msg_id
            }
            const chatData = [data]
            console.warn({ chatData })
            callback && callback(room_id, chatData)
          }
        })
        break
    }
  }

  async createStream(option = {}) {
    return new Promise(resolve => {
      // TODO: screen, custom
      console.log('electron_createStream:', { option })
      const { camera } = option
      if (camera) {
        const defaultAudioDevice = this._client.getDefaultAudioDeviceId({ device_type: 0 }) // 0-输入｜1-输出
        const defaultVideoDevice = this._client.getDefaultVideoDeviceId() // 0-输入｜1-输出
        const enumVideoQuality = {
          1: { width: 320, height: 240, frame: 15, bitrate: 300 },
          2: { width: 640, height: 480, frame: 15, bitrate: 800 },
          3: { width: 1280, height: 720, frame: 20, bitrate: 1500 }
        }
        const {
          // audio,
          audioInput = defaultAudioDevice,
          audioBitrate = 48,
          // video,
          videoInput = defaultVideoDevice,
          videoQuality = 2,
          // facingMode,
          channelCount = 1, // 1-单声道｜2-双声道
          ANS = false,
          AGC = false,
          AEC = false,
          width = 320,
          height = 240,
          bitRate = 300,
          frame = 15
        } = camera
        let quality = enumVideoQuality[videoQuality] | {}
        // const isMuteAudioPublishSucc = this._client.muteAudioPublish({ is_mute: audio, channel_index: 0 })
        // console.log({ isMuteAudioPublishSucc: isMuteAudioPublishSucc === 0 })
        //
        // const isMuteVideoPublishSucc = this._client.muteVideoPublish({ is_mute: video, channel_index: 0 })
        // console.log({ isMuteVideoPublishSucc: isMuteVideoPublishSucc === 0 })

        this._client.setAudioDevice({ device_type: 0, device_id: audioInput })
        this._client.setVideoDevice({ device_id: videoInput })
        this._client.setAudioBitrate({ bitrate: audioBitrate })
        this._client.setAudioChannelCount({ channelCount })
        this._client.enableANS({ enable: ANS })
        this._client.enableAGC({ enable: AGC })
        this._client.enableAEC({ enable: AEC })
        this._client.setVideoEncodeResolution({
          width: videoQuality == 4 ? width : quality.width,
          height: videoQuality == 4 ? height : quality.height
        })
        this._client.setVideoFPS({ fps: videoQuality == 4 ? frame : quality.frame })
        this._client.setVideoBitrate({ bitrate: videoQuality == 4 ? bitRate : quality.bitRate })
        this.localStream = 'electron_mock_localStream'
        resolve({})
      }
    })
  }

  startPublishingStream(streamID, publishOption) {
    publishOption = JSON.stringify(publishOption)
    console.log('electron_startPublishingStream', { streamID, publishOption })
    this.stream_publish_state = 'PUBLISH_REQUESTING'
    const isStartPublishing = this._client.startPublishing({
      title: '',
      publish_flag: 2,
      stream_id: streamID,
      params: publishOption
    })
    console.log('electron_startPublishingStream:', { isStartPublishing })
  }

  loginRoom(roomID = null, config = {}) {
    // config
    roomID = roomID || `room_id_${new Date().getTime()}`
    this.room_id = roomID
    const {
      user: { userID, userName }
    } = this.context.state
    console.log('electron_loginRoom', { userID })
    const { userUpdate, maxMemberCount } = config
    console.log({ userUpdate, maxMemberCount })
    this._client.setUser({
      user_id: userID,
      user_name: userName
    })
    return new Promise(resolve => {
      const res = this._client.loginRoom(
        {
          room_id: roomID,
          room_name: roomID,
          role: 2
        },
        rs => {
          if (rs.error_code === 0) {
            this.afterLoginRoom(roomID)
            const { stream_list } = rs
            const streamList = [].concat(
              stream_list.map(stream => ({
                streamID: stream.stream_id,
                extraInfo: stream.extra_info,
                isVideoOpen: stream.extra_info && JSON.parse(stream.extra_info)?.isVideoOpen,
                user: {
                  userID: stream.user_id,
                  userName: stream.user_name
                }
              }))
            )
            resolve({
              error: false,
              streamList
            })
          } else {
            resolve({
              error: true,
              msg: '登录房间出错！'
            })
          }
          console.warn('登录结果返回', rs)
        }
      )
      console.log('electron_loginRoom 登录是否成功', { res })
    })
  }

  startPlayingStream(streamID, playOption = {}, element) {
    console.log('electron_startPlayingStream', { streamID, playOption, element })
    if (!element?.appendChild) {
      console.warn('element不是dom元素！')
      return
    }
    let $canvas = document.getElementById(streamID)
    if (!$canvas) {
      $canvas = document.createElement('canvas')
      element.style.position = 'relative'
      $canvas.style.width = '100%'
      $canvas.style.height = '100%'
      $canvas.style.position = 'absolute'
      $canvas.style.top = 0
      $canvas.style.left = 0
      $canvas.setAttribute('id', streamID)
      element.appendChild($canvas)
    }
    this._client.startPlayingStream({
      stream_id: streamID,
      canvas_view: $canvas,
      params: playOption
    })
  }

  mutePublishStreamAudio(mute) {
    console.log('electron_mutePublishStreamAudio', { mute })
    const res = this._client.muteAudioPublish({ is_mute: mute })
    return !res
  }

  mutePublishStreamVideo(mute) {
    console.log('electron_mutePublishStreamVideo', { mute })
    const res = this._client.muteVideoPublish({ is_mute: mute })
    this._client.enableCamera({
      enable: !mute,
      channel_index: 0
    })
    console.log('set mutePublishStreamVideo res=', res)
    return !res
  }

  enumDevices() {
    const microphones = this._client.getAudioDeviceList(0)
    const speakers = this._client.getAudioDeviceList(1)
    const cameras = this._client.getVideoDeviceList()
    const deviceInfo = {
      microphones: [].concat(microphones.map(item => ({ deviceID: item.device_id, deviceName: item.device_name }))),
      speakers: [].concat(speakers.map(item => ({ deviceID: item.device_id, deviceName: item.device_name }))),
      cameras: [].concat(cameras.map(item => ({ deviceID: item.device_id, deviceName: item.device_name })))
    }
    return Promise.resolve(deviceInfo)
  }

  useVideoDevice(value) {
    this._client.setVideoDevice({ device_id: value })
  }

  useAudioDevice(value) {
    this._client.setAudioDevice({ device_type: 0, device_id: value })
  }

  stopPlayingStream(streamID) {
    console.warn('electron_stopPlayingStream', { streamID })
    this._client.stopPlayingStream({ stream_id: streamID })
  }

  async stopPublishingStream() {
    if (!this.localStream) return
    console.log('electron_stopPublishingStream')
    this.localStream = null
    this._client.stopPublishing({})
  }

  setDebugVerbose() {}

  setRoomExtraInfo(key, value) {
    return new Promise(resolve => {
      console.log('electron_setRoomExtraInfo', { key, value })
      this._client.onEventHandler('onSetRoomExtraInfo', res => {
        resolve(res)
      })
      this._client.setRoomExtraInfo({
        msg_key: key,
        msg_value: value
      })
    })
  }

  loseCanvasContext({ canvas }, cb = null) {
    console.log('electron_loseCanvasContext', { canvas })
    this._client.loseCanvasContext({ canvas }, cb)
  }

  enableSpeaker({ enable }) {
    this._client.enableSpeaker({ enable })
  }

  startPreview(streamID, $ele) {
    const $canvas = document.createElement('canvas')
    $ele.style.position = 'relative'
    $canvas.style.width = '100%'
    $canvas.style.height = '100%'
    $canvas.style.position = 'absolute'
    $canvas.style.top = 0
    $canvas.style.left = 0
    $canvas.setAttribute('id', streamID)
    $ele.appendChild($canvas)
    const channel_index = 0
    this._client.setVideoMirrorMode({
      mode: 2
    })
    const res_spv = this._client.setPreviewView({
      canvas_view: $canvas,
      channel_index
    })
    const res_sp = this._client.startPreview({
      channel_index
    })
    console.log({ res_sp, res_spv })
    console.warn(`预览${res_spv && res_sp ? '成功' : '失败'}！`)
  }

  stopPreview() {
    const res = this._client.stopPreview({
      channel_index: 0
    })
    console.warn(`停止预览${res ? '成功' : '失败'}！`)
  }

  logoutRoom() {
    this._client.logoutRoom(() => {})
  }

  sendBarrageMessage(message) {
    // return this._client.sendBigRoomMessage(this.room_id, message)
    return new Promise(resolve => {
      this._client.onEventHandler('onSendBigRoomMessage', res => {
        const { error_code, room_id, msg_id } = res
        const v = {
          errorCode: error_code,
          roomId: room_id,
          messageID: msg_id
        }
        resolve(v)
      })
      this._client.sendBigRoomMessage({
        msg_type: 1,
        msg_category: 1,
        msg_content: message
      })
    })
  }
}
