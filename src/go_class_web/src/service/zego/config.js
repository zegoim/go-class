import axios from 'axios'
import { signToArray, createUserId, electron_get_cachePath, storage } from '@/utils/tool'
const cachePath = electron_get_cachePath()

/**
 * go class配置梳理:
 * 1. 构建环境分为：
 *    * 生产环境 - ZEGOENV.wb=
 * 2. 房间环境分为国内(home)和海外(oversea)环境；
 * 3. 海外环境的docview取的是home的appid配置
 */

const appIDMap = {
  1: +process.env.VUE_APP_ZEGO_APPID,
  2: +process.env.VUE_APP_ZEGO_APPID2,
  3: +process.env.VUE_APP_ZEGO_APPID3,
  4: +process.env.VUE_APP_ZEGO_APPID4
}

const appSignMap = {
  1: process.env.VUE_APP_ZEGO_APPSIGN,
  2: process.env.VUE_APP_ZEGO_APPSIGN2,
  3: process.env.VUE_APP_ZEGO_APPSIGN3,
  4: process.env.VUE_APP_ZEGO_APPSIGN4
}

class BaseConfig {
  constructor() {
    let index = 1
    const loginInfo = storage.get('loginInfo')
    if (loginInfo) {
      index = loginInfo.env === 'overseas' ? (loginInfo.classScene === 1 ? 2 : 4) : loginInfo.classScene === 1 ? 1 : 3
    }
    this.appID = appIDMap[index]
    console.warn('appID', this.appID)
    this.appSign = appSignMap[index]
    this.userID = createUserId() + ''
    this.home = this.createConfig(this.appID, '', '', this.userID, [])
    this.overseas = this.createConfig(this.appID, '', '', this.userID, [])
    this.test = this.createConfig(this.appID, '', '', this.userID, [])
  }

  // async getFileList() {
  //   // TODO: getFileList-请求文件列表，自行实现
  //   if (!this.home.fileList.length) {
  //     this.home.fileList = [{
  //       fileID: 'your fileID',
  //       fileName: 'your fileName'
  //     }]
  //     this.overseas.fileList = []
  //   }
  // }

  async getFileList() {
    if (!this.home.fileList.length) {
      const res = await axios({
        method: 'get',
        url: 'https://storage.zego.im/goclass/config.json',
        dataType: 'json',
        crossDomain: true,
        cache: false
      })
      const { docs_prod } = res.data
      this.docs_prod = docs_prod
      // this.docs_test = docs_test
      this.home.fileList = this.docs_prod
      this.overseas.fileList = this.docs_prod
      // this.test.fileList = this.docs_test
    }
  }

  createConfig(appID, server, logURL, userID, fileList) {
    return {
      appID,
      dociewAppID: appID,
      server,
      logURL,
      userID,
      fileList
    }
  }

  async getParams(env = 'home') {
    await this.getFileList()
    return this[env]
  }
}

class WebConfig extends BaseConfig {
  constructor() {
    super()
  }
}

class ElectronConfig extends BaseConfig {
  // 初始化sdk类型：liveRoom-旧版sdk express-新版sdk
  static electronSDKType = {
    LIVEROOM: 'liveRoom',
    EXPRESS: 'express'
  }

  env = ['home', 'overseas', 'test']
  base_electron_config = {
    LOGDIRS: {
      win32: `${cachePath}/zegodocsviewlog/`,
      darwin: `${cachePath}/docsviewlog/`,
      browser: `${cachePath}/docsviewlog/`
    },
    LIVEROOM_LOGDIR: `${cachePath}/zegoLiveroomLog/`,
    FILE_FILTERS: [
      {
        name: 'All',
        extensions: ['*']
      }
    ]
  }

  constructor() {
    super()
    this.bindElectronConfig()
  }

  // 绑定electron所需配置，例如appSign
  bindElectronConfig() {
    this.env.map(e => {
      const signProperty = {
        appSign: signToArray(this.appSign),
        signStr: this.appSign
      }
      this[e] = Object.assign(this[e], this.base_electron_config, signProperty)
    })
  }
}

class Config {
  static WebConfig = WebConfig
  static ElectronConfig = ElectronConfig
  constructor(type) {
    if (type === 'web') return new WebConfig()
    if (type === 'electron') return new ElectronConfig()
    return this
  }
}

export default Config
