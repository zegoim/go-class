<!--
 * @Description: 提供白板sdk和文件转码相关实例的组件，通过provide提供该能力，如需使用相关方法的组件可通过inject注入
-->
<template>
  <div class="zego-whiteboard-area" v-if="!!client">
    <slot></slot>
    <file-upload-percent-dialog v-if="fileUploadStatus === 1 || fileUploadStatus === 8" :percent="fileUploadPercent" :fileUploadStatus="fileUploadStatus"></file-upload-percent-dialog>
  </div>
</template>
<script>
import zegoClient from '@/service/zego/zegoClient'
import ErrorHandle from '@/utils/error'
import { ZEGOENV } from '@/utils/constants'
import FileUploadPercentDialog from '@/components/base/file-upload-percent-dialog'
let extraTask = null

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
      aspectWidth: 500, // 对端接收比例
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
      pencilTextTypes: [1, 2, 4, 8, 16, 'graph','upload'], // 白板工具类型
      graphTypes: [4, 8, 16], // 图形类型
      graphType:8,// 图形类型默认选中矩形
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
      fileUploadPercent: 0, // 文件上传进度
      fileUploadStatus: 0, // 文件上传状态
      waitting: false,
      uploadFileFlag: false
    }
  },
  inject: ['zegoLiveRoom'],
  provide() {
    return {
      zegoWhiteboardArea: this
    }
  },
  components:{
    FileUploadPercentDialog
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
    /**
     * @desc: 监听房间状态
     * @param {房间状态：DISCONNECTED-sdk重连失败，CONNECTING-sdk检测到网络断开，CONNECTED-连接成功} state
     */    
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
      console.warn('defaultSelectWBInfo RoomExtraInfo',newVal.data)
      this.isAllowSendRoomExtraInfo = false
      this.handleRemoteWhiteboardChange(newVal)
    },
    // 初始化
    activeWBView(newVal, oldVal) {
      if (!oldVal && !!newVal) {
        this.initWBPencilSetting()
      }
    },
    activeViewIsPPTH5(newVal, oldVal){
      // 文件切换是动态ppt与其他格式文件
      if(newVal !== oldVal){
        // 切换文件之前是动态ppt且选中了点击工具，则重置画具
        if(oldVal && this.activeToolType == 256){
          console.warn('这里执行了setToolType，值为1')
          this.activeWBView.setToolType(1)
          this.setActiveToolType(1)
          this.resetActiveTextPencil()
          this.setActivePopperType('')
        }
      } 
    }
  },
  destroyed() {
    clearTimeout(this.selectTimer)
  },
  async mounted() {
    await this.initClient()
    await this.initWhiteboardArea()
    /**
     * @desc: 断线重连相关处理，重新更新白板列表和激活白板
     */      
    window.addEventListener('online', () => {
      this.reUpdateWBList()
      this.activeWBView.serviceHandle.reload()
    })
  },
  methods: {
    /**
     * @desc: 处理白板切换
     * @param {res} 房间附加信息
     */    
    handleRemoteWhiteboardChange(res) {
      if (!res) return
      const {type, data} = res
      if (type === '1001' && data !== this.activeWBId && data) {
        console.warn('handleRemoteWhiteboardChange', {res})
        if (!this.originWBViewList.length) {
          console.warn('handleRemoteWhiteboardChange 列表长度不为0', this.originWBViewList.length,this.WBViewList.length)
          !extraTask && (extraTask = setInterval(() => {
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
     * @desc: 初始化相关client-sdk
     */    
    async initClient() {
      this.client = await zegoClient.init('whiteboard')
      this.docsClient = await zegoClient.init('docs')
      this.liveClient = await zegoClient.init('live')
      this.docsClient.setConfig('disableH5ImageDrag', 'true')
      this.docsClient.setConfig('pptStepMode', ZEGOENV.pptStepMode)
      // this.client.setDeferredRenderingTime(+ZEGOENV.deferredRenderingTime)
    },
    /**
     * @desc: 初始化白板区域相关回调
     */    
    async initWhiteboardArea() {
      /**
       * @desc: 监听所有error错误
       * @param {错误码和错误描述} errorData
       */      
      this.client.on('error', errorData => {
        console.warn('error', errorData)
        switch (errorData.code) {
          case 3030005:
            this.showToast('操作失败，当前图元大小超过限制')
            break;
        
          default:
            break;
        }
      })
      /**
       * @desc: 监听远端创建白板view，返回远端创建的白板view实例
       * @return {白板view实例} whiteboardView
       */      
      this.client.on('viewAdd', async whiteboardView => {
        console.warn('viewAdd', whiteboardView)
        await this.addView(whiteboardView)
      })
      /**
       * @desc: 监听远端销毁白板view，返回该实例id
       * @return {白板ID} whiteboardID
       */      
      this.client.on('viewRemoved', async whiteboardID => {
        console.warn('remove', whiteboardID)
        await this.removeView(whiteboardID)
      })
      /**
       * @desc: 监听远端滚动、翻页白板view
       * @return {返回白板ID，翻页模式时当前页码，动态PPT当前动画步数} id, page, step 
       * 更多参数请见官网2.4滚动白板view部分 https://doc-zh.zego.im/zh/4327.html
       */      
      this.client.on('viewScroll', ({ id, page, step }) => {
        console.warn('viewScroll', id, page, step)
        this.updateCurrPage(page)
      })
      /**
       * @desc: 监听加载文档
       * @return {文档相关信息} res
       */      
      this.docsClient.on('onLoadFile', async res => {
        console.log('docsClient.onLoadFile---', { res })
        try {
          await this.createFileWBView(res)
          // if (this.activeViewIsPPTH5) this.stopPlay()
        } catch (e) {
          console.error('createFileWBView', e)
        }
      })
      /**
       * @desc: 动态PPT步数改变的回调
       * @return {返回参数} res
       * 更多参数详情 https://doc-zh.zego.im/zh/api?doc=DocsView_API~Javascript~interface~ZegoDocsViewStepChangeModel
       */      
      this.docsClient.on('onStepChange', res => {
        console.log('======onStepChange', res.page, res.step, res.notify)
      })
      /**
       * @desc: 监听上传文档
       * @return {文档相关信息} res
       */      
      this.docsClient.on('onUpload', async res => {
        this.uploadFileFlag = true
        console.log('docsClient.onLoadFile---', { res })
        var ZegoDocsViewUploadState = {
          1: '上传中',
          2: '已上传',
          4: '排队中',
          8: '转换中',
          16: '转换成功',
          32: '转换失败',
          64: '取消上传'
        };
        this.fileUploadStatus = res.status
        if (res.status === 1 && res.uploadPercent !== 100) {
          console.log(`文件${ZegoDocsViewUploadState[res.status]}，进度${res.uploadPercent}% :`, res);
          this.fileUploadPercent = res.uploadPercent
        } else if (res.uploadPercent == 100) {
          this.fileUploadPercent = 100
        } else if (res.status === 16) {
          this.fileUploadPercent = 0
          this.fileUploadStatus = 0
          this.createDocView(res.fileID)
        } else if (this.fileUploadStatus === undefined){
          this.fileUploadStatus = 0
          // if(!res.error) this.$message('文件上传失败，请重试')
        }else {
          console.log(`文件${ZegoDocsViewUploadState[res.status]}:`, res);
        }
        console.warn(this.fileUploadStatus)
        let errorCode = res.error?.code || res.code 
        this.translateUploadFileCode(errorCode)
      })
       /**
        * @desc: 监听键盘按键事件
        */       
       window.addEventListener('keydown', event => {
        var e = event || window.event || arguments.callee.caller.arguments[0];
        if(!e) return
        switch (e.keyCode) {
          case 8: // 监听backspace按键，批量删除选中图元
            this.deleteSelectedGraphics()
            break;
          case 46: // 监听Delete按键，批量删除选中图元
            this.deleteSelectedGraphics()
            break;
          default:
            break;
        }
      })
    },
    /**
     * @desc: 创建共享文件
     * @param {id} 文件id
     */
    async createDocView(id) {
      const checkResult = this.checkViewFileMaxLength('file')
      if (checkResult) return this.$message(checkResult)
      if (this.waitting) return
      this.waitting = true
      // 如果新建文件之前的是动态ppt，需手动停止该文件音视频
      if (this.activeViewIsPPTH5) this.stopPlay()
      this.setIsAllowSendRoomExtraInfo(true)
      await this.createFileView(id)
      this.waitting = false
    },
    /**
     * @desc: 向本地白板列表添加白板
     * @param {白板} view
     */    
    addView(view) {
      // console.warn('addView this.originWBViewList',this.originWBViewList)
      // // 新增白板与在已有白板列表中的创建时间比较，白板列表中的创建时间更早，则该新增白板不是最新
      // let isLocal = this.originWBViewList.find(x => {
      //   console.warn('fileinfo',view.getFileInfo(),x.getFileInfo())
      //   return view.getFileInfo()?.fileID === x.getFileInfo()?.fileID
      // })
      // let isNotLatest = this.originWBViewList.find(x => {
      //   console.warn('createtime: ',view.getCreateTime() < x.getCreateTime())
      //   return view.getCreateTime() < x.getCreateTime()
      // })
      // console.warn('addview isLocal isNotLatest',isLocal, isNotLatest)
      // // 接收到的白板是比之前接受的同fileid的白板时间更早创建，则以接受白板为准
      // if(view.getFileInfo()) {
      //   if(isLocal && isNotLatest){
      //     console.warn('两个并发创建的文件白板，后收到的白板view比原本的更新')
      //     // 移除旧的同fileid的白板,将新接收的view添加入列表中
      //     this.removeByFileID(this.originWBViewList, view.getFileInfo()?.fileID)
      //     this.originWBViewList.unshift(view)
      //     //发送房间附加消息同步其他端
      //     this.activeWBId = view.getID()
      //     console.warn('this.activeWBId',this.activeWBId)
      //     this.setIsAllowSendRoomExtraInfo(true)
      //     this.notifyAllViewChanged()
      //   }else{
      //     console.warn('列表中的文件白板创建时间比接收的view创建时间更早一些,无视此次viewadd传来的view')
      //   }
      // }else{
      //   this.originWBViewList.unshift(view)
      // }
      this.originWBViewList.unshift(view)
      this.getViewList(false)
    },
    /**
     * @desc: 本地白板列表删除白板
     * @param {需删除的白板id} viewID
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
        this.originWBViewList = this.originWBViewList.filter(
          item => !needRemoveExcelSheets.includes(item.whiteboardID)
        )
      } else {
        this.originWBViewList = this.originWBViewList.filter(x => x.whiteboardID !== viewID)
      }
      this.getViewList(false)
    },
    /** 
     * @desc: 获取房间内全部白板列表
     * @param {是否从服务器拉去新的列表} isPullNew
     */    
    async getViewList(isPullNew = true) {
      let viewList = []
      // 如果是true 则从服务器拉取白板列表
      if (isPullNew) {
        // arr = await this.client.getViewList()
        // viewList = this.checkWBCreateTime(arr)
        viewList = await this.client.getViewList()
        this.originWBViewList = viewList
      } else {
        viewList = this.originWBViewList
      }
      console.warn(viewList)
      const excelSheetsMap = {}
      viewList = viewList.map(view => {
          const fileInfo = view.getFileInfo && view.getFileInfo()
          // 如果是Excel文件，将每个sheet的id存入excelSheetsMap
          if (fileInfo && fileInfo.fileType === 4) {
            const { fileID } = fileInfo
            if (!excelSheetsMap[fileID]) {
              excelSheetsMap[fileID] = []
            }
            excelSheetsMap[fileID].push(view)
            const lastMatched = this.getLastMatchedViewByFileID(fileID)
            if (view.whiteboardID === lastMatched.whiteboardID) {
              return this.addAttrToView(view)
            }
            return null
          }

          return this.addAttrToView(view)
        })
        .filter(x => x)
      this.excelSheetsMap = excelSheetsMap
      console.warn('excelSheetsMap',excelSheetsMap)
      this.WBViewList = viewList
      return viewList
    },

    /**
     * @desc:白板列表里默认展示第一个sheet 
     * @param {文件id} fileID
     * @return {匹配得到的第一个文件} lastMatched
     */    
    getLastMatchedViewByFileID(fileID) {
      let lastMatched
      for (let i = this.originWBViewList.length - 1; i >= 0; i--) {
        if (this.originWBViewList[i].getFileInfo()?.fileID === fileID) {
          lastMatched = this.originWBViewList[i]
          break
        }
      }
      return lastMatched
    },

    /**
     * @desc: 给每一个view对象添加name属性
     * @param {白板实例} view
     */    
    addAttrToView(view) {
      return Object.assign(view, {
        name: this.getViewName(view)
      })
    },

    /**
     * @desc: 获取该view实例的name
     * @param {白板实例} view
     */    
    getViewName(view) {
      return view.getName()
    },

    /**
     * @desc: 更新当前页码，起始是1
     * @param {需要更新页码} page
     */    
    updateCurrPage(page) {
      this.currPage = page || this.activeWBView?.getCurrentPage() || 1
    },
    
    /**
     * @desc: 设置是否发送房间附加信息，本演示项目中房间附加信息一般用来通知对端文件或白板的更新，默认1001
     * @param {是否发送} val
     */    
    setIsAllowSendRoomExtraInfo(val) {
      this.isAllowSendRoomExtraInfo = val
    },

    /**
     * @desc: 通过房间附加信息通知对端通过接收1001可靠消息获得当前激活白板id 
     */    
    async notifyAllViewChanged() {
      if (!this.isAllowSendRoomExtraInfo) return
      this.liveClient.express('setRoomExtraInfo', '1001', this.activeWBId)
    },

    /**
     * @desc: 创建白板
     */    
    async createWhiteboard() {
      const checkResult = this.checkViewFileMaxLength('view')
      if (checkResult) return this.showToast(checkResult)
      // 创建配置参数
      const options = {
        roomID: this.roomID,
        pageCount: this.pageCount,
        aspectWidth: this.aspectWidth * this.pageCount,
        aspectHeight: this.aspectHeight,
        name: `${this.userName}创建的白板${this.WBNameIndex++}`
        // name:this.$t('wb.wb_created_by',{name:this.userName,index:this.WBNameIndex++})
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
        this.getViewList(false)
        this.updateActiveView(activeWBView)
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
     * @param {需检查的类型 view-普通白板 file-文件} type
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
        return this.$t('wb.wb_tip_exceed_max_number_wb')
      }

      if (type === 'file' && fileList.length >= 10) {
        return this.$t('wb.wb_tip_exceed_max_number_file')
      }
    },

    /**
     * @desc: 更新当前激活白板相关参数
     * @param {当前激活白板} activeWBView
     */    
    updateActiveView(activeWBView, flag = 1) {
      setTimeout(() => {
        this.$set(this, 'activeWBId', activeWBView.whiteboardID)
        this.$set(this, 'activeWBView', activeWBView)
        console.warn('更新activeWBId',this.activeWBId)
        // 每次切换文件/白板 关闭缩略图
        this.isThumbnailsVisible = false
        // 获取文件相关参数
        const fileInfo = activeWBView && activeWBView?.getFileInfo()
        this.activeViewIsPPTH5 = !!(fileInfo && fileInfo.fileType === 512)
        this.activeViewIsPDF = !!(fileInfo && fileInfo.fileType === 8)
        this.activeViewIsPPT = !!(fileInfo && fileInfo.fileType === 1)
        this.activeViewIsExcel = !!(fileInfo && fileInfo.fileType === 4)

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
          console.warn('这里执行了setToolType，值为null')
          activeWBView.setToolType(null)
        }

        this.updateCurrPage(undefined)
        this.totalPage = activeWBView?.getPageCount() || 1
        console.log('flag', flag)
        if(flag === 1) this.notifyAllViewChanged()
        // this.notifyAllViewChanged()
      }, 10);
    },

    /**
     * @desc: 收到1001可靠消息时，可能白板列表还未更新，所以白板列表中找不到激活的id时，用定时器不断进行尝试
     * @param {白板id} id
     */    
    async checkRemoteView(id) {
      console.warn('checkRemoteView 查询中', id)
      if (this.originWBViewList.find(item => item.whiteboardID === id)) {
        console.warn('查到目标白板，进入selectRemoteView')
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
     * @param {目标id} id
     */    
    async selectRemoteView(id, setSheetID = false) {
      console.warn('进入selectRemoteView',id)
      if (this.isCreating || !id) return
      console.warn('selectRemoteView', {originWBViewList: this.originWBViewList})
      const view = this.originWBViewList.find(v => id == v.whiteboardID)
      if (!view) {
        this.showToast('远端白板不存在，请尝试刷新重试')
        return
      }
      console.warn('selectRemoteView 查询到目标白板', view,view.whiteboardID)
      this.$set(this, 'activeWBView', view)
      this.$set(this, 'activeWBId', view.whiteboardID)
      const fileInfo = this.activeWBView && this.activeWBView.getFileInfo()
      this.$nextTick(() => {
        if (fileInfo) {
          if (fileInfo.fileType === 4) {
            this.isCreating = id
          }
          console.warn('加载文件白板')
          this.loadFileView(id, fileInfo, setSheetID)
        } else {
          this.loadNormalWhiteboard()
        }
      })

    },

    /**
     * @desc: 加载文件
     * @param {文件id} id
     * @param {文件信息} fileInfo
     * @param {是否设置sheet id} setSheetID
     * 加载文件白板就是先根据普通白板id去加载该白板再根据关联的文件信息进行创建和加载对应的文件
     */    
    async loadFileView(id, fileInfo, setSheetID = false) {
      console.warn('根据白板id，loadFileView',id)
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
      try {
        const res = await zgDocsView.loadFile(fileInfo.fileID, fileInfo.authKey)
        this.zgDocsView = zgDocsView
        this.testPPT(fileInfo.fileID)
        console.warn({zgDocsView: this.zgDocsView})
        // this.splitExcelSheetSuffixHandle(res)
        // this.updateExcelSheetNamesIdMap(res, fileInfo.fileID)
        // this.updateActiveView(this.activeWBView)
        this.$nextTick(() => {
          this.splitExcelSheetSuffixHandle(res)
          this.updateExcelSheetNamesIdMap(res, fileInfo.fileID)
          // this.updateActiveView(this.activeWBView)
          this.updateActiveView(this.activeWBView, 0)
        })
      } catch (e) {
        console.error(e)
        this.showToast(`${(e && e.message) || '网络错误'}，请刷新页面后重试`)
      }
      this.isCreating = false
    },


    /**
     * @desc: 加载普通白板
     */    
    async loadNormalWhiteboard() {
      this.isCreating = false
      await this.client.attachView(this.activeWBView, this.parentId)
      this.zgDocsView = null
      this.updateActiveView(this.activeWBView)
      // this.updateActiveView(this.activeWBView, 0)
    },

    testPPT(fileID) {
      const files = ['81XpTUhfhUAfjmgV', 'xaPB31CucBgvb_5I', 'B9woySjyMIDvJ8yz', 'MzmXyyPuU2OunOU8', 'WD7d2diBgFrQwi0P', 'i48rKR3HKnhbe6nu'];
      if (files.includes(fileID)) {
        this.zgDocsView.addDOMEventListener('click', () => {
          this.zgDocsView.previousStep();
        })
        this.zgDocsView.addDOMEventListener('mouseup', (e) => {
          e.button == 2 && this.zgDocsView.nextStep();
        })
        console.log('testPPT', fileID);
      }
    },

    /**
     * @desc: 创建文件
     * @param {文件id} fileID
     * @param {文件名} fileName
     */    
    async createFileView(fileID, fileName) {
      const originWBViewList = this.originWBViewList
      const matchedView = originWBViewList.find(item => {
        const fileInfo = item.getFileInfo() || {}
        return fileID === fileInfo.fileID
      })
      console.warn('matchedView',matchedView)
      if (matchedView) {
        return this.selectRemoteView(matchedView.whiteboardID)
      }

      this.isRemote = false
      const zgDocsView = this.docsClient.createView(this.parentId, '', fileName)
      try {
        const res = await zgDocsView.loadFile(fileID, '')
        // 处理Excel文件中每个sheet的文件后缀
        this.splitExcelSheetSuffixHandle(res)
        // 获得当前打开Excel每个sheet的名字
        this.updateExcelSheetNamesIdMap(res, fileID)
        this.zgDocsView = zgDocsView
        this.testPPT(fileID)
      } catch (e) {
        console.error(e)
        this.showToast(`${(e && e.message) || '网络错误'}，请刷新页面后重试`)
      }
    },

    /**
     * @desc: 在创建了文件执行完loadFile之后会触发回调，需在回调中配合创建文件白板
     * @param {创建文件之后得到的相关文件参数} res
     */    
    async createFileWBView(res) {
      console.warn('执行 createFileWBView，创建文件白板')
      // 创建Excel文件白板
      const isRemoteNoHasExcelFile =
        res.fileType === 4 && !this.originWBViewList.find(x => res.name === x.getName())

      if (isRemoteNoHasExcelFile) {
        await this.createExcelSheetView(res)
        return
      }

      let activeWBView = this.activeWBView
      // let isRemote = this.originWBViewList.find(x => res.fileID === x.selfWBID)
      // console.warn('createFileWBView',isRemote)
      // 创建普通文件白板
      if (!this.isRemote) {
        console.warn('本地维护的白板列表无此白板，开始根据文件信息创建对应白板')
        try {
          activeWBView = await this.client.createView({
            roomID: this.roomID,
            name: res.fileName || `file-${res.fileID}`,
            aspectWidth: res.width,
            aspectHeight: res.height,
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
      }else{
        console.warn('服务器有此白板')
      }

      const fileInfo = activeWBView?.getFileInfo() || {}
      const fileID = fileInfo.fileID
      // 如果是Excel文件，则将当前激活白板id通过文件id保存在activeExcelSheetsIdMap
      if (fileInfo.fileType === 4) {
        this.activeExcelSheetsIdMap[fileID] = activeWBView.whiteboardID
      }
      await this.client.attachView(activeWBView, res.viewID)
      await this.getViewList(false)
      this.updateActiveView(activeWBView)
    },

    /**
     * @desc: 给每一个sheet创建对应的普通白板
     * @param {创建文件回调返回的相关参数} res
     */    
    async createExcelSheetView(res) {
      console.warn('createExcelSheetView')
      const { sheets } = res
      let activeWBView = this.activeWBView
      if (!this.isRemote) {
        const sheetsPromiseFuncs = sheets.map((sheetName) => {
        return async () => {
          return await this.client.createView({
            roomID: this.roomID,
            name: res.name,
            aspectWidth: this.aspectWidth,
            aspectHeight: this.aspectHeight,
            pageCount: res.pageCount,
            fileInfo: {
              fileID: res.fileID,
              fileName: sheetName,
              authKey: res.authKey,
              fileType: res.fileType
            }
          });
        };
      });

        try {
          const views = await Promise.all(
            sheetsPromiseFuncs.map((x) => x())
          );
          activeWBView = views[0];
          this.originWBViewList = [...views, ...this.originWBViewList];
        } catch (error) {
          console.log(error);
          const { code } = error;
          if (code === ErrorHandle.timeout) {
            this.showToast("请求超时");
          } else {
            this.showToast("共享失败");
          }
        }
      }
      const fileID = activeWBView?.getFileInfo()?.fileID
      this.activeExcelSheetsIdMap[fileID] = activeWBView.whiteboardID
      await this.client.attachView(activeWBView, res.viewID)
      await this.getViewList(false)
      this.updateActiveView(activeWBView)
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
     * @param {创建文件之后返回的相关文件参数} res
     * @return {文件id} fileID
     */    
    updateExcelSheetNamesIdMap(res, fileID) {
      console.warn('updateExcelSheetNamesIdMap res',res)
      if (res.fileType === 4 && !this.excelSheetNamesIdMap[fileID]) {
        this.excelSheetNamesIdMap[fileID] = res.file_list.map(file => file.file_name)
        console.warn('this.excelSheetNamesIdMap',this.excelSheetNamesIdMap)
      }
    },

    /**
     * @desc: 销毁白板
     * @param {需要销毁的白板对象} whiteboardView
     */    
    async destroyView(whiteboardView) {
      const fileInfo = whiteboardView.getFileInfo() || {}
      const activeFileInfo = this.activeWBView.getFileInfo() || {}

      // 缩略图展示的文件
      const isShowThumbnails =
        activeFileInfo.fileType === 1 ||
        activeFileInfo.fileType === 8 ||
        activeFileInfo.fileType === 512

      // 判断销毁的白板是否是当前使用的白板
      const isDestroyActiveView = fileInfo.fileName === activeFileInfo.fileName

      // 如果是销毁当前激活文件白板关闭缩略图，否则维持原状
      if (isShowThumbnails && isDestroyActiveView) {
        this.isThumbnailsVisible = false
      }

      if (fileInfo && fileInfo.fileType === 4) {
        this.WBViewList = this.WBViewList.filter(
          x => x.whiteboardID && x.whiteboardID !== whiteboardView.whiteboardID
        )
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
          this.originWBViewList = this.originWBViewList.filter(
            x => x.whiteboardID !== whiteboardView.whiteboardID
          )
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
        (whiteboardView.whiteboardID === this.activeWBId ||
          fileInfo.fileID === activeFileInfo.fileID) &&
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
      setTimeout(() => {
        this.activeWBView.setBrushColor(this.activeColor)
        this.setBrushSize(this.activeBrushSize)
        this.setTextSize(this.activeTextSize)
      }, 10);
    },

    /**
     * @desc: 重置当前激活文字类型的笔变量
     */    
    resetActiveTextPencil() {
      this.activeTextPencil = ''
    },
    /**
     * @desc: 设置工具类型变量
     * @param {工具类型} type
     */    
    setActiveToolType(type) {
      this.activeToolType = type
    },
    /**
     * @desc: 删除选中图元
     */    
    deleteSelectedGraphics() {
      this.activeWBView.deleteSelectedGraphics()
    },

    /**
     * @desc: 设置文本类型笔变量
     * @param {*} type
     */    
    setActiveTextPencil(type) {
      this.activeTextPencil = type
    },
    /**
     * @desc: 设置当前文件类型
     * @param {*} type
     */    
    setActivePopperType(type) {
      this.activePopperType = type
    },
    /**
     * @desc: 设置画笔颜色变量
     * @param {颜色} val
     */    
    setActiveColor(val) {
      this.activeColor = val
    },
    /**
     * @desc: 设置画笔粗细值变量
     * @param {画笔粗细，取值1~100} val
     */    
    setActiveBrushSize(val) {
      this.activeBrushSize = val
    },
    /**
     * @desc: 设置文本大小变量
     * @param {文本大小，取值12~100} val
     */    
    setActiveTextSize(val) {
      this.activeTextSize = val
    },
    /**
     * @desc: 设置白板背景色
     * @param {val支持16进制、rgba，参数类型：string} val
     */    
    setBackgroundColor(val) {
      this.activeWBView && this.activeWBView.setBackgroundColor(val)
    },
    /**
     * @desc: 设置画笔颜色
     * @param {val支持16进制、rgba，参数类型：string} val
     */    
    setBrushColor(val) {
      this.activeWBView && this.activeWBView.setBrushColor(val)
      this.activeColor = val
    },
    /**
     * @desc: 设置画笔粗细
     * @param {画笔粗细，取值1~100，参数类型：number} val
     */    
    setBrushSize(val) {
      this.activeWBView && this.activeWBView.setBrushSize(val)
      this.activeBrushSize = val
    },
    /**
     * @desc: 设置文本大小
     * @param {文本大小，取值12~100，参数类型：number} val
     */    
    setTextSize(val) {
      this.activeWBView && this.activeWBView.setTextSize(val)
      this.activeTextSize = val
    },
    /**
     * @desc: 设置字体样式-粗体，斜体
     * @param {设置样式类型：1粗体，2斜体，参数类型：string} type
     * @param {设置样式状态，参数类型：boolean} state
     */    
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

    /**
     * @desc: 设置白板缩放
     * @param {缩放倍数，不小于1，参数类型：number} zoom
     * @return {*}
     */    
    selectViewZoom(zoom) {
      this.zoom = zoom
      const _zoom = +zoom / 100
      if (this.activeWBView) {
        this.activeWBView.setScaleFactor(_zoom)
        if (this.activeToolType === 0) {
          console.warn('这里执行了setToolType，值为null')
          this.activeWBView.setToolType(null)
        }
      }
    },

    setZoom(num) {
      this.zoom = num * 100
    },

    /**
     * @desc: 上一步
     * 注意：仅针对动态PPT ZegoDocsViewFileTypeDynamicPPTH5 类型操作
     */    
    previousStep() {
      this.zgDocsView && this.zgDocsView.previousStep()
    },
     /**
     * @desc: 下一步
     * 注意：仅针对动态PPT ZegoDocsViewFileTypeDynamicPPTH5 类型操作
     */ 
    nextStep() {
      this.zgDocsView && this.zgDocsView.nextStep()
    },

    /**
     * @desc: 翻页
     * @param {page} 希望滚动到的页码
     * 注意：
     *  Q:为什么白板不支持页的概念？
     *  A:滚动比例更加灵活，可以适应各种场景，方便和文件联动。
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
     * @param {val，参数类型:boolean} 状态
     */    
    setThumbnailsVisible(val) {
      this.isThumbnailsVisible = val
    },

    /**
     * @desc: 获取当前文件缩略图列表，仅支持PDF，PPT，动态PPT 文件格式，可在文件加载成功后调用
     * @retrn {文件缩略图URL数组}
     */    
    getThumbnailUrlList() {
      if (this.zgDocsView) {
        this.thumbnailsImg = this.zgDocsView.getThumbnailUrlList()
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
     * @param {是否从服务器拉取新的数据}isPullNew
     */    
    async reUpdateWBList(isPullNew = true) {
      console.warn('进入 reUpdateWBList')
      this.isThumbnailsVisible = false
      await this.getViewList(isPullNew)
      if (!this.WBViewList.length) {
        await this.createWhiteboard()
        return
      }
      console.warn('重连网络白板列表:',this.originWBViewList)
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
      const zgDocsView = this.docsClient.createView(
        this.parentId,
        id,
        isExcelFile ? fileInfo.fileName : ''
      )
      try {
        const res = await zgDocsView.loadFile(fileInfo.fileID, fileInfo.authKey)
        this.splitExcelSheetSuffixHandle(res)
        this.updateExcelSheetNamesIdMap(res, fileInfo.fileID)
        this.zgDocsView = zgDocsView
        this.testPPT(fileInfo.fileID)
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
    },
    
    /**
     * @desc: 修改矩形类型变量
     * @param {类型} type
     */    
    setGraphType(type){
      this.graphType = type
    },

    /**
     * @desc: 上传文件
     * @param {文件} file
     * @param {fileType} 上传文件类型
     */ 
    uploadFile(file, fileType){
      try {
        this.docsClient.uploadFile(file, fileType)
      } catch (error) {
        console.log(error);
      }
    },
    /**
     * 当多于两个用户同时共享同一份文件，根据白板创建时间来判断渲染当白板
     */
    checkWBCreateTime(arr){
      console.warn('checkWBCreateTime',arr)
      let obj = {};
      let peon = arr.reduce((cur, next) => {
        console.warn(11111,next.getFileInfo()?.fileID || next.getID(),next.getCreateTime())
        obj[next.getFileInfo()?.fileID || next.getID()] ? "" : obj[next.getFileInfo()?.fileID || next.getID()] = true && cur.push(next);
        var repeatNum = obj[next.getFileInfo()?.fileID || next.getID()]
        if (next.getCreateTime() < cur[repeatNum - 1].getCreateTime()) {
          console.warn(next.getID(),next.getCreateTime())
          cur[repeatNum - 1] = next
        } 
        return cur;
      }, [])
      console.log(peon);
      return peon
    },
    /**
     * @desc: 根据属性删除数组指定元素
     * @param {数组} arr
     * @param {属性} attr
     * @param {属性值} value
     */    
    removeByFileID(arr, value) {
      console.warn('removeByValue - arr, value',arr, value)
      // var index=0;
      // for(var i in arr){
      //     if(arr[i][attr]==value){
      //         index=i;
      //         break;
      //     }
      // }
      // arr.splice(index,1);
      // console.warn('removeByValue',arr)
      for (var i = arr.length - 1; i >= 0; --i) {
        if (arr[i].getFileInfo()?.fileID == value) {
            arr.splice(i,1);
        }
      }
      console.warn('addview 处理之后的arr', arr)
    },
    
    /**
     * @desc: 上传文件错误码转译
     * @param {错误码} code
     * @return {*}
     */    
    translateUploadFileCode(code){
      console.warn('文件上传错误码：',code)
      if(!code) return;
      switch (code) {
        case 2010001:
          this.$message(this.$t('doc.doc_file_not_found'))
          break;
        case 2010002:
          this.$message(this.$t('doc.doc_uploading_failed'))
          break;
        case 2020003:
          this.$message(this.$t('doc.doc_file_not_supported'))
          break;
        case 2020004:
          this.$message(this.$t('doc.doc_converting_failed'))
          break;
        case 2020001:
          this.$message(this.$t('doc.doc_file_not_supported'))
          break;
        case 2020002:
          this.$message(this.$t('doc.doc_uploading_size_limit'))
          break;
        case 2020006:
          this.$message(this.$t('doc.doc_file_empty'))
          break;
        default:
          this.$message(this.$t('doc.doc_uploading_failed'))
          break;
      }
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
