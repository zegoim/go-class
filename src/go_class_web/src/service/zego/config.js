import { signToArray, createUserId, electron_get_cachePath, storage } from '@/utils/tool'

const cachePath = electron_get_cachePath()

/**
 * go class配置梳理:
 * 1. 构建环境分为：
 *    * 测试环境 - ZEGOENV.wb=[alpha|test]
 *    * 生产环境 - ZEGOENV.wb=
 * 2. 房间环境分为国内(home)和海外(oversea)环境；
 * 3. 当构建环境为test时，无论当前房间环境为国内还是国外, docview appID返回test配置的appID 和 fileList；
 * 4. 海外环境的docview取的是home的appid配置
 */

const appIDMap = {
  home1: +process.env.VUE_APP_ZEGO_APPID,       // 国内-小班课
  overseas1: +process.env.VUE_APP_ZEGO_APPID2,  // 海外-小班课
}

const appSignMap = {
  home1: process.env.VUE_APP_ZEGO_APPSIGN,      // 国内-小班课
  home2: process.env.VUE_APP_ZEGO_APPSIGN2,     // 海外-小班课
}


class BaseConfig {
  constructor() {
    const { classScene = 1, env = 'home' } = storage.get('loginInfo') || {}
    this.appID = appIDMap[env + classScene]
    this.appSign = appSignMap[env + classScene]
    this.serverEnv = process.env.VUE_APP_WB_ENV
    this.isTestEnv = !!process.env.VUE_APP_DOCS_ENV
    this.userID = createUserId() + ''
    this.home = this.createConfig(this.appID, '', '', this.userID, [])
    this.overseas = this.createConfig(this.appID, '', '', this.userID, [])
  }

  async getFileList() {
    // TODO: getFileList-请求文件列表，自行实现
    if (!this.home.fileList.length) {
      this.home.fileList = [{ fileID: 'your fileID', fileName: 'your fileName' }]
      this.overseas.fileList = []
    }
  }

  createConfig(appID, server, logURL, userID, fileList) {
    return {
      appID,
      dociewAppID: appID,
      server,
      logURL,
      userID,
      fileList,
      isTestEnv: this.isTestEnv,
      serverEnv: this.serverEnv
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

  env = ['home', 'overseas']
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
      const signProperty = { appSign: signToArray(this.appSign), signStr: this.appSign }
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
