import {
  storage,
  electron_get_system
} from '@/utils/tool'
import Config from './config' // RoomEnv
import {
  LiveHelper
} from '@/service/zego/helper/LiveHelper'
import {
  WhiteboardHelper
} from '@/service/zego/helper/WhiteboardHelper'
import {
  DocsHelper
} from '@/service/zego/helper/DocsHelper'

const electronConf = new Config('electron')

class ZegoClient {
  _client = null
  liveClient = null
  docsClient = null
  whiteboardClient = null
  // tips: 修改此处可选择electron sdk类型
  electronSdk = process.env.VUE_APP_ELECTRON_SDK // enum { LIVEROOM, EXPRESS }
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
      await this.initElectronSDK(user)
    }
    // livingroom
    if (client === 'live') {
      const $client = this._client.zegoLiveRoom
      return this.liveClient || (this.liveClient = new LiveHelper({
        context: this,
        client: $client
      }))
    }
    // 互动白板
    if (client === 'whiteboard') {
      const $client = this._client.zegoWhiteBoard
      return this.whiteboardClient || (this.whiteboardClient = new WhiteboardHelper({
        context: this,
        client: $client
      }))
    }
    // 文件转码
    if (client === 'docs') {
      return this.docsClient || (this.docsClient = new DocsHelper({
        context: this,
        client: this.docsClient
      }))
    }

    this.lockProperty && this.lockProperty()
  }

  async initConfig(env) {
    console.warn('sdk init')
    env = env || storage.get('loginInfo')?.env
    this.setState({
      isInit: true,
      env
    }, () => {
      this.initConfig = null
    })
  }

  /**
   * @desc: 初始化Electron sdk
   * @param {user} 用户信息
   */

  async initElectronSDK(user) {
    if (this._client) return

    // try {
    const {
      env = 'home'
    } = this.state
    const {
      appID,
      appSign
    } = await electronConf.getParams(env)

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
      this.electronSdk == 'express' ?
      await this.originInitElectronExpressSdk(config) :
      await this.originInitElectronLiveRoomSDK(config)
    if (res) {
      this.setState({
        user
      })
      console.warn('sdk初始化成功！')
    } else {
      console.warn('sdk初始化失败！')
    }
  }

  /**
   * @desc: electron相关配置
   */

  electronSetConfig($client) {
    if (!$client?.setRoomConfig) return
    console.warn('electron setRoomConfig, should before loginRoom!')
    $client.setRoomConfig({
      audience_create_room: true,
      user_state_update: true
    })
  }

  /**
   * @desc: electron相关配置
   */

  async originInitElectronLiveRoomSDK(config) {
    console.log('init liveroom ')
    const {
      env = 'home'
    } = this.state
    const {
      LIVEROOM_LOGDIR
    } = await electronConf.getParams(env)
    const ZegoLiveRoom = window.require('zegoliveroom/ZegoLiveRoom.js')
    const ZegoExpressEngine = window.require('zegoliveroom/ZegoWhiteBoardView.js')
    const zegoLiveRoom = new ZegoLiveRoom()
    zegoLiveRoom.setGeneralConfig({
      config: 'device_mgr_mode=3'
    })
    zegoLiveRoom.setGeneralConfig({
      config: 'prefer_play_ultra_source=1'
    })
    const setLogRes = zegoLiveRoom.setLogDir({
      log_dir: LIVEROOM_LOGDIR,
      log_level: 4
    })
    console.warn(`设置日志缓存路径${setLogRes ? '成功' : '失败'}！`)
    return new Promise(resolve => {
      zegoLiveRoom.initSDK(config, async rs => {
        console.log({
          config
        })
        console.log('ZegoLiveRoom sdk初始化', rs)
        if (rs.error_code !== 0) {
          zegoLiveRoom.unInitSDK()
          resolve(false)
        }
        this._client = {
          zegoLiveRoom,
          zegoWhiteBoard: new ZegoExpressEngine(zegoLiveRoom)
        }
        console.log('this._client', this._client)
        await this.originInitElectronDocSDK()
        console.warn('Liveroom wb sdk version:', this._client.zegoWhiteBoard.getVersion())
        this.electronSetConfig(this._client.zegoLiveRoom)
        resolve(true)
      })
    })
  }

  /**
   * @desc: electron相关配置
   */

  async originInitElectronExpressSdk(config = {}) {
    const {
      env = 'home'
    } = this.state
    const conf = await electronConf.getParams(env) // LIVEROOM_LOGDIR
    const {
      signStr
    } = conf
    config.app_sign = signStr
    const zegoExpressEngine = window.require('zego-express-engine-electron/ZegoExpressEngine.js')
    const ZegoWhiteBoard = window.require('zego-express-engine-electron/ZegoWhiteBoardView.js')
    await zegoExpressEngine.initWithProfile({
      appID: config.app_id,
      appSign: config.app_sign,
      scenario: 0
    });
    const zegoWhiteBoard = new ZegoWhiteBoard()
    this._client = {
      zegoLiveRoom: zegoExpressEngine,
      zegoWhiteBoard: zegoWhiteBoard
    }
    await this.originInitElectronDocSDK()
    console.warn('Express wb sdk version:', zegoWhiteBoard.getVersion())
    return Promise.resolve(true)
  }

  async originInitElectronDocSDK() {
    console.log('originInitElectronDocSDK')
    const {
      env = 'home'
    } = this.state
    const platform = electron_get_system()
    const params = await electronConf.getParams(env)
    console.warn('originInitElectronDocSDK', {
      env,
      params
    })
    const {
      dociewAppID,
      dociewAppSign,
      appSign,
      LOGDIRS
    } = params
    console.warn('房间初始化环境为：', env)
    const logDir = LOGDIRS[platform]
    const ZegoExpressDocs = window.require('zego-express-docsview-electron')
    const docConf = {
      appID: dociewAppID,
      appSign: dociewAppSign || appSign,
      dataFolder: logDir,
      cacheFolder: logDir,
      logFolder: logDir,
      platform
    }
    console.warn('docConf', {
      docConf
    })
    const zgDocsViewClient = new ZegoExpressDocs({
      ...docConf
    })
    this.docsClient = zgDocsViewClient
    console.warn('docs sdk version:', zgDocsViewClient.getVersion())
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