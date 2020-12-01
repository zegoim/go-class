<!--
 * @Description: 成员列表设备管理组件
-->
<template>
  <div class="room-controller-device">
    <ul class="control-btn-list">
      <li v-for="item in controlBtnList" :key="item.name" class="control-btn-item">
        <el-tooltip effect="dark" :content="getItemContent(item)" placement="bottom">
          <div
            :class="['main-btn', user[item.name] == 2 ? 'isOpen' : 'isClose']"
            @click="handleMainBtnClick_(item)"
          >
            <div class="main-icon" v-html="getItemIcon(item)"></div>
          </div>
        </el-tooltip>
      </li>
    </ul>
  </div>
</template>
<script>
const controlBtnList = [
  {
    name: 'camera',
    cnName: '摄像头',
    imgSrc: {
      open: require('../../assets/icons/room/mumber_camer.svg').default,
      close: require('../../assets/icons/room/mumber_camer_close.svg').default
    }
  },
  {
    name: 'mic',
    cnName: '麦克风',
    imgSrc: {
      open: require('../../assets/icons/room/mumber_micophone.svg').default,
      close: require('../../assets/icons/room/mumber_micophone_close.svg').default
    }
  },
  {
    name: 'can_share',
    cnName: '共享授权',
    imgSrc: {
      open: require('../../assets/icons/room/mumber_share.svg').default,
      close: require('../../assets/icons/room/mumber_share_close.svg').default
    }
  }
]

import { debounce } from '@/utils/tool'
import { roomStore } from '@/service/biz/room'
import { ROLE_TEACHER, STATE_CLOSE, STATE_OPEN } from '@/utils/constants'

export default {
  name: 'RoomControllerDevice',
  props: ['user'],
  data() {
    return {
      controlBtnList
    }
  },
  mounted() {
    this.roomId = roomStore.roomId // 房间id
    this.userId = roomStore.uid // 用户id
    this.role = roomStore.role  // 用户角色
    this.handleMainBtnClick_ = debounce(this.handleMainBtnClick, 500, true)
  },
  methods: {
    /**
     * @desc: 获取该设备状态
     * @param {item}  目标设备
     */
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

    /**
     * @desc: 设备管理
     * @param {name} 目标设备名称
     */    
    async handleMainBtnClick({ name }) {
      const isOpen = this.user[name] == STATE_OPEN
      if (name !== 'can_share' && !isOpen && roomStore.joinLiveList.length >= 4) {
        const id = this.userId
        const joined = roomStore.joinLiveList.find(v => v.uid == id)
        if (!joined) {
          return this.showToast('演示课堂最多开启3路学生音视频')
        }
      }
      if (this.role == ROLE_TEACHER) {
        const state = isOpen ? STATE_CLOSE : STATE_OPEN
        await roomStore.setUserInfo({
          target_uid: this.user.uid,
          [name]: state
        })
        this.user[name] = state
      }
    }
  }
}
</script>
<style lang="scss">
.room-controller-device {
  @include wh(86px, 34px);
  display: inline-flex;
  justify-content: space-between;
  align-items: center;
  .control-btn-list {
    display: inline-flex;
    align-items: center;
    justify-content: space-between;
    height: 100%;
    width: 86px;
    margin: 0 auto;
  }
  .control-btn-item {
    display: flex;
    align-items: center;
    cursor: pointer;
    .main-btn {
      @include wh(18px, 18px);
      position: relative;
      &:not(.isOpen):hover {
        // /deep/ {
        .hover-stroke {
          stroke: #5c5e66;
        }
        // }
      }
      &:not(.isClose):hover {
        // /deep/ {
        .hover-stroke {
          stroke: #0030ff;
        }
        // }
      }

      .main-icon {
        @include wh(18px, 18px);
        margin: 0 auto;
        svg {
          display: block;
        }
      }
    }
  }
}
</style>
