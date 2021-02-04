<template>
  <div role="alert" class="el-message el-message--info" style="top: 4670px; z-index: 2094">
    <i class="el-message__icon el-icon-info"></i>
    <p class="el-message__content" style="line-height: 20px">
      <i
        class="el-icon-loading"
        style="margin-right: 6px; font-size: 20px; vertical-align: middle"
      ></i>
      <span v-if="fileUploadStatus === 1">{{$t('doc.doc_uploading',{n:percent})}}</span>
      <span v-else-if="fileUploadStatus === 8">{{$t('doc.doc_converting')}}</span>
    </p>
  </div>
</template>
<script>
export default {
  name: 'SceneBaseClass',
  props: ['percent', 'fileUploadStatus'],
}
</script>