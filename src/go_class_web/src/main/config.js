const baseUrl = process.env.WEBPACK_DEV_SERVER_URL
  ? process.env.WEBPACK_DEV_SERVER_URL
  : `file://${__dirname}/index.html`
const platform = process.platform

const commonWindowConfig = {
  show: false,
  frame: false,
  maximizable: false,
  fullscreenable: false,
  resizable: false,
  useContentSize: false,
  center: true,
  titleBarStyle: 'hiddenInset'
}

const commonWebPreferences = {
  nodeIntegration: true,
  webSecurity: false,
  webviewTag: false,
  devTools: true
}

const windows = {
  login: {
    url: `${baseUrl}/#/login`,
    hideReplaceClose: false,
    name: 'login',
    setup: {
      ...commonWindowConfig,
      width: 920,
      height: 560,
      webPreferences: {
        ...commonWebPreferences,
        webSecurity: false
      }
    }
  },
  room: {
    url: `${baseUrl}#/classroom`,
    hideReplaceClose: false,
    name: 'room',
    setup: {
      ...commonWindowConfig,
      width: 1200,
      height: 680,
      webPreferences: {
        ...commonWebPreferences,
        webSecurity: false
      }
    }
  }
}

const defaultOpen = 'login'

export { baseUrl, platform, commonWindowConfig, commonWebPreferences, windows, defaultOpen }
