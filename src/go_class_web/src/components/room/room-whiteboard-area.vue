<!--
 * @Description: 白板操作区域组件
-->
<template>
  <div class="room-whiteboard-area">
    <room-whiteboard-none v-if="noList" :auth="roomAuth.share" :role="role" />
    <div class="whiteboard-canvas-wrap" id="mainArea">
      <div class="whiteboard-canvas" id="whiteboardDemo" @click="handleEntireCanvasClick"></div>
      <room-whiteboard-canvastools v-if="roomAuth.share" :initType="activeToolType" />
      <room-controller-ppt v-if="roomAuth.share" />
      <room-controller-thumbnails v-show="roomAuth.share && isThumbnailsVisible" />
    </div>
    <room-dialog-end ref="endDialog" />
  </div>
</template>

<script>
import RoomWhiteboardNone from '@/components/room/room-whiteboard-none'
import RoomWhiteboardCanvastools from '@/components/room/room-whiteboard-canvastools'
import RoomControllerPpt from '@/components/room/room-controller-ppt'
import RoomControllerThumbnails from '@/components/room/room-controller-thumbnails'
import RoomDialogEnd from '@/components/room/room-dialog-end'
import { roomStore } from '@/service/store/roomStore'
import { ROLE_STUDENT } from '@/utils/constants'

export default {
  name: 'RoomWhiteboardArea',
  inject: ['zegoWhiteboardArea'],
  components: {
    RoomWhiteboardNone,
    RoomWhiteboardCanvastools,
    RoomControllerPpt,
    RoomControllerThumbnails,
    RoomDialogEnd
  },
  data() {
    return {
      isMounted: false,
      noList: false,
      defaultAspectAutio: 16 / 9,
      roomAuth: roomStore.auth,
      role: roomStore.role
    }
  },
  computed: {
    isThumbnailsVisible() {
      return this.zegoWhiteboardArea.isThumbnailsVisible
    },
    activeToolType() {
      return this.zegoWhiteboardArea.activeToolType
    },
    activeViewIsPPTH5() {
      return this.zegoWhiteboardArea.activeViewIsPPTH5
    }
  },
  watch: {
    'zegoWhiteboardArea.WBViewList': function() {
      this.noList = !this.zegoWhiteboardArea.WBViewList.length && this.isMounted
    },
    'zegoWhiteboardArea.activeWBView': function(view) {
      this.setWBViewEnable(view)
    },
    'roomAuth.share': function() {
      this.setWBViewEnable(this.zegoWhiteboardArea.activeWBView)
    }
  },
  mounted() {
    this.init()
    roomStore.$on('endTeaching', this.endTeaching)
  },
  destroyed() {
    roomStore.$off('endTeaching', this.endTeaching)
  },
  methods: {
    async init() {
      try {
        this.WBViewList = await this.zegoWhiteboardArea.getViewList()
        this.initCanvasWidthHeight()
        this.initLayoutHeight()
        if (this.WBViewList.length == 0 && this.roomAuth.share) {
          this.$nextTick(() => {
            this.zegoWhiteboardArea.setIsAllowSendRoomExtraInfo(true)
            this.zegoWhiteboardArea.createWhiteboard()
          })
        }
      } finally {
        this.noList = this.WBViewList.length == 0
        this.isMounted = true
      }
    },

    initCanvasWidthHeight() {
      const $whiteboardDemo = document.getElementById('whiteboardDemo')
      if ($whiteboardDemo) {
        const { clientWidth, clientHeight } = $whiteboardDemo
        const ratio = clientWidth / clientHeight
        if (ratio > 16 / 9) {
          $whiteboardDemo.style.width = Math.ceil(this.defaultAspectAutio * clientHeight) + 'px'
        } else {
          const height = Math.ceil(clientWidth / this.defaultAspectAutio) + 'px'
          $whiteboardDemo.style.height = height
        }
        this.$nextTick(() => {
          this.zegoWhiteboardArea.aspectWidth = $whiteboardDemo.clientWidth
          this.zegoWhiteboardArea.aspectHeight = $whiteboardDemo.clientHeight
        })
      }

      const $canvasTools = document.getElementById('canvasTools')
      if ($canvasTools && $whiteboardDemo) $canvasTools.style.right = $whiteboardDemo.offsetLeft + 10 + 'px'
    },

    initLayoutHeight() {
      const mainHeight = document.getElementsByClassName('main-area')[0].clientHeight || 0
      const whiteboardAreaHeight = document.getElementById('whiteboardDemo').clientHeight || 0
      const minusHeight = mainHeight - whiteboardAreaHeight
      const $controlBtnList = document.getElementsByClassName('main-bottom')[0]
      const $whiteboardBar = document.getElementsByClassName('main-top')[0]
      const whiteboardBarHeight = Math.ceil((minusHeight * 40) / (68 + 40))
      const controlBtnListHeight = mainHeight - whiteboardAreaHeight - whiteboardBarHeight
      if ($whiteboardBar) $whiteboardBar.style.height = whiteboardBarHeight + 'px'
      if ($controlBtnList) $controlBtnList.style.height = controlBtnListHeight + 'px'
    },

    handleEntireCanvasClick() {
      this.zegoWhiteboardArea.resetActiveTextPencil()
    },

    setWBViewEnable(view) {
      if (roomStore.role == ROLE_STUDENT && view) {
        // setTimeout(() => {
        const val = this.roomAuth.share
        val ? view.setWhiteboardOperationMode(2 | 4 | 8) : view.setWhiteboardOperationMode(8)
        window.aaa = view
        view.setToolType(val ? 1 : null)
        if (val) {
          // 如果当前文件不是动态ppt但是当前使用工具是点击工具就重置工具
          if (!this.activeViewIsPPTH5 && this.activeToolType === 256) {
            view.setToolType(1)
          } else {
            view.setToolType(this.activeToolType)
          }
        }
        // }, 10);
      }
    },

    endTeaching() {
      if (roomStore.role == ROLE_STUDENT) this.$refs.endDialog.show = true
    }
  }
}
</script>

<style lang="scss">
.room-whiteboard-area {
  @include wh(100%, 100%);
  @include flex-column();
  flex-grow: 1;
  position: relative;

  .whiteboard-canvas-wrap {
    flex: 1;
    position: relative;
    .whiteboard-canvas {
      @include wh(100%, 100%);
      position: relative;
      margin: 0 auto;
      border: 1px solid aliceblue;
      box-sizing: border-box;
    }
  }
}
</style>
