import axios from 'axios'
import { ZEGOENV, APPID } from '@/utils/constants'
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
      `wss://webliveroom${this.homeAppID}-api.zego.im/ws`,
      '',
      this.userID,
      []
    )
    this.overseas = this.createConfig(
      this.overseasAppID,
      `wss://webliveroom${this.overseasAppID}-api.zegocloud.com/ws`,
      `wss://weblogger${this.overseasAppID}-api.zegocloud.com/log`,
      this.userID,
      []
    )
  }
  /**
   * 获取文件列表弹窗中的文件数据
   * 该数据均为体验文件
   * 如果使用自己上传文件，请注意：
   * 文件id通过文件共享SDK上传后返回，现测试环境与appID无关联。即多个appID上传文件到测试服务器，多个appID的文件在测试服务器共享。
   * 上传地址请参考README.md
   * 将上传文件成功后返回的 fileID 填到本地数据管理中
   * 其中 isDynamic 仅UI层面显示该文件是否动态 PPT
   * this.docs_test = [
   *  {id:'上传文件通过sdk返回的fileid', name:'文件名', isDynamic:'ui层面显示该文件是否是动态 ppt'}
   * ]
   */
  async getFileList() {
    const res = await axios({
      method: 'get',
      url: 'https://storage.zego.im/goclass/config_demo.json',
      dataType: 'json',
      crossDomain: true,
      cache: false
    })
    const { docs_test } = res.data
    this.docs_test = docs_test
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
    await this.getFileList()
    const obj = {}
    // 测试环境下，使用文件数据均为this.docs_test
    if (this.isTestEnv) {
      obj.fileList = this.docs_test
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
