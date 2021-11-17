<!--
 * @Date: 2020-10-23 10:34:32
 * @LastEditTime: 2020-11-04 15:52:38
 * @Description: 大班课场景
 * @FilePath: /work/web-go-class-demo/src/components/base/largeClass-layout-room.vue
-->
<template>
  <div class="page-view-room">
    <div class="page-left">
      <zego-whiteboard-area parentId="whiteboardDemo">
        <div class="main-area">
          <div class="main-top">
            <room-controller-whiteboard />
          </div>
          <div class="main-mid">
            <room-whiteboard-area />
          </div>
          <div class="main-bottom">
            <room-controller-feature />
          </div>
        </div>
      </zego-whiteboard-area>
    </div>
    <div class="page-right">
      <room-video-list />
      <room-chatting-list />
    </div>
  </div>
</template>

<script>
import RoomWhiteboardArea from '@/components/room/room-whiteboard-area'
import RoomVideoList from '@/components/room/room-video-list'
import ZegoWhiteboardArea from '@/components/zego/zego-whiteboard-area'
import RoomControllerWhiteboard from '@/components/room/room-controller-whiteboard'
import RoomControllerFeature from '@/components/room/room-controller-feature'
import RoomChattingList from '@/components/room/room-chatting-list'
import { storage } from '@/utils/tool'
import { roomStore } from '@/service/store/roomStore'

export default {
  name: 'PageLayoutRoom',
  components: {
    RoomWhiteboardArea,
    RoomControllerFeature,
    RoomControllerWhiteboard,
    RoomVideoList,
    ZegoWhiteboardArea,
    RoomChattingList
  },
  mounted() {
    const { roomId, userId, userName, role, classScene} = storage.get('loginInfo')
    roomStore.init({ roomId, uid: userId, name: userName, role, route: this.$route.meta.from, room_type: classScene })
  }
}
</script>
<style lang="scss">
.page-view-room {
  display: flex;
  height: 100%;
  margin: 0 auto;

  .main-area {
    @include wh(100%, 100%);
    @include flex-column();
    flex-grow: 1;
    position: relative;
    .main-top {
      // height: 40px !important;
      width: 100%;
    }
    .main-top,
    .main-bottom {
      @include flex-center();
    }
    .main-mid {
      flex: 1;
    }
    .main-bottom {
      background-color: #ffffff;
    }
  }

  .page-left {
    flex: 1;
  }

  .page-right {
    @include wh(256px, 100%);
  }
}
</style>
