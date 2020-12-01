<template>
  <div class="room-controller-feature">
    <div ref="analogTrigger" />
    <ul class="control-btn-list">
      <li
          class="control-btn-item"
          v-for="(item, i) in controlBtnList"
          :key="item.name"
          @click="getUserMediaAuth(i)"
      >
        <!-- 共享按钮开始 -->
        <el-popover
            v-if="item.name === 'share'"
            placement="top"
            width="154"
            trigger="click"
            popper-class="control-btn-share-popper"
            :disabled="!roomAuth.share"
        >
          <div class="share-list-popper">
            <div class="share-item" @click="createWhiteboard">
              <div
                  class="si-icon"
                  v-html="require('../../assets/icons/room/share-drawing.svg').default"
              ></div>
              <div class="si-name">白板</div>
            </div>
            <div class="share-item" @click="handleFileListDialog">
              <div
                  class="si-icon"
                  v-html="require('../../assets/icons/room/share-file.svg').default"
              ></div>
              <div class="si-name">文件</div>
            </div>
          </div>
          <el-button slot="reference">
            <div class="main-btn">
              <div class="main-icon" v-html="item.imgSrc.default"></div>
              <div class="btn-name">{{ item.cnName }}</div>
            </div>
          </el-button>
        </el-popover>
        <!-- 共享按钮结束 -->
        <div
            v-else
            :class="[
            'main-btn',
            item.isOpen || roomAuth[item.name] === 2 ? 'active' : '',
            item.canSpread && 'can-spread'
          ]"
            @click="handleMainBtnClick_(item)"
        >
          <div class="main-icon" v-html="getItemIcon(item)"></div>
          <div class="btn-name">{{ item.cnName }}</div>
          <div class="no-auth-tip">请打开{{ item.cnName }}权限</div>
          <div v-if="item.name === 'member'" class="memberNum">{{ roomUserList.length }}</div>
        </div>

        <el-popover
            v-if="item.canSpread"
            placement="top"
            width="154"
            trigger="click"
            popper-class="device-select-list-popper"
            :offset="34"
        >
          <div class="device-select-list-content">
            <div class="device-main-name">{{ item.cnName }}</div>
            <el-select
                v-model="activeDeviceIds[item.name]"
                placeholder="请选择"
                popper-class="device-select-list-dropdown"
            >
              <el-option
                  v-for="device in deviceInfo[item.name]"
                  :key="device.deviceID"
                  :label="device.deviceName"
                  :value="device.deviceID"
              >
              </el-option>
            </el-select>
          </div>
          <el-button slot="reference" class="el-sub-btn">
            <div class="sub-btn">
              <div
                  class="arrow-btn"
                  v-html="require('../../assets/icons/room/arrow_up.svg').default"
              ></div>
            </div>
          </el-button>
        </el-popover>
      </li>
    </ul>
    <!-- 退出教室 -->
    <div class="quit-button">
      <button @click="handleMainBtnClick_({ name: 'quit' })" class="quit-button-item">
        <span
            class="button-icon"
            v-html="require('../../assets/icons/room/sign_out.svg').default"
        ></span>
        <span>退出</span>
      </button>
    </div>
    <room-dialog-members
        v-if="memberListDialogShow"
        @handleClose="memberListDialogShow = false"
        v-bind="$attrs"
        :userList="roomUserList"
    />
    <room-dialog-share v-if="shareDialogShow" @handleClose="shareDialogShow = false" />
    <room-dialog-files
        v-if="filesListDialogShow"
        @handleClose="zegoWhiteboardArea.setFilesListDialogShow(false)"
    />
    <room-dialog-quit v-if="quitDialogShow" @handleClose="quitDialogShow = false" />
  </div>
</template>

<script>
import RoomDialogMembers from '@/components/room/room-dialog-members'
import RoomDialogShare from '@/components/room/room-dialog-share'
import RoomDialogFiles from '@/components/room/room-dialog-files'
import RoomDialogQuit from '@/components/room/room-dialog-quit'
import { getUserMedia } from '@/utils/browser'
import { debounce } from '@/utils/tool'
import { roomStore } from '@/service/biz/room'
import { ROLE_STUDENT, ROLE_TEACHER, STATE_CLOSE, STATE_OPEN } from '@/utils/constants'

const controlBtnList = [
  {
    name: 'camera',
    cnName: '摄像头',
    imgSrc: {
      default: require('../../assets/icons/room/camera_open.svg').default,
      open: require('../../assets/icons/room/camera_open.svg').default,
      close: require('../../assets/icons/room/camera_close.svg').default,
      warn: require('../../assets/icons/room/camera_warning.svg').default
    },
    canSpread: true,
    noAuth: true
  },
  {
    name: 'mic',
    cnName: '麦克风',
    imgSrc: {
      default: require('../../assets/icons/room/microphone_open.svg').default,
      open: require('../../assets/icons/room/microphone_open.svg').default,
      close: require('../../assets/icons/room/microphone_close.svg').default,
      warn: require('../../assets/icons/room/microphone_warning.svg').default
    },
    canSpread: true,
    noAuth: true
  },
  {
    name: 'speaker',
    cnName: '扬声器',
    imgSrc: {
      default: require('../../assets/icons/room/sound_open.svg').default,
      open: require('../../assets/icons/room/sound_open.svg').default,
      close: require('../../assets/icons/room/sound_close.svg').default
    },
    canSpread: false,
    isOpen: true
  },
  {
    name: 'share',
    cnName: '共享',
    imgSrc: {
      default: require('../../assets/icons/room/share.svg').default
    }
  },
  {
    name: 'invite',
    cnName: '邀请',
    imgSrc: {
      default: require('../../assets/icons/room/invite.svg').default
    }
  },
  {
    name: 'member',
    cnName: '成员',
    imgSrc: {
      default: require('../../assets/icons/room/member.svg').default
    }
  }
]

let allowSetExtra = false

export default {
  name: 'RoomControllerFeature',
  components: {
    RoomDialogMembers,
    RoomDialogShare,
    RoomDialogFiles,
    RoomDialogQuit
  },
  data() {
    return {
      controlBtnList,
      deviceInfo: {
        camera: [],
        microphone: [],
        speaker: []
      },
      activeDeviceIds: {
        camera: '',
        microphone: '',
        speaker: ''
      },
      memberListDialogShow: false, // 成员列表弹窗标识
      shareDialogShow: false, // 邀请弹窗标识
      quitDialogShow: false, // 退出课堂弹窗标识
      roomUserList: [], // 房间成员列表
      roomAuth: roomStore.auth // 房间权限
    }
  },
  inject: ['zegoLiveRoom', 'zegoWhiteboardArea'],
  computed: {
    filesListDialogShow() {
      return this.zegoWhiteboardArea.filesListDialogShow
    }
  },
  mounted() {
    this.initDevices()
    this.$bus.$on('roomAttendeesChange', this.onRoomAttendeesChange)
    this.$bus.$on('userStateChange', this.tryJionLive)
    this.tryJionLive(null, true)
    setTimeout(() => {
      allowSetExtra = true
    }, 5000)
  },
  destroyed() {
    this.$bus.$off('roomAttendeesChange', this.onRoomAttendeesChange)
    this.$bus.$off('userStateChange', this.tryJionLive)
  },
  methods: {
    /**
     * @desc: 监听房间成员变化
     */
    onRoomAttendeesChange(res) {
      this.roomUserList = res
    },
    /**
     * @desc: 用户进入房间尝试开启摄像头和麦克风
     * @param {users}
     * @return {noSetUser}
     */
    async tryJionLive(users, noSetUser) {
      console.warn('tryJionLive', { users, noSetUser })
      if (roomStore.role == ROLE_TEACHER) {
        let state = (users && users[roomStore.uid])
        if (!users && noSetUser) {
          state = state || { camera: STATE_OPEN, mic: STATE_OPEN }
        }
        console.warn('tryJionLive', { state })
        if (!state) return
        this.$set(this, 'roomAuth', Object.assign(this.roomAuth, state))
        if (state.camera == STATE_OPEN) {
          this.getUserMediaAuth(0, false, async () => {
            await this.toggleDeviceOpen('video', this.controlBtnList[0], false)
          })
        } else {
          await this.toggleDeviceOpen('video', this.controlBtnList[0], false)
        }
        if (state.mic == STATE_OPEN) {
          this.getUserMediaAuth(1, false, async () => {
            await this.toggleDeviceOpen('audio', this.controlBtnList[1], false)
          })
        } else {
          await this.toggleDeviceOpen('audio', this.controlBtnList[1], false)
        }
      } else {
        const state = users && users[roomStore.uid]
        if (!state) return
        console.log('====edu_zpush_room====', state)
        this.$set(this, 'roomAuth', Object.assign(this.roomAuth, state))
        const len = roomStore.joinLiveList.length
        if (len <= 4 && state.camera == STATE_OPEN) {
          this.getUserMediaAuth(0, false, () => {
            this.toggleDeviceOpen('video', this.controlBtnList[0], noSetUser)
          })
        }
        if (len <= 4 && state.mic == STATE_OPEN) {
          this.getUserMediaAuth(1, false, () => {
            this.toggleDeviceOpen('audio', this.controlBtnList[1], noSetUser)
          })
        }

        if (state.camera == STATE_CLOSE) {
          this.getUserMediaAuth(0, false, () => {
            this.toggleDeviceOpen('video', this.controlBtnList[0], noSetUser)
          })
        }
        if (state.mic == STATE_CLOSE) {
          this.getUserMediaAuth(1, false, () => {
            this.toggleDeviceOpen('audio', this.controlBtnList[1], noSetUser)
          })
        }
      }
    },
    /**
     * @desc: 初始化 摄像头/麦克风/扬声器
     */
    async initDevices() {
      const devices = await this.zegoLiveRoom.getDevices()
      console.log({ devices })
      const deviceInfo = {
        camera: devices.cameras,
        microphone: devices.microphones,
        speaker: devices.speakers
      }
      this.$set(this, 'deviceInfo', deviceInfo)
      this.activeDeviceIds.camera = devices.cameras[0].deviceID
      this.activeDeviceIds.microphone = devices.microphones[0].deviceID
      this.activeDeviceIds.speaker = devices.speakers[0].deviceID
      this.zegoLiveRoom.setActiveDevice(this.activeDeviceIds)
    },
    /**
     * @desc: 获取设备权限
     * @param {num} 0video 1audio undefined return
     * @param {showErrorToast} 展示错误提示，默认true
     * @param {cb} 回调方法
     */
    getUserMediaAuth(num, showErrorToast = true, cb) {
      if (num > 1) {
        if (num == 3 && !this.roomAuth.share) {
          this.showToast('老师还未允许你使用共享功能')
        }
        return
      }
      const option = {
        video: num == 0,
        audio: num == 1
      }
      /**
       * @desc: 获取设备权限
       * @param {option} 需要获取权限的设备
       * @param {success} 成功时执行的回调方法
       * @param {error} 失败时执行的回调方法
       */

      getUserMedia(
          option,
          stream => {
            this.controlBtnList[num].noAuth = false
            if (num === 0) {
              stream.getVideoTracks().forEach(track => track.stop())
            } else if (num === 1) {
              stream.getAudioTracks().forEach(track => track.stop())
            }
            console.warn(`${controlBtnList[num].cnName}权限获取成功`)
            this.initDevices()
            cb && cb()
          },
          error => {
            if (num === 0) {
              this.roomAuth.camera = STATE_CLOSE
            } else if (num === 1) {
              this.roomAuth.mic = STATE_CLOSE
            }
            console.warn('摄像头麦克风权限获取错误', error)
            if (showErrorToast) this.showToast(`请在设置中开启${controlBtnList[num].cnName}权限`)
          }
      )
    },

    handleMainBtnClick(item) {
      switch (item.name) {
        case 'camera':
          this.toggleDeviceOpen('video', item, false, true)
          break
        case 'mic':
          this.toggleDeviceOpen('audio', item, false, true)
          break
        case 'speaker':
          if (item) {
            this.zegoLiveRoom.muteSpeaker(!item.isOpen)
            let idx = controlBtnList.findIndex(v => v.name === item.name)
            item = { ...item, isOpen: !item.isOpen }
            idx !== -1 && this.$set(this.controlBtnList, idx, item)
          }
          break
        case 'member':
          this.memberListDialogShow = true
          break
        case 'invite':
          this.shareDialogShow = true
          break
        case 'quit':
          this.quitDialogShow = true
          break
        default:
          break
      }
    },
    /**
     * @desc: 设备状态管理
     * @param {flag} 设备类型
     * @param {item} 点击该按钮信息
     * @param {noSetUser} 更新用户相关信息
     * @param {reverse}
     */
    async toggleDeviceOpen(flag, item, noSetUser, reverse) {
      // if (item.noAuth) {
      //   reverse && this.showToast('获取摄像头/麦克风的系统授权请求')
      //   return
      // }
      if (
          roomStore.role == ROLE_STUDENT &&
          roomStore.joinLiveList.length >= 4 &&
          this.roomAuth[item.name] == STATE_CLOSE
      ) {
        const id = roomStore.uid
        const joined = roomStore.joinLiveList.find(v => v.uid == id)
        if (!joined) {
          await roomStore.setUserInfo({
            target_uid: roomStore.uid,
            camera: STATE_CLOSE,
            mic: STATE_CLOSE
          })
          return this.showToast('演示课堂最多开启3路学生音视频')
        }
      }

      if (!noSetUser) {
        const key = flag == 'video' ? 'camera' : 'mic'
        const val = this.roomAuth[key]
        const params = {
          target_uid: roomStore.uid,
          [key]: reverse ? (val == STATE_OPEN ? STATE_CLOSE : STATE_OPEN) : val
        }
        await roomStore.setUserInfo(params)
        this.roomAuth[key] = params[key]
      }
      await this.zegoLiveRoom.handleDeviceStateChange(
          flag,
          this.roomAuth.camera == STATE_OPEN,
          this.roomAuth.mic == STATE_OPEN
      )
      await roomStore.getJoinLiveList()
    },

    handleMainBtnClick_(item) {
      if (item.noAuth) return
      debounce(this.handleMainBtnClick(item), 500, true)
    },
    /**
     * @desc: 获取设备状态图标
     * @param {item} 对应设备item
     * @return {imgSrc.state} 设备状态图标路径
     */
    getItemIcon(item) {
      // 返回除了摄像头/麦克风/扬声器 的默认图标
      if (!item.canSpread && item.name !== 'speaker') return item.imgSrc.default
      if (item.noAuth) return item.imgSrc.warn
      if (item.isOpen || this.roomAuth[item.name] == STATE_OPEN) return item.imgSrc.open
      return item.imgSrc.close
    },
    /**
     * @desc: 创建白板
     */
    async createWhiteboard() {
      if (!allowSetExtra) return
      if (this.zegoWhiteboardArea) {
        this.zegoWhiteboardArea.setIsAllowSendRoomExtraInfo(true)
        await this.zegoWhiteboardArea.createWhiteboard()
      }
      this.handleAnalogTriggerClick()
    },
    /**
     * @desc: 展示文件列表弹窗
     */
    handleFileListDialog() {
      if (!allowSetExtra) return
      this.zegoWhiteboardArea.setFilesListDialogShow(true)
    },
    /**
     * @desc: 点击创建白板之后关闭改按钮显示
     */
    handleAnalogTriggerClick() {
      const analogTrigger = this.$refs.analogTrigger
      if (analogTrigger) analogTrigger.click()
    },
  },
  beforeDestroy() {
    allowSetExtra = false
  }
}
</script>
<style lang="scss" scoped>
.room-controller-feature {
  display: inline-flex;
  @include wh(100%, 68px);
  margin: 0 auto;
  background-color: #ffffff;
  .control-btn-list {
    display: inline-flex;
    align-items: center;
    height: 100%;
    margin: 0 auto;
    li:hover {
      .can-spread {
        background: #f4f5f8;
        & + span {
          .el-popover__reference {
            border-radius: 0 4px 4px 0;
          }
        }
      }
      .el-popover__reference {
        background-color: #e4e5eb;
      }
    }
  }

  .control-btn-item {
    display: flex;
    align-items: center;
    color: #585c62;
    cursor: pointer;
    // background-color: #f4f5f8;
    .el-popover__reference {
      // border-radius: 0 4px 4px 0;
      .btn-name {
        @include sc(12px, #585c62);
        margin-top: 2px;
        font-family: Microsoft YaHei, Avenir, Helvetica, Arial, sans-serif;
        font-weight: normal;
      }
      .btn-name:hover {
        color: #18191a;
      }
    }
    // .el-popover__reference:active {
    //   background-color: red;
    //   // color: #18191a;
    // }
    & + .control-btn-item {
      margin-left: 16px;
    }

    &.no-auth {
      .sub-btn {
        /deep/ {
          .hover-stroke {
            stroke: #b9bac1;
          }
          .hover-fill {
            fill: #b9bac1;
          }
        }
      }

      .main-btn {
        position: relative;

        &:hover {
          .no-auth-tip {
            display: block;
          }
        }
      }
    }

    /deep/ {
      .el-button {
        padding: 0;
        border: 0;
      }
      .memberNum {
        @include wh(22px, 13px);
        @include sc(10px, #fff);
        @include abs-pos(19px, auto, auto, 19px);
        font-weight: 400;
        line-height: 13px;
        background-color: rgb(70, 74, 77);
        z-index: 2;
        border-radius: 4px;
      }
    }

    .main-btn {
      @include wh(54px, 54px);
      box-sizing: border-box;
      position: relative;
      padding-top: 2px;
      text-align: center;
      font-size: 12px;
      border-radius: 4px;
      background: #fff;
      &.can-spread {
        border-radius: 4px 0 0 4px;
      }

      &:hover {
        background: rgba(244, 245, 248, 1);
      }

      &.active {
        color: #0044ff;
      }

      &:not(.active):hover {
        color: #18191a;
        /deep/ {
          .hover-stroke {
            stroke: #18191a;
          }
          .hover-fill {
            fill: #18191a;
          }
        }
      }

      .main-icon {
        @include wh(32px, 32px);
        margin: 0 auto;
      }

      .no-auth-tip {
        @include sc(12px, #fff);
        @include abs-pos(auto, auto, 105%, 50%);
        display: none;
        height: 32px;
        line-height: 32px;
        padding: 0 9px;
        white-space: nowrap;
        border-radius: 4px;
        background: rgba(0, 0, 0, 0.7);
        transform: translate(-50%, 0);
      }
    }

    .el-sub-btn {
      &.el-button:focus,
      &.el-button:hover {
        background: rgba(228, 229, 235, 1);
        border-radius: 0 4px 4px 0;
      }

      &.el-button:focus {
        .sub-btn {
          .arrow-btn {
            transform: rotate(180deg);
            transition: transform 0.3s ease;
          }
        }
      }

      .sub-btn {
        height: 54px;
        line-height: 54px;

        .arrow-btn {
          width: 14px;
          transform-origin: center;
          transform: rotate(0deg);
          transition: transform 0.3s ease;
        }
      }
    }
  }

  .quit-button {
    display: inline-flex;
    align-items: center;
    height: 100%;
    margin-right: 10px;
    z-index: 10;
    .quit-button-item {
      display: inline-flex;
      flex-direction: row;
      justify-content: center;
      align-items: center;
      @include wh(76px, 36px);
      @include sc(12px, #18191a);
      border: 1px solid #edeff3;
      border-radius: 6px;
      background-color: #fff;
      cursor: pointer;
      // line-height: 36px;
      outline: 0;
      &:hover {
        /deep/ {
          .hover-stroke {
            stroke: #585c62;
          }
        }
        border-color: #b1b4bc;
        color: #18191a;
      }
      &:active {
        color: #0044ff;
        border-color: #0044ff;
        background-color: #f0f4ff;
        /deep/ {
          .hover-stroke {
            stroke: #0044ff;
          }
        }
      }
      .button-icon {
        display: inline-block;
        @include wh(20px, 20px);
        margin-right: 6px;
      }
    }
  }
}
</style>
