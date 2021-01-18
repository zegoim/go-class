<!--
 * @Description: IM聊天室
-->
<template>
  <div class="message-box">
    <div class="title">{{$t("room.room_im_discuss")}}</div>
    <div class="message-list" ref="messageList">
      <div
        v-for="item of messages"
        :key="item.messageID || item.messageTimestamp"
        :class="[
          item.userID == user.uid ? 'isMe' : '',
          item.messageCategory === 1 ? 'item' : 'state-item',
        ]"
      >
        <!--用户发送普通消息 messageCategory == 1 -->
        <div class="name" v-if="item.messageCategory == 1 && item.userID != user.uid">
          {{ item.nick_name }}
        </div>
        <!--用户进入房间系统消息 messageCategory == 2 -->
        <div class="text" v-if="item.messageCategory !== 1">
          {{ item.userID == user.uid ? $t('room.room_im_I') : item.nick_name }} {{ item.messageContent[0] }}
        </div>
        <div class="text-box" v-if="item.messageCategory === 1">
          <div v-for="(item, i) of item.messageContent" :key="i" class="text-item">
            <!--消息状态 messageState = 1 发送中 -->
            <div class="loading-box" v-show="item.messageState === 1">
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
            <!--消息状态 messageState = 2 发送失败 -->
            <!--消息状态 messageState = 3 发送成功 -->
            <el-tooltip class="item" effect="dark" :content="$t('room.room_im_message_send_fail')" placement="top">
              <div
                class="icon icon-fail"
                v-show="item.messageState === 2"
                v-html="require('../../assets/icons/room/discuss_fail.svg').default"
              ></div>
             </el-tooltip>
            <p class="text">{{ item.content }}</p>
          </div>
        </div>
      </div>
    </div>
    <div class="send">
      <textarea
        class="send-textarea"
        maxlength="100"
        :placeholder="$t('room.room_im_say_something')"
        v-model="textareaValue"
        @keyup.enter="enterToSend"
      ></textarea>
      <div class="send-tool-box">
        <div class="input-warn">
          <div class="input-warn-tip" v-show="textareaValue.length === 100">
            <div
              class="icon"
              v-html="require('../../assets/icons/room/input_error.svg').default"
            ></div>
            {{$t('room.room_im_max_characters')}}
          </div>
        </div>

        <button class="btn" @click="send" :disabled="isDisabled">{{$t('room.room_im_send')}}</button>
      </div>
    </div>
  </div>
</template>
<script>
import { roomStore } from '@/service/biz/room'
export default {
  name: 'RoomChattingList',
  inject: ['zegoLiveRoom'],
  components: {},
  data() {
    return {
      user: {}, // 用户信息
      textareaValue: '',
      sendTime: 0,
      clientHeight: 0, //im初始高度
    }
  },
  computed: {
    messages() {
      return this.zegoLiveRoom.messages
    },
    isDisabled() {
      return !this.textareaValue
    },
  },
  mounted() {
    this.user = roomStore.params // 用户信息
    this.$bus.$on('imAttendeesChange', this.onIMAttendeesChange)
    // 获取初始高度值
    this.clientHeight = this.$refs.messageList.clientHeight
  },
  updated() {
    // 聊天定位到底部
    this.$refs.messageList.scrollTop = this.$refs.messageList.scrollHeight
  },
  destroyed() {},
  methods: {
    /**
     * @desc: 监听im成员变化
     * @param {*} res
     * @return {*}
     */
    onIMAttendeesChange(res) {
      let data = {
        userID: res.uid,
        messageCategory: 2,
        messageContent: res.delta === 1 ? [this.$t('room.room_im_join_class')] : [this.$t('room.room_im_exit_class')],
        messageState: 1,
        nick_name: res.nick_name,
      }
      this.zegoLiveRoom.setRoomMessage(1, data)
    },
    /**
     * @desc: 回车发送消息
     */
    async enterToSend() {
      if (this.sendTime && new Date().getTime() - this.sendTime < 300) {
        this.showToast(this.$t('room.room_im_messasge_sent_frequently'))
        return
      }
      // 除掉回车换行符
      let textareaValue = this.textareaValue.replace(/[\r\n]/g, '')
      this.textareaValue = ''
      if (textareaValue) {
        this.sendMessage(textareaValue)
      } else {
        this.textareaValue = ''
        this.showToast(this.$t('room.room_im_message_cannot_empty'))
      }
    },
    /**
     * @desc: 点击发送按钮发送消息
     */
    send() {
      if (this.sendTime && new Date().getTime() - this.sendTime < 300) {
        this.showToast(this.$t('room.room_im_messasge_sent_frequently'))
        return
      }
      let message = this.textareaValue
      this.textareaValue = ''
      this.sendMessage(message)
    },
    /**
     * @desc: 发送消息
     */    
    async sendMessage(message){
      try {
        await this.zegoLiveRoom.sendBarrageMessage(message)
      } catch (e) {
        this.showToast(this.$t('room.room_im_message_send_fail'))
      }
      this.sendTime = new Date().getTime()
      this.$nextTick(() => {
        this.$refs.messageList.scrollTop = this.$refs.messageList.scrollHeight - this.clientHeight
      })
    }
  },
}
</script>
<style lang="scss" scoped>
.message-box {
  position: relative;
  display: flex;
  flex-direction: column;
  height: calc(100% - 144px);
  overflow: hidden;
  background-color: #fbfcff;
  padding-right: 2px;
  .title {
    height: 32px;
    @include sc(12px, #18191a);
    line-height: 32px;
    box-sizing: border-box;
    border-bottom: 1px solid #edeff3;
  }
  .message-list {
    position: relative;
    box-sizing: border-box;
    padding: 0 10px;
    overflow: auto;
    flex-grow: 1;
    @include wh(100%, 168px);

    &::-webkit-scrollbar {
      width: 4px;
    }
    &::-webkit-scrollbar-track {
      padding-right: 2px;
    }
    &::-webkit-scrollbar-thumb {
      background-color: rgba(177, 180, 188, 0.5);
      border-radius: 2px;
    }
    .item {
      display: flex;
      flex-direction: column;
      font-size: 12px;
      font-weight: 400;
      .name {
        margin-bottom: 1px;
        line-height: 18px;
        color: #86888c;
        text-align: left;
      }
      .text-box {
        display: flex;
        flex-direction: column;
        text-align: left;
      }
      .text-item {
        display: flex;
        align-items: center;
      }
      .text {
        margin: 4px 0;
        padding: 9px 12px;
        width: fit-content;
        max-width: 181px;
        background-color: #fff;
        color: #585c62;
        line-height: 18px;
        border-radius: 2px 16px 16px 16px;
        word-break: break-all;
        @include box-shadow(0 0 10px 2px rgba($color: #000000, $alpha: 0.04));
        p {
          margin: 0;
        }
      }

      &.isMe {
        position: relative;
        .text-box {
          align-items: flex-end;
        }
        .text {
          margin: 4px 0;
          background-color: #0044ff;
          border-radius: 16px 2px 16px 16px;
          color: #fff;
          @include box-shadow(0 0 10px 2px rgba($color: #0044ff, $alpha: 0.2));
        }
        .loading-box {
          position: relative;
          @include wh(18px, 18px);
          margin: 0 auto;
          margin-right: 6px;
          .fade-item {
            position: absolute;
            top: 0;
            left: 0;
            @include wh(18px, 18px);
            &:before {
              content: '';
              display: block;
              margin: 0 auto;
              @include wh(1px, 5px);
              background-color: #bcbfc5;
              border-radius: 2px;
              -webkit-border-radius: 2px;
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
        .icon {
          margin-right: 6px;
          @include wh(16px, 16px);
        }
      }
    }
    .state-item {
      padding: 7px 0;
      text-align: center;
      line-height: 12px;
      @include sc(12px, #86888c);
      .name {
        display: inline-block;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        vertical-align: bottom;
        max-width: 145px;
      }
      .text {
        display: inline-block;
      }
    }
  }
  .send {
    @include wh(100%, 110px);
    padding: 14px 0;
    padding-right: 2px;
    box-sizing: border-box;
    border-top: 1px solid #edeff3;
    .send-textarea {
      padding: 0 14px;
      resize: none;
      @include wh(228px, 44px);
      @include sc(12px, #585c62);
      background-color: transparent;
      border: none;
      word-break: break-all;
      &::-webkit-scrollbar {
        width: 4px;
      }
      &::-webkit-scrollbar-track {
        padding-right: 2px;
      }
      &::-webkit-scrollbar-thumb {
        background-color: rgba(177, 180, 188, 0.5);
        border-radius: 2px;
      }
      &:focus {
        outline: none;
      }
    }
    .send-textarea:disabled {
      &::-webkit-input-placeholder {
        color: #505458;
      }
    }
    .send-tool-box {
      display: flex;
      justify-content: space-between;
      align-items: center;
      .input-warn {
        display: flex;
        &-tip {
          display: flex;
          height: 12px;
          @include sc(12px, #f64326);
          margin-left: 14px;
          line-height: 12px;
          .icon {
            margin-right: 4px;
            @include wh(12px, 12px);
          }
        }
      }
      .btn {
        padding: 0;
        border: 0;
        text-align: center;
        @include wh(44px, 24px);
        @include sc(12px, #edf1fa);
        border-radius: 4px;
        background-color: #0044ff;
        line-height: 24px;
        &:hover {
          cursor: pointer;
          background-color: #0030ff;
          @include box-shadow(0 0 10px 2px rgba($color: #0044ff, $alpha: 0.02));
        }
        &:active {
          background-color: #0044ff;
        }
        &:focus {
          outline: none;
        }
        &:disabled {
          cursor: not-allowed;
          background-color: #9ab0f9;
          color: #ffffff;
        }
      }
    }
  }
}
</style>
