<template>
  <div class="room-whiteboard-area">
    <room-whiteboard-none v-if="!WBViewList.length" :auth="roomAuth.share" />
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
import { isElectron } from '@/utils/tool'
import RoomWhiteboardNone from '@/components/room/room-whiteboard-none'
import RoomWhiteboardCanvastools from '@/components/room/room-whiteboard-canvastools'
import RoomControllerPpt from '@/components/room/room-controller-ppt'
import RoomControllerThumbnails from '@/components/room/room-controller-thumbnails'
import RoomDialogEnd from '@/components/room/room-dialog-end'
import { roomStore } from '@/service/biz/room'
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
      // activeToolType: 1,
      isElectron: isElectron,
      // noList: false,
      defaultAspectAutio: 16 / 9,
      roomAuth: roomStore.auth
    }
  },
  computed: {
    isThumbnailsVisible() {
      return this.zegoWhiteboardArea.isThumbnailsVisible
    },
    activeToolType(){
      return this.zegoWhiteboardArea.activeToolType
    },
    activeViewIsPPTH5(){
      return this.zegoWhiteboardArea.activeViewIsPPTH5
    },
    WBViewList() {
      return this.zegoWhiteboardArea.WBViewList
    }
  },
  watch: {
    'zegoWhiteboardArea.activeWBView': function(view) {
      this.setWBViewEnable(view)
    },
    'roomAuth.share': function() {
      this.setWBViewEnable(this.zegoWhiteboardArea.activeWBView)
    }
  },
  mounted() {
    this.init()
    this.$bus.$on('endTeaching', this.endTeaching)
  },
  destroyed() {
    this.$bus.$off('endTeaching', this.endTeaching)
  },
  methods: {
    init() {
      this.initCanvasWidthHeight()
      this.initLayoutHeight()
    },

    initCanvasWidthHeight() {
      const $whiteboardDemo = document.getElementById("whiteboardDemo");

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
      if ($canvasTools && $whiteboardDemo)
        $canvasTools.style.right = $whiteboardDemo.offsetLeft + 10 + 'px'
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
        const val = this.roomAuth.share
        view.enable(val)
        view.setToolType(val ? 1 : null)
        if(val){
          // 如果当前文件不是动态ppt但是当前使用工具是点击工具就重置工具
          if(!this.activeViewIsPPTH5 && this.activeToolType === 256){
            view.setToolType(1)
            this.zegoWhiteboardArea.set()
            // this.activeToolType = 1
          }else{
            view.setToolType(this.activeToolType)
          }
        }else {
          view.setToolType(null)
        }
        // if (val) {
        //   this.activeToolType = 1
        // }
      }
    },

    endTeaching() {
      if(roomStore.role == ROLE_STUDENT) this.$refs.endDialog.show = true
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
    border: 1px solid aliceblue;

    .whiteboard-canvas {
      @include wh(100%, 100%);
      position: relative;
      margin: 0 auto;
      //position: absolute !important;
    }

    .canvas-tools {
      @include abs-pos(50%, 10px, auto, auto);
      @include box-shadow(0px 10px 30px 0px rgba(0, 0, 0, 0.05));
      transform: translate(0, -50%);
      background: #fff;
      z-index: 9;
      border-radius: 4px;

      .tool-item {
        @include wh(20px, 20px);
        position: relative;
        margin: 16px 10px;
        cursor: pointer;

        &.divide-line {
          margin-top: -4px;
          padding-top: 10px;
          border-top: 1px solid rgba(237, 239, 243, 1);
        }

        &.disabled {
          pointer-events: none;
        }

        &:hover {
          /deep/ {
            .hover-fill {
              fill: #18191a;
            }
            .hover-stroke {
              stroke: #18191a;
            }
          }

          .tooltip {
            display: block;
            background: rgba(0, 0, 0, 0.7);
          }
        }

        &.active {
          /deep/ {
            .hover-fill {
              fill: #0044ff;
            }
            .hover-stroke {
              stroke: #0044ff;
            }
          }
        }

        .tooltip {
          @include sc(12px, #fff);
          @include abs-pos(50%, 110%, auto, auto);
          display: none;
          padding: 10px;
          white-space: nowrap;
          background: #18191a;
          border-radius: 4px;
          transform: translate(0, -50%);
        }
      }
    }
  }
}
</style>
