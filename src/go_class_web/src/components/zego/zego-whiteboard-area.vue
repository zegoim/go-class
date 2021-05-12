<template>
  <div class="zego-whiteboard-area" v-if="!!client">
    <slot></slot>
  </div>
</template>
<script>
import zegoClient from '@/service/zego/zegoClient'
import ErrorHandle from '@/utils/error'
import { roomStore } from '@/service/biz/room'
let extraTask = null
let allowSetExtra = false

export default {
  name: 'ZegoWhiteboardArea',
  props: {
    parentId: String // 传入白板渲染dom id
  },
  data() {
    return {
      client: null, // 白板sdk
      docsClient: null, // 文件转码sdk
      liveClient: null, // express sdk
      WBViewList: [], // 白板列表
      excelSheetsMap: [], // excel sheet列表
      activeExcelSheets: [], // 当前激活excel sheet
      activeExcelSheetNames: [], // 当前激活excel sheet 文件名
      activeExcelSheetsIdMap: {}, // 当前激活excel sheet id
      excelSheetNamesIdMap: {}, // 当前激活excel sheet 文件名 id
      originWBViewList: [], // 原始远程白板列表
      defaultAspectAutio: 16 / 9, // 默认白板比例
      aspectWidth: (500 / 9) * 16, // 对端接收比例
      aspectHeight: 500, // 对端接收比例
      pageCount: 5, // 创建默认页数
      currPage: 1, // 当前页码
      totalPage: 1, // 总页数
      isCreating: false, // 白板创建状态标识
      activeWBId: null, // 当前激活白板id
      activeWBView: null, // 当前激活白板
      WBNameIndex: 1, // 白板索引
      fileInfo: null, // 文件白板信息
      activeViewIsPPTH5: null, // 当前激活文件白板是否动态ppt
      activeViewIsPDF: null, // 当前激活文件白板是否pdf
      activeViewIsPPT: null, // 当前激活文件白板是否静态ppt
      activeViewIsExcel: null, // 当前激活文件白板是否excel
      zoom: 100, // 当前激活白板缩放比例
      activeTextPencil: null, // 当前激活白板工具类型
      activePopperType: '', // 当前激活白板文件类型
      activeToolType: 1, // 当前激活白板默认选择工具类型
      pencilTextTypes: [1, 2, 4, 8, 16], // 白板工具类型
      activeColor: '#f64326', // 默认激活颜色
      activeBrushSize: 6, // 默认粗细
      activeTextSize: 24, // 默认字体大小
      isRemote: false, // 是否远程
      zgDocsView: null, // 文件白板对象
      selectTimerTryTimes: 0, // 监听远程白板列表轮询起始值
      selectTimer: -1, // 监听远程白板列表轮询定时器
      isThumbnailsVisible: false, // 缩略图显示状态
      thumbnailsStatus: true, // 当前激活文件是否有加载失败的缩略图
      thumbnailsImg: [], // 缩略图列表
      filesListDialogShow: false, // 文件列表弹窗
      isAllowSendRoomExtraInfo: true, // 是否发送房间附加信息
      isInitGetList: false
    }
  },
  inject: ['zegoLiveRoom'],
  provide() {
    return {
      zegoWhiteboardArea: this
    }
  },
  computed: {
    // 用户名
    userName() {
      return this.zegoLiveRoom.userName
    },
    // 该房间状态
    roomState() {
      return this.zegoLiveRoom.roomState
    },
    // 房间附加信息
    defaultSelectWBInfo() {
      // 最后一次选择的白板信息，进入页面时渲染
      return this.zegoLiveRoom.roomExtraInfo
    },
    // roomID
    roomID() {
      return this.zegoLiveRoom.roomId
    }
  },
  watch: {
    roomState(state) {
      switch (state) {
        case 'CONNECTED':
          this.reUpdateWBList()
          this.activeWBView.serviceHandle.reload()
          break
        default:
          break
      }
    },
    defaultSelectWBInfo(newVal) {
      this.isAllowSendRoomExtraInfo = false
      this.handleRemoteWhiteboardChange(newVal)
    },
    // 初始化
    activeWBView(newVal, oldVal) {
      if (!oldVal && !!newVal) {
        this.initWBPencilSetting()
      }
    },
    activeToolType(newVal, oldVal) {
      this.activeWBView._activeToolType = newVal
      console.warn('new activeToolType', newVal)
      console.warn('old activeToolType', oldVal)
    },
    activeViewIsPPTH5(newVal, oldVal) {
      // 文件切换是动态ppt与其他格式文件
      if (newVal !== oldVal) {
        console.warn('oldVal', oldVal + 'this.activeToolType ', this.activeToolType)
        // 切换文件之前是动态ppt且选中了点击工具，则重置画具
        if (oldVal && this.activeToolType == 256) {
          console.warn('切换之前的文件是动态ppt且选中了点击工具')
          this.activeWBView.setToolType(1)
          this.setActiveToolType(1)
          this.resetActiveTextPencil()
          this.setActivePopperType('')
        }
        if (newVal) {
          this.activeWBView.setToolType(this.activeToolType)
        }
        console.warn('this.activeWBView---', this.activeWBView)
        console.warn('ActivePopperType------', this.activePopperType)
      }
    }
  },
  destroyed() {
    clearTimeout(this.selectTimer)
  },
  async mounted() {
    await this.initClient()
    await this.initWhiteboardArea()
    if (!this.originWBViewList.length) {
      const WBViewList = await this.getViewList()
      this.$set(this, 'WBViewList', WBViewList)
      if (roomStore.auth.share && !WBViewList.length) {
        this.$nextTick(() => {
          this.createWhiteboard()
        })
      }
    }
  },
  methods: {
    /**
     * @desc: 处理白板切换
     * @param {res} 房间附加信息
     */
    handleRemoteWhiteboardChange(res) {
      if (!res) return
      const { type, data } = res
      if (type === '1001' && data !== this.activeWBId && data) {
        console.warn('handleRemoteWhiteboardChange', { res })
        if (!this.originWBViewList.length) {
          !extraTask &&
            (extraTask = setInterval(() => {
              if (this.originWBViewList.length) {
                this.checkRemoteView(data)
                clearInterval(extraTask)
                extraTask = null
              }
            }, 10))
        } else {
          this.checkRemoteView(data)
        }
      }
    },
    /**
     * @desc: 初始化相关client
     */
    async initClient() {
      this.client = await zegoClient.init('whiteboard')
      this.docsClient = await zegoClient.init('docs')
      this.liveClient = await zegoClient.init('live')
    },
    /**
     * @desc: 初始化白板区域相关回调
     */
    async initWhiteboardArea() {
      /**
       * @desc: 监听所有error错误
       * @param {errorData} 错误码和错误描述
       */
      this.client.on('error', errorData => {
        console.warn('error', errorData)
      })
      /**
       * @desc: 监听远端创建白板view，返回远端创建的白板view实例
       * @return {whiteboardView} 白板view实例
       */
      this.client.on('viewAdd', async whiteboardView => {
        console.warn('viewAdd', whiteboardView)
        await this.addView(whiteboardView)
        if (this.activeViewIsPPTH5) this.stopPlay()
      })
      /**
       * @desc: 监听远端销毁白板view，返回该实例id
       * @return {whiteboardID} 白板ID
       */
      this.client.on('viewRemoved', async whiteboardID => {
        console.warn('remove', whiteboardID)
        await this.removeView(whiteboardID)
      })
      /**
       * @desc: 监听远端滚动、翻页白板view
       * @return {id, page, step } 返回白板ID，翻页模式时当前页码，动态PPT当前动画步数
       * 更多参数请见官网2.4滚动白板view部分 https://doc-zh.zego.im/zh/4327.html
       */
      this.client.on('viewScroll', ({ id, page, step }) => {
        console.warn('viewScroll', id, page, step)
        this.updateCurrPage(page)
      })
      /**
       * @desc: 监听加载文档
       * @return {res} 文档相关信息
       */
      this.docsClient.on('onLoadFile', async res => {
        console.log('docsClient.onLoadFile---', { res })
        try {
          await this.createFileWBView(res)
          if (this.activeViewIsPPTH5) this.stopPlay()
        } catch (e) {
          console.error('createFileWBView', e)
        }
      })
      /**
       * @desc: 断线重连相关处理，重新更新白板列表和激活白板
       */
      window.addEventListener('online', () => {
        // this.reUpdateWBList()
        // this.activeWBView.serviceHandle.reload()
        // window.location.reload()
      })
    },
    /**
     * @desc: 向本地白板列表添加白板
     * @param {view} 白板
     */
    addView(view) {
      this.originWBViewList.unshift(view)
      this.getViewList(false)
    },
    /**
     * @desc: 本地白板列表删除白板
     * @param {viewID} 需删除的白板id
     */
    removeView(viewID) {
      // 如果要删除的白板当前是激活状态，关闭缩略图
      if (this.activeWBId === viewID) this.setThumbnailsVisible(false)
      const excelSheetsMap = this.excelSheetsMap
      let needRemoveExcelSheets = []
      for (const key of Object.keys(excelSheetsMap)) {
        const ids = excelSheetsMap[key].map(item => item.whiteboardID)
        if (ids.includes(viewID)) needRemoveExcelSheets = ids
      }
      if (needRemoveExcelSheets.length) {
        this.originWBViewList = this.originWBViewList.filter(item => !needRemoveExcelSheets.includes(item.whiteboardID))
      } else {
        this.originWBViewList = this.originWBViewList.filter(x => x.whiteboardID !== viewID)
      }
      this.getViewList(false)
    },
    /**
     * @desc: 获取房间内全部白板列表
     * @param isPullNew { boolean }
     */
    async getViewList(isPullNew = true) {
      let viewList = []
      // 如果是true 则从服务器拉取白板列表
      if (isPullNew) {
        console.warn('getViewList', { isPullNew })
        viewList = await this.client.getViewList()
        this.originWBViewList = viewList
      } else {
        viewList = this.originWBViewList
      }
      const excelSheetsMap = {}
      viewList = viewList
        .map(view => {
          const fileInfo = view.getFileInfo && view.getFileInfo()
          // 如果是Excel文件，将每个sheet的id存入excelSheetsMap
          if (fileInfo && fileInfo.fileType === 4) {
            const { fileID } = fileInfo
            if (!excelSheetsMap[fileID]) {
              excelSheetsMap[fileID] = []
            }
            excelSheetsMap[fileID].push(view)
            const lastMatched = this.getLastMatchedViewByFileID(fileID)
            if (view && lastMatched && view.whiteboardID === lastMatched.whiteboardID) {
              return this.addAttrToView(view)
            }
            return null
          }

          return this.addAttrToView(view)
        })
        .filter(x => x)

      this.excelSheetsMap = excelSheetsMap
      this.WBViewList = viewList
      return viewList
    },

    /**
     * @desc:白板列表里默认展示第一个sheet
     * @param {fileID} 文件id
     * @return {lastMatched} 匹配得到的第一个文件
     */
    getLastMatchedViewByFileID(fileID) {
      let lastMatched
      for (let i = this.originWBViewList.length - 1; i > 0; i--) {
        if (this.originWBViewList[i].getFileInfo()?.fileID === fileID) {
          lastMatched = this.originWBViewList[i]
          break
        }
      }
      return lastMatched
    },

    /**
     * @desc: 给每一个view对象添加name属性
     * @param {view} 白板实例
     */
    addAttrToView(view) {
      return Object.assign(view, {
        name: this.getViewName(view)
      })
    },

    /**
     * @desc: 获取该view实例的name
     * @param {view} 白板实例
     */
    getViewName(view) {
      return view.getName()
    },

    /**
     * @desc: 更新当前页码，起始是1
     * @param {page} 需要更新页码
     */
    updateCurrPage(page) {
      this.currPage = page || this.activeWBView?.getCurrentPage() || 1
    },

    /**
     * @desc: 设置是否发送房间附加信息，本演示项目中房间附加信息一般用来通知对端文件或白板的更新，默认1001
     * @param {val} 是否发送
     */
    setIsAllowSendRoomExtraInfo(val) {
      this.isAllowSendRoomExtraInfo = val
    },

    /**
     * @desc: 通过房间附加信息通知对端通过接收1001可靠消息获得当前激活白板id
     */
    async notifyAllViewChanged() {
      if (!allowSetExtra) {
        setTimeout(async () => {
          const res = await this.liveClient.express('setRoomExtraInfo', '1001', this.activeWBId)
          console.warn('setRoomExtraInfo', { res })
          allowSetExtra = true
        }, 5000)
        return
      }
      if (!this.isAllowSendRoomExtraInfo) return
      const res = await this.liveClient.express('setRoomExtraInfo', '1001', this.activeWBId)
      console.warn('setRoomExtraInfo', { res })
      if (res.errorCode === 0 || res.error_code === 0) {
        // TODO
      }
    },

    /**
     * @desc: 创建白板
     */
    async createWhiteboard() {
      if (this.activeViewIsPPTH5) this.stopPlay()
      const checkResult = this.checkViewFileMaxLength('view')
      if (checkResult) return this.showToast(checkResult)
      // 创建配置参数
      const options = {
        roomID: this.roomID,
        pageCount: this.pageCount,
        aspectWidth: this.aspectWidth * this.pageCount,
        aspectHeight: this.aspectHeight,
        name: `${this.userName}创建的白板${this.WBNameIndex++}`
      }
      try {
        const activeWBView = await this.client.createView(options)
        await this.client.attachView(activeWBView, this.parentId)
        if (!this.originWBViewList.find(item => item.whiteboardID === activeWBView.whiteboardID)) {
          this.originWBViewList.unshift(
            Object.assign(activeWBView, {
              name: this.getViewName(activeWBView)
            })
          )
        }
        await this.getViewList(false)
        await this.updateActiveView(activeWBView)
      } catch (error) {
        console.log(error)
        const { code } = error
        if (code === ErrorHandle.timeout) {
          this.showToast('请求超时')
        } else {
          this.showToast('共享失败')
        }
      }
    },

    /**
     * @desc: 本演示项目普通白板最多只能创建10个，文件只能创建10个
     * @param {type} 需检查的类型 view-普通白板 file-文件
     */
    checkViewFileMaxLength(type = 'view') {
      const viewList = []
      const fileList = []
      for (const item of this.WBViewList) {
        if (item.getFileInfo()) {
          fileList.push(item)
        } else {
          viewList.push(item)
        }
      }

      if (type === 'view' && viewList.length >= 10) {
        return '已超过最大数量，请关闭部分白板'
      }

      if (type === 'file' && fileList.length >= 10) {
        return '已超过最大数量，请关闭部分文件'
      }
    },

    /**
     * @desc: 更新当前激活白板相关参数
     * @param {activeWBView} 当前激活白板
     */
    async updateActiveView(activeWBView) {
      this.$set(this, 'activeWBId', activeWBView.whiteboardID)
      this.$set(this, 'activeWBView', activeWBView)

      // 每次切换文件/白板 关闭缩略图
      this.isThumbnailsVisible = false
      // 获取文件相关参数
      const fileInfo = activeWBView && activeWBView?.getFileInfo()
      this.activeViewIsPPTH5 = !!(fileInfo && (fileInfo.fileType === 512 || fileInfo.fileType === 4096))
      this.activeViewIsPDF = !!(fileInfo && fileInfo.fileType === 8)
      this.activeViewIsPPT = !!(fileInfo && fileInfo.fileType === 1)
      this.activeViewIsExcel = !!(fileInfo && fileInfo.fileType === 4)
      // 如果是Excel文件，获取需要渲染的sheet
      if (this.activeViewIsExcel) {
        this.activeExcelSheets = this.excelSheetsMap[fileInfo.fileID]
        this.activeExcelSheetNames = this.excelSheetNamesIdMap[fileInfo.fileID]
      }
      if (!fileInfo) {
        this.zgDocsView = null
      }

      const zoom = activeWBView.getScaleFactor().scaleFactor
      this.$set(this, 'zoom', zoom * 100)
      this.activeToolType = activeWBView.getToolType() || 0

      if (this.activeToolType === 0) {
        activeWBView.setToolType(null)
      }

      this.updateCurrPage(undefined)
      this.totalPage = activeWBView?.getPageCount() || 1
      await this.notifyAllViewChanged()
    },

    // 收到1001可靠消息时，可能白板列表还未更新，所以白板列表中找不到激活的id时，用定时器不断进行尝试
    async checkRemoteView(id) {
      if (this.originWBViewList.find(item => item.whiteboardID === id)) {
        this.selectRemoteView(id, true)
      } else {
        this.selectTimerTryTimes = this.selectTimerTryTimes + 1
        if (this.selectTimerTryTimes >= 20) {
          return clearTimeout(this.selectTimer)
        }
        this.selectTimer = setTimeout(() => {
          clearTimeout(this.selectTimer)
          this.checkRemoteView(id)
        }, 50)
      }
    },

    /**
     * @desc: 从服务器获取白板
     * @param {id} 目标文件id
     */
    async selectRemoteView(id, setSheetID = false) {
      if (this.isCreating || !id) return
      console.warn('selectRemoteView', { originWBViewList: this.originWBViewList })
      const view = this.originWBViewList.find(v => id == v.whiteboardID)
      if (!view) {
        this.showToast('远端白板不存在，请尝试刷新重试')
        return
      }
      console.warn('selectRemoteView', view)
      this.$set(this, 'activeWBView', view)
      this.$set(this, 'activeWBId', view.whiteboardID)
      const fileInfo = this.activeWBView && this.activeWBView.getFileInfo()
      this.$nextTick(() => {
        if (fileInfo) {
          if (fileInfo.fileType === 4) {
            this.isCreating = id
          }
          this.loadFileView(id, fileInfo, setSheetID)
        } else {
          this.loadNormalWhiteboard()
        }
        // const page = view.getCurrentPage()
        // console.warn('selectRemoteView page', page)
        // this.updateCurrPage(page)
      })
    },

    /**x
     * @desc: 加载文件
     * @param {id} 文件id
     * @param {fileInfo} 文件信息
     * @param {setSheetID} 是否设置sheet id
     */
    async loadFileView(id, fileInfo, setSheetID = false) {
      const isExcelFile = fileInfo.fileType === 4
      if (isExcelFile && !setSheetID) {
        // 通过文件id获得Excel文件需要渲染的sheet
        const activeId = this.activeExcelSheetsIdMap[fileInfo.fileID]
        if (activeId && activeId !== id && !this.isCreating) {
          this.selectRemoteView(activeId)
          return
        }
      }
      this.isRemote = true
      // 创建文件
      const zgDocsView = this.docsClient.createView(this.parentId, id, fileInfo.fileName)
      this.$set(this, 'zgDocsView', zgDocsView)
      try {
        const res = await zgDocsView.loadFile(fileInfo.fileID, fileInfo.authKey)
        this.$nextTick(() => {
          this.splitExcelSheetSuffixHandle(res)
          this.updateExcelSheetNamesIdMap(res, fileInfo.fileID)
        })
      } catch (e) {
        console.error(e)
        this.showToast(`${(e && e.message) || '网络错误'}，请刷新页面后重试`)
      }
      this.isCreating = false
    },

    async loadNormalWhiteboard() {
      this.isCreating = false
      await this.client.attachView(this.activeWBView, this.parentId)
      this.zgDocsView = null
      await this.updateActiveView(this.activeWBView)
    },

    /**
     * @desc: 创建文件
     * @param fileID {number | string} 文件id
     * @param fileName {string} 文件名
     * @return type {any}
     */
    // eslint-disable-next-line no-unused-vars
    async createFileView(fileID, fileName) {
      if (this.activeViewIsPPTH5) this.stopPlay()
      const originWBViewList = this.originWBViewList
      const matchedView = originWBViewList.find(item => {
        const fileInfo = item.getFileInfo() || {}
        return fileID === fileInfo.fileID
      })

      if (matchedView) {
        return this.selectRemoteView(matchedView.whiteboardID)
      }

      this.isRemote = false
      const zgDocsView = fileName
        ? this.docsClient.createView(this.parentId, undefined, fileName)
        : this.docsClient.createView(this.parentId)
      try {
        const res = await zgDocsView.loadFile(fileID, '')
        // 处理Excel文件中每个sheet的文件后缀
        this.splitExcelSheetSuffixHandle(res)
        // 获得当前打开Excel每个sheet的名字
        this.updateExcelSheetNamesIdMap(res, fileID)
        this.zgDocsView = zgDocsView
      } catch (e) {
        console.error(e)
        this.showToast(`${(e && e.message) || '网络错误'}，请刷新页面后重试`)
      }
    },

    /**
     * @desc: 在创建了文件执行完loadFile之后会触发回调，需在回调中配合创建文件白板
     * @param {res} 创建文件之后得到的相关文件参数
     */
    async createFileWBView(res) {
      if (this.activeViewIsPPTH5) this.stopPlay()
      console.warn('createFileWBView', { res })
      // 创建Excel文件白板
      const isRemoteNoHasExcelFile = res.fileType === 4 && !this.originWBViewList.find(x => res.name === x.getName())
      if (isRemoteNoHasExcelFile) {
        await this.createExcelSheetView(res)
        return
      }

      let activeWBView = this.activeWBView
      // 创建普通文件白板
      if (!this.isRemote) {
        try {
          activeWBView = await this.client.createView({
            roomID: this.roomID,
            name: res.fileName || `file-${res.fileID}`,
            aspectWidth: this.aspectWidth,
            aspectHeight: this.aspectHeight,
            pageCount: res.pageCount,
            fileInfo: {
              fileID: res.fileID,
              fileName: res.fileType === 4 ? res.fileName : res.fileName || res.fileID,
              authKey: res.authKey,
              fileType: res.fileType
            }
          })
          this.originWBViewList.unshift(
            Object.assign(activeWBView, {
              name: this.getViewName(activeWBView)
            })
          )
        } catch (error) {
          console.log('createFileWBView error', { error })
          const { code } = error
          if (code === ErrorHandle.timeout) {
            this.showToast('请求超时')
          } else {
            this.showToast('共享失败')
          }
        }
      }

      const fileInfo = activeWBView?.getFileInfo() || {}
      const fileID = fileInfo.fileID
      // 如果是Excel文件，则将当前激活白板id通过文件id保存在activeExcelSheetsIdMap
      if (fileInfo.fileType === 4) {
        this.activeExcelSheetsIdMap[fileID] = activeWBView.whiteboardID
      }
      await this.client.attachView(activeWBView, res.viewID)
      await this.getViewList(false)
      await this.updateActiveView(activeWBView)
    },

    /**
     * @desc: 给每一个sheet创建对应的普通白板
     * @param {res} 创建文件回调返回的相关参数
     */
    async createExcelSheetView(res) {
      const { sheets } = res
      let activeWBView = this.activeWBView
      if (!this.isRemote) {
        try {
          const views = []
          let createSingleExcelSheetFunc = async (sheets, index = 0) => {
            const sheetName = sheets[index]
            const options = {
              roomID: this.roomID,
              name: res.name || res.fileName,
              aspectWidth: this.aspectWidth,
              aspectHeight: this.aspectHeight,
              pageCount: res.pageCount,
              fileInfo: {
                fileID: res.fileID,
                fileName: sheetName,
                authKey: res.authKey,
                fileType: res.fileType
              }
            }
            const view = await this.client.createView(options)
            if (view) views.push(view)
            if (index < sheets.length - 1) {
              index = index + 1
              await createSingleExcelSheetFunc(sheets, index)
            } else {
              createSingleExcelSheetFunc = null
            }
          }
          await createSingleExcelSheetFunc(sheets)
          activeWBView = views[0]
          this.originWBViewList = [...views, ...this.originWBViewList]
        } catch (error) {
          const { code } = error
          if (code === ErrorHandle.timeout) {
            this.showToast('请求超时')
          } else {
            this.showToast('共享失败')
          }
        }
      }
      const fileID = activeWBView?.getFileInfo()?.fileID
      this.activeExcelSheetsIdMap[fileID] = activeWBView.whiteboardID
      await this.client.attachView(activeWBView, res.viewID)
      await this.getViewList(false)
      await this.updateActiveView(activeWBView)
    },

    /**
     * @desc: 处理Excel文件sheet
     */
    splitExcelSheetSuffixHandle(res) {
      res.fileType === 4 &&
        res.file_list &&
        res.file_list.forEach(item => {
          item.file_name = item.file_name.replace(/.pdf/, '')
        })
    },

    /**
     * @desc: 获得新的Excel每个sheet的名字
     * @param {res} 创建文件之后返回的相关文件参数
     * @return {fileID} 文件id
     */
    updateExcelSheetNamesIdMap(res, fileID) {
      if (res.fileType === 4 && !this.excelSheetNamesIdMap[fileID]) {
        this.excelSheetNamesIdMap[fileID] = res.file_list.map(file => file.file_name)
      }
    },

    /**
     * @desc: 销毁白板
     * @param {whiteboardView} 需要销毁的白板对象
     */
    async destroyView(whiteboardView) {
      const fileInfo = whiteboardView.getFileInfo() || {}
      const activeFileInfo = this.activeWBView?.getFileInfo() || {}

      // 缩略图展示的文件
      const isShowThumbnails =
        activeFileInfo.fileType === 1 || activeFileInfo.fileType === 8 || activeFileInfo.fileType === 512

      // 判断销毁的白板是否是当前使用的白板
      const isDestroyActiveView = fileInfo.fileName === activeFileInfo.fileName

      // 如果是销毁当前激活文件白板关闭缩略图，否则维持原状
      if (isShowThumbnails && isDestroyActiveView) {
        this.isThumbnailsVisible = false
      }

      if (fileInfo && fileInfo.fileType === 4) {
        this.WBViewList = this.WBViewList.filter(x => x.whiteboardID && x.whiteboardID !== whiteboardView.whiteboardID)
        for (const item of this.originWBViewList) {
          if (item.getFileInfo() && item.getFileInfo().fileID === fileInfo.fileID) {
            try {
              await this.client.destroyView(item)
              item.delete = true
            } catch (error) {
              console.log(error)
              const { code } = error
              if (code === ErrorHandle.timeout) {
                this.showToast('请求超时')
              } else {
                this.showToast('关闭失败')
              }
            }
          }
        }
        this.originWBViewList = this.originWBViewList.filter(item => !item.delete)
      } else {
        try {
          await this.client.destroyView(whiteboardView)
          this.WBViewList = this.WBViewList.filter(
            x => x.whiteboardID && x.whiteboardID !== whiteboardView.whiteboardID
          )
          this.originWBViewList = this.originWBViewList.filter(x => x.whiteboardID !== whiteboardView.whiteboardID)
        } catch (error) {
          console.log(error)
          const { code } = error
          if (code === ErrorHandle.timeout) {
            this.showToast('请求超时')
          } else {
            this.showToast('关闭失败')
          }
        }
      }

      if (
        (whiteboardView.whiteboardID === this.activeWBId || fileInfo.fileID === activeFileInfo.fileID) &&
        this.WBViewList.length
      ) {
        const id = this.WBViewList[0].whiteboardID
        this.selectRemoteView(id)
      }
    },

    /**
     * @desc: 初始化画具面板
     */
    initWBPencilSetting() {
      this.activeWBView.setBrushColor(this.activeColor)
      this.setBrushSize(this.activeBrushSize)
      this.setTextSize(this.activeTextSize)
    },

    resetActiveTextPencil() {
      this.activeTextPencil = ''
    },
    setActiveToolType(type) {
      this.activeToolType = type
    },
    setActiveTextPencil(type) {
      this.activeTextPencil = type
    },
    setActivePopperType(type) {
      this.activePopperType = type
    },
    setActiveColor(val) {
      this.activeColor = val
    },
    setActiveBrushSize(val) {
      this.activeBrushSize = val
    },
    setActiveTextSize(val) {
      this.activeTextSize = val
    },
    // 设置背景颜色
    setBackgroundColor(val) {
      this.activeWBView && this.activeWBView.setBackgroundColor(val)
    },
    // 设置画笔颜色
    setBrushColor(val) {
      this.activeWBView && this.activeWBView.setBrushColor(val)
      this.activeColor = val
    },
    // 设置画笔粗细
    setBrushSize(val) {
      this.activeWBView && this.activeWBView.setBrushSize(val)
      this.activeBrushSize = val
    },
    // 设置文本大小
    setTextSize(val) {
      this.activeWBView && this.activeWBView.setTextSize(val)
      this.activeTextSize = val
    },
    // 设置字体
    setTextStyle(type, state) {
      switch (type) {
        case 'bold':
          this.activeWBView && this.activeWBView.setFontBold(state)
          break
        case 'italic':
          this.activeWBView && this.activeWBView.setFontItalic(state)
          break
      }
      this.activeTextStyle = type
    },

    // 设置白板缩放
    selectViewZoom(zoom) {
      this.zoom = zoom
      const _zoom = +zoom / 100
      if (this.activeWBView) {
        this.activeWBView.setScaleFactor(_zoom)
        if (this.activeToolType === 0) {
          this.activeWBView.setToolType(null)
        }
      }
    },

    setZoom(num) {
      this.zoom = num * 100
    },

    // 动态ppt 上/下一步
    previousStep() {
      this.zgDocsView && this.zgDocsView.previousStep()
    },
    nextStep() {
      this.zgDocsView && this.zgDocsView.nextStep()
    },

    /**
     * @desc: 翻页
     * @param {page} 当前页码
     */
    flipPage(page) {
      if (!this.activeWBView || page < 1 || page > this.totalPage) return
      const percent = (page - 1) / this.totalPage
      const { direction } = this.activeWBView.getCurrentScrollPercent()
      console.warn('percent:', percent)
      if (direction === 1) {
        this.activeWBView.scroll(percent, 0)
      } else {
        this.activeWBView.scroll(0, percent)
      }
      // 略缩图有加载失败的情况，翻动上下页面重新请求
      if (!this.thumbnailsStatus) this.getThumbnailUrlList()
    },

    // 上一页
    previousPage() {
      this.flipPage(this.currPage - 1)
    },
    // 下一页
    nextPage() {
      this.flipPage(this.currPage + 1)
    },

    /**
     * @desc: 开关缩略图
     * @param {val} 状态
     */
    setThumbnailsVisible(val) {
      this.isThumbnailsVisible = val
    },

    /**
     * @desc: 获取缩略图
     */
    getThumbnailUrlList() {
      if (this.zgDocsView) {
        this.thumbnailsImg = this.zgDocsView.getThumbnailUrlList()
        console.log('this.zgDocsView', this.zgDocsView)
        console.log('getThumbnailUrlList:', this.thumbnailsImg)
      }
    },

    /**
     * @desc: 当前激活文件是否有加载失败的缩略图
     * @param {val} 状态
     */
    setThumbnailsStatus(val) {
      this.thumbnailsStatus = val
    },

    /**
     * @desc: 设置文件列表弹窗状态
     * @param {val} 状态
     */
    setFilesListDialogShow(val) {
      this.filesListDialogShow = val
    },

    /**
     * @desc: 断开重连后更新白板列表和激活白板
     * @param {isPullNew} 是否从服务器拉取新的数据
     */
    async reUpdateWBList(isPullNew = true) {
      console.warn('进入 reUpdateWBList')
      this.isThumbnailsVisible = false
      await this.getViewList(isPullNew)
      if (!this.WBViewList.length) {
        await this.createWhiteboard()
        return
      }
      if (!this.originWBViewList.find(x => x.whiteboardID === this.activeWBId)) {
        this.checkRemoteView(this.WBViewList[0].whiteboardID)
      }
    },
    async selectExcelSheetView(id) {
      if (this.isCreating || !id) return

      const view = this.originWBViewList.find(v => id === v.whiteboardID)
      if (!view) {
        this.showToast('远端白板不存在，请尝试刷新重试')
        return
      }

      this.$set(this, 'activeWBView', view)
      const fileInfo = this.activeWBView && this.activeWBView.getFileInfo()
      const isExcelFile = fileInfo.fileType === 4
      this.isRemote = true
      const zgDocsView = this.docsClient.createView(this.parentId, id, isExcelFile ? fileInfo.fileName : '')
      console.warn({ zgDocsView, docsClient: this.docsClient })
      try {
        const res = await zgDocsView.loadFile(fileInfo.fileID, fileInfo.authKey)
        this.splitExcelSheetSuffixHandle(res)
        this.updateExcelSheetNamesIdMap(res, fileInfo.fileID)
        this.zgDocsView = zgDocsView
        console.warn(id, this.activeWBView, fileInfo)
      } catch (e) {
        console.error(e)
        this.showToast(`${(e && e.message) || '网络错误'}，请刷新页面后重试`)
      }
    },
    /**
     * @desc: 停止动态ppt中的视频播放
     * 注意： 当业务逻辑上需要切换文件白板时，如果当前文件白板是动态ppt需要手动执行该API停止播放。
     * 传入0，表示停止当前页的音视频，传入指定数字停掉指定页的音视频
     */
    stopPlay(num = 0) {
      this.zgDocsView && this.zgDocsView.stopPlay(num)
    }
  }
}
</script>

<style lang="scss">
.zego-whiteboard-area {
  width: 100%;
  height: 100%;
}
</style>
