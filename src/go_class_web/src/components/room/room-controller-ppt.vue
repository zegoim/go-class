<template>
  <div class="ppt-dynamic" v-if="activeViewIsPPTH5">
    <button
      @click="previousStep"
      class="step-item"
      v-html="require('../../assets/icons/room/p_step.svg').default"
    ></button>
    <div class="line"></div>
    <button
      @click="nextStep"
      class="step-item"
      v-html="require('../../assets/icons/room/n_step.svg').default"
    ></button>
  </div>
</template>

<script>
import { debounce } from '@/utils/tool'
export default {
  name: 'RoomControllerPpt',
  inject: ['zegoWhiteboardArea'],
  computed: {
    activeViewIsPPTH5() {
      return this.zegoWhiteboardArea.activeViewIsPPTH5
    }
  },
  methods: {
    previousStep() {
      debounce(this.zegoWhiteboardArea.previousStep(), 300, true)
    },
    nextStep() {
      debounce(this.zegoWhiteboardArea.nextStep(), 300, true)
    }
  }
}
</script>
<style lang="scss" scoped>
.ppt-dynamic {
  position: absolute;
  left: 50%;
  bottom: 14px;
  transform: translate(-50%, 0);
  padding: 7px 14px;
  z-index: 9;
  display: flex;
  border-radius: 17px;
  box-shadow: 0px 10px 30px 0px rgba(0, 0, 0, 0.05);
  background-color: #fff;
  .step-item {
    @include wh(20px, 20px);
    margin: 0;
    padding: 0;
    border: 1px solid transparent;
    outline: none;
    background-color: #fff;
    cursor: pointer;
    &:hover {
      /deep/ {
        .hover-stroke {
          stroke: #18191a;
        }
      }
    }
    &:active {
      /deep/ {
        .hover-stroke {
          stroke: #0044ff;
        }
      }
    }
  }
  .line {
    @include wh(1px, 16px);
    margin: 2px 8px 0;
    background-color: #edeff3;
  }
}
</style>
