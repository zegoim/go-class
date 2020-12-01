<template>
  <div class="room-whiteboard-none">
    <div class="content">
      <div class="share-content">
        <span>请选择要共享的内容</span>
      </div>
      <div class="share-button">
        <el-button round @click="createWhiteboard">互动白板</el-button>
        <el-button round @click="showFileListDialog">共享文件</el-button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RoomWhiteboardNone',
  props: ['auth'],
  inject: ['zegoWhiteboardArea'],
  methods: {
    /**
     * @desc: 创建普通白板
     */    
    async createWhiteboard() {
      if (!this.auth) return this.showToast('老师还未允许你使用共享功能')
      this.zegoWhiteboardArea && this.zegoWhiteboardArea.createWhiteboard('whiteboardDemo')
    },

    /**
     * @desc: 打开文件列表弹窗
     */    
    showFileListDialog() {
      if (!this.auth) return this.showToast('老师还未允许你使用共享功能')
      this.zegoWhiteboardArea && this.zegoWhiteboardArea.setFilesListDialogShow(true)
    }
  }
}
</script>
<style lang="scss">
.room-whiteboard-none {
  @include flex-center();
  @include abs-pos(0, 0, 0, 0);
  z-index: 10;
  background-color: #f4f5f8;
  .share-content {
    @include sc(20px, #585c62);
  }

  .el-button {
    @include wh(140px, 50px);
    @include sc(16px, #18191a);
    @include box-shadow(0 0 30px 10px rgba($color: #000000, $alpha: 0.05));
    margin: 30px 30px 0 0;
    font-weight: normal;
    border: 0;
    border-radius: 25px;
    background-color: #fff;
  }
  .el-button:nth-child(2) {
    margin-right: 0;
  }
  .el-button:hover {
    color: #0044ff;
    background-color: #fff;
  }
}
</style>
