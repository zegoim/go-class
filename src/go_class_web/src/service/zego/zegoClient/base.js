import { storage } from '@/utils/tool'
import { LiveHelper } from '@/service/zego/helper/LiveHelper/index'
import { WhiteboardHelper } from '@/service/zego/helper/WhiteboardHelper'
import { DocsHelper } from '@/service/zego/helper/DocsHelper'

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

  getToken() {
    return this.state.tokenInfo.token
  }

  async createZegoContext(roomEnv) {
    const { appID, userID, docsviewAppID } = await this.Config.getParams(roomEnv)
    console.warn('createZegoContext appID,docsviewAppID,roomEnv', appID, docsviewAppID, roomEnv)
    const token1 = this.getToken(appID, userID)
    console.warn('tokenInfo:', token1)
    this.setState({
      env: roomEnv,
      tokenInfo: { token1 }
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
