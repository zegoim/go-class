import { isSafariBrowser } from '@/utils/browser'
// import eventEmitter from '../eventEmitter'

export class LiveHelper {
  _client = null
  constructor({ context, client }) {
    this.context = context
    this._client = client
    this.room_id = null
    this.roomUserList = []
    this.localStream = null
    // this.EventEmitter = new eventEmitter()
    this.stream_publish_state = 'NO_PUBLISH' // NO_PUBLISH-未推流状态｜PUBLISH_REQUESTING-正在请求推流状态｜PUBLISHING-正在推流状态
    this.isCreatingStream = false
    // this.proxy()
  }

  /**
   * 监听事件
   */
  on(eventName, callback) {
    console.log('监听事件: ', eventName)
    this._client && this._client.on(eventName, callback)
  }

  getProxyFunc() {
    return [
      'createStream',
      'startPreview',
      'startPublishingStream',
      'startPlayingStream',
      'mutePublishStreamAudio',
      'mutePublishStreamVideo',
      'loginRoom',
      'enumDevices',
      'useVideoDevice',
      'useAudioDevice',
      'stopPlayingStream',
      'stopPublishingStream',
      'setRoomExtraInfo',
      'sendBarrageMessage'
    ]
  }

  /**
   * 通用调底层方法, 抹平请求接口差异
   * @param {方法名称} methodName
   * @param {参数} args
   * @returns {*}
   */
  express(methodName = '', ...args) {
    const proxyFunc = this.getProxyFunc()
    if (proxyFunc.some(func => func === methodName)) {
      console.warn('express methods: ', methodName, ', args:', args)
      return this[methodName](...args)
    } else {
      console.warn('不存在该方法, methodName=', methodName)
    }
  }

  async loginRoom(roomID = '', config = {}) {
    const { isLogin } = this.context.getState('isLogin')
    if (isLogin) {
      console.warn('has login!!!')
    }
    const { token1 } = this.context.state.tokenInfo
    config = { userUpdate: true, maxMemberCount: 10, ...config }
    const { userID, userName } = this.context.state.user
    let res
    try {
      const args = [roomID, token1, { userID, userName }, config]
      console.log('loginRoom', { args })
      res = await this._client.loginRoom(...args)
      console.log({ res })
      if (res) {
        console.warn('loginRoom is success!!')
        this.afterLoginRoom(roomID)
      }
      res = {
        error: false
      }
      this.context.setState({ tokenInfo: {} })
    } catch (e) {
      console.log('login error', { e })
      this.context.setState({ tokenInfo: {} })
      res = {
        error: true,
        msg: e.msg,
        code: e.code
      }
    }
    return res
  }

  afterLoginRoom(roomId) {
    this.room_id = roomId
    this.roomUserList.push(this.context.state.user)
    this.context.setState({
      isLogin: true,
      room_id: roomId
    })
  }

  async createStream(option) {
    if (this.isCreatingStream) return
    this.isCreatingStream = true
    if (isSafariBrowser) {
      this.localStream = await this._client.createStream()
    } else {
      try {
        this.localStream = await this._client.createStream(option)
      } catch (e) {
        this.localStream = await this._client.createStream()
      }
    }
  }

  startPublishingStream(streamID, publishOption) {
    if (!this.localStream) {
      console.warn('this.localStream is not exist！!')
      return
    }
    return this._client.startPublishingStream(streamID, this.localStream, publishOption)
  }

  startPreview(streamID, element) {
    console.warn('startPreview')
    let $video = document.getElementById(streamID)
    this.removeElementVideo(element)
    if (!$video) {
      $video = document.createElement('video')
      $video.setAttribute('autoplay', true)
      $video.setAttribute('muted', true)
      $video.setAttribute('id', streamID)
      element.appendChild($video)
    }
    $video.srcObject = this.localStream
  }

  // 重写startPlayingStream
  async startPlayingStream(streamID, playOption = {}, element) {
    const stream = await this._client.startPlayingStream(streamID, playOption)
    let $video = document.getElementById(streamID)
    this.removeElementVideo(element)
    if (!$video) {
      $video = document.createElement('video')
      $video.setAttribute('autoplay', true)
      $video.setAttribute('muted', true)
      $video.setAttribute('id', streamID)
      $video.style.position = 'absolute'
      $video.style.left = 0
      $video.style.top = 0
      element.appendChild($video)
    }
    $video.srcObject = stream
  }

  removeElementVideo(element) {
    if (element?.removeChild) {
      let $videos = element.getElementsByTagName('video')
      if ($videos.length) {
        for (let i = 0; i < $videos.length; i++) {
          element.removeChild($videos[i])
        }
      }
      $videos = null
    }
  }

  mutePublishStreamAudio(mute) {
    return this._client.mutePublishStreamAudio(this.localStream, mute)
  }

  mutePublishStreamVideo(mute) {
    console.warn('mutePublishStreamVideo', this.localStream, mute)
    return this._client.mutePublishStreamVideo(this.localStream, mute)
  }

  async enumDevices() {
    return await this._client.enumDevices()
  }

  async useVideoDevice(value) {
    return await this._client.useVideoDevice(this.localStream, value)
  }

  async useAudioDevice(value) {
    return await this._client.useAudioDevice(this.localStream, value)
  }

  stopPlayingStream(streamID) {
    this._client.stopPlayingStream(streamID)
  }

  stopPublishingStream(streamID) {
    this._client.stopPublishingStream(streamID)
    this.destroyStream()
    return Promise.resolve(true)
  }

  destroyStream() {
    this._client.destroyStream(this.localStream)
    this.localStream = null
    this.isCreatingStream = false
  }

  setRoomExtraInfo(key, value) {
    this._client.setRoomExtraInfo(this.room_id, key, value)
  }

  async sendBarrageMessage(message) {
    return await this._client.sendBarrageMessage(this.room_id, message)
  }
}
