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
          item.name === 'clearCurrentPage' && 'divide-line clearCurrentPage',
          isClickable(item) && 'active',
          hoverState ? '' : 'forbid',
          item.popperType === 'graph' && item.clicked && 'active'
        ]"
        v-for="item in canvasToolList"
        :key="item.name"
        @click.prevent.stop="setToolType_(item)"
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
import { roomStore } from '@/service/store/roomStore'
import { ROLE_STUDENT } from '@/utils/constants'

const canvasToolConf = {
  color: '#f64326',
  size: 6,
  textSize: 24
}
const canvasToolList = [
  {
    imgName: 'tool_click',
    cnName: '点击',
    type: 256
  },
  {
    imgName: 'tool_choose',
    cnName: '选择',
    type: 32
  },
  {
    imgName: 'tool_hand',
    cnName: '拖拽',
    type: 0
  },
  {
    imgName: 'tool_laser',
    cnName: '激光笔',
    type: 128
  },
  {
    imgName: 'tool_pen',
    cnName: '画笔',
    type: 1,
    popperType: 'pencil',
    ...canvasToolConf
  },
  {
    imgName: 'tool_text',
    cnName: '文本',
    type: 2,
    popperType: 'text',
    ...canvasToolConf
  },
  {
    imgName: 'tool_figure',
    cnName: '图形',
    popperType: 'graph',
    clicked: false,
    type: 'graph',
    ...canvasToolConf
  },
  {
    imgName: 'tool_eraser',
    cnName: '橡皮擦',
    type: 64
  },
  {
    name: 'clear',
    imgName: 'tool_Del',
    cnName: '清空'
  },
  {
    name: 'undo',
    imgName: 'tool_cancel',
    cnName: '撤销'
  },
  {
    name: 'redo',
    imgName: 'tool_redo',
    cnName: '重做'
  }
]

export default {
  name: 'RoomWhiteboardTools',
  props: ['initType'],
  inject: ['zegoWhiteboardArea'],
  components: {
    RoomWhiteboardPencil
  },
  data() {
    return {
      canvasToolList,
      hoverState: true
    }
  },
  mounted() {
    if (roomStore.role == ROLE_STUDENT) {
      this.setToolType(this.canvasToolList.find(v => v.type == this.initType))
    }
    this.setToolType_ = debounce(this.setToolType, 500, true)
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
    graphTypes() {
      return this.zegoWhiteboardArea.graphTypes
    },
    graphType() {
      return this.zegoWhiteboardArea.graphType
    }
  },
  methods: {
    /**
     * @desc: 判断如果是非动态ppt，则点击工具不可点击
     * @param {item} 点击item
     */
    isClickable(item) {
      if (item.type === this.activeToolType) {
        if (this.activeViewIsPPTH5 && item.type === 256) return true
        if (item.type === 256) return false
        return true
      }
    },
    /**
     * @desc: 鼠标hover图标，判断如果是非动态ppt，则点击工具为禁止点击样式
     * @param {type} hover经过的工具类型
     */
    itemHoverState(type) {
      if (this.activeViewIsPPTH5) {
        this.hoverState = true
      } else {
        this.hoverState = type === 256 ? false : true
      }
    },

    /**
     * @desc: 设置工具类型
     */
    setToolType(item) {
      const type = item.type
      // 非动态ppt文件不可以选择点击工具
      if (!this.activeViewIsPPTH5 && type === 256) return
      // 多选图元点击橡皮擦可批量删除
      if (type === 64) this.zegoWhiteboardArea.deleteSelectedGraphics()
      this.zegoWhiteboardArea.setActivePopperType(item.popperType)

      // 点击工具，将 图形 按钮点击激活样式关闭
      var graphIcon = this.canvasToolList.filter(function(item) {
        return item.popperType == 'graph'
      })
      graphIcon[0].clicked = false

      if (typeof type === 'number') {
        this.zegoWhiteboardArea.setActiveToolType(type)
        this.zegoWhiteboardArea.activeWBView.setToolType(type || null)
      } else {
        // 点击图形按钮，默认为矩形
        if (item.popperType === 'graph') {
          item.clicked = true
          this.zegoWhiteboardArea.activeWBView.setToolType(this.zegoWhiteboardArea.graphType)
          this.zegoWhiteboardArea.setActiveToolType(this.zegoWhiteboardArea.graphType)
        } else {
          this.zegoWhiteboardArea.activeWBView[item.name]()
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
     * @desc: 重置工具面板
     * @param {type} 类型
     */
    resetCanvasToolList(type) {
      const tool = canvasToolList.find(item => item.type && item.type == type)
      if (tool) {
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
        this.zegoWhiteboardArea.activeTextPencil == 'graph' ? 'graph' : +this.zegoWhiteboardArea.activeTextPencil
      console.warn('updateCanvasToolList', type)
      const tool = canvasToolList.find(item => item.type && item.type == type)
      if (tool) {
        tool[key] = value
      }
    }
  }
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
      padding: 10px;
      white-space: nowrap;
      background: #18191a;
      border-radius: 4px;
      transform: translate(0, -50%);
    }
  }
}
</style>
