import { isElectron } from '@/utils/tool'
import ExpressWeb from '../repository/web/express'
import LiveRoomEl from '../repository/electron/liveRoom'
import ExpressEl from '../repository/electron/express'

export class LiveHelper {
  _client = null
  constructor({ context, client }) {
    this.context = context
    this._client = client
    this.room_id = null
    this.instance = null
    this.roomUserList = []
    this.localStream = null
    this._isElectron = isElectron()
    this.stream_publish_state = 'NO_PUBLISH' // NO_PUBLISH-未推流状态｜PUBLISH_REQUESTING-正在请求推流状态｜PUBLISHING-正在推流状态
    this.isCreatingStream = false
    this.initInstance()
  }

  initInstance() {
    if (!this._isElectron) {
      this.instance = new ExpressWeb()
      return
    }
    if (this.context.electronSdk === 'liveRoom') {
      this.instance = new LiveRoomEl()
      return
    }
    this.instance = new ExpressEl()
  }

  /**
   * 监听事件
   */
  on(eventName, callback) {
    console.log('监听事件: ', eventName)
    this._client && this.instance.on.call(this, eventName, callback)
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
      'enableSpeaker',
      'stopPlayingStream',
      'stopPublishingStream',
      'setRoomExtraInfo',
      'startPreview',
      'stopPreview',
      'loseCanvasContext',
      'logoutRoom'
    ]
  }

  /**
   * 通用调底层方法, 抹平请求接口差异
   * @param {string} methodName
   * @param {参数} args
   * @returns {*}
   */
  express(methodName = '', ...args) {
    const proxyFunc = this.getProxyFunc()
    if (proxyFunc.some(func => func === methodName)) {
      console.warn('方法被转发, methods: ', methodName, ', args:', args)
      return this.instance[methodName].apply(this, args)
    } else {
      console.warn('不存在该方法, methodName=', methodName)
    }
  }

  afterLoginRoom(roomId) {
    this.room_id = roomId
    this.roomUserList.push(this.context.state.user)
    this.context.setState({
      isLogin: true,
      room_id: roomId
    })
  }

  shouldTranslateFuncName(eventName) {
    const v = {
      onRemoteCameraStatusUpdate: 'onRemoteCameraStateUpdate'
    }
    return v[eventName] || eventName
  }
}
