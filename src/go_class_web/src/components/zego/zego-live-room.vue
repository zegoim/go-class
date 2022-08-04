<!--
 * @Description: 提供音视频sdk相关实例的组件，通过provide提供该能力，如需使用该音视频相关方法的组件可通过inject注入
-->
<template>
  <div class="zego-live-room" v-if="!!client && isLogin">
    <slot></slot>
    <room-dialog-loading v-if="loading" />
    <room-dialog-error ref="errorDialog" />
    <room-dialog-message ref="timeOutDialog" :msg="timeOutMessage" />
  </div>
</template>

<script>
import zegoClient from '@/service/zego/zegoClient'
import { storage } from '@/utils/tool'
import ErrorHandle from '@/utils/error'
import RoomDialogLoading from '@/components/room/room-dialog-loading'
import RoomDialogError from '@/components/room/room-dialog-error'
import RoomDialogMessage from '@/components/base/base-dialog-message'
import { postRoomHttp, roomStore, setGoclassEnv } from '@/service/biz/room'
import { STATE_OPEN } from '@/utils/constants'

export default {
  name: 'ZegoLiveRoom',
  components: {
    RoomDialogLoading,
    RoomDialogError,
    RoomDialogMessage
  },
  data() {
    return {
      roomId: '',
      userName: '',
      env: '',
      client: null, // sdk实例
      streamList: [], // 流
      userList: [], // 房间用户列表
      user: {}, // 用户本身
      isPushStreamList: false, // 是否正在推流
      isLogin: false, // 是否登录
      publishStreamId: '', // 推流id
      publishingFlag: '', // 判断正在推的是视频流还是音频流
      devices: null, // 音频、视频输入输出设备列表
      activeDevice: {}, // 当前使用设备
      roomState: '', // 房间当前状态
      loading: false,
      loadingTimer: null,
      loadingInterval: 30,
      confirm: false,
      roomExtraInfo: null,
      messages: [], // 房间消息
      sendLoadingTimer: null, //发送消息loading
      sendLoadingInterval: 5, //发送消息loading
      timeOutMessage: '',
      hasPush: false, // 是否推过流，防止首次推流回包之前执行mute,
      roomAuth: roomStore.auth, // 房间权限
    }
  },
  provide() {
    return {
      zegoLiveRoom: this
    }
  },
  created() {
    const env = this.$route.query.env || storage.get('loginInfo')?.env
    setGoclassEnv(env)
  },
  async mounted() {
    const loading = this.$loading()
    try {
      // 调用顺序：loginRoomBiz -> initClient -> initLiveRoom -> loginRoom | 后台业务登录房间 -> 初始化sdk -> 监听回调方法 -> 登录房间
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
      const { roomId, userId, userName, role, env, classScene } = storage.get('loginInfo')
      this.roomId = roomId
      this.userName = userName
      this.env = env
      //从登录页面跳转过来
      if (this.$route.meta.from) {
        // 用户自身加入房间，往房间消息push一条系统提示
        let data = {
          userID: userId,
          messageCategory: 2,
          messageContent: [this.$t('room.room_im_join_class')],
          messageState: 1,
          nick_name: userName
        }
        this.setRoomMessage(1, data)
        this.$message(this.$t('room.room_login_time_limit_15'))
        return
      }
      // 非登录页面跳转，直接刷新页面时需要执行业务登录接口
      const loginParams = {
        uid: userId,
        room_id: roomId,
        nick_name: userName,
        role: role || 2,
        room_type: classScene
      }
      try {
        const result = await postRoomHttp('login_room', loginParams)
        // 存储 token
        zegoClient.setState({
          tokenInfo: { token: result.data.app_token }
        })
      } catch (e) {
        // 已有老师 或者 人数已满
        const code = e && e.ret && e.ret.code
        if (code == 10001 || code == 10002) {
          this.$route.meta.reload = true
          this.$router.replace('/login')
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
      if (res.error) {
        if (res.code) {
          ErrorHandle.showErrorCodeMsg(res.code, () => {
            const timer = setTimeout(() => {
              clearTimeout(timer)
              this.$route.meta.reload = true
              this.$router.replace('/login')
            }, 3000)
          })
          return
        }
        res.msg && this.showToast(res.msg)
      }
      this.isLogin = true
      const { user } = zegoClient.getState('user')
      this.$set(this, 'user', user)
      this.userList.push(user)
    },

    /**
     * @desc: 监听回调方法
     */
    async initLiveRoom() {
      // 监听房间流更新
      this.client.on('roomStreamUpdate', (roomID, updateType, streamList) => {
        console.warn('this.streamList', this.streamList)
        let tempStreamList = []
        streamList = streamList.filter(v => !!v.streamID)
        if (updateType === 'ADD') {
          console.warn('roomStreamUpdate ADD streamList', streamList)
          streamList.map(x => (x.isVideoOpen = x.isVideoOpen || false))
          tempStreamList = [...this.streamList, ...streamList]
        }
        if (updateType === 'DELETE') {
          console.warn('roomStreamUpdate DELETE streamList', streamList)
          tempStreamList = this.streamList.filter(x => x.streamID !== streamList[0].streamID)
        }
        console.warn('tempStreamList', tempStreamList)
        this.$set(
          this,
          'streamList',
          tempStreamList.filter(v => !!v.streamID)
        )
        roomStore.getJoinLiveList()
      })
      // 监听房间用户变化
      this.client.on('roomUserUpdate', (roomID, updateType, userList) => {
        console.warn("this.client.on('roomUserUpdate'", { roomID, updateType, userList })
        if (updateType === 'ADD' && userList && userList.length) {
          // 去重
          console.warn(userList, 'ADD userList')
          console.warn(this.userList, 'this.userList')
          userList.forEach(user => {
            const index = this.userList.findIndex(x => x.userID === user.userID)
            index === -1 && this.userList.push(user)
          })
        }
        if (updateType === 'DELETE' && userList && userList.length) {
          console.warn(userList, 'DELETE userList')
          const index = this.userList.findIndex(x => x.userID === userList[0].userID)
          index !== -1 && this.userList.splice(index, 1)
        }
        roomStore.getAttendeeList()
        roomStore.getJoinLiveList()
      })
      // 监听摄像头状态
      this.client.on('remoteCameraStatusUpdate', (streamID, status) => {
        console.warn('remoteCameraStatusUpdate', streamID, status)
        const streamIndex = this.streamList.findIndex(item => streamID.endsWith(item.streamID))
        streamIndex !== -1 &&
          this.$set(this.streamList[streamIndex], 'isVideoOpen', status === 'OPEN')
      })
      this.client.on('publisherStateUpdate', result => {
        console.warn('publisherStateUpdate', result)
        console.warn('publishStreamId', this.publishStreamId)
        if (result.state === 'PUBLISHING') {
          // redo
          if(!this.hasPush) {
            this.hasPush = true;
            let isCamaraOpen = !this.roomAuth.camera == STATE_OPEN;
            let isMicrophoneOpen = !this.roomAuth.mic == STATE_OPEN
            this.client.express('mutePublishStreamVideo', isCamaraOpen)
            this.client.express('mutePublishStreamAudio', isMicrophoneOpen)
          }
        }
      })
      // 监听房间状态
      this.client.on('roomStateUpdate', (roomID, state, errorCode, extendedData) => {
        console.warn('roomStateUpdate:', state)
        console.warn('errorCode:', errorCode)
        console.warn('extendedData:', extendedData)
        this.roomState = state
        // if (!this.client.isLogin) return // 对应loginState
        switch (state) {
          // 连接中
          case 'CONNECTING':
            // this.offlineHandle()
            break
          // 已连接
          case 'CONNECTED':
            this.initLoadingTimerHandle()
            break
          // 连接失败
          case 'DISCONNECTED':
            if (errorCode === 1002050) {
              this.timeOutMessage = this.$t('room.room_login_time_out')
              this.$refs.timeOutDialog.show = true
            } else {
              // if(extendedData !== null){
              //   console.warn(this.$t('system.experience_duration_expired'))
              //   this.$alert(this.$t('system.experience_duration_expired'), '', {
              //     confirmButtonText: this.$t('room.room_ok'),
              //     callback: () => {
              //       window.location.hash = '#/login'
              //     }
              //   });
              // }else{
              this.disconnectedHandle()
            }
            // this.disconnectedHandle()
            break
          default:
            break
        }
      })
      // 监听房间附加信息
      this.client.on('roomExtraInfoUpdate', (roomID, roomExtraInfoList) => {
        const roomExtraInfo = {
          type: roomExtraInfoList[0].key,
          data: roomExtraInfoList[0].value
        }
        console.warn('监听到的roomExtraInfo', roomExtraInfo)
        // tips: 第一次emit组件还没渲染，监听不到
        // this.roomExtraInfo && this.emitRoomExtraInfoUpdate(roomExtraInfo)
        this.$set(this, 'roomExtraInfo', roomExtraInfo)
      })
      // 监听IM消息接收（弹幕消息）
      this.client.on('IMRecvBarrageMessage', (roomID, chatData) => {
        console.warn("this.client.on('IMRecvBarrageMessage'", { roomID, chatData })
        let data = {
          userID: chatData[0].fromUser.userID,
          messageCategory: 1,
          messageID: chatData[0].messageID,
          messageContent: [{ messageState: 3, content: chatData[0].message }],
          nick_name: chatData[0].fromUser.userName
        }
        this.setRoomMessage(1, data)
      })
      window.addEventListener('offline', () => {
        this.offlineHandle()
      })

      window.addEventListener('online', () => {
        // this.initLoadingTimerHandle()
        window.location.reload()
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
     * @param {'camera'|'mic'|'speak'} type
     * @param {boolean} value
     */
    async selectDevice(value, type) {
      const { localStream } = this.client
      switch (type) {
        case 'camera':
          localStream && (await this.client.express('useVideoDevice', value))
          break
        case 'mic':
          localStream && (await this.client.express('useAudioDevice', value))
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
     */
    async createPushStream(publishOption = {}) {
      console.warn('createPushStream, 开始推流！')
      // const { isVideoOpen, isAudioOpen } = publishOption
      const { camera, microphone } = this.activeDevice
      const option = {
        camera: {
          videoQuality: 4,
          width: 640,
          height: 360,
          bitRate: 600,
          frameRate: 15,
          video: true,
          audio: true
        }
      }
      if (camera) option.camera.videoInput = camera
      if (microphone) option.camera.audioInput = microphone

      await this.client.express('createStream', option)

      // 创建流 更新流列表 start
      console.warn('创建流 更新流列表 start')
      const { userID } = this.user
      this.isPushStreamList = true
      this.publishStreamId = `${this.client.isElectron ? 'ec' : 'web'}_${userID}`
      if (this.isPushStreamList) {
        this.streamList.push({
          streamID: this.publishStreamId,
          type: 'push',
          stream: this.client.localStream,
          isVideoOpen: true,
          isAudioOpen: true,
          user: this.user
        })
        this.isPushStreamList = false
      }
      console.warn('创建流 更新流列表 end')
      // 创建流 更新流列表 end

      await this.client.express('startPublishingStream', this.publishStreamId, publishOption)
    },
    /**
     * @desc - 设备状态变更
     * @param {'video'|'audio'} flag
     * @param {boolean} isVideoOpen
     * @param {boolean} isAudioOpen
     * @returns {Promise<void>}
     */
    async handleDeviceStateChange(flag, isVideoOpen, isAudioOpen) {
      const [isSendVideoStream, isSendAudioStream] = [!isVideoOpen, !isAudioOpen]
      console.warn({ localStream: this.client.localStream })
      console.warn('flag, isVideoOpen, isAudioOpen', flag, isVideoOpen, isAudioOpen)
      // 摄像头/麦克风 二者之一的状态是开 则推送一条流
      if (isVideoOpen || isAudioOpen) {
        if (!this.client.localStream) {
          if (this.client.isCreatingStream) return
          this.publishingFlag = flag
          /**
           * 单独开启某个设备（摄像头或者麦克风）在创建流的时候摄像头和麦克风状态都必须设置为true，然后再根据设备状态更新流状态
           */
          await this.createPushStream({ isVideoOpen, isAudioOpen })
          if(this.hasPush) {
            await this.client.express('mutePublishStreamVideo', isSendVideoStream)
            await this.client.express('mutePublishStreamAudio', isSendAudioStream)
          }
        } else {
          // 更新摄像头麦克风状态
          if (flag === 'video' || (isVideoOpen && isAudioOpen)) {
            // 是否停止发送视频流 -> true-表示不发送视频流 false-表示发送视频流
            if(this.hasPush) {
              this.client.express('mutePublishStreamVideo', isSendVideoStream)
            }
            this.handleSelfVideoToggle(isVideoOpen)
          }
          if (flag === 'audio' || (isVideoOpen && isAudioOpen)) {
            if(this.hasPush) {
              this.client.express('mutePublishStreamAudio', isSendAudioStream)
            }
            this.handleSelfAudioToggle(isAudioOpen)
          }
        }
      } else {
        // 如果摄像头和麦克风都是关闭，则销毁流
        this.handleDestroyStream()
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
      const idx = this.streamList.findIndex(stream => stream.streamID === this.publishStreamId)
      idx !== -1 && this.streamList.splice(idx, 1)
    },
    /**
     * @desc: 开启预览
     * @param {streamID} 流id
     * @return {element} 预览dom
     */
    startPreview(streamID, element) {
      this.client.express('startPreview', streamID, element)
    },
    /**
     * @desc: 播放流
     * @param {streamID} 需播放目标流id
     * @param {playOption}
     * @param {element}
     */
    async startPlayingStream(streamID, playOption, element) {
      return await this.client.express('startPlayingStream', streamID, playOption, element)
    },
    /**
     * @desc: 停止播放流
     * @param {streamID} 需停止播放目标流id
     */
    stopPlayingStream(streamID) {
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
      if (this.$refs.errorDialog) this.$refs.errorDialog.show = true
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

    /**
     * @desc: 维护im聊天室消息
     * @param {*} type 设置类型 1-增加 2-更新
     * @param {*} data 消息主体
     * @return {*}
     */
    setRoomMessage(type, data, targetMessageID, res) {
      const lastMessage = this.messages[this.messages.length - 1]
      if (type === 1) {
        if (!lastMessage) {
          this.messages.push(data)
        } else {
          const { userID: lastUserID, messageCategory: lastMessageCategory } = lastMessage
          // 判断信息数组里面最新到一条信息是否是系统信息并且是否是同一个用户发送的，如果不是系统信息且是同一个用户发送则是该用户连续发送消息。
          if (
            lastMessageCategory === 1 &&
            lastUserID === data.userID &&
            data.messageCategory === 1
          ) {
            lastMessage.messageContent.push({
              messageID: new Date().getTime(),
              messageState: 1,
              content: data.messageContent[0].content
            })
          } else {
            this.messages.push(data)
          }
        }
      } else if (type === 2) {
        /**
         * messageState状态：
         * 1 消息发送中
         * 2 发送失败
         * 3 发送成功
         */
        lastMessage.messageContent.find(item => {
          if (item.messageID === targetMessageID) {
            if (res.errorCode === 0) {
              item.messageState = 3
              item.messageID = res.messageID
            } else {
              item.messageState = 2
            }
          }
        })
      }
    },

    /**
     * @desc: 大班课通过弹幕信息发送im消息
     * @param {*} message
     * @return {*}
     */
    async sendBarrageMessage(message) {
      let data = {
        userID: this.user.userID,
        messageCategory: 1,
        messageTimestamp: new Date().getTime(),
        messageContent: [{ messageState: 1, content: message, messageID: new Date().getTime() }],
        nick_name: this.user.userName
      }
      // 需要更新的目标消息id
      let targetMessageID = data.messageContent[0].messageID
      // 用户自身发送消息默认发送中状态，后续消息状态更新根据回调重置
      this.setRoomMessage(1, data)
      try {
        let res = await this.client.express('sendBarrageMessage', message)
        var num = 0,
          max = 5,
          intervalId = null
        intervalId = setInterval(() => {
          num++
          console.warn('倒计时：', num)
          if (res) {
            console.warn('发送成功')
            clearInterval(intervalId)
            // 消息发送成功，更新该消息状态
            if (res.errorCode === 0) this.setRoomMessage(2, data, targetMessageID, res)
            // 消息发送不成功，更新该消息状态
            if (res.errorCode !== 0) this.setRoomMessage(2, data, targetMessageID, res)
          }
          if (num === max) {
            clearInterval(intervalId)
            // 超过60s接收不到状态回调，消息发送不成功，更新该消息状态
            this.setRoomMessage(2, data, targetMessageID, res)
          }
        }, 1000)
      } catch (error) {
        console.warn('------error----', error)
        this.setRoomMessage(2, data, targetMessageID, { errorCode: error })
      }
    }
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
