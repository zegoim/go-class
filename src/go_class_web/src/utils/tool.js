import { ROLE_STUDENT } from '@/utils/constants'

const isElectron = _isElectron()

const _store = isElectron ? localStorage : sessionStorage
const storage = {
  set(key, value) {
    _store.setItem(key, JSON.stringify(value))
  },
  get(key) {
    let res = null
    try {
      res = JSON.parse(_store.getItem(key))
    } catch (e) {
      console.error(e)
    }
    return res
  },
  remove(key) {
    _store.removeItem(key)
  }
}

const createUserId = () => {
  const uid = storage.get('zegouid') || Date.now()
  storage.set('zegouid', uid)
  return uid
}

function _isElectron() {
  // Renderer process
  if (
    typeof window !== 'undefined' &&
    typeof window.process === 'object' &&
    window.process.type === 'renderer'
  ) {
    return true
  }

  // Main process
  if (
    typeof process !== 'undefined' &&
    typeof process.versions === 'object' &&
    !!process.versions.electron
  ) {
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

const setLoginInfo = data => {
  const uid = createUserId()
  const { roomId, userName, env, role, classScene } = data
  const user = {
    userID: uid + '',
    userName,
    isMe: true
  }
  const loginInfo = {
    roomId,
    userId: uid,
    userName,
    role: role || ROLE_STUDENT,
    env,
    user,
    classScene
  }
  storage.set('loginInfo', loginInfo)
  return loginInfo
}

function signToArray(str) {
  const arr = []
  for (let i = 0; i < str.length; ) {
    arr.push(`0x${str[i]}${str[i + 1]}`)
    i += 2
  }
  return arr
}

export { isElectron, storage, getQueryValue, debounce, setLoginInfo, createUserId, signToArray }
