<!--
 * @Description: 课堂场景 1：小班课 2:大班课
-->
<template>
  <div class="scene-base-class" v-if="isInit">
    <zego-live-room>
      <page-layout-room v-if="classScene === 1"/>
      <large-class-layout-room  v-if="classScene === 2"/>
    </zego-live-room>
  </div>
</template>

<script>
import PageLayoutRoom from '@/components/base/page-layout-room.vue'
import LargeClassLayoutRoom from '@/components/base/largeClass-layout-room'
import ZegoLiveRoom from '@/components/zego/zego-live-room.vue'
import { storage } from '@/utils/tool'

export default {
  name: 'SceneBaseClass',
  components: {
    ZegoLiveRoom,
    PageLayoutRoom,
    LargeClassLayoutRoom
  },
  data() {
    return {
      isInit: false,
      classScene: 1,
    }
  },
  mounted() {
    this.initProps()
  },
  destroyed() {
    this.isInit = false
  },
  methods: {
    initProps() {
      // 复制url在新窗口打开时跳转到登录页（session不存在）
      const loginInfo = storage.get('loginInfo')
      this.classScene = loginInfo?.classScene || 1
      if (!loginInfo) {
        this.$router.replace({ path: 'login', query: this.$route.query })
        return
      }
      this.isInit = true
    }
  }
}
</script>

<style lang="scss">
.scene-base-class {
  @include wh(100%, 100%);
}
</style>
