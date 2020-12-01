<template>
  <div class='zego-video-pull'>
    <slot></slot>
  </div>
</template>
<script>
export default {
  name: 'zego-video-push',
  data () {
    return {
      isPull: false,
    }
  },
  inject: ['zegoLiveRoom'],
  provide: {
    videoPullState: this
  },
  mounted () {
  },
  methods: {
    pullStream () {
      console.warn('pullStream')
    }
  }
}
</script>
<style lang='scss'>
.zego-video-pull {
  @include wh(100%, 100%);
}
</style>
