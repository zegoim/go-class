// 根据字符串版本号（主版本号 + 次版本号 + 补丁号 + CI编译号）计算数字版本号
// web、electron 没有 CI 编译号，默认传 0
const countNumVersion = (function() {
  let cache = {}
  let countFun = function() {
    return (
      ((arguments[0] & 0xf) << 28) |
      ((arguments[1] & 0xf) << 24) |
      ((arguments[2] & 0xf) << 20) |
      (arguments[3] & 0xfffff)
    )
  }
  return function() {
    let currKey = Array.prototype.join.call(arguments, ',')
    if (currKey in cache) {
      return parseInt(cache[currKey])
    }
    cache[currKey] = countFun.apply(null, arguments)
    return parseInt(cache[currKey])
  }
})()

// 拆分 UserAgent
const splitUserAgent = (function() {
  let cache = {}
  let splitUserAgentFun = function() {
    const info = { system_version: '', client: '' }
    const reg = /^([a-zA-Z]+)\/([\d\S]+)\s+\(([\s\S]+)\)\s+(\S+)\s+\(([\s\S]+)\)\s+([\s\S]+)/
    // web: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36"
    // electron: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) web-go-class-demo/2.6.0 Chrome/73.0.3683.121 Electron/5.0.11 Safari/537.36"
    // 拆分 system_version 中的设备型号（Mac OS X 10_15_4） + 浏览器版本（Chrome/90.0.4430.212）
    // User-Agent: Mozilla/<version> (<system-information>) <platform> (<platform-details>) <extensions>
    // result: ['full', 'Mozilla', '5.0', 'Macintosh; Intel Mac OS X 10_15_4', 'AppleWebKit/537.36', 'KHTML, like Gecko', 'Chrome/90.0.4430.212 Safari/537.36']
    const result = reg.exec(arguments[0])
    if (result) {
      info.system_version = result[6]
      info.client = result[3]
    }
    return info
  }
  return function() {
    let currKey = arguments[0]
    if (currKey in cache) {
      return cache[currKey]
    }
    cache[currKey] = splitUserAgentFun.apply(null, arguments)
    return cache[currKey]
  }
})()

const APP_VERSION_STRING = '2.7.0' // APP 字符串版本号（主版本号 + 次版本号 + 补丁号）
const APP_VERSION_ARRAY = APP_VERSION_STRING.split('.')
const APP_VERSION = countNumVersion(APP_VERSION_ARRAY[0], APP_VERSION_ARRAY[1], APP_VERSION_ARRAY[2], 0) // APP 数字版本号
const WHITEBOARDVIEW_VERSION = '1.20.0' // 白板 SDK 版本
const DOCSVIEW_VERSION = '1.20.0' // 文件 SDK 版本
const BROWSER_INFO = splitUserAgent(navigator.userAgent)

const COMMON_DATA = {
  device_id: '', // SDK 或客户端生成的设备唯一 ID
  device_name: BROWSER_INFO.client, // 设备名称，web 这边无法获取，electron 暂时和 web 一致
  client: BROWSER_INFO.client, // 同设备名称
  client_mode: 0, // 客户端模式 1: Talkline, 2: EduSuit
  dist_no: 0, // 渠道号
  mac: '', // MAC 地址
  platform: 32, // 平台
  seq: 0, // 包序号，客户端累加
  app_version: APP_VERSION,
  app_version_string: APP_VERSION_STRING,
  sdk_version: `${WHITEBOARDVIEW_VERSION}_${DOCSVIEW_VERSION}`,
  system_version: BROWSER_INFO.system_version
}
export default COMMON_DATA
