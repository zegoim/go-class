<!--
 * @Description: loading弹窗组件
-->
<template>
  <div class="room-dialog-loading">
    <div class="loading-box">
      <i class="fade-item fade-item1"></i>
      <i class="fade-item fade-item2"></i>
      <i class="fade-item fade-item3"></i>
      <i class="fade-item fade-item4"></i>
      <i class="fade-item fade-item5"></i>
      <i class="fade-item fade-item6"></i>
      <i class="fade-item fade-item7"></i>
      <i class="fade-item fade-item8"></i>
      <i class="fade-item fade-item9"></i>
      <i class="fade-item fade-item10"></i>
      <i class="fade-item fade-item11"></i>
      <i class="fade-item fade-item12"></i>
    </div>
    <p>{{$t('room.room_network_exception')}}</p>
  </div>
</template>
<script>
export default {
  name: 'RoomDialogLoading'
}
</script>
<style lang="scss">
.room-dialog-loading {
  @include wh(214px, 98px);
  @include center();
  background-color: rgba($color: #000000, $alpha: 0.8);
  border-radius: 8px;
  z-index: 10001;
  .loading-box {
    position: relative;
    @include wh(34px, 34px);
    margin: 0 auto;
    margin-top: 20px;
    .fade-item {
      position: absolute;
      top: 0;
      left: 0;
      @include wh(34px, 34px);
      &:before {
        content: '';
        display: block;
        margin: 0 auto;
        @include wh(3px, 9px);
        background-color: #fff;
        border-radius: 4px;
        -webkit-border-radius: 4px;
        animation: fadeDelay 1.2s infinite ease-in-out both;
      }
    }
    .fade-item2 {
      transform: rotate(30deg);
      &:before {
        animation-delay: -1.1s; //注意animation-delay负值指跳过1.1s进入动画
      }
    }
    .fade-item3 {
      transform: rotate(60deg);
      &:before {
        animation-delay: -1s;
      }
    }
    .fade-item4 {
      transform: rotate(90deg);
      &:before {
        animation-delay: -0.9s;
      }
    }
    .fade-item5 {
      transform: rotate(120deg);
      &:before {
        animation-delay: -0.8s;
      }
    }
    .fade-item6 {
      transform: rotate(150deg);
      &:before {
        animation-delay: -0.7s;
      }
    }
    .fade-item7 {
      transform: rotate(180deg);
      &:before {
        animation-delay: -0.6s;
      }
    }
    .fade-item8 {
      transform: rotate(210deg);
      &:before {
        animation-delay: -0.5s;
      }
    }
    .fade-item9 {
      transform: rotate(240deg);
      &:before {
        animation-delay: -0.4s;
      }
    }
    .fade-item10 {
      transform: rotate(270deg);
      &:before {
        animation-delay: -0.3s;
      }
    }
    .fade-item11 {
      transform: rotate(300deg);
      &:before {
        animation-delay: -0.2s;
      }
    }
    .fade-item12 {
      transform: rotate(330deg);
      &:before {
        animation-delay: -0.1s;
      }
    }
    @keyframes fadeDelay {
      0%,
      39%,
      100% {
        opacity: 0.2;
      }
      40% {
        opacity: 1;
      }
    }
    @-webkit-keyframes fadeDelay {
      0%,
      39%,
      100% {
        opacity: 0.2;
      }
      40% {
        opacity: 1;
      }
    }
  }
  p {
    margin-top: 10px;
    @include sc(14px, #ffffff);
  }
}
</style>
