<template>
  <div class='page-login'>
    <div class='login-content'>
      <div class='img-section draggable-area'>
        <img src='../assets/images/login/logo.png' alt class='logo'/>
        <img class='login-bg' src='../assets/images/login/login-page-bg.png' alt/>
      </div>
      <el-form
          :model='loginForm'
          :rules='rules'
          :hide-required-asterisk='false'
          ref='loginForm'
          class='login-form'
      >
        <div class='login-form-container'>
          <div>
            <span class='welcome'>欢迎加入</span>
            <span class='forClass'>GO课堂</span>
          </div>
          <el-form-item prop='roomId' class='el-form-item__content roomid'>
            <el-input
                placeholder='请输入课堂ID'
                v-model='loginForm.roomId'
                class='el-input el-input-ID'
            ></el-input>
          </el-form-item>
          <el-form-item prop='userName' class='el-form-item__content username'>
            <el-input
                placeholder='请输入名称'
                v-model='loginForm.userName'
                class='el-input'
            ></el-input>
          </el-form-item>
          <el-form-item class="el-form-item__content login-select">
            <el-select
                v-model="loginForm.classScene"
                placeholder="请选择"
                popper-class="login-select-list"
            >
              <el-option
                  v-for="item in classOptions"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
              >
              </el-option>
            </el-select>
          </el-form-item>
          <el-form-item class="el-form-item__content login-select">
            <el-select
                v-model="loginForm.role"
                placeholder="请选择"
                popper-class="login-select-list"
            >
              <el-option
                  v-for="item in roleOptions"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
              >
              </el-option>
            </el-select>
          </el-form-item>
          <!-- 加入课堂 -->
          <!-- <el-form-item>

          </el-form-item> -->
          <el-button
              type="primary"
              native-type="submit"
              @click="handleJoinClassroom"
              class="join-class"
              :disabled="!joinBtnClickable"
          >加入课堂
          </el-button
          >
          <!--接入环境-->
          <div class="env">
            <el-divider>接入环境</el-divider>
            <el-radio-group v-model="loginForm.env">
              <el-radio label="home" class="left">中国内地</el-radio>
              <el-radio label="overseas">海外</el-radio>
            </el-radio-group>
            <p class="env-tip">
              国内和海外不互通，请确保体验者均连接相同环境
            </p>
          </div>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script>

import zegoClient from '@/service/zego/zegoClient'
// import Config from '@/service/zego/config'
import {ZEGOENV} from '@/utils/constants'
// const electronConf = new Config('electron')
import {storage, setLoginInfo} from '@/utils/tool'
import {postRoomHttp, setGoclassEnv} from '@/service/biz/room'

const {ipcRenderer} = window.require('electron')

const rules = {
  roomId: [
    {
      required: true,
      pattern: /^[\d]{1,9}$/,
      message: '仅支持纯数字，最大9位',
      trigger: 'change'
    }
  ],
  userName: [
    {
      required: true,
      message: '仅支持汉字，数字，大小写字母，最长30位',
      pattern: /^[\d\w\u4e00-\u9fa5]{1,30}$/,
      trigger: 'change'
    }
  ]
}

const isSetEnv = window.location.hostname != 'goclass.zego.im'

export default {
  name: 'Login',
  data() {
    return {
      isSetEnv,
      showEnv: false,
      envForm: ZEGOENV,
      loginForm: {
        roomId: '',
        userName: '',
        env: 'home',
        classScene: 1,
        role: 1
      },
      rules,
      classOptions: [
        {
          value: 1,
          label: '小班课'
        }
      ],
      roleOptions: [
        {
          value: 1,
          label: '老师'
        },
        {
          value: 2,
          label: '学生'
        }
      ]
    }
  },
  computed: {
    joinBtnClickable() {
      const {roomId, userName} = this.loginForm
      return roomId && userName
    }
  },
  beforeRouteEnter(to, from, next) {
    next(() => {
      if (from.name) {
        // storage.remove('zegouid')
        // tip:重新初始化sdk
        window.location.reload()
      }
    })
  },
  mounted() {
    zegoClient.setState({isInit: false})
    this.initParams()
  },
  methods: {
    initParams() {
      const loginInfo = storage.get('loginInfo')
      if (!loginInfo) return
      this.loginForm.roomId = loginInfo.roomId
      this.loginForm.env = loginInfo.env
      this.loginForm.userName = loginInfo?.userName || ''
      this.loginForm.role = loginInfo?.role || 1
    },
    handleJoinClassroom(e) {
      e.preventDefault()
      this.$refs.loginForm.validate(async valid => {
        if (!valid) return
        const loading = this.$loading()
        const {roomId, userName, env, role} = this.loginForm
        const data = setLoginInfo(this.loginForm)
        const loginParams = {
          uid: +data.userId,
          room_id: roomId,
          nick_name: userName,
          role: role
        }
        // 设置后台环境
        setGoclassEnv(env)
        try {
          await postRoomHttp('login_room', loginParams)
          await zegoClient.init('live', data.env, data.user)
          ipcRenderer.send('open-window', {
            name: 'room',
            autoHide: true,
            showHostWhenClose: true,
            listenClose: true,
            data
          })
        } finally {
          localStorage.route = 'electron_mock'
          this.$nextTick(() => {
            loading.close()
          })
        }
      })
    },
    setAllEnv() {
      localStorage.setItem('zegoenv', JSON.stringify(this.envForm))
      this.showEnv = false
      window.location.reload()
    }
  }
}
</script>

<style lang="scss">
.login-select-list {
  margin-top: 6px !important;
  border-color: #f4f5f8 !important;

  // box-shadow: none !important;
  .popper__arrow {
    display: none !important;
  }

  .el-select-dropdown__item {
    &.selected {
      color: #0044ff;
      font-weight: normal;
    }
  }

  .el-select-dropdown__list {
    padding: 8px 0;
    border-radius: 6px;
    box-shadow: -5px 5px 10px -4px rgba(0, 0, 0, 0.04), 5px 5px 10px -4px rgba(0, 0, 0, 0.04);
  }
}

.page-login {
  @include wh(100%, 100%);
  background-color: #f4f5f8;

  .el-dialog {
    -webkit-app-region: no-drag;
  }

  .login-content {
    @include wh(920px, 560px);
    @include abs-pos(50%, auto, auto, 50%);
    @include box-shadow(3px 3px 30px rgba(0, 0, 0, 0.08));
    display: flex;
    margin: 0 auto;
    border-radius: 6px;
    transform: translate(-50%, -50%);
    background-color: #fff;

    // /deep/ {
    .el-form-item {
      width: 260px;
      margin-bottom: 0;
    }

    .el-form-item__label {
      text-align: left;
    }

    .el-form-item__content {
      @include wh(260px, 48px);
      @include sc(12px, #585c62);

      &.is-error {
        height: 58px;
      }
    }

    .el-input__inner {
      @include wh(260px, 34px);
      @include sc(14px, #18191a);
      padding: 0 16px;
      background-color: #f4f5f8;
      border: 0;
      border-radius: 4px;
    }

    .el-form-item__label {
      @include sc(12px, #585c62);
      display: block;
      height: 14px;
      line-height: 14px;
      padding: 0;
    }

    .el-input-ID {
      // margin-bottom: 10px;
    }

    .join-class {
      @include wh(190px, 38px);
      @include sc(14px, #fff);
      border-radius: 20px;
      margin: 18px auto 0;
      border-color: #1751f5;
      background-color: #1751f5;

      &:disabled {
        border-color: #94b0ff;
        background-color: #94b0ff;
      }
    }

    .login-form {
      @include wh(340px, 460px);
      float: left;
      margin: 34px 80px 50px 80px;
      border-radius: 3px;
    }

    .login-form-container {
      position: relative;
    }

    .username {
      display: block;
      // margin-top: 10px;
    }

    .welcome {
      margin-bottom: 20px;
      @include sc(18px, #585c62);
      font-weight: bold;
      text-align: left;
    }

    .forClass {
      display: block;
      @include sc(26px, #18191a);
      font-weight: bold;
      text-align: left;
    }

    .el-input {
      @include wh(260px, 34px);
      font-size: 14px;
    }

    .el-form-item__error {
      @include sc(10px, #f64326);
      @include abs-pos(43px, auto, auto, 0);
      padding: 0;
    }

    .env {
      @include abs-pos(341px, auto, 24px, auto);
      width: 100%;

      .el-divider--horizontal {
        margin: 72px 0 16px 0;
      }

      .el-divider__text {
        @include sc(12px, #585c62);
        padding: 0 16px;
      }

      .el-radio {
        @include sc(12px, #18191a);
        font-weight: normal;
        // line-height: 18px;
        &__inner {
          @include wh(16px, 16px);
          border: 2px solid #c0c4cc;
        }

        &__label {
          padding-left: 4px;
          @include sc(12px, #18191a);
        }

        &.is-checked {
          .el-radio__inner {
            border-color: #0044ff;
            background: #0044ff;

            &::after {
              @include wh(5px, 5px);
            }
          }
        }
      }

      .left {
        margin-right: 40px;
      }

      .env-tip {
        width: 190px;
        margin: 0 auto;
        margin-top: 8px;
        text-align: center;
        line-height: 18px;
        @include sc(12px, #b1b4bb);
      }
    }

    .login-select {
      .el-input__icon {
        line-height: 34px;
        font-size: 12px;
      }

      .el-icon-arrow-up {
        margin-right: 4px;
        color: #b1b4bb;

        &.is-reverse {
          color: #0044ff;
        }
      }
    }

    // }

    .img-section {
      width: 500px;
      // height: 500px;
      background-color: #f9fafb;

      .login-bg {
        @include wh(400px, 400px);
        display: block;
        margin: 34px 50px 60px 50px;
      }

      .logo {
        @include wh(92px, 16px);
        display: block;
        margin: 50px 0 0 60px;
      }
    }
  }

  .envbtn {
    position: fixed;
    top: 0;
    right: 0;
    color: transparent;
  }
}
</style>
