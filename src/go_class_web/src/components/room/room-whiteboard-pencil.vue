<template>
  <div class="pencil-text-setting">
    <div class="common-box pencil-box" v-if="activePopperType === 'pencil'">
      <div class="setting-title pencilThickness">笔触粗细</div>
      <ul class="bs-list">
        <li
          v-for="item in brushSizeList"
          :key="item"
          :class="['bs-item', activeBrushSize === item && 'active']"
          :style="
            `width: ${item}px;
            height: ${item}px;
            margin-top: ${(bigItem - item) / 2}px;`
          "
          @click="setBrushSize(item)"
        ></li>
      </ul>
    </div>

    <div class="common-box text-box" v-if="activePopperType === 'text'">
      <div class="setting-title">字体</div>
      <ul class="pencil-style">
        <li
          :class="['pencil-style-item', item.isClicked && 'active']"
          v-for="item in textStyleList"
          :key="item.type"
          @click="setTextStyle(item)"
        >
          <div
            class="style-item"
            v-html="require(`../../assets/icons/room/${item.imgName}.svg`).default"
          ></div>
        </li>
      </ul>
      <div class="setting-title">字号大小</div>
      <ul class="pencil-size">
        <li
          :class="['pencil-size-item', item === activeTextSize && 'active']"
          v-for="item in textSizeList"
          :key="item"
          @click="setTextSize(item)"
        >
          {{ item }}
        </li>
      </ul>
    </div>
    <div class="common-box">
      <div class="setting-title">
        {{ { text: '文本颜色', pencil: '笔触颜色' }[activePopperType] }}
      </div>
      <ul class="color-list">
        <li
          v-for="item in colorList"
          :key="item"
          :class="['color-item', activeColor === item && 'active']"
          :style="`background: ${item}`"
          @click="setBrushColor(item)"
        >
          <div
            :class="['checkmark', item === '#ffffff' && 'white']"
            v-html="require('../../assets/icons/room/tool_checkmark.svg').default"
          ></div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
const textStyleList = [
  {
    imgName: 'text_bold',
    type: 'bold',
    isClicked: false
  },
  {
    imgName: 'text_italic',
    type: 'italic',
    isClicked: false
  }
]
const colorList = [
  '#ffffff',
  '#a4a4a4',
  '#262626',
  '#000000',
  '#f64326',
  '#fd7803',
  '#f9e40a',
  '#37b142',
  '#1FE8E0',
  '#0E6BFE',
  '#6E45C5',
  '#F7666B'
]
export default {
  name: 'RoomWhiteboardPencil',
  props: {
    type: String
  },
  components: {},
  data() {
    return {
      bigItem: 10,
      brushSizeList: [4, 6, 8, 10],
      textSizeList: [18, 24, 36, 48],
      colorList,
      textStyleList
    }
  },
  inject: ['zegoWhiteboardArea'],
  computed: {
    // 当前激活白板文件类型
    activePopperType() {
      return this.zegoWhiteboardArea.activePopperType
    },
    // 当前激活刷子尺寸
    activeBrushSize() {
      return this.zegoWhiteboardArea.activeBrushSize
    },
    // 当前激活文字大小
    activeTextSize() {
      return this.zegoWhiteboardArea.activeTextSize
    },
    // 当前激活颜色
    activeColor() {
      return this.zegoWhiteboardArea.activeColor
    }
  },
  mounted() {},
  methods: {
    // 设置画笔粗细
    setBrushSize(val) {
      this.zegoWhiteboardArea.setBrushSize(val)
      this.$parent.updateCanvasToolList('size', val)
    },
    // 设置画笔颜色
    setBrushColor(val) {
      this.zegoWhiteboardArea.setBrushColor(val)
      this.$parent.updateCanvasToolList('color', val)
    },
    // 设置文本大小
    setTextSize(val) {
      this.zegoWhiteboardArea.setTextSize(val)
      this.$parent.updateCanvasToolList('textSize', val)
    },
    // 设置字体
    setTextStyle(item) {
      item.isClicked = !item.isClicked
      switch (item.type) {
        case 'bold':
          this.zegoWhiteboardArea.setTextStyle(item.type, item.isClicked)
          break
        case 'italic':
          this.zegoWhiteboardArea.setTextStyle(item.type, item.isClicked)
          break
      }
    }
  }
}
</script>
<style lang="scss" scoped>
.pencil-text-setting {
  position: absolute;
  right: 200%;
  top: 50%;
  transform: translate(0, -50%);
  width: 238px;
  background-color: #fff;
  display: flex;
  flex-direction: column;
  border-radius: 6px;
  box-shadow: 0px 10px 30px 0px rgba(0, 0, 0, 0.05);
  .common-box {
    display: block;
  }
  .bs-list {
    display: flex;
    // justify-content: space-around;
    padding-left: 16px;
    text-align: left;
    margin: 0;
    height: 10px;
    line-height: 10px;
    .bs-item {
      background: #b1b4bd;
      margin-right: 20px;
      border-radius: 50%;

      &.active {
        background: #0044ff;
      }
    }
  }
  .pencil-size {
    display: flex;
    align-items: center;
    margin: 10px 0 0 16px;

    .pencil-size-item {
      width: 34px;
      height: 20px;
      line-height: 20px;
      font-size: 12px;
      background-color: #f4f5f8;
      color: #18191a;
      border-radius: 10px;
      margin-right: 10px;

      &.active {
        background-color: #0044ff;
        color: #fff;
      }
    }
  }
  .pencil-style {
    display: flex;
    align-items: center;
    margin: 10px 0 0 16px;

    &-item {
      width: 34px;
      height: 20px;
      line-height: 20px;
      font-size: 12px;
      background-color: #f4f5f8;
      color: #18191a;
      border-radius: 10px;
      margin-right: 10px;

      &.active {
        background-color: #0044ff;
        /deep/ {
          .font-fill {
            fill: #fff;
          }
          .font-stroke {
            stroke: #fff;
          }
        }
      }

      .style-item {
        width: 12px;
        height: 12px;
        margin: 0 auto;
        padding: 2px 0;
      }
    }
  }
  .setting-title {
    color: #585c62;
    font-size: 12px;
    margin-top: 16px;
    margin-left: 16px;
    text-align: left;
  }
  .fontColor {
    clear: both;
  }
  .pencilThickness {
    margin-bottom: 16px;
    height: 10px;
    vertical-align: middle;
  }
  .color-list {
    list-style: none;
    width: 216px;
    height: 50px;
    margin: 16px 16px 20px 16px;
  }
  .color-item {
    border: 2px solid #f4f5f8;
    box-sizing: border-box;
    width: 20px;
    height: 20px;
    display: inline-block;
    border-radius: 50%;
    margin-right: 16px;
    margin-bottom: 10px;

    .checkmark {
      visibility: hidden;
      width: 16px;
      height: 16px;

      &.white {
        /deep/ .stroke {
          stroke: #333;
        }
      }
    }

    &.active {
      .checkmark {
        visibility: visible;
      }
    }
  }
  .el-icon-circle-check {
    width: 12px;
    height: 12px;
  }
}
.pencil-text-setting::after {
  //画笔弹出框的三角形箭头
  border: 6px solid transparent;
  border-left: 6px solid #fff;
  width: 0;
  height: 0;
  position: absolute;
  top: 47%;
  right: -12px;
  content: '';
}
</style>
