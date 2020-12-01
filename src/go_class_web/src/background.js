'use strict'

import { app, protocol, BrowserWindow, globalShortcut } from 'electron'
import { createProtocol } from 'vue-cli-plugin-electron-builder/lib'
import installExtension, { VUEJS_DEVTOOLS } from 'electron-devtools-installer'
import { winClient } from './main/windowInstance'
import { windows, defaultOpen } from './main/config'
import { createWindow } from './main/methods'
const isDevelopment = process.env.NODE_ENV !== 'production'
require('./main/listeners')

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let win

// Scheme must be registered before the app is ready
protocol.registerSchemesAsPrivileged([{ scheme: 'app', privileges: { secure: true, standard: true } }])

function startApp() {
  const [winInstance] = winClient.getInstance(defaultOpen)
  if (winInstance) {
    winInstance.show()
  } else {
    const win = createWindow(windows[defaultOpen])
    winClient.setInstance(defaultOpen, win)
  }

  if (process.env.WEBPACK_DEV_SERVER_URL) {
    // Load the url of the dev server if in development mode
    // win.loadURL(process.env.WEBPACK_DEV_SERVER_URL)
    // if (!process.env.IS_TEST) win.webContents.openDevTools()
  } else {
    createProtocol('app')
  }
}

function handleAppActive() {
  const currentWindow = BrowserWindow.getFocusedWindow()
  if (!currentWindow) {
    const allWindows = BrowserWindow.getAllWindows()
    if (allWindows.length) {
      allWindows[allWindows.length - 1].show()
    } else {
      startApp()
    }
  } else {
    currentWindow.show()
  }
}

app.allowRendererProcessReuse = false
// app.commandLine.appendSwitch('--disable-http-cache')
app.commandLine.appendSwitch('ignore-certificate-errors')

const lock = app.requestSingleInstanceLock()
if (!lock) {
  app.quit()
} else {
  app.on('second-instance', handleAppActive)
}

// Quit when all windows are closed.
app.on('window-all-closed', () => {
  // On macOS it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  const currentWindow = BrowserWindow.getFocusedWindow()
  currentWindow &&
    currentWindow.webContents &&
    currentWindow.webContents.executeJavaScript('localStorage.clear()').then(() => {})
  if (process.platform !== 'darwin') {
    // 退出时清空缓存
    app.quit()
  }
})

app.on('activate', () => {
  // On macOS it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (win === null) {
    handleAppActive()
  }
})

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', async () => {
  if (isDevelopment && !process.env.IS_TEST) {
    // Install Vue Devtools
    try {
      await installExtension(VUEJS_DEVTOOLS)
    } catch (e) {
      console.error('Vue Devtools failed to install:', e.toString())
    }
  }
  const ret = globalShortcut.register('CommandOrControl+Shift+|', () => {
    const currentWindow = BrowserWindow.getFocusedWindow()
    currentWindow && currentWindow.webContents.openDevTools()
  })
  if (!ret) {
    // 快捷键注册失败，尝试更换快捷键重新注册
    globalShortcut.register('CommandOrControl+Shift+D', () => {
      const currentWindow = BrowserWindow.getFocusedWindow()
      currentWindow && currentWindow.webContents.openDevTools()
    })
  }
  startApp()
})

// Exit cleanly on request from parent process in development mode.
if (isDevelopment) {
  if (process.platform === 'win32') {
    process.on('message', data => {
      if (data === 'graceful-exit') {
        app.quit()
      }
    })
  } else {
    process.on('SIGTERM', () => {
      app.quit()
    })
  }
}
