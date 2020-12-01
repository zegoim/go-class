import { ROLE_STUDENT } from '@/utils/constants'

function isElectron() {
  // Renderer process
  if (typeof window !== 'undefined' && typeof window.process === 'object' && window.process.type === 'renderer') {
    return true
  }

  // Main process
  if (typeof process !== 'undefined' && typeof process.versions === 'object' && !!process.versions.electron) {
    return true
  }

  // Detect the user agent when the `nodeIntegration` option is set to true
  if (
    typeof navigator === 'object' &&
    typeof navigator.userAgent === 'string' &&
    navigator.userAgent.indexOf('Electron') >= 0
  ) {
    return true
  }

  return false
}

function getQueryValue(queryName) {
  const query = decodeURI(window.location.href)
  const vars = query.split('&')
  for (let i = 0; i < vars.length; i++) {
    const pair = vars[i].split('=')
    if (pair[0] == queryName) {
      return pair[1]
    }
  }
  return null
}

/**
 * @desc 防抖函数
 * @param {需要防抖的函数} func
 * @param {number} wait
 * @param {是否立即执行} immediate
 */
function debounce(func, wait, immediate) {
  const context = this
  let timeout
  return (...args) => {
    if (timeout) clearTimeout(timeout)
    if (immediate) {
      const callNow = !timeout
      timeout = setTimeout(() => {
        timeout = null
      }, wait)
      if (callNow) func.apply(context, args)
    } else {
      timeout = setTimeout(() => {
        func.apply(context, args)
      }, wait)
    }
  }
}

const storage = class {
  static _isEle = isElectron()
  static _store = this._isEle ? localStorage : sessionStorage
  static set(key, value) {
    this._store.setItem(key, JSON.stringify(value))
  }
  static get(key) {
    return JSON.parse(this._store.getItem(key))
  }
  static remove(key) {
    this._store.removeItem(key)
  }
}

const createUserId = () => {
  const uid = storage.get('loginInfo')?.user?.userID || new Date().getTime()
  storage.set('zegouid', uid)
  return uid
}

const setLoginInfo = data => {
  const uid = createUserId()
  const { roomId, userName, env, role } = data
  const user = {
    userID: uid,
    userName,
    isMe: true
  }
  const loginInfo = { roomId, userId: uid, userName, role: role || ROLE_STUDENT, env, user }
  storage.set('loginInfo', loginInfo)
  return loginInfo
}

function createUserID() {
  const userID = storage.get('loginInfo')?.user?.userID
  return userID || 'userid_' + new Date().getTime()
}

function signToArray(str) {
  const arr = []
  for (let i = 0; i < str.length; ) {
    arr.push(`0x${str[i]}${str[i + 1]}`)
    i += 2
  }
  return arr
}

function electron_get_system() {
  const { ipcRenderer } = window.require('electron')
  return ipcRenderer?.sendSync('get-current-system')
}

function electron_get_cachePath() {
  const { ipcRenderer } = window.require('electron')
  return ipcRenderer?.sendSync('get-cache-path')
}

const defaultOpenVideo = isElectron()

const firstUpperCase = ([first, ...rest]) => first.toUpperCase() + rest.join('')

export {
  isElectron,
  getQueryValue,
  debounce,
  storage,
  setLoginInfo,
  createUserId,
  createUserID,
  signToArray,
  electron_get_system,
  electron_get_cachePath,
  defaultOpenVideo,
  firstUpperCase
}
