<template>
  <div class="scene-base-class" v-if="isInit">
    <zego-live-room
        :roomId='roomId'
        :userName='userName'
        :env='env'>
      <page-layout-room />
    </zego-live-room>
  </div>
</template>

<script>
import zegoClient from '@/service/zego/zegoClient'
import PageLayoutRoom from '@/components/base/page-layout-room.vue'
import ZegoLiveRoom from '@/components/zego/zego-live-room.vue'
const { ipcRenderer } = window.require('electron')

export default {
  name: 'SceneBaseClass',
  components: {
    PageLayoutRoom,
    ZegoLiveRoom
  },
  data() {
    return {
      roomId: '',
      userName: '',
      env: '',
      isInit: false,
    }
  },
  created () {
    this.electronInitProps()
  },
  destroyed() {
    this.isInit = false
  },
  methods: {
    async electronInitProps () { // electron - 外部注入用户登录信息
      ipcRenderer.on('get-init-data', async (...args) => {
        const [, params] = args
        const { data } = params
        console.warn('ipcRenderer get-init-data', { data })
        // try {
          const { userName, roomId, env, user } = data
          await zegoClient.init('live', env, user)
          this.roomId     = roomId
          this.userName   = userName
          this.env        = env
          this.isInit     = true
        // } catch (e) {
        //   console.warn('获取房间号、用户名失败')
        // }
      })
    }
  },
}
</script>

<style lang="scss">
.scene-base-class {
  @include wh(100%, 100%);
}
</style>
