module.exports = {
  devServer: {
    https: true
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
  css: {
    loaderOptions: {
      scss: {
        prependData: '@import "@/style/global.scss";'
      }
    }
  },
  productionSourceMap: false
}
