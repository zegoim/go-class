import { app, BrowserWindow } from 'electron'
import { wins } from './windowInstance'
import { handleContextMenu } from './menu'

export function createWindow (options, onComplete) {
  const win = new BrowserWindow(options.setup)
  win.on('show', () => {
    win.webContents.send('window-show')
  })
  win.on('focus', () => {
    win.webContents.send('window-focus')
  })
  win.on('maximize', () => {
    win.webContents.send('maximize')
  })
  win.on('unmaximize', () => {
    win.webContents.send('unmaximize')
  })
  win.once('ready-to-show', () => {
    win.show()
  })
  win.on('closed', () => {
    console.log(options.name + ' closed.')
    wins[options.name] = null
  })
  if (options.hideReplaceClose && process.platform === 'darwin') {
    let forceQuit = false
    app.on('before-quit', () => {
      forceQuit = true
    })
    win.on('close', (e) => {
      console.log(`==>win ${options.name} on close`, forceQuit)
      if (!forceQuit) {
        e.preventDefault()
        win.hide()
      }
    })
  }
  console.log('options.url', options.url)
  win.loadURL(options.url)
  win.webContents.on('context-menu', handleContextMenu)
  if (process.env.NODE_ENV !== 'production') {
    win.webContents.openDevTools()
  }
  if (options.setup.webPreferences.webviewTag) {
    win.webContents.on('did-attach-webview', (event, webContents) => {
      webContents.session.setCertificateVerifyProc((request, callback) => {
        callback(0)
      })
    })
  }
  if (onComplete) {
    onComplete(win)
  }
  return win
}
