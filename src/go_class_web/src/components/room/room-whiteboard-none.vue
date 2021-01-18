<!--
 * @Description: 教学区（暂无白板或者文件分享）
-->
<template>
  <div class="room-whiteboard-none">
    <!--业务场景：如果在大班课场景下且用户角色是学生-->
    <div class="content" v-if="role === 2 && classScene === 2">
      <div class="share-content large-class">
        <img src="../../assets/images/whiteboard/default_waiting_share.png" alt />
        <div>{{$t('wb.wb_tip_wait_teacher_share')}}</div>
      </div>
    </div>
    <div class="content" v-else>
      <div class="share-content">
        <span>{{$t('wb.wb_select_share')}}</span>
      </div>
      <div class="share-button">
        <el-button round @click="createWhiteboard">{{$t('wb.wb_shared_wb')}}</el-button>
        <el-button round @click="showFileListDialog">{{$t('wb.wb_shared_file')}}</el-button>
      </div>
    </div>
    
  </div>
</template>

<script>
import { storage } from '@/utils/tool'

export default {
  name: 'RoomWhiteboardNone',
  props: ['auth','role'],
  inject: ['zegoWhiteboardArea'],
  data(){
    return{
      classScene: storage.get('loginInfo')?.classScene
    }
  },
  methods: {
    /**
     * @desc: 创建普通白板
     */    
    async createWhiteboard() {
      if (!this.auth) return this.showToast(this.$t('wb.wb_tip_not_allowed_share'))
      this.zegoWhiteboardArea.setIsAllowSendRoomExtraInfo(true)
      this.zegoWhiteboardArea && this.zegoWhiteboardArea.createWhiteboard('whiteboardDemo')
    },

    /**
     * @desc: 打开文件列表弹窗
     */    
    showFileListDialog() {
      if (!this.auth) return this.showToast(this.$t('wb.wb_tip_not_allowed_share'))
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
    &.large-class{
      font-size: 16px;
      line-height: 16px;
      margin: 0;
      margin-top: 6px;
    }
  }

  .el-button {
    // @include wh(140px, 50px);
    height: 50px;
    padding: 0px 35px;
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
