<!--
 * @Description: 白板工具-文字、矩形和画笔等样式设置
-->
<template>
  <div :class="['pencil-text-setting', activePopperType === 'upload' ? 'upload-setting' : '']">
    <div ref="trigger" />
    <div class="common-box pencil-box" v-if="activePopperType === 'graph' ">
      <div class="setting-title pencilThickness">{{$t('wb.wb_tool_shape_selection')}}</div>
      <ul class="pencil-style">
        <li
          :class="['graph-style-item', item.type === activeToolType && 'active']"
          v-for="item in graphList"
          :key="item.type"
          @click="setGraphType(item)"
        >
          <div
            class="style-item"
            v-html="require(`../../assets/icons/room/${item.imgName}.svg`).default"
          ></div>
        </li>
      </ul>
    </div>

    <div class="common-box pencil-box" v-if="activePopperType === 'pencil' || activePopperType === 'graph'">
      <div class="setting-title pencilThickness">{{$t('wb.wb_tool_pen_style_thickness')}}</div>
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
      <div class="setting-title">{{$t('wb.wb_tool_font')}}</div>
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
      <div class="setting-title">{{$t('wb.wb_tool_font_size')}}</div>
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
    <div class="common-box" v-if="activePopperType !== 'upload'">
      <div class="setting-title">
        {{ { text: $t('wb.wb_tool_text_color'), pencil: $t('wb.wb_tool_pen_stroke_color'), graph: $t('wb.wb_tool_pen_stroke_color') }[activePopperType] }}
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
    <div class="common-box upload-box" v-if="activePopperType === 'upload'">
      <div class="static">
        <input type="file" class="static-upload-input" @change="uploadStatic" ref="staticRef" accept=".ppt,.pptx,.doc,.docx,.xls,.xlsx,.pdf,.txt,.jpg,.jpeg,.png, .bmp, .heic">
        <p><span>{{$t('wb.wb_tool_upload_static')}}</span><span style="width:16px;height:16px" v-html="require(`../../assets/icons/room/static_file.svg`).default"></span></p>
        {{$t('wb.wb_tool_upload_static_content')}}
      </div>
      
      <el-divider></el-divider>
      <div class="dymic">
        <input type="file" class="dymic-upload-input" @change="uploadDynamic" ref="dynamicRef" accept=".pptx, .ppt">
        <p><span>{{$t('wb.wb_tool_upload_dynamic')}}</span><span style="width:16px;height:16px" v-html="require(`../../assets/icons/room/dynamic_file.svg`).default"></span></p>
        {{$t('wb.wb_tool_upload_dynamic_content')}}
      </div>
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
const graphList = [
  {
    imgName: 'tool_square',
    cnName: '矩形',
    type: 8
  },
  {
    imgName: 'tool_round',
    cnName: '椭圆',
    type: 16
  },
  {
    imgName: 'tool_line',
    cnName: '直线',
    type: 4
  },
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
  components: {},
  data() {
    return {
      bigItem: 10,
      brushSizeList: [4, 6, 8, 10],
      textSizeList: [18, 24, 36, 48],
      colorList,
      textStyleList,
      graphList,
      fileList:[]
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
    },
    activeToolType(){
      return this.zegoWhiteboardArea.activeToolType
    }
  },
  methods: {
    // 设置画笔粗细
    setBrushSize(val) {
      console.warn(val)
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
    },
    // 设置图形  
    setGraphType(item){
      let type = item.type
      this.zegoWhiteboardArea.setGraphType(type)
      this.zegoWhiteboardArea.activeWBView.setToolType(type)
    },
    uploadStatic(e){
      this.$parent.resetUploadIconStatus()
      try {
        this.zegoWhiteboardArea.uploadFile(e.target.files[0], 3)
        this.$refs.staticRef.value = null;
      } catch (error) {
        console.warn('uploadStatic',error)
        this.$refs.staticRef.value = null;
      }
    },
    uploadDynamic(e){
      this.$parent.resetUploadIconStatus()
      try {
        this.zegoWhiteboardArea.uploadFile(e.target.files[0], 6)
        this.$refs.dynamicRef.value = null;
      } catch (error) {
        console.warn('uploadDynamic',error)
        this.$refs.dynamicRef.value = null;
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
  width: 232px;
  background-color: #fff;
  display: flex;
  flex-direction: column;
  border-radius: 6px;
  box-shadow: 0px 10px 30px 0px rgba(0, 0, 0, 0.05);
  .common-box {
    display: block;
  }
  .upload-box {
    padding: 8px 8px;
    text-align: left;
    @include sc(12px, #999999);
    overflow: hidden;
    word-break:break-all;
    .el-divider--horizontal {
      width: 200px;
      margin: 8px 0 8px 8px;
    }
    .static, .dymic {
      position: relative;
      padding: 8px 8px;
    }
     :hover.static{
        background-color: #f3f6ff;
        border-radius: 4px;
      }
      :hover.dymic{
        background-color: #f3f6ff;
        border-radius: 4px;
      }
    .static-upload-input {
      position: absolute;
      top: 0;
      right: 0;
      bottom: 0;
      left: 0;
      opacity: 0;
      cursor: pointer;
    }
    
    .dymic-upload-input {
      position: absolute;
      top: 0;
      right: 0;
      bottom: 0;
      left: 0;
      opacity: 0;
      cursor: pointer;
    }
    p {
      display: flex;
      justify-content: space-between;
      margin: 0;
      margin-bottom: 6px;
      color: #18191a;
    }
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
  .graph-style {
    display: flex;
    align-items: center;
    margin: 10px 0 0 16px;

    &-item {
      width: 20px;
      height: 20px;
      line-height: 20px;
      margin-right: 14px;
      font-size: 12px;
      &.active {
        /deep/ {
          .graph-stroke{
            stroke: #0044ff;
          }
          .graph-fill{
            fill: #0044ff;
          }
        }
      }
      &:hover{
        /deep/ {
          .graph-stroke{
            stroke: #18191a;
          }
          .graph-fill{
            fill: #18191a;
          }
        }
      }

      .style-item {
        width: 18px;
        height: 18px;
        margin: 0 auto;
        // padding: 2px 0;
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
@media only screen and (max-height: 550px) {
  .upload-setting {
    @include abs-pos(-290%, 200%, auto, auto);
  }
  .upload-setting::after {
    top: 85%;
  }
}
</style>
