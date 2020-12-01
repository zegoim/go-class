<template>
  <div class="room-controller-video">
    <ul class="controller-btn-list">
      <li
        v-for="item in controlBtnList"
        :key="item.name"
        :class="['btn-content', getItemDisabled(item) ? 'disabled' : '']"
      >
        <el-tooltip
          :disabled="getItemDisabled(item)"
          effect="dark"
          :content="getItemContent(item)"
          placement="bottom"
          :visible-arrow="false"
        >
          <div
            :class="['main-btn', user[item.name] == 2 ? 'isOpen' : 'isClose']"
            @click="handleMainBtnClick_(item)"
          >
            <div class="main-icon" v-html="getItemIcon(item)"></div>
          </div>
        </el-tooltip>
      </li>
    </ul>
    <div class="user-name">
      <el-tooltip class="item" effect="dark" :content="userName" placement="bottom">
        <span>{{ userName }}</span>
      </el-tooltip>
    </div>
  </div>
</template>

<script>
const controlBtnList = [
  {
    name: 'camera',
    cnName: '摄像头',
    imgSrc: {
      open: require('../../assets/icons/room/seating_camer.svg').default,
      close: require('../../assets/icons/room/seating_camer_close.svg').default
    }
  },
  {
    name: 'mic',
    cnName: '麦克风',
    imgSrc: {
      open: require('../../assets/icons/room/seating_micophone.svg').default,
      close: require('../../assets/icons/room/seating_micophone_close.svg').default
    }
  },
  {
    name: 'can_share',
    cnName: '共享授权',
    imgSrc: {
      open: require('../../assets/icons/room/seating_share.svg').default,
      close: require('../../assets/icons/room/seating_share_close.svg').default
    }
  }
]

import { debounce } from '@/utils/tool'
import { roomStore } from '@/service/biz/room'
import { ROLE_TEACHER, STATE_CLOSE, STATE_OPEN } from '@/utils/constants'

export default {
  name: 'RoomControllerVideo',
  props: ['user', 'isTeacher'],
  data() {
    return {
      controlBtnList: this.isTeacher ? controlBtnList.slice(0, 2) : controlBtnList
    }
  },
  computed: {
    userName() {
      return this.user.userName || this.user.nick_name
    }
  },
  created() {
    this.roomId = roomStore.roomId
    this.userId = roomStore.uid
    this.role = roomStore.role
    this.isMe = this.userId == this.user.uid
  },
  methods: {
    getItemDisabled({ name }) {
      return this.role == ROLE_TEACHER ? false : !(this.isMe && name !== 'can_share')
    },
    getItemIcon(item) {
      return this.user[item.name] == STATE_OPEN ? item.imgSrc.open : item.imgSrc.close
    },
    getItemContent(item) {
      const isOpen = this.user[item.name] == STATE_OPEN
      let str = isOpen ? '关闭' : '打开'
      if (item.name == 'can_share') {
        str = isOpen ? '取消' : ''
      }
      return str + item.cnName
    },
    handleMainBtnClick_(item) {
      debounce(this.handleMainBtnClick(item), 500, true)
    },
    async handleMainBtnClick({ name }) {
      if (this.isMe && name === 'can_share') return
      if (this.role == ROLE_TEACHER || this.isMe) {
        const state = this.user[name] == STATE_OPEN ? STATE_CLOSE : STATE_OPEN
        await roomStore.setUserInfo({
          target_uid: this.user.uid,
          [name]: state
        })
        this.user[name] = state
        if (this.isMe) {
          this.$bus.$emit('userStateChange', { [this.user.uid]: { [name]: state } }, false)
        }
      }
    }
  }
}
</script>

<style lang="scss">
.room-controller-video {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  @include abs-pos(6px, 4px, 10px, auto);
  z-index: 100;
  .controller-btn-list {
    display: flex;
    justify-content: flex-end;
    .btn-content {
      display: flex;
      align-items: center;
      justify-content: center;
      @include wh(28px, 28px);
      margin-right: 6px;
      border-radius: 50%;
      background-color: rgba($color: #000000, $alpha: 0.6);
      &:not(.disabled):hover {
        background-color: rgba($color: #000000, $alpha: 0.8);
        cursor: pointer;
      }
    }
    .main-btn {
      @include wh(18px, 18px);
    }
    .main-icon {
      @include wh(18px, 18px);
      margin: 0 auto;
    }
  }
  .user-name {
    display: flex;
    justify-content: flex-end;
    margin-right: 6px;
    span {
      display: inline-block;
      height: 22px;
      max-width: 73px;
      padding: 0 10px;
      @include sc(12px, #ffffff);
      @include textCenter(22px);
      @include ellipsis();
      border-radius: 12px;
      background-color: rgba($color: #000000, $alpha: 0.6);
      cursor: pointer;
    }
  }
}
</style>
