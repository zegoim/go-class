import { ZEGOENV, APPID, SEVERURL } from '@/utils/constants'
import { DOCS_IS_TEST_ENV } from '@/utils/config_data'
import { fileList } from '@/utils/fileList'
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
    this.isTestEnv = DOCS_IS_TEST_ENV
    this.homeAppID = APPID.home // 国内环境appID
    this.overseasAppID = APPID.overseas // 海外环境appID
    this.homeServer = SEVERURL.home
    this.overseasServer = SEVERURL.overseas
    this.userID = createUserId() + ''
    this.home = this.createConfig(
      this.homeAppID,
      this.homeServer,
      '',
      this.userID,
      []
    )
    this.overseas = this.createConfig(
      this.overseasAppID,
      this.overseasServer,
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
    obj.fileList = fileList
    // 测试环境下
    // if (this.isTestEnv) {
    //   obj.fileList = fileList
    // }
    if (env === 'overseas') {
      obj.docsviewAppID = this.home.appID
    }
    Object.assign(this[env], obj)
    console.warn(111,this[env])
    return this[env]
  }
}
