import axios from 'axios'
import { storage } from '@/utils/tool'
import { LiveHelper } from '@/service/zego/helper/LiveHelper/index'
import { WhiteboardHelper } from '@/service/zego/helper/WhiteboardHelper'
import { DocsHelper } from '@/service/zego/helper/DocsHelper'
import { YOUR_SDK_TOKEN_URL } from '@/utils/config_data'

export class ZegoClient {
  _client = null
  _docsClient = null
  liveClient = null
  docsClient = null
  whiteboardClient = null
  protectList = ['liveClient', 'whiteboardClient', 'docsClient']
  isElectron = false
  Config = null

  constructor(Config) {
    this.Config = Config
    this.state = {
      room_id: null,
      env: 'home',
      user: {},
      tokenInfo: {},
      isLogin: false,
      isInit: false
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
      await this.initSDK(user)
    }
    // livingroom
    if (client === 'live') {
      const $client = this._client.zegoLiveRoom || this._client
      return (
        this.liveClient || (this.liveClient = new LiveHelper({ context: this, client: $client }))
      )
    }
    // 互动白板
    if (client === 'whiteboard') {
      return (
        this.whiteboardClient ||
        (this.whiteboardClient = new WhiteboardHelper({ context: this, client: this._client }))
      )
    }
    // 文件转码
    if (client === 'docs') {
      return (
        this.docsClient ||
        (this.docsClient = new DocsHelper({ context: this, client: this._docsClient }))
      )
    }

    this.lockProperty && this.lockProperty()
  }

  async initConfig(env) {
    env = env || storage.get('loginInfo')?.env
    if (!this.state.tokenInfo.token1) {
      await this.createZegoContext(env)
    }
    this.setState({ isInit: true, env }, () => {
      this.initConfig = null
    })
  }

  async getToken(appID, userID) {
    console.log('getToken', { appID, userID })
    const { data } = await axios.get(YOUR_SDK_TOKEN_URL, {
      params: {
        appID,
        userID
      }
    })
    return data.data
  }

  async createZegoContext(roomEnv) {
    const { appID, userID, isTestEnv, docsviewAppID } = await this.Config.getParams(roomEnv)
    console.warn('createZegoContext appID,roomEnv', appID, roomEnv)
    const token1 = await this.getToken(appID, userID)
    let token2 = token1
    if (docsviewAppID != appID && !isTestEnv) {
      token2 = await this.getToken(docsviewAppID, userID)
    }
    console.warn('tokenInfo:', token1, token2)
    this.setState({
      env: roomEnv,
      tokenInfo: { token1, token2 }
    })
  }

  /**
   * @desc: 初始化web端sdk
   * @param {user} 用户信息
   */
  async initSDK(user) {
    console.log(user)
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
