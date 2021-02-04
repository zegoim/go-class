<template>
  <div class="page-login">
    <div class="login-content">
      <div class="img-sertion">
        <img src="../assets/images/login/logo.png" alt class="logo" />
        <img class="login-bg" src="../assets/images/login/login-page-bg.png" alt />
      </div>
      <el-form
        :model="loginForm"
        :rules="rules"
        :hide-required-asterisk="false"
        ref="loginForm"
        class="login-form"
      >
        <div class="login-form-container">
          <div class="welcome">
            <span>{{$t("login.login_welcome")}}</span>
            <span class="forClass">{{$t("login.login_goclass")}}</span>
          </div>
          <el-form-item prop="roomId" class="el-form-item__content roomid">
            <el-input
              :placeholder="$t('login.login_input_classid')"
              v-model="loginForm.roomId"
              class="el-input el-input-ID"
            ></el-input>
          </el-form-item>
          <el-form-item prop="userName" class="el-form-item__content username">
            <el-input
              :placeholder="$t('login.login_enter_name')"
              v-model="loginForm.userName"
              class="el-input"
            ></el-input>
          </el-form-item>
          <el-form-item class="el-form-item__content login-select">
            <el-select
              v-model="loginForm.classScene"
              :placeholder="$t('login.login_select')"
              popper-class="login-select-list"
              @change="setRoomType"
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
              :placeholder="$t('login.login_select')"
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
            >{{$t('login.login_join_class')}}</el-button
          >
          <!--接入环境-->
          <div class="env">
            <el-divider>{{$t('login.login_access_env')}}</el-divider>
            <el-radio-group v-model="loginForm.env">
              <el-radio label="home" class="left">{{$t('login.login_mainland_china')}}</el-radio>
              <el-radio label="overseas">{{$t('login.login_overseas')}}</el-radio>
            </el-radio-group>
            <p class="env-tip">{{$t('login.login_interconnected')}}</p>
          </div>
        </div>
      </el-form>
    </div>
    <el-select
        v-model="zego_locale"
        :placeholder="$t('login.login_select')"
        popper-class="zego-locale-list"
        :popper-append-to-body="false"
        @change="changeLocale"
        class="zego-locale"
      >
        <template slot="prefix">
          <div
              class="prefix-icon"
              v-html="require('../assets/icons/login/language_switch.svg').default"
            ></div>
        </template>
        <el-option label="简体中文" value="zh">
          <span>简体中文</span>
          <span class="option-icon" v-html="require('../assets/icons/login/language_check.svg').default"></span>
        </el-option>
        <el-option label="English" value="en">
          <span>English</span>
          <span class="option-icon" v-html="require('../assets/icons/login/language_check.svg').default"></span>
        </el-option>
      </el-select>
  </div>
</template>

<script>
import zegoClient from '@/service/zego/zegoClient'
import { ZEGOENV } from '@/utils/constants'
import { storage, setLoginInfo } from '@/utils/tool'
import { postRoomHttp, setGoclassEnv } from '@/service/biz/room'

export default {
  name: 'Login',
  data() {
    return {
      showEnv: false,
      envForm: ZEGOENV,
      loginForm: {
        roomId: '',
        userName: '',
        env: '',
        classScene: 1,
        role: 1,
      },
      rules: {
        roomId: [
          {
            required: true,
            pattern: /^[\d]{1,9}$/,
            message: this.$t('login.login_supports_pure_digits'),
            trigger: 'change',
          },
        ],
        userName: [
          {
            required: true,
            message: this.$t('login.login_supports_characters_number_uppercase_letter'),
            pattern: /^[\d\w\u4e00-\u9fa5]{1,30}$/,
            trigger: 'change',
          },
        ],
      },
      classOptions: [
        {
          value: 1,
          label: this.$t('login.login_small_class')
        },
        {
          value: 2,
          label: this.$t('login.login_large_class')
        }
      ],
      roleOptions: [
        {
          value: 1,
          label: this.$t('login.login_teacher')
        },
        {
          value: 2,
          label: this.$t('login.login_student')
        },
      ],
      zego_locale: 'zh',
      isDev: false
    }
  },
  computed: {
    joinBtnClickable() {
      const { roomId, userName } = this.loginForm
      return roomId && userName
    },
  },
  beforeRouteEnter(to, from, next) {
    next(() => {
      if (from.name) {
        // tip:重新初始化sdk
        window.location.reload()
      }
    })
  },
  watch: {
    loginForm: {
      handler(newValue) {
        setLoginInfo(newValue)
      },
      deep: true
    }
  },
  mounted() {
    zegoClient.setState({ isInit: false })
    this.initParams()
    this.isDev = window.location.hostname !== 'goclass.zego.im'
  },
  methods: {
    initParams() {
      const loginInfo = storage.get('loginInfo')
      this.loginForm.roomId = this.$route.query.roomId || loginInfo?.roomId || ''
      this.loginForm.env = this.$route.query.env || loginInfo?.env || 'home'
      this.loginForm.userName = loginInfo?.userName || ''
      this.loginForm.role = loginInfo?.role || 1
      this.loginForm.classScene = storage.get('zego_room_type') || 1
      const zego_locale = sessionStorage.getItem('zego_locale') || 'zh'
      console.warn(zego_locale)
      this.zego_locale = zego_locale
    },
    handleJoinClassroom(e) {
      e.preventDefault()
      this.$refs.loginForm.validate(async (valid) => {
        if (!valid) return
        const loading = this.$loading()
        const { roomId, userName, env, role, classScene } = this.loginForm
        const data = setLoginInfo(this.loginForm)
        const loginParams = {
          uid: data.userId,
          room_id: roomId,
          nick_name: userName,
          role: role,
          room_type: classScene
        }
        // 设置后台环境
        setGoclassEnv(env)
        try {
          await postRoomHttp('login_room', loginParams)
          await zegoClient.init('live', data.env, data.user)
          this.$router.push({ path: 'classroom', query: { roomId, env } })
        } finally {
          this.$nextTick(() => {
            loading.close()
          })
        }
      })
    },
    setRoomType() {
      sessionStorage.setItem('zego_room_type', JSON.stringify(this.loginForm.classScene))
      window.location.reload()
    },
    changeLocale(){
      sessionStorage.setItem('zego_locale',this.zego_locale)
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

    .img-sertion {
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
    float: left;
    color: transparent;
  }
  .zego-locale{
    float: right;
    margin: 24px 42px;
    .el-input{
      @include wh(108px,30px);
      input{
        @include wh(100%,100%);
        background-color: #f4f5f8;
        @include sc(14px, #585c62);
        border:none
      }
      :hover{
        background-color: #ededed;
      }
    }
    .el-input__prefix{
      top: 6px;
      @include wh(18px,18px);
    }
    .el-input--prefix .el-input__inner {
        padding-right: 32px;
    }
    .el-input__suffix{
      @include wh(10px,10px);
      right: 6px;
      top: 10px;
      i.el-select__caret { 
        @include wh(100%,100%);
        appearance:none;
        -moz-appearance:none;
        -webkit-appearance:none;
        background: url("../assets/icons/login/language_drop-down.png") no-repeat scroll right center transparent; 
        background-size: 10px 10px;
      } 
    .el-icon-arrow-up:before {
        content: '';
      }
    }
    .el-input--suffix .el-input__inner {
      padding-right: 16px;
    }
  }
  .zego-locale-list {
    .el-select-dropdown__item{
      display: flex;
      justify-content: space-between;
      padding: 0 12px;
      text-align: left;
    }
    .el-select-dropdown__item.selected{
      color: #0f0f0f;
      font-weight: normal;
    }
  }
  .zego-locale-list .el-select-dropdown__item.selected {
    .option-icon{
      display: inline-block;
      @include wh(10px, 10px);
    }
  }
}
</style>
