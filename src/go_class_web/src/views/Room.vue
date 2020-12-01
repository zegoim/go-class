<template>
  <div class="room">
    <scene-base-class />
  </div>
</template>

<script>
import SceneBaseClass from '@/components/scene/scene-base-class.vue'

export default {
  name: 'room',
  components: {
    SceneBaseClass
  },
  beforeRouteEnter(to, from, next) {
    to.meta.from = from.name
    next()
  }
}
</script>
<style lang="scss" scoped>
.room {
  @include wh(100%, 100%);
}
</style>
