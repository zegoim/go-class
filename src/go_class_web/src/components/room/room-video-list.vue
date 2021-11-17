<!--
 * @Description: 右侧坐席区组件
-->
<template>
  <div class="room-video-list">
    <ul class="video-preview-list">
      <room-video-item :stream="teacherStream" />
      <div v-if="classScene !==2 ">
        <room-video-item v-for="stream in stuStreamList" :key="stream.streamID" :stream="stream" />
      </div>
    </ul>
  </div>
</template>

<script>
import { storage } from '@/utils/tool'
import RoomVideoItem from './room-video-item'
import { roomStore } from '@/service/store/roomStore'
import {ROLE_TEACHER, STATE_OPEN} from '@/utils/constants'
// 老师默认占一个麦位，创建一条默认无数据流
const emptyTeacherStream = { streamID: '', user: { role: ROLE_TEACHER } }
export default {
  name: 'RoomVideoList',
  components: {
    RoomVideoItem
  },
  data() {
    return {
      teacherStream : emptyTeacherStream,    // 老师流
      stuStreamList : [],                     // 学生流列表
      classScene: storage.get('loginInfo').classScene  || 1
    }
  },
  inject: ['zegoLiveRoom'],
  computed: {
    streamList() { // 流列表
      return this.zegoLiveRoom.streamList
    },
    memberList () { // 连麦成员列表
      return roomStore.joinLiveList
    }
  },
  watch: {
    streamList: function(newList) { // 监听流变化
      const memberList = this.memberList.slice()
      newList = newList.slice()
      this.makeTeacherStream(newList, memberList)
      this.makeStuStreamList(newList, memberList)
    },
    memberList: function(newList) { // 监听成员状态变化
      const streamList = this.streamList.slice()
      this.makeTeacherStream(streamList, newList)
      this.makeStuStreamList(streamList, newList)
    }
  },
  methods: {
    /**
     * @desc  获取老师流
     * @param streamList - 音视频sdk原始成员流
     * @param memberList - 后台返回房间连麦成员列表
     */
    makeTeacherStream(streamList, memberList) {
      if (!memberList.length) return
      if (!memberList[0].uid || !streamList.length) {
        const teacherStream = this.teacherStream
        teacherStream.user = memberList[0]
        teacherStream.isVideoOpen = teacherStream.user.camera === STATE_OPEN
        teacherStream.isAudioOpen = teacherStream.user.mic === STATE_OPEN
        teacherStream.streamID = ''
        this.$set(this, 'teacherStream', teacherStream)
        return
      }
      const id = memberList[0].uid
      const joing = memberList[0].joing
      let stream = streamList.find(v => joing && (v.user.uid == id || v.user.userID == id))
      if (!stream) {
        const teacherStream = this.teacherStream
        teacherStream.user = memberList[0]
        teacherStream.isVideoOpen = teacherStream.user.camera === STATE_OPEN
        teacherStream.isAudioOpen = teacherStream.user.mic === STATE_OPEN
        teacherStream.streamID = ''
        this.$set(this, 'teacherStream', teacherStream)
        return
      }
      stream.user = { ...stream.user, ...this.teacherStream.user, ...memberList[0] }
      stream.isVideoOpen = stream.user.camera === STATE_OPEN
      stream.isAudioOpen = stream.user.mic === STATE_OPEN
      this.$set(this, 'teacherStream', stream)
    },
    /**
     * @desc  获取学生流列表
     * @param streamList - 音视频sdk原始成员流
     * @param memberList - 后台返回成员连麦成员列表
     */
    makeStuStreamList(streamList, memberList) {
      let arr = []
      for (let i = 1; i < memberList.length; i++) {
        const id = memberList[i].uid
        const stream = streamList.find(v => v.user.uid == id || v.user.userID == id)
        if (stream) {
          stream.user = { ...stream.user, ...memberList[i] }
          stream.isVideoOpen = stream.user.camera === STATE_OPEN
          stream.isAudioOpen = stream.user.mic === STATE_OPEN
          arr.push(stream)
        } else {
          arr.push({ streamID: '', user: memberList[i] })
        }
      }
      this.$set(this, 'stuStreamList', arr)
      arr = null
    }
  }
}
</script>
<style lang="scss">
.room-video-list {
  width: 100%;
  // @include wh(100%, 100%);
  overflow-y: auto;
  background: rgba(251, 252, 255, 1);

  &::-webkit-scrollbar {
    width: 8px;
  }
  &::-webkit-scrollbar-thumb {
    background-color: rgba(177, 180, 188, 0.5);
    border-radius: 2px;
  }
}
</style>
