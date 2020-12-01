import { ZEGOENV, APPID, DOCS_TEST } from '@/utils/constants'
import { createUserId } from '@/utils/tool'

/**
 * go class配置梳理:
 * 1. 构建环境分为：
 *    * 测试环境 - ZEGOENV.wb=[alpha|test]
 *    * 生产环境 - ZEGOENV.wb=
 * 2. 房间环境分为国内(home)和海外(oversea)环境；
 * 3. 目前项目要使得多个场景相同roomID不相互影响，一个场景需要一套appID配置
 * 4. 当构建环境为test时，无论当前房间环境为国内还是国外, docview appID返回test配置的appID
 * 5. 海外环境的docview取的是home的appid配置
 */

export class Config {
  constructor() {
    this.serverEnv = ZEGOENV.wb
    // 设置连接环境是否是测试环境,true为测试环境，false为正式环境
    this.isTestEnv = true
    this.homeAppID = APPID.home // 国内环境appID
    this.overseasAppID = APPID.overseas // 海外环境appID
    this.userID = createUserId() + ''
    this.home = this.createConfig(
      this.homeAppID,
      'wss://webliveroom-test.zego.im/ws',
      '',
      this.userID,
      []
    )
    this.overseas = this.createConfig(
      this.overseasAppID,
      'wss://webliveroom-test.zego.im/ws',
      '',
      this.userID,
      []
    )
  }

  createConfig(appID, server, logURL, userID, fileList) {
    return {
      appID,
      docsviewAppID: appID,
      server,
      logURL,
      userID,
      fileList,
      isTestEnv: this.isTestEnv
    }
  }

  async getParams(env = 'home') {
    const obj = {}
    if (this.isTestEnv) {
      obj.fileList = DOCS_TEST
    }
    if (env === 'home' && this.serverEnv) {
      obj.server = `wss://webliveroom-${this.serverEnv}.zego.im/ws`
    } else if (env === 'overseas') {
      obj.docsviewAppID = this.home.appID
      if (this.serverEnv) {
        obj.server = 'wss://webliveroom-hk-test.zegocloud.com/ws'
      }
    }
    Object.assign(this[env], obj)
    return this[env]
  }
}
