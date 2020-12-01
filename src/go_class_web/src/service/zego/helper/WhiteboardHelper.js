export class WhiteboardHelper {
  _client = null
  constructor({ context, client }) {
    this.context = context
    this._client = client
  }

  on(eventName, callback) {
    console.log('监听事件: ', eventName)
    this._client && this._client.on(eventName, callback)
  }

  getProxyFunc() {
    return ['createView', 'destroyView', 'attachView', 'getViewList']
  }

  whiteboard(methodName = '', ...args) {
    const proxyFunc = this.getProxyFunc()
    if (proxyFunc.some(func => func === methodName)) {
      console.warn('方法被转发, methods: ', methodName, ', args:', args)
      return this[methodName](...args)
    } else {
      console.warn('不存在该方法, methodName=', methodName)
      return
    }
  }

  async createView(options) {
    return await this._client.createView(options)
  }

  destroyView(whiteboardView) {
    return this._client.destroyView(whiteboardView)
  }

  attachView(activeWBView, parentId) {
    return this._client.attachView(activeWBView, parentId)
  }

  getViewList() {
    return this._client.getViewList()
  }
}
