import { storage } from '@/utils/tool'
import { isSafariBrowser } from '@/utils/browser'
import { WebLiveInterface } from '@/service/zego/interface/live'

export default class extends WebLiveInterface {
  async loginRoom(roomID = '', config = {}) {
    const { isLogin } = this.context.getState('isLogin')
    if (isLogin) {
      console.warn('has login!!!')
    }
    const { token1 } = storage.get('tokenInfo') || {}
    config = { userUpdate: true, maxMemberCount: 10, ...config }
    const user = this.context.state.user
    let res
    try {
      const args = [roomID, token1, user, config]
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
    } catch (e) {
      console.log('login error', { e })
      res = {
        error: true,
        msg: e.msg,
        code: e.code
      }
    }
    return res
  }

  async createStream(option) {
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

  // 重写startPlayingStream
  async startPlayingStream(streamID, playOption = {}, element) {
    !this.stream && (this.stream = await this._client.startPlayingStream(streamID, playOption))
    const $video = document.createElement('video')
    $video.setAttribute('autoplay', true)
    $video.setAttribute('muted', true)
    $video.setAttribute('id', streamID)
    element.appendChild($video)
    $video.srcObject = this.stream
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

  useVideoDevice(value) {
    this._client.useVideoDevice(this.localStream, value)
  }

  useAudioDevice(value) {
    this._client.useAudioDevice(this.localStream, value)
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
  }

  setRoomExtraInfo(key, value) {
    this._client.setRoomExtraInfo(this.room_id, key, value)
  }

  logoutRoom(roomId) {
    this._client.logoutRoom(roomId)
  }
}
