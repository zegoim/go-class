<!--
 * @Description: 顶部工具栏（白板相关控制操作）
-->
<template>
  <div class="top-bar">
    <div
      v-if="noList"
      :class="['no-canvas-bar', classScene === 2 && role === 2 ? 'large-class' : '']"
    >
      {{ $t('room.room_class_id') }}: {{ roomID }}
    </div>
    <div v-else class="room-controller-whiteboard">
      <div class="whiteboard-bar-classid">
        <span>{{ $t('room.room_class_id') }}：{{ roomID }}</span>
      </div>
      <div class="controller" v-if="role === 1 || classScene !== 2">
        <el-select
          v-if="roomAuth.share"
          :value="activeSelfWBID"
          :placeholder="$t('room.room_select')"
          popper-class="whiteboard-name-select-list"
          @change="handleWBSelect"
        >
          <el-option
            v-for="item in computedViewList"
            :key="item.selfWBID"
            :value="item.selfWBID"
            :label="item.name"
            @click.native="wbItemClick"
          >
            <div class="wb-name-label">{{ item.name }}</div>
            <div
              class="delete-btn"
              @click.stop="handleWBDelete(item)"
              v-html="require('../../assets/icons/room/but_del.svg').default"
            ></div>
          </el-option>
        </el-select>
        <div v-if="roomAuth.share && activeViewIsExcel" class="excel-sheets">
          <el-select
            :value="activeWBId"
            :placeholder="$t('room.room_select')"
            popper-class="whiteboard-name-select-list"
            @change="handleExcelSheetSelect"
          >
            <el-option
              v-for="item in computedExcelSheets"
              :key="item.whiteboardID"
              :value="item.whiteboardID"
              :label="item.fileName"
            >
              <div class="label">{{ item.fileName }}</div>
            </el-option>
          </el-select>
        </div>
        <!-- 分页 -->
        <div v-if="roomAuth.share && !activeViewIsExcel" class="page-bar">
          <div
            @click="handlePageChange_(-1)"
            :class="['page-bar-arrow', 'arrow-prev']"
            v-html="require('../../assets/icons/room/arrow_left.svg').default"
          ></div>
          <div class="pagebar-center">{{ `${currPage} / ${totalPage}` }}</div>
          <div
            @click="handlePageChange_(1)"
            :class="['page-bar-arrow', 'arrow-next', currPage === totalPage && 'disabled']"
            v-html="require('../../assets/icons/room/arrow_right.svg').default"
          >
            next
          </div>
        </div>
        <!-- 缩放 -->
        <div class="zoom-bar" v-if="computedViewList && computedViewList.length > 0">
          <div
            @click="handleZoomChange_(-1)"
            :class="[
              'zoom-bar-operation',
              'zoom-add',
              zoomIndex === 0 && 'disabled',
              activeToolType === 256 && (activeViewIsPPTH5 || activeViewIsH5) && 'disabled'
            ]"
            v-html="require('../../assets/icons/room/top_down.svg').default"
          ></div>
          <div class="zoombar-center">
            <el-select
              v-model="zoom"
              :placeholder="$t('room.room_select')"
              popper-class="whiteboard-zoom-select-list"
              :disabled="(activeViewIsPPTH5 || activeViewIsH5) && activeToolType === 256"
              @change="handleWBZoom"
            >
              <el-option
                v-for="item in zoomList"
                :key="item"
                :value="item"
                :label="item + '%'"
              ></el-option>
            </el-select>
          </div>
          <div
            @click="handleZoomChange_(1)"
            :class="[
              'zoom-bar-operation',
              'zoom-cut',
              zoomIndex === zoomList.length - 1 && 'disabled',
              activeToolType === 256 && (activeViewIsPPTH5 || activeViewIsH5) && 'disabled'
            ]"
            v-html="require('../../assets/icons/room/top_add.svg').default"
          ></div>
        </div>
        <!-- 略缩图 -->
        <div
          v-if="
            roomAuth.share &&
              (activeViewIsPDF || activeViewIsPPTH5 || activeViewIsPPT || activeViewIsH5)
          "
          @click="handleThumbnailsShow(thumbnailsVisible)"
          :class="['thumb-button', thumbnailsVisible && 'active']"
        >
          <span
            class="button-icon"
            v-html="require('../../assets/icons/room/preview.svg').default"
          ></span>
          <span>{{ $t('wb.wb_priview') }}</span>
        </div>
      </div>
      <div class="controller" v-else-if="role === 2 && classScene === 2">
        <!-- 缩放 -->
        <div class="zoom-bar" v-if="computedViewList && computedViewList.length > 0">
          <div
            @click="handleZoomChange_(-1)"
            :class="[
              'zoom-bar-operation',
              'zoom-add',
              zoomIndex === 0 && 'disabled',
              activeToolType === 256 && activeViewIsPPTH5 && 'disabled'
            ]"
            v-html="require('../../assets/icons/room/top_down.svg').default"
          ></div>
          <div class="zoombar-center">
            <el-select
              v-model="zoom"
              :placeholder="$t('room.room_select')"
              popper-class="whiteboard-zoom-select-list"
              :disabled="activeViewIsPPTH5 && activeToolType === 256"
              @change="handleWBZoom"
            >
              <el-option
                v-for="item in zoomList"
                :key="item"
                :value="item"
                :label="item + '%'"
              ></el-option>
            </el-select>
          </div>
          <div
            @click="handleZoomChange_(1)"
            :class="[
              'zoom-bar-operation',
              'zoom-cut',
              zoomIndex === zoomList.length - 1 && 'disabled',
              activeToolType === 256 && activeViewIsPPTH5 && 'disabled'
            ]"
            v-html="require('../../assets/icons/room/top_add.svg').default"
          ></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { debounce, storage } from '@/utils/tool'
import { roomStore } from '@/service/biz/room'

const zoomList = [100, 125, 150, 175, 200, 225, 250, 275, 300]
export default {
  name: 'RoomControllerWhiteboard',
  components: {},
  data() {
    return {
      zoomList: zoomList, // 缩放参数
      zoomIndex: 0, // 缩放默认第一个
      selectExcelId: null, //Excelid
      roomAuth: roomStore.auth, // 权限
      noList: false, // 是否列表为空，默认false
      classScene: storage.get('loginInfo').classScene || 1, // 当前课堂场景
      role: storage.get('loginInfo').role || 1 // 当前用户角色
    }
  },
  inject: ['zegoLiveRoom', 'zegoWhiteboardArea'],
  computed: {
    /**
     * @desc: 房间id
     */
    roomID() {
      return this.zegoLiveRoom.roomId
    },
    /**
     * @desc: 当前激活是否Excel
     */
    activeViewIsExcel() {
      // const fileInfo = this.zegoWhiteboardArea.activeWBView?.getFileInfo();
      // return fileInfo?.fileType === 4
      return this.zegoWhiteboardArea.activeViewIsExcel
    },
    /**
     * @desc: 当前激活是否PDF
     */
    activeViewIsPDF() {
      return this.zegoWhiteboardArea.activeViewIsPDF
    },
    /**
     * @desc: 当前激活是否动态ppt
     */
    activeViewIsPPTH5() {
      return this.zegoWhiteboardArea.activeViewIsPPTH5
    },
    /**
     * @desc: 当前激活是否H5
     */
    activeViewIsH5() {
      return this.zegoWhiteboardArea.activeViewIsH5
    },
    /**
     * @desc: 当前激活是否ppt
     */
    activeViewIsPPT() {
      return this.zegoWhiteboardArea.activeViewIsPPT
    },
    /**
     * @desc: 当前激活白板id
     */
    activeWBId() {
      return this.zegoWhiteboardArea.activeWBId
    },
    /**
     * @desc: 获取当前激活白板当前页码
     */
    currPage() {
      return this.zegoWhiteboardArea.currPage
    },
    /**
     * @desc: 当前激活白板全部页数
     */
    totalPage() {
      return this.zegoWhiteboardArea.totalPage
    },
    /**
     * @desc: 缩略图是否展示
     */
    thumbnailsVisible() {
      return this.zegoWhiteboardArea.isThumbnailsVisible
    },
    /**
     * @desc: 获取当前激活白板id
     */
    activeSelfWBID() {
      const activeItem =
        this.zegoWhiteboardArea.originWBViewList.find(
          item => item.whiteboardID === this.zegoWhiteboardArea.activeWBId
        ) || {}
      const fileInfo = (activeItem.getFileInfo && activeItem.getFileInfo()) || {}
      return fileInfo.fileID || activeItem.whiteboardID
    },
    /**
     * @desc: 处理展示白板名
     */
    computedViewList() {
      return this.zegoWhiteboardArea.WBViewList.map(item => {
        const fileInfo = item.getFileInfo() || {}
        const res = Object.assign(item, {
          name: fileInfo.fileType ? this.hideTitle(item.name) : this.hideWBTitle(item.name),
          selfWBID: fileInfo.fileID || item.whiteboardID
        })
        return res
      })
    },
    /**
     * @desc: 处理展示Excel sheet名
     */
    computedExcelSheets() {
      console.warn(
        'this.zegoWhiteboardArea.activeExcelSheetNames',
        this.zegoWhiteboardArea.activeExcelSheetNames
      )
      const res = this.zegoWhiteboardArea.activeExcelSheetNames.map(name => {
        const item =
          this.zegoWhiteboardArea.activeExcelSheets.find(x => {
            const fileInfo = x.getFileInfo()
            return fileInfo.fileName === name
          }) || {}
        return Object.assign(item, { fileName: name })
      })
      return res
    },
    zoom: {
      get() {
        return +this.zegoWhiteboardArea.zoom || 100
      },
      set(val) {
        this.zegoWhiteboardArea.zoom = val
      }
    },
    computedWBZoom() {
      const index = this.zoomList.findIndex(i => i === this.zoom)
      return index
    },
    /**
     * @desc: 当前工具选中类型
     */
    activeToolType() {
      return this.zegoWhiteboardArea.activeToolType
    }
  },
  watch: {
    'zegoWhiteboardArea.WBViewList': function() {
      this.noList = !this.zegoWhiteboardArea.WBViewList.length
    },
    activeWBId(newId) {
      if (newId) {
        const _zoom = this.zegoWhiteboardArea.activeWBView.getScaleFactor().scaleFactor
        this.zoomIndex = this.zoomList.findIndex(i => i === this.zoom)
        this.zegoWhiteboardArea.setZoom(_zoom)
      }
    }
  },
  mounted() {
    this.handlePageChange_ = debounce(this.handlePageChange, 500, true)
    this.handleZoomChange_ = debounce(this.handleZoomChange, 500, true)
  },
  methods: {
    /**
     * @desc: 选择白板
     * @param {id} 目标id
     */
    handleWBSelect(id) {
      // 如果切换文件白板是动态ppt，需手动停止该文件音视频
      if (this.activeViewIsPPTH5) this.zegoWhiteboardArea.stopPlay()
      if (this.activeViewIsH5) this.zegoWhiteboardArea.stopPlay()
      // 切换文件/白板需通过房间附加信息通知对端
      this.zegoWhiteboardArea.setIsAllowSendRoomExtraInfo(true)
      const activeItem = this.computedViewList.find(item => {
        return item.selfWBID === id
      })
      console.warn('handleWBSelect:', activeItem.whiteboardID)
      this.zegoWhiteboardArea.selectRemoteView(activeItem.whiteboardID)
      // this.zegoWhiteboardArea.notifyAllViewChanged()
      console.warn('当前激活工具', this.zegoWhiteboardArea.activeToolType)
    },
    /**
     * @desc: 删除白板
     * @param {item} 目标文件
     */
    handleWBDelete(item) {
      this.$confirm(this.$t('wb.wb_tip_are_u_sure_close', { wbname: item.getName() }), '', {
        confirmButtonText: this.$t('wb.wb_determine'),
        cancelButtonText: this.$t('wb.wb_cancel'),
        showClose: false,
        customClass: 'delete-wb-view-dialog',
        type: 'warning'
      })
        .then(async () => {
          this.zegoWhiteboardArea.setIsAllowSendRoomExtraInfo(true)
          this.zegoWhiteboardArea.destroyView(item)
        })
        .catch(() => {
          console.log('取消了')
        })
    },

    /**
     * @desc: 处理文件名过长
     */
    hideTitle(name) {
      // console.warn(name)
      let last = 0
      let all = name.length
      let fisrt = name.substring(0, 3)
      last = all - 8
      if (all > 10) {
        return fisrt + '...' + name.substring(last, all)
      } else {
        return name
      }
    },

    hideWBTitle(name) {
      let zego_locale = sessionStorage.getItem('zego_locale')
      let wbnameArr = name.split('创建的白板')
      let wbName

      if (!zego_locale) zego_locale = 'zh'

      if (zego_locale === 'zh') {
        wbName = name.replace(/^(.{3}).*?(创建的白板\d+)$/, '$1...$2')
      } else {
        wbName =
          this.$t('wb.wb_created_by', { name: wbnameArr[0], index: wbnameArr[1] }).substring(
            0,
            17
          ) + '...'
      }
      return wbName
    },
    /**
     * @desc: 上/下一页
     * @param {num} 操作类型
     */
    handlePageChange(num) {
      if (num === -1) this.previousPage()
      if (num === 1) this.nextPage()
    },

    previousPage() {
      this.zegoWhiteboardArea.previousPage()
    },

    nextPage() {
      this.zegoWhiteboardArea.nextPage()
    },

    setScaleFactor(zoom) {
      if (this.zegoWhiteboardArea.activeWBView) {
        this.zegoWhiteboardArea.activeWBView.setScaleFactor(zoom)
        if (this.zegoWhiteboardArea.activeToolType === 0) {
          this.zegoWhiteboardArea.activeWBView.setToolType(null)
        }
      }
    },

    /**
     * @desc: 下拉框选择设置缩放
     */
    handleWBZoom() {
      const _zoom = this.zoom / 100
      this.zegoWhiteboardArea.setZoom(_zoom)
      this.setScaleFactor(_zoom)
      this.zoomIndex = this.zoomList.findIndex(i => i === this.zoom)
    },

    /**
     * @desc: 缩放设置
     * @param {type} 放大/缩小
     */
    handleZoomChange(type) {
      if (this.activeToolType === 256 && (this.activeViewIsPPTH5 || this.activeViewIsH5)) return
      let zoom
      if (type === 1 && this.zoomIndex <= this.zoomList.length - 1) {
        this.zoomIndex === this.zoomList.length - 1
          ? (this.zoomIndex = this.zoomList.length - 1)
          : this.zoomIndex++
      } else if (type === -1 && this.zoomIndex >= 0) {
        this.zoomIndex === 0 ? 0 : this.zoomIndex--
      }
      this.zoom = this.zoomList[this.zoomIndex]
      zoom = this.zoom / 100
      this.zegoWhiteboardArea.setZoom(zoom)
      zoom && this.setScaleFactor(zoom)
    },

    /**
     * @desc: 选择Excel sheet id渲染
     * @param {id} sheet id
     */
    handleExcelSheetSelect(id) {
      this.zegoWhiteboardArea.setIsAllowSendRoomExtraInfo(true)
      this.zegoWhiteboardArea.selectRemoteView(id, true)
    },

    /**
     * @desc: 设置缩略图展示状态
     * @param {type} 状态
     */
    handleThumbnailsShow(val) {
      this.zegoWhiteboardArea.setThumbnailsVisible(!val)
    },

    /**
     * @desc: 点击关闭缩略图
     */
    wbItemClick() {
      this.zegoWhiteboardArea.setThumbnailsVisible(false)
    }
  }
}
</script>
<style lang="scss">
.top-bar {
  @include wh(100%, 100%);
  @include flex-center();
  display: flex;
  flex-shrink: 0;
  .no-canvas-bar {
    align-self: flex-start;
    @include wh(100%, 100%);
    @include sc(12px, #585c62);
    @include textCenter(40px);
    // background-color: #f4f5f8;
    &.large-class {
      text-align: left;
      margin-left: 7%;
      background-color: #fff;
    }
  }
}

.room-controller-whiteboard {
  .controller {
    @include flex-center();
    width: 100%;
    flex-shrink: 0;
    position: relative;
    height: 40px;
    margin: 0;
  }
  @include flex-center();
  width: 100%;
  flex-shrink: 0;
  position: relative;
  height: 40px;
  margin: 0;

  .whiteboard-bar-classid {
    @include sc(12px, #585c62);
    @include abs-pos(auto, auto, auto, 7%);
  }

  .el-select {
    @include wh(160px, 28px);
    border-radius: 14px;
    border: 1px solid #edeff3;
    overflow: hidden;
    appearance: none;
    -moz-appearance: none;
    -webkit-appearance: none;
  }

  // /deep/ {
  .el-input__inner {
    @include sc(12px, #18191a);
    height: 28px;
    line-height: 28px;
    margin-right: 30px;
    padding: 0 0 0 16px;
    border: 0;
    // overflow: hidden;
    // text-overflow: ellipsis;
    // white-space: nowrap;
  }

  .el-select__caret {
    line-height: 1;
    color: rgb(95, 98, 102);
  }
  .el-select__caret:hover {
    color: #18191a;
  }
  .el-select .el-input .el-select__caret.is-reverse {
    color: #0044ff;
  }
  // }

  .page-bar {
    @include wh(120px, 30px);
    @include sc(12px, #18191a);
    display: flex;
    align-items: center;
    line-height: 30px;
    box-sizing: border-box;
    border-radius: 14px;
    text-align: center;
    border: 1px solid #edeff3;
    background-color: #fff;
    margin-left: 30px;

    &.disabled {
      opacity: 0.7;
      cursor: not-allowed;
    }

    .el-select {
      @include wh(160px, 28px);
      @include css3(appearance, none);
      border-radius: 14px;
      border: 1px solid #edeff3;
    }
    /deep/ {
      .el-input__inner {
        @include wh(112px, 28px);
        @include sc(12px, #18191a);
        line-height: 28px;
        margin-right: 30px;
        border: 0;
        padding: 0 0 0 2px;
      }
    }
    .pagebar-center {
      @include wh(72px, 12px);
      line-height: 1;
      text-align: center;
    }
    .page-bar-arrow {
      @include wh(12px, 12px);
      line-height: 1;
      cursor: pointer;
      &:not(.disabled):hover {
        /deep/ {
          .hover-stroke {
            stroke: #18191a;
          }
          .hover-fill {
            fill: #18191a;
          }
        }
      }
      &.disabled {
        opacity: 0.7;
        cursor: not-allowed;
      }
    }
    .arrow-prev {
      margin-left: 10px;
    }
    .arrow-next {
      margin-right: 10px;
    }
  }

  .zoom-bar {
    @include wh(122px, 30px);
    @include sc(12px, #18191a);
    display: flex;
    align-items: center;
    box-sizing: border-box;
    margin-left: 30px;
    line-height: 30px;
    border: 1px solid #edeff3;
    border-radius: 14px;
    text-align: center;
    background-color: #fff;

    &.disabled {
      opacity: 0.7;
      cursor: not-allowed;
    }

    .zoombar-center {
      @include wh(46px, 28px);
      margin: 0 8px;
      line-height: 28px;
      text-align: center;
      .el-select {
        @include css3(appearance, none);
        width: 46px;
        border: none;
        overflow: hidden;
      }
      .is-disabled .el-input__inner {
        background-color: #fff;
      }
      // /deep/ {
      .el-input__inner {
        @include sc(12px, #18191a);
        height: 28px;
        margin-right: 30px;
        padding: 0 0 0 2px;
        border: 0;
        line-height: 28px;
      }
      .el-input__suffix {
        right: -8px;
      }
      // }
    }
    .zoom-bar-operation {
      @include wh(20px, 20px);
      line-height: 1;
      cursor: pointer;
      &:not(.disabled):hover {
        /deep/ {
          .hover-stroke {
            stroke: #18191a;
          }
          .hover-fill {
            fill: #18191a;
          }
        }
      }
      &.disabled {
        opacity: 0.7;
        cursor: not-allowed;
      }
    }
    .zoom-add {
      margin-left: 10px;
    }
    .zoom-cut {
      margin-right: 10px;
    }
  }

  .excel-sheets {
    margin-left: 30px;
    input {
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
    .label {
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  }
  .thumb-button {
    display: flex;
    flex-direction: row;
    justify-content: center;
    align-items: center;
    position: absolute;
    right: 10px;
    @include wh(72px, 32px);
    @include sc(12px, #18191a);
    border: 1px solid #edeff3;
    border-radius: 6px;
    background-color: #fff;
    cursor: pointer;
    line-height: 32px;
    outline: 0;
    &:hover {
      /deep/ {
        .hover-fill {
          fill: #585c62;
        }
      }
      border-color: #b1b4bc;
      color: #18191a;
    }
    &.active {
      color: #0044ff;
      border-color: #0044ff;
      background-color: #f0f4ff;
      /deep/ {
        .hover-fill {
          fill: #0044ff;
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
</style>
