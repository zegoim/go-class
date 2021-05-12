<template>
  <div class="canvas-tools" id="canvasTools">
    <ul class="tools-list">
      <li
        :class="[
          'tool-item',
          item.name === 'undo' && 'divide-line',
          isClickable(item) && 'active',
          hoverState ? '' : 'forbid'
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
import { roomStore } from '@/service/biz/room'
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
    imgName: 'tool_square',
    cnName: '矩形',
    type: 8,
    popperType: 'pencil',
    ...canvasToolConf
  },
  {
    imgName: 'tool_round',
    cnName: '椭圆',
    type: 16,
    popperType: 'pencil',
    ...canvasToolConf
  },
  {
    imgName: 'tool_eraser',
    cnName: '橡皮擦',
    type: 64
  },
  {
    imgName: 'tool_line',
    cnName: '直线',
    type: 4,
    popperType: 'pencil',
    ...canvasToolConf
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
    setToolType_(item) {
      // 非动态ppt文件不可以选择点击工具
      if (!this.activeViewIsPPTH5 && item.type === 256) return
      debounce(this.setToolType(item), 500, true)
    },

    /**
     * @desc: 设置工具类型
     */
    setToolType(item) {
      console.warn(this.zegoWhiteboardArea.activeWBView)
      console.warn('setToolType item=', item)
      this.zegoWhiteboardArea.setActivePopperType(item.popperType)
      const type = item.type
      if (typeof type === 'number') {
        this.zegoWhiteboardArea.setActiveToolType(type)
        this.zegoWhiteboardArea.activeWBView.setToolType(type || null)
      } else {
        this.zegoWhiteboardArea.activeWBView[item.name]()
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
      const type = +this.zegoWhiteboardArea.activeTextPencil
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
    margin: 12px 10px;
    cursor: pointer;

    &.divide-line {
      margin-top: -4px;
      padding-top: 10px;
      border-top: 1px solid rgba(237, 239, 243, 1);
    }

    &.disabled {
      pointer-events: none;
    }
    &.forbid {
      &:hover {
        cursor: not-allowed !important;
        /deep/ {
          .hover-fill {
            fill: #b0b3ba !important;
          }
          .hover-stroke {
            stroke: #b0b3ba !important;
          }
        }
      }
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
</style>
