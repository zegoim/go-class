<template>
  <div class="room-video-list">
    <ul class="video-preview-list">
      <room-video-item :stream="teacherStream" />
      <room-video-item v-for="stream in stuStreamList" :key="stream.streamID" :stream="stream" />
    </ul>
  </div>
</template>

<script>
import RoomVideoItem from './room-video-item'
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
      memberList    : [],                    // 连麦成员列表
      teacherStream : emptyTeacherStream,    // 老师流
      stuStreamList : []                     // 学生流列表
    }
  },
  inject: ['zegoLiveRoom'],
  computed: {
    streamList() {
      return this.zegoLiveRoom.streamList
    }
  },
  watch: {
    streamList: function(newList) {
      const memberList = this.memberList.slice()
      newList = newList.slice()
      this.makeTeacherStream(newList, memberList)
      this.makeStuStreamList(newList, memberList)
    },
    memberList: function(newList) {
      const streamList = this.streamList.slice()
      this.makeTeacherStream(streamList, newList)
      this.makeStuStreamList(streamList, newList)
    }
  },
  mounted() {
    this.$bus.$on('roomJoinLivesChange', this.onRoomJoinLivesChange)
    this.$bus.$on('userStateChange', this.onUserStateChange)
  },
  destroyed() {
    this.$bus.$off('roomJoinLivesChange', this.onRoomJoinLivesChange)
    this.$bus.$off('userStateChange', this.onUserStateChange)
  },
  methods: {
    /**
     * @desc 房间连麦成员列表变化监听
     */
    onRoomJoinLivesChange(res) {
      this.$set(this, 'memberList', res)
    },
    /**
     * @desc 成员 摄像头/麦克风/共享权限 状态变化监听
     */
    onUserStateChange(users, local) {
      console.warn('onUserStateChange list', { users, local })
      if (local) {
        this.memberList.forEach(v => {
          Object.assign(v, users[v.uid])
          v.isVideoOpen = users[v.uid]?.camera === STATE_OPEN
          v.isAudioOpen = users[v.uid]?.mic === STATE_OPEN
        })
        this.memberList = [...this.memberList]
        console.log('this.memberList', this.memberList)
      }
    },

    /**
     * @desc  获取老师流
     * @param {streamList} 音视频sdk原始成员流
     * @param {memberList} 后台返回房间连麦成员列表
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
     * @param {streamList} 音视频sdk原始成员流
     * @param {memberList} 后台返回成员连麦成员列表
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
  @include wh(100%, 100%);
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
