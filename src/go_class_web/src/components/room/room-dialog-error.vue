<!--
 * @Description: 网络错误弹窗组件
-->
<template>
  <div class="room-dialog-error">
    <el-dialog
      :visible.sync="show"
      width="380px"
      :showClose="false"
      :distinguishCancelAndClose="true"
    >
      <div class="dialog-content">
        <div class="des">
          重新加入失败，请检查网络后重试
        </div>
        <div>
          <el-button class="cancle" round @click="retry">重试</el-button>
          <el-button class="end" round @click="gotoLogin">确定</el-button>
        </div>
      </div>
    </el-dialog>
  </div>
</template>
<script>
export default {
  name: 'RoomDialogError',
  data() {
    return {
      show: false
    }
  },
  methods: {
    retry() {
      window.location.reload()
    },
    gotoLogin() {
      this.$route.meta.reload = true
      this.$router.replace('/login')
    }
  }
}
</script>
<style lang="scss">
.room-dialog-error {
  .el-dialog {
    width: 280px !important;
  }
  .el-dialog__wrapper {
    margin-top: 22vh;
  }
  .el-dialog {
    border-radius: 6px;
  }
  .el-dialog__header {
    display: none !important;
  }
  .el-dialog__headerbtn {
    @include abs-pos(16px, 16px, auto, auto);
    font-size: 12px;
  }
  .el-dialog__body {
    padding: 0;
    padding-top: 40px;
    font-size: 12px;
  }
  .el-dialog__title {
    @include sc(14px, #18191a);
  }
  .dialog-content {
    padding: 0 0 30px 0;
  }
  .des {
    margin-bottom: 30px;
    color: #18191a;
  }
  .el-button.is-round {
    padding: 0;
    @include wh(70px, 30px);
    @include sc(12px, #ffffff);
    padding: 0;
    border: 0;
    border-radius: 15px;
  }

  .end {
    background-color: #1742f5;
    &:hover {
      background-color: #0030ff;
      color: #fff;
    }
    &:active {
      background-color: #0030ff !important;
      color: #fff;
    }
    &:focus {
      background-color: #1742f5;
      color: #fff;
    }
  }

  .cancle {
    background-color: #b1b4bd;
    &:hover {
      background-color: #a3a6ad;
      color: #fff;
    }
    &:focus {
      background-color: #a3a6ad !important;
      color: #fff;
    }
  }
}
</style>
