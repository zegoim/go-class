import { ZegoClient } from './base'
import config from '../config/electron'

class ElectronZegoClient extends ZegoClient {
  constructor(Config) {
    super(Config)
    this.isElectron = true
  }
  /**
   * @desc: 初始化Electron sdk，web端集成无需理会
   * @param {user} 用户信息
   */
  async initSDK(user) {
    if (this._client) return

    // try {
    const { env = 'home' } = this.state
    const { appID, appSign } = await this.Config.getParams(env)

    // const zegoLiveRoom = new ZegoLiveRoom()
    const user_id = (user && user.userID) || `test_id_${new Date().getTime()}`
    const user_name = (user && user.userName) || `test_name_${new Date().getTime()}`

    const config = {
      app_id: appID,
      sign_key: appSign,
      user_id,
      user_name
    }

    const res = await this.originInitElectronSDK(config)
    if (res) {
      this.setState({ user })
      this.electronSetConfig(this._client.zegoLiveRoom)
      console.warn('sdk初始化成功！')
    } else {
      console.warn('sdk初始化失败！')
    }
    // } catch (e) {
    //   console.warn('当前不支持node环境！')
    // }
  }

  /**
   * @desc: electron相关配置，web集成无需理会
   */
  electronSetConfig($client) {
    if (!$client?.setRoomConfig) return
    console.warn('electron setRoomConfig, should before loginRoom!')
    $client.setRoomConfig({
      audience_create_room: true,
      user_state_update: true
    })
    const token1 = this.state.tokenInfo.token1
    if (token1) {
      $client.setCustomToken({
        third_party_token: token1
      })
    }
  }

  /**
   * @desc: electron相关配置，web集成无需理会
   */
  async originInitElectronSDK(config) {
    const { env = 'home' } = this.state
    const { serverEnv } = await this.Config.getParams(env)
    const ZegoLiveRoom = window.require('zegoliveroom/ZegoLiveRoom.js')
    const ZegoExpressEngine = window.require('zegoliveroom/ZegoWhiteBoardView.js').ZegoExpressEngine
    const zegoLiveRoom = new ZegoLiveRoom()
    zegoLiveRoom.setUseEnv({ use_test_env: !!serverEnv })
    zegoLiveRoom.setGeneralConfig({ config: 'device_mgr_mode=3' })
    return new Promise(resolve => {
      zegoLiveRoom.initSDK(config, async rs => {
        console.log({ config })
        console.log('ZegoLiveRoom sdk初始化', rs)
        if (rs.error_code !== 0) {
          zegoLiveRoom.unInitSDK()
          resolve(false)
        }
        this._client = new ZegoExpressEngine(config, zegoLiveRoom)
        await this.originInitElectronDocSDK(config)
        resolve(true)
      })
    })
  }

  /**
   * @desc: electron相关配置，web集成无需理会
   */
  async originInitElectronDocSDK() {
    console.log('originInitElectronWBSDK')
    const { env = 'home' } = this.state
    const os = require('os')
    const platform = os.platform()
    const { appID, appSign, isTestEnv, LOGDIRS } = await this.Config.getParams(env)
    const logDir = LOGDIRS[platform]
    const ZegoDocsViewBin = window.require('zegodocsview/ZegoDocsView.bin')
    const ZegoExpressDocs = window.require('zegodocsview/ZegoDocsView.js').ZegoExpressDocs
    const zgDocsViewClient = new ZegoExpressDocs(
      {
        appID: appID,
        appSign: appSign,
        dataFolder: logDir,
        cacheFolder: logDir,
        logFolder: logDir,
        isTestEnv
      },
      new ZegoDocsViewBin()
    )
    this._docsClient = zgDocsViewClient
    // console.log(zgWhiteBoardView,zgDocsViewClient)
  }
}

export default new ElectronZegoClient(config)
