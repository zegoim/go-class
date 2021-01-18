import { Config } from './index'
import { signToArray } from '@/utils/tool'

class ElectronConfig extends Config {
  _base = {
    LOGDIRS: {
      win32: 'c:/zegodocsviewlog/',
      darwin: process.env.HOME + '/docsviewlog/'
    }
  }
  _sign = {
    home: {
      ...this._base,
      appSign: signToArray('')
    },
    overseas: {
      ...this._base,
      appSign: signToArray('')
    }
  }
  constructor() {
    super()
    this.bindElectronConfig()
  }

  // 绑定electron所需配置，例如appSign
  bindElectronConfig() {
    Object.keys(this._sign).forEach(e => {
      Object.assign(this[e], this._sign[e])
    })
  }
}

export default new ElectronConfig()
