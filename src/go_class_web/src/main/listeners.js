import { app, ipcMain, BrowserWindow } from 'electron'
import { wins } from './windowInstance'
import { createWindow } from './methods'
import { platform, windows } from './config'
import path from 'path'

let isOnLive = false

ipcMain.on('get-current-system', e => {
  e.returnValue = platform
})

ipcMain.on('get-user-path', e => {
  e.returnValue = app.getPath('appData')
})

ipcMain.on('get-cache-path', e => {
  e.returnValue = app.getPath('cache')
})

ipcMain.on('get-preload-path', e => {
  e.returnValue = path.join(__dirname, 'preload.js')
})

ipcMain.on('live-status-change', (e, onlive) => {
  isOnLive = onlive
  console.log({ isOnLive })
})

ipcMain.on('open-window', (e, args) => {
  console.log({ args })
  // 打开窗口
  if (!args.name) return
  if (wins[args.name]) {
    wins[args.name].show()
    if (args.data) {
      wins[args.name].webContents.send('get-init-data', { data: args.data })
    }
  } else {
    const win = BrowserWindow.fromWebContents(e.sender)
    const config = windows[args.name]
    if (args.parent) {
      config.setup.parent = win
      config.setup.modal = true
    }
    wins[args.name] = createWindow(config, () => {
      if (args.autoClose) {
        win && win.close()
      }
      if (args.autoHide) {
        win && win.hide()
      }
    })
    if (args.data) {
      wins[args.name].webContents.on('dom-ready', () => {
        wins[args.name].webContents.send('get-init-data', { data: args.data })
      })
    }
    if (args.listenClose) {
      wins[args.name].on('close', event => {
        console.log('try close', isOnLive)
        if (isOnLive) {
          event.preventDefault()
          wins[args.name].webContents.send('window-close')
        } else {
          event.returnValue = undefined
        }
      })
    }
    if (args.showHostWhenClose) {
      wins[args.name].once('closed', () => {
        win.show()
      })
    }
  }
})

ipcMain.on('minimize-window', e => {
  const win = BrowserWindow.fromWebContents(e.sender)
  if (win.isMinimizable) {
    win.minimize()
  }
})

ipcMain.on('unmaximize-window', e => {
  const win = BrowserWindow.fromWebContents(e.sender)
  win.unmaximize()
})

ipcMain.on('maximize-window', e => {
  const win = BrowserWindow.fromWebContents(e.sender)
  if (win.isMaximizable) {
    win.maximize()
  }
})

ipcMain.on('close-window', e => {
  const win = BrowserWindow.fromWebContents(e.sender)
    win && win.close()
})

ipcMain.on('get-web-content-id', (e, name) => {
  let id = 0
  if (wins[name]) {
    id = wins[name].webContents.id
  }
  e.returnValue = id
})

ipcMain.on('logout', () => {
  if (wins.login) {
    return wins.login.show()
  }
  wins.login = createWindow(windows.login, win => {
    const allBrowserWindow = BrowserWindow.getAllWindows()
    allBrowserWindow.forEach(item => {
      if (item.id !== win.id) {
        item.destroy()
      }
    })
  })
})
