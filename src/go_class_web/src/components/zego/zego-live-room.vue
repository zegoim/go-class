<template>
  <div class="zego-live-room" v-if="!!client && isLogin">
    <slot></slot>
    <room-dialog-loading v-if="loading" />
    <room-dialog-error ref="errorDialog" />
  </div>
</template>

<script>
import zegoClient from '@/service/zego/zegoClient'
import RoomDialogLoading from '@/components/room/room-dialog-loading'
import RoomDialogError from '@/components/room/room-dialog-error'
import { postRoomHttp, roomStore, setGoclassEnv } from '@/service/biz/room'
import { storage, defaultOpenVideo, isElectron } from '@/utils/tool'
import ErrorHandle from '@/utils/error'

const { ipcRenderer } = window.require('electron')

export default {
  name: 'ZegoLiveRoom',
  components: {
    RoomDialogLoading,
    RoomDialogError
  },
  props: {
    roomId  : String, // 传入roomId
    userName: String, // 传入用户名
    env     : String, // env
  },
  data () {
    return {
      client: null,             // sdk实例
      streamList: [],           // 流
      userList: [],             // 房间用户列表
      user: {},                 // 用户本身
      isPushStreamList: false,  // 是否正在推流
      isLogin: false,           // 是否登录
      publishStreamId: '',      // 推流id
      publishingFlag: '',       // 判断正在推的是视频流还是音频流
      devices: null,            // 音频、视频输入输出设备列表
      activeDevice: {},         // 当前使用设备
      roomState: '',            // 房间当前状态
      loading: false,
      loadingTimer: null,
      loadingInterval: 30,
      confirm: false,
      roomExtraInfo: null
    }
  },
  provide () {
    return {
      zegoLiveRoom: this
    }
  },
  created() {
    const env = storage.get('loginInfo')?.env
    setGoclassEnv(env)
  },
  async mounted () {
    // 调用顺序：loginRoomBiz -> initClient -> initLiveRoom -> loginRoom | 后台业务登录房间 -> 初始化sdk -> 监听回调方法 -> 登录房间
    const loading = this.$loading()
    try {
      await this.loginRoomBiz()
      await this.initClient()
      await this.initLiveRoom() // 回调方法
      await this.loginRoom()
    } finally {
      this.$nextTick(() => {
        loading.close()
      })
    }
  },
  methods: {
    /**
     * @desc: 后台业务 - 登录房间
     */
    async loginRoomBiz() {
      const { roomId, userId, userName, role, env } = storage.get('loginInfo')
      this.roomId = roomId
      this.userName = userName
      this.env = env
      if (this.$route.meta.from) return
      // 非登录页面跳转，直接刷新页面时需要执行业务登录接口
      const loginParams = {
        uid: userId,
        room_id: roomId,
        nick_name: userName,
        role: role || 2
      }
      try {
        await postRoomHttp('login_room', loginParams)
      } catch (e) {
        // 已有老师 或者 人数已满
        const code = e && e.ret && e.ret.code
        if (code == 10001 || code == 10002) {
          this.$route.meta.reload = true
          // this.$router.replace('/login')
          ipcRenderer.send('close-window')
          return Promise.reject()
        }
      }
    },
    /**
     * @desc: 初始化sdk
     */
    async initClient() {
      this.client = await zegoClient.init('live', this.env)
    },
    /**
     * @desc: sdk - 登录房间
     */
    async loginRoom() {
      const res = await this.client.express('loginRoom', this.roomId)
      console.warn('loginRoom', { res })
      if (res.error) {
        storage.remove('tokenInfo')
        if (res.code) {
          ErrorHandle.showErrorCodeMsg(res.code, () => {
            const timer = setTimeout(() => {
              clearTimeout(timer)
              this.$route.meta.reload = true
              ipcRenderer.send('close-window')
            }, 3000)
          })
          return
        }
        res.msg && this.showToast(res.msg)
      }
      this.isLogin = true
      const { user } = zegoClient.getState('user')
      user.userID = user.userID.toString()
      this.$set(this, 'user', user)
      this.userList.push(user)
      if (res.streamList && res.streamList.length) {
        res.streamList.map(stream => stream.isVideoOpen = defaultOpenVideo)
        this.$set(this, 'streamList', res.streamList)
      }
    },
    /**
     * @desc: 监听回调方法
     */

    async initLiveRoom() {
      this.client.on('roomStreamUpdate', (roomID, updateType, streamList) => {
        console.log('roomStreamUpdate', { roomID, updateType, streamList })
        let tempStreamList = []
        streamList = streamList.filter(v => !!v.streamID)
        if (updateType === 'ADD') {
          streamList.map(x => x.isVideoOpen = (x.isVideoOpen || defaultOpenVideo))
          tempStreamList = [...this.streamList, ...streamList]
        }
        if (updateType === 'DELETE') {
          console.warn('roomStreamUpdate DELETE streamList', streamList)
          tempStreamList = this.streamList.filter(x => x.streamID !== streamList[0].streamID)
        }
        tempStreamList = tempStreamList.filter(v => v.streamID)
        this.$set(this, 'streamList', tempStreamList)
      })
      this.client.on('roomUserUpdate', (roomID, updateType, userList) => {
        console.warn('this.client.on(\'roomUserUpdate\'', { roomID, updateType, userList })
        if (updateType === 'ADD' && userList?.length) {
          // 去重
          console.warn(userList, 'ADD userList')
          console.warn(this.userList, 'this.userList')
          userList.forEach(user => {
            const index = this.userList.findIndex(x => x.userID === user.userID)
            index === -1 && this.userList.push(user)
          })
        }
        if (updateType === 'DELETE' && userList?.length) {
          console.warn(userList, 'DELETE userList')
          const index = this.userList.findIndex(x => x.userID === userList[0].userID)
          index !== -1 && this.userList.splice(index, 1)
        }
      })
      this.client.on('remoteCameraStatusUpdate', (streamID, status) => {
        console.warn('remoteCameraStatusUpdate', streamID, status)
        const streamIndex = this.streamList.findIndex(item => streamID.endsWith(item.streamID))
        streamIndex !== -1 && this.$set(this.streamList[streamIndex], 'isVideoOpen', status === 'OPEN')
        roomStore.getAttendeeList()
      })
      this.client.on('remoteMicStatusUpdate', (streamID, status) => {
        console.warn('remoteMicStatusUpdate', streamID, status)
        const streamIndex = this.streamList.findIndex(item => streamID.endsWith(item.streamID))
        streamIndex !== -1 && this.$set(this.streamList[streamIndex], 'isAudioOpen', status === 'OPEN')
        roomStore.getAttendeeList()
      })
      this.client.on('publisherStateUpdate', result => {
        console.warn('publisherStateUpdate', result)
        console.warn('publishStreamId', this.publishStreamId)
        if (result.state === 'PUBLISHING') {
          const flag = this.publishingFlag
          if (this.isPushStreamList) {
            this.streamList.push({
              streamID: this.publishStreamId,
              type: 'push',
              stream: this.client.localStream,
              isVideoOpen: flag !== 'audio',
              user: this.user
            })
            this.isPushStreamList = false
            // flag === 'video' && this.client.express('mutePublishStreamAudio', true)
            // flag === 'audio' && this.client.express('mutePublishStreamVideo', true)
          }
        }
      })
      this.client.on('roomStateUpdate', (roomID, state) => {
        console.warn('roomStateUpdate', state)
        this.roomState = state
        if (!this.client.isLogin) return // 对应loginState
        switch (state) {
          case 'CONNECTING':
            this.offlineHandle()
            break
          case 'CONNECTED':
            this.initLoadingTimerHandle()
            break
          case 'DISCONNECTED':
            this.disconnectedHandle()
            break
          default:
            break
        }
      })
      this.client.on('roomExtraInfoUpdate', (roomID, type, data) => {
        console.log('onRoomExtraInfoUpdate', { roomID, type, data })
        const roomExtraInfo = {
          type,
          data
        }
        this.$set(this, 'roomExtraInfo', roomExtraInfo)
      })

      window.addEventListener('offline', () => {
        this.offlineHandle()
      })

      window.addEventListener('online', () => {
        window.location.reload()
        // this.initLoadingTimerHandle()
      })
    },
    /**
     * @desc 获取设备列表
     */
    async getDevices() {
      const devices = await this.client.express('enumDevices')
      this.$set(this, 'devices', devices)
      return devices
    },
    /**
     * @desc 设备选择处理
     * @param {'camera'|'microphone'|'speak'} type
     * @param {boolean} value
     */
    selectDevice(type, value) {
      const { localStream } = this.client
      switch (type) {
        case 'camera':
          localStream && this.client.express('useVideoDevice', value)
          break
        case 'microphone':
          localStream && this.client.express('useAudioDevice', value)
          break
        case 'speak':
          this.$set(this.activeDevice, 'speaker', value)
          break
      }
    },
    /**
     * @desc {设置设备id}
     * @param {Object} activeDevice
     */
    setActiveDevice(activeDevice) {
      this.$set(this, 'activeDevice', activeDevice)
    },
    /**
     * @desc {推流}
     * @param {Object} publishOption
     * @param {Boolean} isStartPub
     */
    async createPushStream (publishOption = {}) {
      console.warn('createPushStream, 开始推流！')
      const { isVideoOpen, isAudioOpen } = publishOption
      const { camera, microphone } = this.activeDevice
      const option = {
        camera: {
          videoQuality: 4,
          width: 640,
          height: 360,
          bitRate: 600,
          video: isVideoOpen,
          audio: isAudioOpen
        }
      }
      if (camera) option.camera.videoInput = camera
      if (microphone) option.camera.audioInput = microphone

      await this.client.express('createStream', option)
      const { userID } = this.user
      this.publishStreamId = `${isElectron ? 'ec' : 'web'}_${userID}`
      await this.client.express(
          'startPublishingStream',
          this.publishStreamId,
          {}
      )
      this.isPushStreamList = true
    },
    /**
     * @desc - 本地设备状态变更
     * @param {'video'|'audio'} flag
     * @param {boolean} isVideoOpen
     * @param {boolean} isAudioOpen
     * @returns {Promise<void>}
     */
    async handleDeviceStateChange(flag, isVideoOpen, isAudioOpen) {
      const [isSendVideoStream, isSendAudioStream] = [!isVideoOpen, !isAudioOpen]
      console.warn({ localStream: this.client.localStream, flag, isVideoOpen, isAudioOpen })
      // 摄像头/麦克风 二者之一的状态是开 则推送一条流
      if (isVideoOpen || isAudioOpen) {
        if (!this.client.localStream) { // 已经推流
          if (this.client.isCreatingStream) return
          this.publishingFlag = flag
          await this.createPushStream({ isVideoOpen, isAudioOpen })
          this.client.express('mutePublishStreamVideo', isSendVideoStream)
          this.client.express('mutePublishStreamAudio', isSendAudioStream)
        } else {
          // 更新摄像头麦克风状态
          if (flag === 'video' || (isVideoOpen && isAudioOpen)) { //  || (isVideoOpen && isAudioOpen)
            this.client.express('mutePublishStreamVideo', isSendVideoStream) // 是否停止发送视频流 -> true-表示不发送视频流 false-表示发送视频流
            this.handleSelfVideoToggle(isVideoOpen)
          }
          if (flag === 'audio' || (isVideoOpen && isAudioOpen)) { //  || (isVideoOpen && isAudioOpen)
            this.client.express('mutePublishStreamAudio', isSendAudioStream)
            this.handleSelfAudioToggle(isAudioOpen)
          }
        }
      } else {
        // 如果摄像头和麦克风都是关闭，则销毁流
        await this.handleDestroyStream()
      }
    },
    /**
     * @desc: 更新自身流摄像头状态
     * @param {isOpen}
     */
    handleSelfVideoToggle(isOpen) {
      const index = this.streamList.findIndex(stream => stream.user.isMe === true)
      if (index !== -1) {
        this.$set(this.streamList[index], 'isVideoOpen', isOpen)
      }
    },
    /**
     * @desc: 更新自身流麦克风状态
     * @param {isOpen}
     */
    handleSelfAudioToggle(isOpen) {
      const index = this.streamList.findIndex(stream => stream.user.isMe === true)
      if (index !== -1) {
        this.$set(this.streamList[index], 'isAudioOpen', isOpen)
      }
    },
    /**
     * @desc: 销毁流
     */
    handleDestroyStream() {
      this.client.express('stopPublishingStream', this.publishStreamId)
      const idx = this.streamList.findIndex(stream => stream.streamID === this.publishStreamId || !stream.streamID)
      idx !== -1 && this.streamList.splice(idx, 1)
    },

    /**
     * @desc: 播放流
     * @param {streamID} 需播放目标流id
     * @param {playOption}
     * @param {element}
     */
    async startPlayingStream (streamID, playOption, element, isMe = false) {
      return await this.client.express('startPlayingStream', streamID, playOption, element, isMe)
    },
    /**
     * @desc: 停止播放流
     * @param {streamID} 需停止播放目标流id
     */
    stopPlayingStream (streamID) {
      this.client.express('stopPlayingStream', streamID)
    },

    /**
     * @desc 扬声器开关监听
     * @param {Function} cb
     */
    onMuteSpeaker(cb) {
      this.$on('muteSpeaker', cb)
    },

    /**
     * @desc 扬声器开关
     * @param {Boolean} isOpen
     */
    muteSpeaker(isOpen) {
      this.$emit('muteSpeaker', isOpen)
    },

    /**
     * @desc: 断网重连
     */

    offlineHandle() {
      if (this.loading || this.confirm) return
      this.loading = true
      this.loadingTimer = setInterval(() => {
        if (this.loadingInterval === 0) {
          this.disconnectedHandle()
        } else {
          this.loadingInterval--
          console.log(this.loadingInterval)
        }
      }, 1000)
    },

    // 重连失败后处理
    disconnectedHandle() {
      this.streamList = []
      this.localStream = null
      this.initLoadingTimerHandle()
      this.$refs.errorDialog.show = true
      this.handleDestroyStream()
      roomStore.close()
    },

    // 初始化loading定时器
    initLoadingTimerHandle() {
      this.loadingTimer && clearInterval(this.loadingTimer)
      this.loadingTimer = null
      this.loadingInterval = 30
      if (this.loading) {
        this.loading = false
        this.$refs.errorDialog.show = false
      }
    },
    // tips: electron有，web没有的方法 start
    loseCanvasContext ({ canvas }, cb) {
      this.client.express('loseCanvasContext', { canvas }, cb)
    },
    enableSpeaker ({ enable }) {
      this.client.express('enableSpeaker', { enable })
    },
    startPreview (streamID, $ele) {
      this.client.express('startPreview', streamID, $ele)
    },
    stopPreview () {
      this.client.express('stopPreview')
    }
    // tips: electron有，web没有的方法 end
  },
  destroyed() {
    this.$off(['muteSpeaker', 'roomExtraInfoUpdate'])
  }
}
</script>
<style lang="scss">
.zego-live-room {
  @include wh(100%, 100%);
}
</style>
