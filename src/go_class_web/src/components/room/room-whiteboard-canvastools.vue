<!--
 * @Description: 白板区域内等工具栏（文字，画笔，矩形等工具）
-->
<template>
  <div class="canvas-tools" id="canvasTools">
    <ul class="tools-list">
      <li
        :class="[
          'tool-item',
          item.name === 'undo' && 'divide-line undo',
          item.name === 'save' && 'divide-line save',
          item.name === 'clearCurrentPage' && 'divide-line clearCurrentPage',
          isClickable(item) && 'active',
          hoverState ? '' : 'forbid',
          item.clicked && 'active',
        ]"
        v-for="item in canvasToolList"
        :key="item.name"
        @click="setToolType_(item)"
        @mouseover.prevent.stop="itemHoverState(item.type)"
      >
        <div v-html="require(`../../assets/icons/room/${item.imgName}.svg`).default"></div>
        <div class="tooltip">{{ item.cnName }}</div>
        <room-whiteboard-pencil v-if="!!item.popperType" v-show="activeTextPencil === item.type" />
      </li>
    </ul>
  </div>
</template>

<script>
import { debounce } from '@/utils/tool'
import RoomWhiteboardPencil from '@/components/room/room-whiteboard-pencil'
import { roomStore } from '@/service/biz/room'
import { ROLE_STUDENT } from '@/utils/constants'

const canvasToolConf = {
  color: '#f64326',
  size: 6,
  textSize: 24,
}

export default {
  name: 'RoomWhiteboardTools',
  props: ['initType'],
  inject: ['zegoWhiteboardArea'],
  components: {
    RoomWhiteboardPencil,
  },
  data() {
    return {
      canvasToolList: [
        {
          imgName: 'tool_click',
          cnName: this.$t('wb.wb_tool_click'),
          type: 256,
        },
        {
          imgName: 'tool_choose',
          cnName: this.$t('wb.wb_tool_choice'),
          type: 32,
        },
        {
          imgName: 'tool_hand',
          cnName: this.$t('wb.wb_tool_drag'),
          type: 0,
        },
        {
          imgName: 'tool_laser',
          cnName: this.$t('wb.wb_tool_laser'),
          type: 128,
        },
        {
          imgName: 'tool_pen',
          cnName: this.$t('wb.wb_tool_brush'),
          type: 1,
          popperType: 'pencil',
          ...canvasToolConf,
        },
        {
          imgName: 'tool_text',
          cnName: this.$t('wb.wb_tool_text'),
          type: 2,
          popperType: 'text',
          ...canvasToolConf,
        },
        {
          imgName: 'tool_figure',
          cnName: this.$t('wb.wb_tool_graphical'),
          popperType: 'graph',
          clicked: false,
          type: 'graph',
          ...canvasToolConf,
        },
        {
          imgName: 'tool_eraser',
          cnName: this.$t('wb.wb_tool_erase'),
          type: 64,
        },
        {
          name: 'clear',
          imgName: 'tool_Del',
          cnName: this.$t('wb.wb_tool_clear'),
        },
        {
          name: 'undo',
          imgName: 'tool_cancel',
          cnName: this.$t('wb.wb_tool_revoke'),
        },
        {
          name: 'redo',
          imgName: 'tool_redo',
          cnName: this.$t('wb.wb_tool_redo'),
        },
        {
          name: 'snapshot',
          imgName: 'tool_save',
          cnName: this.$t('wb.wb_tool_save'),
        },
        {
          imgName: 'tool_upload',
          cnName: this.$t('wb.wb_tool_upload_files'),
          type: 'upload',
          clicked: false,
          popperType: 'upload',
        },
      ],
      hoverState: true,
      isNotDoType: ['redo', 'undo', 'snapshot', 'upload'],
    }
  },
  mounted() {
    if (roomStore.role == ROLE_STUDENT) {
      this.setToolType(this.canvasToolList.find((v) => v.type == this.initType))
    }
    this.setToolType_ = debounce(this.setToolType, 500, true)
  },
  watch: {
    activeTextPencil(newVal, oldVal) {
      if (oldVal === 'upload' && !this.isNotDoType.includes(newVal)) {
        this.resetUploadIconStatus(oldVal)
      }
      if (oldVal === 'graph' && !this.isNotDoType.includes(newVal)) {
        this.resetGraphIconStatus()
      }
    },
  },
  computed: {
    /**
     * @desc: 获得当前激活白板默认选择工具类型
     */
    activeToolType() {
      return this.zegoWhiteboardArea.activeToolType
    },
    /**
     * @desc: 获得当前激活白板画笔类型
     */
    activeTextPencil() {
      return this.zegoWhiteboardArea.activeTextPencil
    },
    activeViewIsPPTH5() {
      return this.zegoWhiteboardArea.activeViewIsPPTH5
    },
    activeViewIsH5() {
      return this.zegoWhiteboardArea.activeViewIsH5
    },
    graphTypes() {
      return this.zegoWhiteboardArea.graphTypes
    },
    graphType() {
      return this.zegoWhiteboardArea.graphType
    },
    fileUploadStatus() {
      return this.zegoWhiteboardArea.fileUploadStatus
    },
  },
  methods: {
    /**
     * @desc: 判断如果是非动态ppt，则点击工具不可点击
     * @param {item} 点击item
     */
    isClickable(item) {
      if (item.type === this.activeToolType) {
        if ((this.activeViewIsPPTH5 || this.activeViewIsH5) && item.type === 256) return true
        if (item.type === 256) return false
        return true
      }
    },
    /**
     * @desc: 鼠标hover图标，判断如果是非动态ppt，则点击工具为禁止点击样式
     * @param {type} hover经过的工具类型
     */
    itemHoverState(type) {
      if (type === 'upload') {
        this.hoverState = this.fileUploadStatus === 0 || this.fileUploadStatus === 16
      } else if (this.activeViewIsPPTH5 || this.activeViewIsH5) {
        this.hoverState = true
      } else {
        this.hoverState = type === 256 ? false : true
      }
    },

    /**
     * @desc: 设置工具类型
     */
    async setToolType(item) {
      const type = item.type
      if (!this.hoverState) return
      // 非动态ppt文件不可以选择点击工具
      if (!(this.activeViewIsPPTH5 || this.activeViewIsH5) && type === 256) return
      // 多选图元点击橡皮擦可批量删除
      if (type === 64) this.zegoWhiteboardArea.deleteSelectedGraphics()
      this.zegoWhiteboardArea.setActivePopperType(item.popperType)

      const isNotDoType = !(
        item.name === 'redo' ||
        item.name === 'undo' ||
        item.name === 'snapshot'
      )
      // 点击工具，将 图形 按钮点击激活样式关闭
      var graphIcon = this.canvasToolList.filter(function (item) {
        return item.popperType == 'graph'
      })

      if (isNotDoType) graphIcon[0].clicked = false

      // 点击工具，将 上传 按钮点击激活样式关闭
      var uploadIcon = this.canvasToolList.filter(function (item) {
        return item.popperType == 'upload'
      })
      if (isNotDoType) uploadIcon[0].clicked = false

      if (typeof type === 'number') {
        this.zegoWhiteboardArea.setActiveToolType(type)
        console.warn('这里设置白板工具类型:', type)
        this.zegoWhiteboardArea.activeWBView.setToolType(type || null)
      } else {
        // 点击图形按钮，默认为矩形
        if (item.popperType === 'graph') {
          item.clicked = true
          console.warn('这里设置白板工具类型-图形:', this.zegoWhiteboardArea.graphType)
          this.zegoWhiteboardArea.activeWBView.setToolType(this.zegoWhiteboardArea.graphType)
          this.zegoWhiteboardArea.setActiveToolType(this.zegoWhiteboardArea.graphType)
        } else if (item.popperType === 'upload') {
          const checkResult = this.zegoWhiteboardArea.checkViewFileMaxLength('file')
          if (checkResult) {
            return this.$message(checkResult)
          } else {
            item.clicked = true
            // this.zegoWhiteboardArea.activeWBView.setToolType(null)
            // this.zegoWhiteboardArea.setActiveToolType('upload')
          }
        } else {
          if (item.name === 'snapshot') {
            const wbname = this.zegoWhiteboardArea.activeWBView.getName()
            const data = await this.zegoWhiteboardArea.activeWBView[item.name]({ userData: '11' })
            this.saveFile(data.image, `${wbname}`)
          } else {
            this.zegoWhiteboardArea.activeWBView[item.name]()
          }
        }
      }
      if (this.zegoWhiteboardArea.pencilTextTypes.includes(type)) {
        this.zegoWhiteboardArea.setActiveTextPencil(type)
        this.resetCanvasToolList(type)
      } else {
        this.zegoWhiteboardArea.resetActiveTextPencil()
      }
    },
    /**
     * 在本地进行文件保存
     * @param  {String} data     要保存到本地的图片数据
     * @param  {String} filename 文件名
     */
    saveFile(data, filename) {
      const save_link = document.createElementNS('http://www.w3.org/1999/xhtml', 'a')
      save_link.href = data
      let downloadFilename = filename.endsWith('png') ? filename : filename + '.png'
      save_link.download = downloadFilename

      const event = document.createEvent('MouseEvents')
      event.initMouseEvent(
        'click',
        true,
        false,
        window,
        0,
        0,
        0,
        0,
        0,
        false,
        false,
        false,
        false,
        0,
        null
      )
      save_link.dispatchEvent(event)
      this.$message(this.$t('wb.wb_tip_save_success'))
    },
    /**
     * @desc: 重置工具面板
     * @param {type} 类型
     */
    resetCanvasToolList(type) {
      const tool = this.canvasToolList.find((item) => item.type && item.type == type)
      if (tool.type !== 'upload') {
        this.zegoWhiteboardArea.setActiveColor(tool.color)
        this.zegoWhiteboardArea.setActiveBrushSize(tool.size)
        this.zegoWhiteboardArea.setActiveTextSize(tool.textSize)
        this.zegoWhiteboardArea.setBrushColor(this.zegoWhiteboardArea.activeColor)
        this.zegoWhiteboardArea.setBrushSize(this.zegoWhiteboardArea.activeBrushSize)
        this.zegoWhiteboardArea.setTextSize(this.zegoWhiteboardArea.activeTextSize)
      }
    },

    /**
     * @desc: 更新canvasToolList
     * @param {key}
     * @param {value}
     */
    updateCanvasToolList(key, value) {
      const type =
        this.zegoWhiteboardArea.activeTextPencil == 'graph'
          ? 'graph'
          : +this.zegoWhiteboardArea.activeTextPencil
      console.warn('updateCanvasToolList', type)
      const tool = this.canvasToolList.find((item) => item.type && item.type == type)
      if (tool) {
        tool[key] = value
      }
    },
    resetUploadIconStatus() {
      var uploadIcon = this.canvasToolList.filter(function (item) {
        return item.popperType == 'upload'
      })
      uploadIcon[0].clicked = false
      this.zegoWhiteboardArea.resetActiveTextPencil()
    },
    resetGraphIconStatus() {
      var uploadIcon = this.canvasToolList.filter(function (item) {
        return item.popperType == 'upload'
      })
      uploadIcon[0].clicked = false
    },
  },
}
</script>

<style lang="scss">
.canvas-tools {
  @include abs-pos(50%, 10px, auto, auto);
  padding: 2px 0;
  @include box-shadow(0px 10px 30px 0px rgba(0, 0, 0, 0.05));
  transform: translate(0, -50%);
  background: #fff;
  z-index: 9;
  border-radius: 4px;

  .tool-item {
    @include wh(20px, 20px);
    position: relative;
    margin: 13px 10px;
    cursor: pointer;

    &.divide-line {
      margin-top: -4px;
      padding-top: 10px;
      border-top: 1px solid rgba(237, 239, 243, 1);
    }
    &.undo {
      margin-bottom: 11px;
    }
    &.clearCurrentPage {
      &:hover {
        .tooltip {
          margin-top: 4px;
        }
      }
    }
    &.disabled {
      pointer-events: none;
    }
    &.forbid {
      &:hover {
        cursor: not-allowed !important;
        .hover-fill {
          fill: #b0b3ba !important;
        }
        .hover-stroke {
          stroke: #b0b3ba !important;
        }
      }
    }
    &:hover {
      .hover-fill {
        fill: #18191a;
      }
      .hover-stroke {
        stroke: #18191a;
      }

      .tooltip {
        display: block;
        background: rgba(0, 0, 0, 0.7);
      }
    }

    &.active {
      .hover-fill {
        fill: #0044ff;
      }
      .hover-stroke {
        stroke: #0044ff;
      }
    }
    .tooltip {
      @include sc(12px, #fff);
      @include abs-pos(50%, 110%, auto, auto);
      display: none;
      padding: 9px;
      white-space: nowrap;
      background: #18191a;
      border-radius: 4px;
      transform: translate(0, -50%);
    }
  }
}
</style>
