<template>
  <li class="video-item">
    <span v-if="isTeacher" class="role-tag">老师</span>
    <div class="no-stream-mask" v-if="isTeacherQuit">
      <div class="center-content">
        <div
            class="icon-camera-close"
            v-html="require('../../assets/icons/room/seating_teacher.svg').default"
        />
        <div class="tip">等待老师加入</div>
      </div>
    </div>
    <div class="no-video-mask" v-else-if="isTeacher && !isVideoOpen">
      <div class="center-content">
        <div
            class="icon-camera-close"
            v-html="require('../../assets/icons/room/seating_teacher.svg').default"
        />
      </div>
    </div>
    <div class="no-video-mask" v-if="!isTeacher && !isVideoOpen">
      <div
          class="icon-camera-close"
          v-html="require('../../assets/icons/room/seating_student.svg').default"
      />
    </div>
    <room-controller-video :user="stream.user" v-if="!!stream.user.uid" :isTeacher="isTeacher"/>
  </li>
</template>

<script>
import RoomControllerVideo from './room-controller-video'
import {isFirefox} from '@/utils/browser'
import {ROLE_TEACHER, STATE_OPEN, STATE_CLOSE} from '@/utils/constants'

export default {
  name: 'RoomVideoItem',
  props: ['stream'],
  inject: ['zegoLiveRoom'],
  components: {
    RoomControllerVideo
  },
  data() {
    return {
      interaction: false,    // 是否已交互
      isMuted: false     // 默认不静音
    }
  },
  computed: {
    // 该用户摄像头是否打开
    isVideoOpen() {
      return this.stream.isVideoOpen
    },
    // 该用户麦克风是否打开
    isAudioOpen() {
      return this.stream.isAudioOpen
    },
    // 该用户是否加入连麦
    isJoing() {
      return this.stream.user.joing
    },
    // 该用户是否老师
    isTeacher() {
      return this.stream.user.role == ROLE_TEACHER
    },
    // 老师是否退出当前房间
    isTeacherQuit() {
      return this.isTeacher && !this.stream.streamID
    },
    // 当前房间是否销毁
    isDestroy() {
      return (!this.isAudioOpen && !this.isVideoOpen) || !this.isJoing
    }
  },
  watch: {
    /**
     * @desc: 销毁之前需要停止播放流
     */
    isDestroy(newVal) {
      if (newVal) {
        if (this.stream.streamID) {
          if (this.stream.user.isMe) {
            this.zegoLiveRoom.handleDestroyStream(this.stream.streamID)
          } else {
            this.zegoLiveRoom.stopPlayingStream(this.stream.streamID)
          }
        }
      }
    },
    isTeacherQuit(newVal) {
      if (newVal) {
        // this.zegoLiveRoom.stopPlayingStream(this.stream.streamID)
        this.deleteVideoTag()
      }
    },
    /**
     * @desc: 监听摄像头状态
     * @param newVal {boolean} 摄像头是否开启
     */
    isVideoOpen(newVal) {
      this.$bus.$emit('userStateChange', {[this.stream.user.uid]: {camera: newVal ? STATE_OPEN : STATE_CLOSE}}, false)
      if (newVal) {
        const $video = document.getElementById(this.stream.streamID)
        if ($video) {
          console.warn('isVideoOpen 修改muted', this.stream.user.isMe ? true : this.isMuted)
          // tip:本端播放自己流的video muted属性设置都是为true，播放其他流的video的muted属性则根据扬声器状态来设置
          $video.muted = this.stream.user.isMe ? true : this.isMuted
          $video.tagName !== 'CANVAS' && $video.play()
        }
      }
    },
    /**
     * @desc: 监听麦克风状态
     * @param newVal {boolean} 摄像头是否开启
     */
    isAudioOpen(newVal) {
      this.$bus.$emit('userStateChange', {[this.stream.user.uid]: {mic: newVal ? STATE_OPEN : STATE_CLOSE}}, false)
    },
    /**
     * @desc: 监听流id变化
     * @param {value} 新的流
     * @return {oldValue} 旧的流
     */
    'stream.streamID': function (value, oldValue) {
      // tip:重新拉流之前需把旧的流停止拉取，不然会重复拉流
      if (!value) {
        this.zegoLiveRoom.stopPlayingStream(oldValue)
        this.deleteVideoTag(oldValue)
      }
      this.$nextTick().then(() => this.pullVideo(value))
    }
  },
  mounted() {
    this.pullVideo(this.stream.streamID)
    this.onMuteSpeaker()
  },
  beforeDestroy() {
    // tip:electron集成相关操作，web集成可不管
    if (this.$video?.nodeName === 'CANVAS') {
      if (this.stream.user.isMe) {
        this.zegoLiveRoom.stopPreview()
        this.zegoLiveRoom.handleDestroyStream()
      } else {
        this.stream.streamID && this.zegoLiveRoom.stopPlayingStream(this.stream.streamID)
      }
      this.zegoLiveRoom.loseCanvasContext({canvas: this.$video}, () => {
        this.$video = null
      })
      return
    }
    this.stream.streamID && this.zegoLiveRoom.stopPlayingStream(this.stream.streamID)
    this.$video = null
  },
  methods: {
    /**
     * @desc 扬声器监听
     */
    onMuteSpeaker() {
      this.zegoLiveRoom.onMuteSpeaker(isOpen => {
        this.isMuted = !isOpen // 设置静音
        const $video = document.getElementById(this.stream.streamID)
        if (!$video) return
        if ($video?.nodeName == 'CANVAS') {
          // tip:electron集成相关操作，web集成可不管
          this.zegoLiveRoom.enableSpeaker({enable: isOpen})
        } else if ($video?.nodeName == 'VIDEO') {
          console.warn('onMuteSpeaker 修改muted', this.stream.user.isMe ? true : this.isMuted)
          // tip:本端播放自己流的video muted属性设置都是为true，播放其他流的video的muted属性则根据扬声器状态来设置
          $video.muted = this.stream.user.isMe ? true : this.isMuted
        }
      })
    },
    /**
     * @desc 拉流
     * @returns {Promise<void>}
     */
    async pullVideo(streamID) {
      if (!streamID) {
        this.deleteVideoTag()
        return
      }
      const className = 'video' + (this.stream.type === 'push' ? ' pull-stream' : '')
      // tip:如果是本端拉自己的流则直接预览即可，如果是要拉对端的流则使用startPlayingStream播放流
      this.stream.user.isMe
          ? this.zegoLiveRoom.startPreview(streamID, this.$el)
          : await this.zegoLiveRoom.startPlayingStream(streamID, {}, this.$el)
      this.$video = document.getElementById(streamID)
      this.$video.setAttribute('class', className)
      console.warn('this.isMuted', this.isMuted)
      console.warn('pullVideo 修改muted', this.stream.user.isMe ? true : this.isMuted)
      // tip:本端播放自己流的video muted属性设置都是为true，播放其他流的video的muted属性则根据扬声器状态来设置
      this.$video.muted = this.stream.user.isMe ? true : this.isMuted
      // tip:electron集成相关操作，web集成可不管
      if (this.$video.nodeName === 'CANVAS') return
      this.autoPlay()
    },

    /**
     * @desc: 渲染的video自动播放音视频流
     */
    autoPlay() {
      console.warn('自动播放')
      if (isFirefox) {
        this.tryFirefoxPlay(this.$video)
        return
      }
      const canplayHandle = $ele => {
        if ($ele) {
          console.warn('canplayHandle 修改muted', this.stream.user.isMe ? true : this.isMuted)
          $ele.muted = this.stream.user.isMe ? true : this.isMuted

          $ele.tagName !== 'CANVAS' && $ele.play()
        }
      }
      if (this.interaction) {
        this.$video.addEventListener('canplay', () => {
          canplayHandle(this.$video)
        })
      } else {
        const $app = document.getElementById('app')
        const mousedownHandle = () => {
          console.warn('模拟交互 自动播放')
          canplayHandle(this.$video)
          this.interaction = true
          $app.removeEventListener('mousedown', mousedownHandle)
        }
        this.$video.click()
        $app.addEventListener('mousedown', mousedownHandle)
      }
    },
    /**
     * @desc 浏览器兼容性处理
     */
    tryFirefoxPlay($video) {
      if (!$video && $video.tagName !== 'CANVAS') return
      console.warn('firefox try play', $video)
      $video
          .play()
          .then(() => {
            console.warn('firefox', '播放成功')
            clearTimeout($video.tryPlaytimer)
            console.warn('tryFirefoxPlay 修改muted', this.stream.user.isMe ? true : this.isMuted)
            $video.muted = this.stream.user.isMe ? true : this.isMuted
          })
          .catch(e => {
            console.warn('firefox', '播放失败', e)
            $video.tryPlaytimer = setTimeout(() => {
              this.tryFirefoxPlay($video)
            }, 200)
          })
    },

    /**
     * @desc: 每次停止拉流，生成的video标签需要开发者自行销毁
     */
    deleteVideoTag(id) {
      if (this.$el?.removeChild) {
        let $videos = document.getElementById(id)
        console.warn('deleteVideoTag', { $videos })
        $videos?.parentElement.removeChild($videos)
        $videos = null
      }
    }
  }
}
</script>

<style lang="scss">
.video-item {
  position: relative;
  height: 144px;

  video {
    @include wh(100%, 100%);
    object-fit: cover;
  }

  .role-tag {
    display: inline-block;
    @include wh(46px, 22px);
    position: absolute;
    left: 0;
    top: 0;
    @include sc(12px, #ffffff);
    @include textCenter(22px);
    background-color: #4879ff;
    z-index: 10;
  }

  .no-stream-mask,
  .no-video-mask {
    @include abs-pos(0, 0, 0, 0);
    @include flex-center();
    padding: 0 40px;
    background-color: rgba(251, 252, 255, 1);
    z-index: 2;

    .icon-camera-close {
      @include wh(50px, 50px);
      margin: 0 auto;
    }

    .tip {
      @include sc(14px, #b1b4bb);
      line-height: 14px;
      margin-top: 8px;
    }
  }
}
</style>
