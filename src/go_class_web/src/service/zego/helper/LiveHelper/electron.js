import { LiveHelper } from './base'

export class ElectronLiveHelper extends LiveHelper {
  /**
   * 监听事件
   */
  on(eventName, callback) {
    console.log('监听事件: ', eventName)
    this._client && this._on(eventName, callback)
  }

  /**
   * 抹平回调接口
   * @param {事件名称} eventName
   * @param {回调方法} callback
   * @returns {*}
   */
  _on(eventName, callback) {
    switch (eventName) {
      case 'roomUserUpdate':
        this._client.onEventHandler('onUserUpdate', res => {
          const { update_type, update_flag, users } = res // update_type -> 1-全量更新 2-增量更新
          console.log('onUserUpdate', { update_type, update_flag, users })
          if (update_type == 1) {
            this.roomUserList.length = 0
            this.roomUserList.push(...users)
          }
          if (update_type == 2) {
            if (update_flag == 1) {
              this.roomUserList.push(...users)
              return
            }
            this.roomUserList = this.roomUserList.filter(
              user => !users.some(u => u.user_id == user.user_id)
            )
          }
          const _users = [].concat(
            this.roomUserList.map(item => ({ userID: item.user_id, userName: item.user_name }))
          )
          callback && callback(this.room_id, update_flag == 1 ? 'ADD' : 'DELETE', _users)
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

      case 'publisherStateUpdate':
        this._client.onEventHandler('onPublishStateUpdate', res => {
          console.log('publisherStateUpdate', { res })
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
        this._client.onEventHandler('onRecvCustomCommand', res => {
          console.log('roomExtraInfoUpdate', { res })
          const { room_id, content } = res
          const { key, value, methodName } = JSON.parse(content)
          if (methodName !== 'roomExtraInfoUpdate') return
          if (this.room_id !== room_id) return
          callback && callback(room_id, key, value)
        })
        this._client.onEventHandler('onCustomCommand', res => {
          console.log('onCustomCommand', { res })
        })
        break
      case 'roomStateUpdate':
        // eslint-disable-next-line no-case-declarations
        const isOnDisconnect = this._client.onEventHandler('onDisconnect', res => {
          console.warn('onDisconnect', { res })
        })
        console.log({ isOnDisconnect })
        this._client.onEventHandler('onReconnect', res => {
          console.warn('onReconnect', { res })
        })
        this._client.onEventHandler('onTempBroken', res => {
          console.warn('onTempBroken', { res })
        })
    }
  }

  async createStream(option = {}) {
    return new Promise(resolve => {
      // TODO: screen, custom
      console.log('createStream:', { option })
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
          audio = true,
          audioInput = defaultAudioDevice,
          audioBitrate = 48,
          video = false,
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
        const isMuteAudioPublishSucc = this._client.muteAudioPublish({ is_mute: audio })
        console.log({ isMuteAudioPublishSucc: isMuteAudioPublishSucc === 0 })

        const isMuteVideoPublishSucc = this._client.muteVideoPublish({ is_mute: video })
        console.log({ isMuteVideoPublishSucc: isMuteVideoPublishSucc === 0 })

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
        this.localStream = 'mock_localStream'
        resolve({})
      }
    })
  }

  startPublishingStream(streamID, publishOption) {
    console.log('startPublishingStream', { streamID, publishOption })
    this.stream_publish_state = 'PUBLISH_REQUESTING'
    const isStartPublishing = this._client.startPublishing({
      title: '',
      publish_flag: 2,
      stream_id: streamID,
      params: publishOption
    })
    console.log('startPublishingStream:', { isStartPublishing })
  }

  loginRoom(roomID = null, config = {}) {
    // config
    roomID = roomID || `room_id_${new Date().getTime()}`
    this.room_id = roomID
    const {
      user: { userID, userName }
    } = this.context.state
    console.log('loginRoom', { userID })
    const { userUpdate, maxMemberCount } = config
    console.log({ userUpdate, maxMemberCount })
    // this._client.setCustomToken({ third_party_token: token })
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
            const user = { userID, userName }
            this.afterLoginRoom(user, roomID)
            resolve({
              error: false
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
      console.log('loginRoom result', { res })
    })
  }

  startPlayingStream(streamID, playOption = {}, element) {
    console.log('startPlayingStream', { streamID, playOption, element })
    if (!element || !(element && element.appendChild)) {
      console.warn('element不是dom元素！')
      return
    }
    const $canvas = document.createElement('canvas')
    element.style.position = 'relative'
    $canvas.style.width = '100%'
    $canvas.style.height = '100%'
    $canvas.style.position = 'absolute'
    $canvas.style.top = 0
    $canvas.style.left = 0
    $canvas.setAttribute('id', streamID)
    element.appendChild($canvas)
    console.log({ $canvas })
    this._client.startPlayingStream({
      stream_id: streamID,
      canvas_view: $canvas,
      params: playOption
    })
  }

  mutePublishStreamAudio(mute) {
    console.log('mutePublishStreamAudio', { mute })
    const res = this._client.muteAudioPublish({ is_mute: mute })
    return !res
  }

  mutePublishStreamVideo(mute) {
    console.log('mutePublishStreamVideo', { mute })
    const res = this._client.muteVideoPublish({ is_mute: mute })
    return !res
  }

  enumDevices() {
    const microphones = this._client.getAudioDeviceList(0)
    const speakers = this._client.getAudioDeviceList(1)
    const cameras = this._client.getVideoDeviceList()
    const deviceInfo = {
      microphones: [].concat(
        microphones.map(item => ({ deviceID: item.device_id, deviceName: item.device_name }))
      ),
      speakers: [].concat(
        speakers.map(item => ({ deviceID: item.device_id, deviceName: item.device_name }))
      ),
      cameras: [].concat(
        cameras.map(item => ({ deviceID: item.device_id, deviceName: item.device_name }))
      )
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
    this._client.stopPlayingStream({ stream_id: streamID })
  }

  async stopPublishingStream() {
    console.log('stopPublishingStream')
    this.localStream = null
    return await this._client.stopPublishing({})
  }

  setDebugVerbose() {}

  setRoomExtraInfo(key, value) {
    console.log('setRoomExtraInfo', { key, value })
    console.log('this.roomUserList', this.roomUserList)
    const member_list = []
    this.roomUserList.map(user => {
      member_list.push({
        user_id: user.userID,
        user_name: user.userName
      })
    })
    const msg_content = JSON.stringify({ key, value, methodName: 'roomExtraInfoUpdate' })
    console.log({ member_list, msg_content })
    this._client.sendCustomCommand({
      member_list,
      msg_content
    })
  }
}
