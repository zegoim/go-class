import axios from 'axios'
import { isElectron, storage, electron_get_system } from '@/utils/tool'
import Config from './config' // RoomEnv
import { LiveHelper } from '@/service/zego/helper/LiveHelper'
import { WhiteboardHelper } from '@/service/zego/helper/WhiteboardHelper'
import { DocsHelper } from '@/service/zego/helper/DocsHelper'

const webConf = new Config('web')
const electronConf = new Config('electron')

class ZegoClient {
  _isElectron = isElectron
  _client = null
  liveClient = null
  docsClient = null
  whiteboardClient = null
  // tips: 修改此处可选择electron sdk类型
  electronSdk = process.env.VUE_APP_ELECTRON_SDK || 'express' // enum { LIVEROOM, EXPRESS }
  protectList = ['liveClient', 'whiteboardClient', 'docsClient']

  constructor() {
    console.log('electronSdk=', this.electronSdk)
    this.state = {
      room_id: null,
      env: 'home',
      user: {},
      tokenInfo: {},
      isLogin: false,
      isInit: false,
      fileEnv: null,
      isTestEnv: null
    }
  }

  /**
   *
   * @param {初始化的client} client
   * @param {string} env
   * @param { Object | null } user
   * @returns {Promise<WhiteboardHelper|LiveHelper|DocsHelper>}
   */

  async init(client, env = 'home', user = null) {
    this.initConfig && (await this.initConfig(env))

    user = (storage.get('loginInfo') || {}).user || user

    if (!this._client) {
      this._isElectron ? await this.initElectronSDK(user) : await this.initWebSDK(user)
    }
    // livingroom
    if (client === 'live') {
      const $client = this._isElectron ? this._client.zegoLiveRoom : this._client
      return this.liveClient || (this.liveClient = new LiveHelper({ context: this, client: $client }))
    }
    // 互动白板
    if (client === 'whiteboard') {
      const $client = this.electronSdk === 'express' ? this._client.zegoWhiteBoard : this._client
      return this.whiteboardClient || (this.whiteboardClient = new WhiteboardHelper({ context: this, client: $client }))
    }
    // 文件转码
    if (client === 'docs') {
      return this.docsClient || (this.docsClient = new DocsHelper({ context: this, client: this.docsClient }))
    }

    this.lockProperty && this.lockProperty()
  }

  async initConfig(env) {
    console.warn('sdk init')
    const tokenInfo = storage.get('tokenInfo')
    env = env || storage.get('loginInfo')?.env
    if (!tokenInfo) {
      await this.createZegoContext(env)
    }
    this.setState({ isInit: true, env }, () => {
      this.initConfig = null
    })
  }

  async getToken(appID, userID) {
    console.log('getToken', { appID, userID })
    const { data } = await axios.get(process.env.VUE_APP_TOKEN_URL, {
      params: {
        appID,
        userID
      }
    })
    return data.data
  }

  async createZegoContext(roomEnv) {
    console.warn('createZegoContext roomEnv:', roomEnv)
    const $conf = this._isElectron ? electronConf : webConf
    const { appID, userID, isTestEnv, dociewAppID } = await $conf.getParams(roomEnv)
    const token1 = await this.getToken(appID, userID)
    let token2 = token1
    if (dociewAppID != appID && !isTestEnv) {
      token2 = await this.getToken(dociewAppID, userID)
    }
    this.setState({
      env: roomEnv,
      tokenInfo: { token1, token2 }
    })
  }

  /**
   * @desc: 初始化web端sdk
   * @param {user} 用户信息
   */

  async initWebSDK(user) {
    if (this._client) return
    console.warn('init web sdk start')
    const { userID } = user
    const { env = 'home' } = this.state
    const { appID, logURL, server, isTestEnv, docsviewAppID } = await webConf.getParams(env)
    const zg = new window.ZegoExpressEngine(appID, server)
    const zgDocsClient = new window.ZegoExpressDocs({
      appID: docsviewAppID,
      token: this.state.tokenInfo.token2,
      userID,
      isTestEnv
    })
    if (zg) console.log('init web sdk success!')
    if (zgDocsClient) console.log('init docs sdk success!')
    this._client = zg
    const config = {
      logLevel: 3
    }
    logURL && (config.logURL = logURL)
    this.setState({ user })
    zg.setLogConfig(config)

    this.docsClient = zgDocsClient

    console.warn('init web sdk done')
  }

  /**
   * @desc: 初始化Electron sdk，web端集成无需理会
   * @param {user} 用户信息
   */

  async initElectronSDK(user) {
    if (this._client) return

    if (!this._isElectron) {
      console.warn('当前不是electron环境')
      return
    }

    // try {
    const { env = 'home' } = this.state
    const { appID, appSign } = await electronConf.getParams(env)

    // const zegoLiveRoom = new ZegoLiveRoom()
    const user_id = (user && user.userID) || `test_id_${new Date().getTime()}`
    const user_name = (user && user.userName) || `test_name_${new Date().getTime()}`

    const config = {
      app_id: appID,
      sign_key: appSign,
      user_id,
      user_name
    }

    const res =
      this.electronSdk == 'express'
        ? await this.originInitElectronExpressSdk(config)
        : await this.originInitElectronLiveRoomSDK(config)
    if (res) {
      this.setState({ user })
      console.warn('sdk初始化成功！')
    } else {
      console.warn('sdk初始化失败！')
    }
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

  async originInitElectronLiveRoomSDK(config) {
    const { env = 'home' } = this.state
    const { serverEnv, LIVEROOM_LOGDIR } = await electronConf.getParams(env)
    const ZegoLiveRoom = window.require('zegoliveroom/ZegoLiveRoom.js')
    const ZegoExpressEngine = window.require('zegoliveroom/ZegoWhiteBoardView.js').ZegoExpressEngine
    const zegoLiveRoom = new ZegoLiveRoom()
    zegoLiveRoom.setUseEnv({ use_test_env: !!serverEnv })
    zegoLiveRoom.setGeneralConfig({ config: 'device_mgr_mode=3' })
    zegoLiveRoom.setGeneralConfig({ config: 'prefer_play_ultra_source=1' })
    const setLogRes = zegoLiveRoom.setLogDir({
      log_dir: LIVEROOM_LOGDIR,
      log_level: 4
    })
    console.warn(`设置日志缓存路径${setLogRes ? '成功' : '失败'}！`)
    return new Promise(resolve => {
      zegoLiveRoom.initSDK(config, async rs => {
        console.log({ config })
        console.log('ZegoLiveRoom sdk初始化', rs)
        if (rs.error_code !== 0) {
          zegoLiveRoom.unInitSDK()
          resolve(false)
        }
        this._client = new ZegoExpressEngine(config, zegoLiveRoom)
        await this.originInitElectronDocSDK()
        this.electronSetConfig(this._client.zegoLiveRoom)
        resolve(true)
      })
    })
  }

  /**
   * @desc: electron相关配置，web集成无需理会
   */

  async originInitElectronExpressSdk(config = {}) {
    const { env = 'home' } = this.state
    const conf = await electronConf.getParams(env) // LIVEROOM_LOGDIR
    const { signStr, serverEnv } = conf
    config.app_sign = signStr
    const zegoExpressEngine = window.require('zego-express-engine-electron/ZegoExpressEngine.js')
    const ZegoWhiteBoard = window.require('zego-express-engine-electron/ZegoWhiteBoardView.js')
    await zegoExpressEngine.init(config.app_id, config.app_sign, !!serverEnv, 0)
    const zegoWhiteBoard = new ZegoWhiteBoard()
    this._client = {
      zegoLiveRoom: zegoExpressEngine,
      zegoWhiteBoard: zegoWhiteBoard
    }
    await this.originInitElectronDocSDK()
    return Promise.resolve(true)
  }

  async originInitElectronDocSDK() {
    console.log('originInitElectronWBSDK')
    const { env = 'home' } = this.state
    const platform = electron_get_system()
    const params = await electronConf.getParams(env)
    console.warn('originInitElectronDocSDK', { env, params })
    const { dociewAppID, dociewAppSign, appSign, LOGDIRS, serverEnv, isTestEnv } = params
    console.warn('房间初始化环境为：', env, '，构建环境为：', serverEnv || 'dev')
    const logDir = LOGDIRS[platform]
    const ZegoExpressDocs = window.require('zego-express-docsview-electron')
    const docConf = {
      appID: dociewAppID,
      appSign: dociewAppSign || appSign,
      dataFolder: logDir,
      cacheFolder: logDir,
      logFolder: logDir,
      isTestEnv,
      platform
    }
    console.warn({ docConf })
    const zgDocsViewClient = new ZegoExpressDocs(
      {
        ...docConf
      })
    this.docsClient = zgDocsViewClient
  }

  lockProperty() {
    this.protectList.forEach(key => {
      const temp = this[key]
      Object.defineProperty(this, key, {
        get: () => {
          return temp
        },
        set: () => {
          console.warn(`受保护的属性: ${key}，禁止修改！`)
          return temp
        }
      })
    })
    this.lockProperty = null
  }

  /**
   * @desc 状态更新
   * @param {Object} state
   * @param {function | none} cb
   */

  setState(state, cb = null) {
    if (Object.prototype.toString.call(state) !== '[object Object]') return
    const keys = Object.keys(state)
    keys.reduce((acc, key) => {
      acc[key] = state[key]
      return acc
    }, this.state)
    cb && cb()
  }

  getState(...args) {
    return args.reduce((acc, k) => {
      acc[k] = this.state[k]
      return acc
    }, {})
  }
}

export default new ZegoClient()
