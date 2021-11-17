const os = require('os')

// function generateVersion() {
//   var d = new Date()
//   var version =
//     `${d
//       .getFullYear()
//       .toString()
//       .slice(-2)}` +
//     `${d.getMonth() + 1}` +
//     `${d.getDate()}` +
//     '-' +
//     `${d.getHours()}` +
//     `${d.getMinutes()}` +
//     `${d.getSeconds() < 10 ? '0' + d.getSeconds() : d.getSeconds()}`
//   return version
// }

module.exports = {
  // devServer: {
  //   https: true
  // },
  configureWebpack: config => {
    const nodeLoader = {
      test: /\.node$/,
      loader: 'native-ext-loader',
      options: {
        rewritePath: os.platform() === 'win32' ? './resources' : '../Resources'
      }
    }
    config.module.rules.push(nodeLoader)
  },
  chainWebpack: config => {
    // svg rule loader
    const svgRule = config.module.rule('svg') // 找到svg-loader
    svgRule.uses.clear() // 清除已有的loader, 如果不这样做会添加在此loader之后
    svgRule.exclude.add(/node_modules/) // 正则匹配排除node_modules目录
    // svgRule.oneOfs.clear()
    svgRule // 添加svg新的loader处理
      .test(/\.svg$/)
      .use('raw-loader')
      .loader('raw-loader')
  },
  pluginOptions: {
    electronBuilder: {
      // List native deps here if they don't work
      externals: ['zego-express-docsview-electron', 'zego-express-engine-electron', 'zegoliveroom'],
      extraResources: [
        './node_modules/zego-express-docsview-electron/**',
        './node_modules/zego-express-engine-electron/**',
        './node_modules/zegoliveroom/**',
      ],
      mainProcessWatch: [
        'src/main/config.js',
        'src/main/listeners.js',
        'src/main/methods.js',
        'src/main/windowInstance.js',
        'src/main/menu.js'
      ],
      // If you are using Yarn Workspaces, you may have multiple node_modules folders
      // List them all here so that VCP Electron Builder can find them
      nodeModulesPath: ['../../node_modules', './node_modules'],
      builderOptions: {
        // productName: 'GoClass-liveroom-' + generateVersion(),
        productName: 'GO课堂',
        copyright: 'Copyright © 即构科技',
        appId: 'com.zego.goclass_electron',
        directories: {
          buildResources: 'icons' // icons 文件夹
        },
        dmg: {
          sign: false,
          // eslint-disable-next-line no-template-curly-in-string
          title: '${productName} ${version}',
          contents: [
            {
              x: 410,
              y: 150,
              type: 'link',
              path: '/Applications'
            },
            {
              x: 130,
              y: 150,
              type: 'file'
            }
          ]
        },
        mac: {
          category: 'public.app-category.productivity',
          target: ['dmg'],
          hardenedRuntime: true,
          gatekeeperAssess: false,
          entitlements: 'build/entitlements.mac.plist',
          entitlementsInherit: 'build/entitlements.mac.plist',
          icon: 'build/icons/512.png'
        },
        win: {
          target: [
            {
              target: 'nsis',
              arch: ['ia32'] // win32-ia32 win64-x64
            }
          ],
          icon: 'build/icons/512.ico'
        },
        nsis: {
          differentialPackage: false,
          perMachine: false,
          oneClick: false, // 是否一键安装
          allowElevation: true, // 允许请求提升。 如果为false，则用户必须使用提升的权限重新启动安装程序。
          allowToChangeInstallationDirectory: true, // 允许修改安装目录
          installerIcon: 'build/icons/48.ico', // 安装图标
          uninstallerIcon: 'build/icons/48.ico', // 卸载图标
          installerHeaderIcon: 'build/icons/48.ico', // 安装时头部图标
          createDesktopShortcut: true, // 创建桌面图标
          createStartMenuShortcut: true, // 创建开始菜单图标
          deleteAppDataOnUninstall: true, //
          shortcutName: 'GO课堂' // 图标名称
          // include: './build/script/installer.nsh' // 包含的自定义nsis脚本
        }
      }
    }
  },
  css: {
    loaderOptions: {
      scss: {
        prependData: '@import "@/style/global.scss";'
      }
    }
  },
  productionSourceMap: false
}
