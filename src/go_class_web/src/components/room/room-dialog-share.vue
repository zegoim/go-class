<template>
  <div class="room-dialog-share">
    <el-dialog
      title="邀请人员"
      :visible.sync="dialogVisible"
      width="380px"
      @close="$emit('handleClose')"
    >
      <div class="dialog-content">
        <div class="classLink">
          <span class="link">课堂链接</span>
          <span class="linkContent">{{ shareUrl }}</span>
        </div>
        <div class="classID">
          <span class="linkid">课堂ID</span>
          <span class="linkContent">{{ roomId }}</span>
        </div>
        <div class="classLink">
          <span class="link">接入环境</span>
          <span class="linkContent">{{ envName }}</span>
        </div>
        <el-button type="primary" round @click="copyShareUrl">{{ copyLink }}</el-button>
      </div>
    </el-dialog>
  </div>
</template>
<script>
import { storage } from '@/utils/tool'
import copy from 'copy-to-clipboard'
export default {
  name: 'RoomDialogShare',
  data() {
    return {
      dialogVisible: true,
      roomId: '',
      shareUrl: '',
      copyLink: '复制邀请链接',
      envName: ''
    }
  },
  mounted() {
    this.initInfo()
  },
  methods: {
    initInfo() {
      const { roomId, env } = storage.get('loginInfo') || {}
      if (roomId) {
        this.roomId = roomId
        this.envName = env === 'home' ? '中国内地' : '海外'
        this.shareUrl = `${location.protocol}//${location.host}/#/login?roomId=${roomId}&env=${env}`
      }
    },
    copyShareUrl() {
      copy(this.shareUrl)
      this.copyLink = '复制成功'
    }
  }
}
</script>
<style lang="scss">
.room-dialog-share {
  /deep/ {
    .el-dialog__wrapper {
      margin-top: 22vh;
    }
    .el-dialog {
      border-radius: 6px;
    }
    .el-dialog__header {
      @include sc(12px, #585c62);
      @include textCenter(43px);
      height: 43px;
      padding: 0;
    }
    .el-dialog__headerbtn {
      @include abs-pos(16px, 16px, auto, auto);
      font-size: 12px;
    }
    .el-dialog__body {
      padding: 0;
      font-size: 12px;
    }
    .el-dialog__title {
      @include sc(14px, #18191a);
    }
    .dialog-content {
      padding: 14px 30px 20px 30px;
    }
    .classLink {
      // @include wh(320px, 12px);
      width: 320px;
      margin-bottom: 14px;
      line-height: 12px;
      text-align: left;
      .linkContent {
        display: inline-block;
        width: 256px;
      }
    }
    .classID {
      @include wh(320px, 12px);
      margin-bottom: 14px;
      line-height: 12px;
      text-align: left;
      .linkContent {
        display: inline-block;
        height: 12px;
        // margin-top: 14px;
      }
    }
    .link {
      display: block;
      margin-right: 16px;
      float: left;
    }
    .linkid {
      margin-right: 28px;
    }
    .el-button.is-round {
      padding: 0;
    }
    .el-button--primary {
      @include wh(110px, 30px);
      @include sc(12px, #ffffff);
      margin-top: 16px;
      padding: 0;
      border: 0;
      border-radius: 15px;
      background-color: #1742f5;
    }
    .el-button--primary:focus {
      border: 0;
      background-color: #79ddad;
    }
    .linkContent {
      @include sc(12px, #18191a);
    }
  }
}
</style>
