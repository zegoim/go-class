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
            <span>欢迎加入</span>
            <span class="forClass">GO课堂</span>
          </div>
          <el-form-item prop="roomId" class="el-form-item__content roomid">
            <el-input
              placeholder="请输入课堂ID"
              v-model="loginForm.roomId"
              class="el-input el-input-ID"
            ></el-input>
          </el-form-item>
          <el-form-item prop="userName" class="el-form-item__content username">
            <el-input
              placeholder="请输入名称"
              v-model="loginForm.userName"
              class="el-input"
            ></el-input>
          </el-form-item>
          <el-form-item class="el-form-item__content login-select">
            <el-select
              v-model="loginForm.classScene"
              placeholder="请选择"
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
            >加入课堂</el-button
          >
          <!--接入环境-->
          <div class="env">
            <el-divider>接入环境</el-divider>
            <el-radio-group v-model="loginForm.env">
              <el-radio label="home" class="left">中国内地</el-radio>
              <el-radio label="overseas">海外</el-radio>
            </el-radio-group>
            <p class="env-tip">国内和海外不互通，请确保体验者均连接相同环境</p>
          </div>
        </div>
      </el-form>
    </div>
    <el-button class="envbtn" type="text" @click="showEnv = true">设置</el-button>
    <el-dialog title="设置环境" width="360px" :visible.sync="showEnv">
      <el-form :model="envForm" label-width="100px" label-position="right">
        <el-form-item label="白板环境">
          <el-select v-model="envForm.wb" placeholder="请选择 白板 环境">
            <el-option label="alpha" value="alpha"></el-option>
            <el-option label="test" value="test"></el-option>
            <el-option label="正式" value=""></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="文件环境">
          <el-select v-model="envForm.docs" placeholder="请选择 文件 环境">
            <el-option label="测试" value="test"></el-option>
            <el-option label="正式" value=""></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="Go课堂环境">
          <el-select v-model="envForm.goclass" placeholder="请选择 Go课堂 环境">
            <el-option label="测试" value="test"></el-option>
            <el-option label="正式" value=""></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="PPT切页">
          <el-select v-model="envForm.pptStepMode" placeholder="请选择 切页模式">
            <el-option label="正常" value="1"></el-option>
            <el-option label="不切页" value="2"></el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <el-button type="primary" @click="setAllEnv">确定</el-button>
    </el-dialog>
  </div>
</template>

<script>
import zegoClient from '@/service/zego/zegoClient'
import { ZEGOENV,APPID } from '@/utils/constants'
import { storage, setLoginInfo } from '@/utils/tool'
import { postRoomHttp, setGoclassEnv } from '@/service/biz/room'

const rules = {
  roomId: [
    {
      required: true,
      pattern: /^[\d]{1,9}$/,
      message: '仅支持纯数字，最大9位',
      trigger: 'change',
    },
  ],
  userName: [
    {
      required: true,
      message: '仅支持汉字，数字，大小写字母，最长30位',
      pattern: /^[\d\w\u4e00-\u9fa5]{1,30}$/,
      trigger: 'change',
    },
  ],
}

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
      rules,
      classOptions: [
        {
          value: 1,
          label: '小班课',
        },
        {
          value: 2,
          label: '大班课',
        },
      ],
      roleOptions: [
        {
          value: 1,
          label: '老师',
        },
        {
          value: 2,
          label: '学生',
        },
      ],
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
      deep: true,
    },
  },
  mounted() {
    zegoClient.setState({ isInit: false })
    this.initParams()
  },
  methods: {
    showTip(){
      if (this.loginForm.classScene == 2 && APPID.home == 0) {
        this.$alert('演示项目仅提供小班课场景，即构官网可在线体验大班课场景。本地运行体验大班课需申请appID，如需帮助可联系技术支持。', '提示', {
            confirmButtonText: '确定'
          });
        return true
        }
    },
    initParams() {
      const loginInfo = storage.get('loginInfo')
      this.loginForm.roomId = this.$route.query.roomId || loginInfo?.roomId || ''
      this.loginForm.env = this.$route.query.env || loginInfo?.env || 'home'
      this.loginForm.userName = loginInfo?.userName || ''
      this.loginForm.role = loginInfo?.role || 1
      this.loginForm.classScene = storage.get('zego_room_type') || 1
    },
    handleJoinClassroom(e) {
      if(this.showTip()) return
      
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
          room_type: classScene,
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
    setAllEnv() {
      sessionStorage.setItem('zegoenv', JSON.stringify(this.envForm))
      this.showEnv = false
      window.location.reload()
    },
    setRoomType() {
      sessionStorage.setItem('zego_room_type', JSON.stringify(this.loginForm.classScene))
      window.location.reload()
    },
  },
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
    float: right;
    color: transparent;
  }
}
</style>
