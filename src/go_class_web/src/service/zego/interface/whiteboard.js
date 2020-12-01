const WhiteboardInterface = {
  createWhiteboard () {},   // 创建新白板
  createView () {},         // 创建白板view实例
  destroyView () {},        // 销毁白板实例
  attachView () {},         // 渲染白板
  getViewList () {},        // 获取白板列表
  on: [
      'viewAdd',              // 监听创建白板view，返回远端创建的白板实例
      'viewRemoved',          // 监听远端销毁白板view，返回该实例id
      'viewScroll',           // 监听远端滚动，翻页白板view
  ],
}

export {
  WhiteboardInterface
}
