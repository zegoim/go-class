<template>
  <div class="file-list-dialog">
    <el-dialog title="选择文件" :visible.sync="filesListDialogShow" width="460px" height="314px" @close="closeDialog">
      <div class="dialog-content">
        <ul class="file-list">
          <li class="file-item" v-for="item in fileList" :key="item.name + item.id" @click="createDocView(item.id)">
            <!-- <div :class="['state', item.isDynamic && 'dynamic']">
              {{ item.isDynamic ? '动态' : '静态' }}
            </div> -->
            <div :class="['state', item.isDynamic && 'dynamic', item.isH5 && 'h5']">
              {{ item.isH5 ? 'H5' : item.isDynamic && !item.isH5 ? '动态' : '静态' }}
            </div>
            {{ item.name }}
          </li>
        </ul>
        <div class="tips">
          <div style="width:400px;border-top:1px solid #f4f5f8">
            <span class="static">静态：无法展示PPT动画</span>
            <span class="static">动态：可展示PPT动画</span>
            <span class="dynamic">H5：展示H5文件</span>
          </div>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { storage } from '@/utils/tool'
import Config from '@/service/zego/config' // RoomEnv

export default {
  name: 'RoomDialogFiles',
  inject: ['zegoWhiteboardArea'],
  data() {
    return {
      fileList: [],
      waitting: false
    }
  },
  computed: {
    filesListDialogShow: {
      get() {
        return this.zegoWhiteboardArea.filesListDialogShow
      },
      set(val) {
        this.zegoWhiteboardArea.filesListDialogShow = val
      }
    }
  },
  async mounted() {
    const env = storage.get('loginInfo')?.env || 'home'
    const electronConf = new Config('electron')
    const { fileList } = await electronConf.getParams(env)
    this.$set(this, 'fileList', fileList)
  },
  methods: {
    /**
     * @desc: 创建共享文件
     * @param id {number|string} 文件id
     */
    // eslint-disable-next-line no-unused-vars
    async createDocView(id) {
      try {
        const checkResult = this.zegoWhiteboardArea.checkViewFileMaxLength('file')
        if (checkResult) return this.showToast(checkResult)
        if (this.waitting) return
        this.waitting = true
        this.zegoWhiteboardArea.setIsAllowSendRoomExtraInfo(true)
        await this.zegoWhiteboardArea.createFileView(id)
        this.waitting = false
        this.closeDialog()
      } catch (e) {
        console.error('files createDocView', e)
      }
      return false
    },
    closeDialog() {
      this.zegoWhiteboardArea.setFilesListDialogShow(false)
    }
  }
}
</script>
<style lang="scss" scoped>
.file-list-dialog {
  /deep/ {
    .el-dialog__wrapper {
      padding-top: 12vh;
    }
    .el-dialog {
      width: 460px;
      height: 314px;
      border-radius: 6px;
    }
    .el-dialog__body {
      width: 460px;
      height: 271px;
      padding: 0;
      color: #18191a;
      font-size: 12px;
    }
    .el-dialog__title {
      @include sc(14px, #18191a);
    }
    .el-dialog-content ul {
      margin-top: 8px;
      margin-bottom: 8px;
    }
    .file-list {
      height: 220px;
      overflow-y: auto;

      &::-webkit-scrollbar {
        width: 4px;
      }
      &::-webkit-scrollbar-thumb {
        background-color: rgba(177, 180, 188, 0.5);
        border-radius: 2px;
      }
    }
    .file-list .file-item {
      height: 34px;
      line-height: 34px;
      font-size: 12px;
      color: #18191a;
      text-align: left;
      cursor: pointer;
      padding: 0 30px;

      &:hover {
        background: rgba(244, 245, 248, 1);
      }
    }
    .file-item .state {
      display: inline-block;
      width: 28px;
      height: 16px;
      border-radius: 4px;
      background-color: #0045ff;
      color: #fff;
      font-size: 10px;
      text-align: center;
      line-height: 16px;
      margin-right: 6px;

      &.dynamic {
        background-color: #ffa402;
      }
      &.h5 {
        width: 23px;
        background-color: #00baff;
      }
    }
    .el-dialog__header {
      width: 460px;
      height: 43px;
      line-height: 43px;
      text-align: center;
      padding: 0;
    }
    .el-dialog__headerbtn {
      height: 12px;
      width: 12px;
      position: absolute;
      top: 16px;
      right: 16px;
    }
    .el-dialog__close {
      height: 12px;
      width: 12px;
    }
    .tips {
      width: 430px;
      height: 51px;
      text-align: left;
      font-size: 10px;
      color: #585c62;
      line-height: 51px;
      padding: 0 0 0 30px;
      // border-top: 1px solid #f4f5f8;
    }
    .tips .static {
      margin-right: 20px;
      line-height: 51px;
      height: 51px;
    }
  }
}
</style>
