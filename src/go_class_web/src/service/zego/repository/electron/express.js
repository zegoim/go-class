import { firstUpperCase } from '@/utils/tool'
import { ElectronLiveInterface } from '@/service/zego/interface/live'

export default class extends ElectronLiveInterface {
  on(eventName, callback) {
    eventName = `on${firstUpperCase(eventName)}`
    eventName = this.shouldTranslateFuncName(eventName)
    console.warn('electron express on=', eventName)
    switch (eventName) {
      case 'onPublisherStateUpdate':
        this._client.on('onPublisherStateUpdate', res => {
          console.warn('electron express emit=', { eventName, res })
          const { errorCode, streamID, state } = res
          this.stream_publish_state = 'PUBLISHING'
          const params = {
            state: state == 2 && this.stream_publish_state,
            streamID,
            errorCode
          }
          callback && callback(params)
        })
        break
      case 'onRoomStreamUpdate':
        this._client.on('onRoomStreamUpdate', res => {
          let { roomID, updateType, streamList } = res
          updateType = updateType === 0 ? 'ADD' : 'DELETE'
          callback && callback(roomID, updateType, streamList)
        })
        break
      case 'onRoomUserUpdate':
        this._client.on('onRoomUserUpdate', res => {
          let { roomID, updateType, userList } = res
          updateType = updateType === 0 ? 'ADD' : 'DELETE'
          callback && callback(roomID, updateType, userList)
        })
        break
      case 'onRoomExtraInfoUpdate':
        this._client.on('onRoomExtraInfoUpdate', res => {
          const { roomID, roomExtraInfoList } = res
          const key = roomExtraInfoList[0]?.key
          const value = roomExtraInfoList[0]?.value
          callback && callback(roomID, key, value)
        })
        break
      case 'onRemoteCameraStateUpdate':
        this._client.on('onRemoteCameraStateUpdate', res => {
          let { streamID, state } = res
          state = state == 0 ? 'OPEN' : 'CLOSE'
          callback && callback(streamID, state)
        })
        break
      case 'onIMRecvCustomCommand':
        this._client.on('onIMRecvCustomCommand', res => {
          try {
            callback && callback(res)
          } catch (e) {
            console.error({ res })
            console.error('onIMRecvCustomCommand', e)
          }
        })
        break
      case 'onIMRecvBarrageMessage':
        this._client.on('onIMRecvBarrageMessage', res => {
          console.warn('onIMRecvBarrageMessage back', { res })
          try {
            const { roomID, messageList } = res || {}
            callback && callback(roomID, messageList)
          } catch (e) {
            console.error('onIMRecvBarrageMessage', e)
          }
        })
        break
      default:
        this._client.on(eventName, res => {
          const values = Object.values(res)
          console.warn('electron express emit=', { eventName, res, values })
          callback && callback(...values)
        })
    }
  }

  createStream(option = {}) {
    return new Promise(resolve => {
      console.log('electron_createStream:', { option })
      const { camera } = option
      if (camera) {
        // const defaultAudioDevice = this._client.getDefaultAudioDeviceId({device_type: 0}) // 0-输入｜1-输出
        // const defaultVideoDevice = this._client.getDefaultVideoDeviceId() // 0-输入｜1-输出
        // const enumVideoQuality = {
        //   1: {width: 320, height: 240, frame: 15, bitrate: 300},
        //   2: {width: 640, height: 480, frame: 15, bitrate: 800},
        //   3: {width: 1280, height: 720, frame: 20, bitrate: 1500},
        // }
        const {
          // facingMode,
          ANS = false,
          AGC = false,
          AEC = false
        } = camera
        this._client.enableANS(ANS)
        this._client.enableAGC(AGC)
        this._client.enableAEC(AEC)
        this._client.setAudioConfig(1)
        this._client.setVideoConfig(2)
        this.localStream = 'electron_mock_localStream'
        resolve({})
      }
    })
  }

  startPublishingStream(streamID) {
    this._client.startPublishingStream(streamID)
  }

  loginRoom(roomID, config = {}) {
    return new Promise(resolve => {
      const { isLogin } = this.context.getState('isLogin')
      if (isLogin) {
        console.warn('has login!!!')
      }
      // token 默认为空，表示不鉴权
      config = { isUserStatusNotify: true, maxMemberCount: 10, token: '', ...config }
      const { isMe, ...v } = this.context.state.user
      console.log(isMe)
      this._client.on('onRoomStateUpdate', res => {
        console.warn('onRoomStateUpdate', { res })
        if (res.state == 2 && res.errorCode == 0) {
          // 登录成功
          this.afterLoginRoom(roomID)
          resolve({
            error: false,
            streamList: []
          })
          console.log('登录房间成功！')
        } else {
          // resolve({
          //   error: true,
          //   msg: '登录房间出错！',
          // })
        }
      })
      console.warn({ roomID, v, config })
      console.log(this._client.loginRoom)
      try {
        v.userID = v.userID.toString()
        this._client.loginRoom(roomID, v, config)
      } catch (e) {
        console.error('loginRoom', e)
      }
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
    const view = { canvas: $canvas }
    this._client.startPlayingStream(streamID, view, playOption)
  }

  startPreview(streamID, element) {
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
    const view = {
      canvas: $canvas
    }
    this._client.startPreview(view)
  }

  mutePublishStreamAudio(mute) {
    this._client.mutePublishStreamAudio(mute)
  }

  mutePublishStreamVideo(mute) {
    this._client.mutePublishStreamVideo(mute)
    this._client.enableCamera(!mute)
  }

  enumDevices() {
    const microphones = this._client.getAudioDeviceList(0)
    const speakers = this._client.getAudioDeviceList(1)
    const cameras = this._client.getVideoDeviceList()
    const deviceInfo = {
      microphones: [].concat(microphones.map(item => ({ deviceID: item.deviceID, deviceName: item.deviceName }))),
      speakers: [].concat(speakers.map(item => ({ deviceID: item.deviceID, deviceName: item.deviceName }))),
      cameras: [].concat(cameras.map(item => ({ deviceID: item.deviceID, deviceName: item.deviceName })))
    }
    return Promise.resolve(deviceInfo)
  }

  useVideoDevice(value) {
    this._client.setVideoDevice(value)
  }

  useAudioDevice(value) {
    this._client.setAudioDevice(value)
  }

  stopPlayingStream(streamID) {
    this._client.stopPlayingStream(streamID)
    return Promise.resolve(true)
  }

  // eslint-disable-next-line no-unused-vars
  stopPublishingStream(streamID) {
    this.localStream = null
    this._client.stopPublishingStream()
  }

  async setRoomExtraInfo(key, value) {
    console.log('electron_setRoomExtraInfo', { roomID: this.room_id, key, value })
    const res = await this._client.setRoomExtraInfo(this.room_id, key, value)
    console.warn('setRoomExtraInfo res=', res)
    return res
  }

  loseCanvasContext() {} // none

  enableSpeaker({ enable }) {
    this._client.muteSpeaker(!enable)
  }

  stopPreview() {
    this._client.stopPreview()
  }

  logoutRoom(roomId) {
    this._client.logoutRoom(roomId)
  }

  sendBarrageMessage(message) {
    return this._client.sendBarrageMessage(this.room_id, message)
  }

  // 对照 - start

  /**
   * @return { object } result
   * @return { string } result.roomID
   * @return { ZegoUpdateType } result.updateType
   * @return { ZegoUser[] } result.userList
   */
  onRoomUserUpdate() {}

  /**
   * @return { object } result
   * @return { string } result.roomID
   * @return { ZegoUpdateType } result.updateType
   * @return { ZegoStream[] } result.streamList
   */
  onRoomStreamUpdate() {}

  /**
   * @return { object } result
   * @return { string } result.streamID
   * @return { ZegoRemoteDeviceState } result.state
   */
  onRemoteCameraStateUpdate() {}

  /**
   * @return { object } result
   * @return { string } result.streamID
   * @return { ZegoPublisherState } result.state
   * @return { number } result.errorCode
   * @return { string } result.extendedData
   */
  onPublisherStateUpdate() {}

  /**
   * @return { object } result
   * @return { string } result.roomID
   * @return { ZegoRoomExtraInfo[] } result.roomExtraInfoList
   */
  onRoomExtraInfoUpdate() {}

  /**
   * @return { object } result
   * @return { string } result.roomID
   * @return { ZegoRoomState[] } result.state
   * @return { number } result.errorCode
   * @return { string } result.extendedData
   */
  onRoomStateUpdate() {}

  // 对照 - end
}
