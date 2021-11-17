package im.zego.goclass.widget

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.RectF
import android.net.Uri
import android.util.AttributeSet
import android.util.Log
import android.util.Size
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.core.app.ActivityCompat
import androidx.fragment.app.FragmentActivity
import im.zego.goclass.CONFERENCE_ID
import im.zego.goclass.R
import im.zego.goclass.classroom.ClassRoomManager
import im.zego.goclass.sdk.ZegoSDKManager
import im.zego.goclass.tool.PermissionHelper
import im.zego.goclass.tool.ToastUtils
import im.zego.goclass.upload.FileUtil
import im.zego.zegodocs.*
import im.zego.zegowhiteboard.ZegoWhiteboardConstants
import im.zego.zegowhiteboard.ZegoWhiteboardManager
import im.zego.zegowhiteboard.ZegoWhiteboardView
import im.zego.zegowhiteboard.callback.IZegoWhiteboardViewScaleListener
import im.zego.zegowhiteboard.callback.IZegoWhiteboardViewScrollListener
import im.zego.zegowhiteboard.model.ZegoWhiteboardViewModel
import kotlin.math.round

/**
 * 白板和文件展示的容器,封装了一些常用的方法
 * 如果是excel，包含一个docsView和多个whiteboardView(每一个sheet创建一个白板)
 * 如果是纯白板，那就只有一个whiteboardView，没有docsView
 * 其他类型的文件，包含一个docsView和一个whiteboardView
 */
class ZegoWhiteboardViewHolder : FrameLayout {
    val TAG = "WhiteboardViewHolder"

    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet) : super(context, attrs)
    constructor(context: Context, attrs: AttributeSet, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    )

    /**
     * 如果是excel，包含多个whiteboardView(每一个sheet创建一个白板)
     * 如果是纯白板，那就只有一个whiteboardView
     * 其他类型的文件，包含一个whiteboardView
     *
     * 如果有docsvidw, 需要关注文件加载的结果
     */
    private var whiteboardViewList: MutableList<ZegoWhiteboardView> = mutableListOf()

    /**
     * 如果是纯白板，那就没有 zegoDocsView
     * 否则就会有一个 docsview ,
     * 如果有docsvidw, 需要关注文件加载的结果
     */
    private var zegoDocsView: ZegoDocsView? = null

    private var fileLoadSuccessed = false

    /**
     * 为了避免动态ppt文件滚动后调用白板滚动->触发文件对白板滚动对监听->再次滚动文件这样的循环，
     * 我们对动态ppt白板的滚动方法，成功则不再触发滚动回调，失败了才触发，然后调用文件接口进行回滚
     *
     */
    private var internalScrollListener: IZegoWhiteboardViewScrollListener =
        IZegoWhiteboardViewScrollListener { horizontalPercent, verticalPercent ->
            outScrollListener?.onScroll(horizontalPercent, verticalPercent)
        }
    private var outScrollListener: IZegoWhiteboardViewScrollListener? = null
    var toolsView: WhiteboardToolsView? = null

    /**
     * 当前显示的白板ID
     */
    var currentWhiteboardID = 0L
        set(value) {
            field = value
            Log.d(TAG, "set currentWhiteboardID:${value}")
            // 根据白板ID找到当前显示是哪个白板，列表是针对excel的情况
            var selectedView: ZegoWhiteboardView? = null
            whiteboardViewList.forEach {
                val viewModel = it.getWhiteboardViewModel()
                if (viewModel.whiteboardID == value) {
                    it.visibility = View.VISIBLE
                    selectedView = it
                } else {
                    it.visibility = View.GONE
                }
                Log.d(
                    TAG,
                    "whiteboardViewList: ${viewModel.whiteboardID}:${viewModel.fileInfo.fileName}"
                )
            }
            selectedView?.let {
                Log.d(TAG, "selectedView:${it.getWhiteboardViewModel().fileInfo.fileName}")
                val viewModel = it.getWhiteboardViewModel()
                // 假如是excel的一个白板，那么找出来是哪个sheet，找到后文件也要切换到对应的表格
                if (zegoDocsView != null && isExcel()) {
                    val fileName = viewModel.fileInfo.fileName
                    val sheetIndex = getExcelSheetNameList().indexOf(fileName)
                    zegoDocsView!!.switchSheet(sheetIndex, IZegoDocsViewLoadListener { loadResult ->
                        Log.d(TAG, "loadResult = $loadResult")
                        if (loadResult == 0) {
                            Log.i(
                                TAG, "switchSheet,sheetIndex:$sheetIndex," +
                                        "visibleSize:${zegoDocsView!!.getVisibleSize()}" +
                                        "contentSize:${zegoDocsView!!.getContentSize()}"
                            )
                            // 每个表格大小不一样，需要更新白板的宽高比
                            viewModel.aspectWidth = zegoDocsView!!.getContentSize().width
                            viewModel.aspectHeight = zegoDocsView!!.getContentSize().height
                            // 绑定一下
                            connectDocsViewAndWhiteboardView(it)
                            // 把白板的缩放系数也同步给文件
                            zegoDocsView!!.scaleDocsView(
                                it.getScaleFactor(),
                                it.getScaleOffsetX(),
                                it.getScaleOffsetY()
                            )
                        }
                    })
                }
            }
            enableUserOperation(ClassRoomManager.me().sharable)
            toolsView?.let {
                Log.i(TAG, "set currentWhiteboardID,setCanDraw:${!it.isDragSelected()}")
                this.setCanDraw(!it.isDragSelected())
            }
        }

    fun setDocsScaleEnable(enable: Boolean) {
        zegoDocsView?.setScaleEnable(enable)
    }

    private var currentWhiteboardView: ZegoWhiteboardView?
        private set(value) {}
        get() {
            return whiteboardViewList.firstOrNull {
                it.getWhiteboardViewModel().whiteboardID == currentWhiteboardID
            }
        }

    fun hasWhiteboardID(whiteboardID: Long): Boolean {
        val firstOrNull = whiteboardViewList.firstOrNull {
            it.getWhiteboardViewModel().whiteboardID == whiteboardID
        }
        return firstOrNull != null
    }

    fun getWhiteboardIDList(): List<Long> {
        return whiteboardViewList.map { it.getWhiteboardViewModel().whiteboardID }
    }

    fun isFileWhiteboard(): Boolean {
        return getFileID() != null
    }

    fun isPureWhiteboard(): Boolean {
        return getFileID() == null
    }

    fun getFileID(): String? {
        return when {
            zegoDocsView != null -> {
                zegoDocsView!!.getFileID()
            }
            whiteboardViewList.isNotEmpty() -> {
                val fileInfo = whiteboardViewList.first().getWhiteboardViewModel().fileInfo
                if (fileInfo.fileID.isEmpty()) return null else fileInfo.fileID
            }
            else -> {
                null
            }
        }
    }

    /**
     * 获取excle文件的sheet表名字
     */
    fun getExcelSheetNameList(): MutableList<String> {
        return if (isExcel() && isDocsViewLoadSuccessed()) {
            zegoDocsView!!.getSheetNameList()
        } else {
            mutableListOf()
        }
    }

    fun selectExcelSheet(sheetIndex: Int, selectResult: (Int, String) -> Unit) {
        if (sheetIndex < 0 || sheetIndex > getExcelSheetNameList().size - 1) {
            return
        }
        if (isExcel() && isDocsViewLoadSuccessed()) {
            val firstOrNull = whiteboardViewList.firstOrNull {
                it.getWhiteboardViewModel().fileInfo.fileName == getExcelSheetNameList()[sheetIndex]
            }
            firstOrNull?.let {
                val model = it.getWhiteboardViewModel()
                Log.i(TAG, "selectSheet,fileName：${model.fileInfo.fileName}，${model.whiteboardID}")
                val roomService = ZegoSDKManager.getInstance().roomService
                roomService.sendCurrentWhiteboardID(model.whiteboardID) { errorCode ->
                    if (errorCode == 0) {
                        currentWhiteboardID = roomService.currentWhiteboardID
                    }
                    selectResult.invoke(errorCode, model.fileInfo.fileName)
                }
            }
        }
    }

    fun isExcel(): Boolean {
        return getFileType() == ZegoDocsViewConstants.ZegoDocsViewFileTypeELS
    }

    fun isDisplayedByWebView(): Boolean {
        return getFileType() == ZegoDocsViewConstants.ZegoDocsViewFileTypeDynamicPPTH5 ||
                getFileType() == ZegoDocsViewConstants.ZegoDocsViewFileTypeCustomH5
    }

    fun isPPT(): Boolean {
        return getFileType() == ZegoDocsViewConstants.ZegoDocsViewFileTypePPT
    }

    fun getThumbnailUrlList(): ArrayList<String> {
        var urls = ArrayList<String>()
        if (zegoDocsView != null) {
            return zegoDocsView!!.thumbnailUrlList
        }
        return urls
    }


    fun getFileType(): Int {
        return when {
            zegoDocsView != null && isDocsViewLoadSuccessed() -> {
                zegoDocsView!!.getFileType()
            }
            whiteboardViewList.isNotEmpty() -> {
                // 任意一个白板，包含的是同样的 fileInfo
                whiteboardViewList.first().getWhiteboardViewModel().fileInfo.fileType
            }
            else -> {
                ZegoDocsViewConstants.ZegoDocsViewFileTypeUnknown
            }
        }
    }

    fun supportDragWhiteboard(): Boolean {
        return !(isPureWhiteboard() || isDisplayedByWebView() || isPPT())
    }

    fun getCurrentWhiteboardName(): String? {
        return getCurrentWhiteboardModel().name
    }

    fun getCurrentWhiteboardModel(): ZegoWhiteboardViewModel {
        return currentWhiteboardView!!.getWhiteboardViewModel()
    }

    fun getCurrentWhiteboardMsg(): String {
        return "modelMessage:name:${getCurrentWhiteboardModel().name},whiteboardID:${getCurrentWhiteboardModel().whiteboardID}," +
                "fileInfo:${getCurrentWhiteboardModel().fileInfo.fileName}" +
                "hori:${getCurrentWhiteboardModel().horizontalScrollPercent},vertical:${getCurrentWhiteboardModel().verticalScrollPercent}"
    }

    fun addTextEdit() {
        currentWhiteboardView?.addTextEdit { }
    }

    fun undo() {
        currentWhiteboardView?.undo()
    }

    fun redo() {
        currentWhiteboardView?.redo()
    }

    fun clearCurrentPage() {
        val curPageRectF = if (isPureWhiteboard()) {
            currentWhiteboardView?.let {
                val width = it.width.toFloat()
                val height = it.height.toFloat()
                val pageOffsetX = width * (getCurrentPage() - 1)
                val pageOffsetY = 0F

                RectF(
                    pageOffsetX,
                    pageOffsetY,
                    (pageOffsetX + width),
                    (pageOffsetY + height)
                )
            }

        } else {
            zegoDocsView!!.currentPageInfo!!.rect
        }

        Log.i(TAG, "clearCurrentPage: ${curPageRectF.toString()}")
        curPageRectF?.let {
            currentWhiteboardView?.clear(curPageRectF)
        }
    }

    fun saveImage() {
        PermissionHelper.onWriteSDCardPermissionGranted(context as FragmentActivity) { grant ->
            if (grant) {
                currentWhiteboardView?.whiteboardViewModel?.let {
//                    ToastUtils.showCenterToast(context.getString(R.string.start_save_image))
                    Log.i(TAG, "saveImage() start")
                    var name = it.name
                    // 去掉后缀名
                    if (name.contains(".")) {
                        name = name.substring(0, name.lastIndexOf("."))
                    }
                    FileUtil.saveImage(
                        name, this
                    ) { success ->
                        if (success) {
                            ToastUtils.showCenterToast(context.getString(R.string.wb_tip_save_success))
                        } else {
                            ToastUtils.showCenterToast(context.getString(R.string.wb_tip_fail_save))
                        }
                    }

                }
            } else {
                if (!ActivityCompat.shouldShowRequestPermissionRationale(
                        context as Activity,
                        Manifest.permission.READ_EXTERNAL_STORAGE
                    )
                ) {
                    ZegoDialog.Builder(context as Activity)
                        .setTitle(context.getString(R.string.wb_tip_unable_save))
                        .setMessage(context.getString(R.string.wb_tip_open_permission))
                        .setPositiveButton(context.getString(R.string.jump_to_settings)) { dialog, _ ->
                            dialog.dismiss()
                            val intent =
                                Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                            val uri: Uri = Uri.fromParts("package", context.packageName, null)
                            intent.data = uri
                            context.startActivity(intent)

                        }
                        .setNegativeButton(R.string.wb_cancel) { dialog, _ ->
                            dialog.dismiss()

                        }
                        .setNegativeButtonBackground(R.drawable.drawable_dialog_confirm2)
                        .setNegativeButtonTextColor(R.color.colorAccent)
                        .setButtonWidth(80)
                        .setMaxDialogWidth(320)
                        .create().showWithLengthLimit()

                }
            }
        }

    }

    fun setCanDraw(canDraw: Boolean) {
        if (canDraw) {
            if (ClassRoomManager.me().sharable) {
                currentWhiteboardView?.setWhiteboardOperationMode(
                    ZegoWhiteboardConstants.ZegoWhiteboardOperationModeDraw
                            or ZegoWhiteboardConstants.ZegoWhiteboardOperationModeZoom
                )
            } else {
                currentWhiteboardView?.setWhiteboardOperationMode(
                    ZegoWhiteboardConstants.ZegoWhiteboardOperationModeZoom
                )
            }
        } else {
            if (ClassRoomManager.me().sharable) {
                currentWhiteboardView?.setWhiteboardOperationMode(
                            ZegoWhiteboardConstants.ZegoWhiteboardOperationModeZoom
                            or ZegoWhiteboardConstants.ZegoWhiteboardOperationModeScroll
                )
            } else {
                currentWhiteboardView?.setWhiteboardOperationMode(
                    ZegoWhiteboardConstants.ZegoWhiteboardOperationModeZoom
                )
            }
        }
    }

    fun setUserOperationMode(mode: Int) {
        currentWhiteboardView?.setWhiteboardOperationMode(mode)
    }

    fun scrollTo(horizontalPercent: Float, verticalPercent: Float, currentStep: Int = 1) {
        Log.d(
            TAG,
            "scrollTo() called with: horizontalPercent = $horizontalPercent, verticalPercent = $verticalPercent, currentStep = $currentStep"
        )
        if (getFileID() != null) {
            if (isDocsViewLoadSuccessed()) {
                currentWhiteboardView?.scrollTo(horizontalPercent, verticalPercent, currentStep)
            }
        } else {
            currentWhiteboardView?.scrollTo(horizontalPercent, verticalPercent, currentStep)
        }
        internalScrollListener.onScroll(horizontalPercent, verticalPercent)
    }

    fun clear() {
        currentWhiteboardView?.clear()
    }

    private fun addDocsView(docsView: ZegoDocsView, estimatedSize: Size) {
        Log.d(TAG, "addDocsView, estimatedSize:$estimatedSize")
        docsView.setEstimatedSize(estimatedSize.width, estimatedSize.height)
        this.zegoDocsView = docsView
        addView(
            zegoDocsView, 0, ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        )
    }

    private fun addWhiteboardView(zegoWhiteboardView: ZegoWhiteboardView) {
        val model = zegoWhiteboardView.whiteboardViewModel
        Log.i(
            TAG, "addWhiteboardView:${model.whiteboardID},${model.name},${model.fileInfo.fileName}"
        )
        this.whiteboardViewList.add(zegoWhiteboardView)

        addView(
            zegoWhiteboardView,
            LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        )
    }

    private fun connectDocsViewAndWhiteboardView(zegoWhiteboardView: ZegoWhiteboardView) {
        Log.i(TAG, "connectDocsViewAndWhiteboardView...")
        zegoDocsView?.let { docsview ->
            // 同步docsview 的展示区域大小给白板
            if (docsview.getVisibleSize().height != 0 || docsview.getVisibleSize().width != 0) {
                zegoWhiteboardView.setVisibleRegion(zegoDocsView!!.getVisibleSize())
            }
            // docsview 监听白板的滚动
            zegoWhiteboardView.setScrollListener { horizontalPercent, verticalPercent ->
                Log.d(
                    TAG,
                    "ScrollListener.onScroll,horizontalPercent:${horizontalPercent},verticalPercent:${verticalPercent}"
                )
                if (isDisplayedByWebView()) {
                    val page = calcWebViewPage(verticalPercent)
                    val model = zegoWhiteboardView.whiteboardViewModel
                    val stepChanged = docsview.currentStep != model.pptStep
                    val pageChanged = docsview.currentPage != page
                    Log.i(
                        TAG,
                        "page:${page},step:${model.pptStep},stepChanged:$stepChanged,pageChanged:$pageChanged"
                    )
                    docsview.flipPage(page, model.pptStep) { result ->
                        Log.i(TAG, "docsview.flipPage() : result = $result")
                    }
                    internalScrollListener.onScroll(horizontalPercent, verticalPercent)
                } else {
                    docsview.scrollTo(verticalPercent) { complete ->
                        internalScrollListener.onScroll(0f, verticalPercent)
                    }
                }

            }

            if (isDisplayedByWebView()) {
                // 对于动态PPT和H5，白板监听docsview的动画回调，用来同步给房间里面的其他用户
                docsview.setAnimationListener(IZegoDocsViewAnimationListener {
                    if (windowVisibility == View.VISIBLE) {
                        zegoWhiteboardView.playAnimation(it)
                    }
                })
                // 对于动态PPT和H5，白板监听docsview的步骤回调，用来同步给房间里面的其他用户
                docsview.setStepChangeListener(object : IZegoDocsViewCurrentStepChangeListener {
                    override fun onChanged() {
                    }

                    override fun onStepChangeForClick() {
                        // 动态PPT，直接点击H5，触发翻页、步数变化
                        Log.d(TAG, "onStepChangeForClick() called")
                        scrollTo(0f, docsview.verticalPercent, docsview.currentStep)
                    }
                })
            }
            // 白板监听其他用户的动画回调，用来同步给自己的白板
            zegoWhiteboardView.setAnimationListener { animation ->
                Log.d(TAG, "setAnimationListener() called")
                docsview.playAnimation(animation)
            }
            // docsview监听白板的缩放回调，同步缩放
            zegoWhiteboardView.setScaleListener(IZegoWhiteboardViewScaleListener { scaleFactor, transX, transY ->
//            Log.d(TAG,"scaleFactor:$scaleFactor,transX:$transX,transY:$transY")
                docsview.scaleDocsView(scaleFactor, transX, transY)
            })
        }

        // 加载完后，根据model里面的数据更新docsview和whiteboardview
        post {
            val model = zegoWhiteboardView.whiteboardViewModel
            val horPercent = model.horizontalScrollPercent
            val verPercent = model.verticalScrollPercent
            val currentStep = model.pptStep
            Log.d(TAG, "horPercent:$horPercent,verPercent:$verPercent,currentStep:$currentStep")
            if (isDisplayedByWebView()) {
                // 此处是首次加载，要跳转到到文件对应页。完成后需要判断是否播动画
                zegoDocsView?.let {
                    val targetPage = calcWebViewPage(verPercent)
                    it.flipPage(targetPage, currentStep) { result ->
                        if (result) {
                            zegoWhiteboardView.whiteboardViewModel.h5Extra?.let { h5Extra ->
                                it.playAnimation(h5Extra)
                            }
                        }
                    }
                }
            } else {
                zegoDocsView?.scrollTo(verPercent, null)
            }
            // 假如白板已经滚过了，这时候额外通知外面更新当前状态（页码等）
            internalScrollListener.onScroll(horPercent, verPercent)
        }
    }

    fun calcWebViewPage(verticalPercent: Float): Int {
        return if (isDisplayedByWebView()) {
            if (isDocsViewLoadSuccessed()) {
                val page = round(verticalPercent * zegoDocsView!!.pageCount).toInt() + 1
                page
            } else {
                1
            }
        } else {
            throw IllegalArgumentException("only used for dynamic PPT")
        }
    }

    /**
     * 收到其他用户的创建纯白板消息
     */
    private fun onPureWhiteboardViewAdded(zegoWhiteboardView: ZegoWhiteboardView) {
        val model = zegoWhiteboardView.getWhiteboardViewModel()
        currentWhiteboardID = model.whiteboardID
        zegoWhiteboardView.setScrollListener(IZegoWhiteboardViewScrollListener { horizontalPercent, verticalPercent ->
            internalScrollListener.onScroll(horizontalPercent, verticalPercent)
        })
    }

    /**
     * 添加纯白板
     */
    fun onReceivePureWhiteboardView(zegoWhiteboardView: ZegoWhiteboardView) {
        zegoWhiteboardView.setBackgroundColor(Color.parseColor("#f4f5f8"))
        addWhiteboardView(zegoWhiteboardView)
        onPureWhiteboardViewAdded(zegoWhiteboardView)
    }

    /**
     * 创建纯白板并且同步给房间里其他用户，aspectWidth，aspectHeight:宽高比
     */
    fun createPureWhiteboardView(
        aspectWidth: Int, aspectHeight: Int, pageCount: Int,
        whiteboardName: String, requestResult: (Int) -> Unit
    ) {
        val data = ZegoWhiteboardViewModel()
        data.aspectHeight = aspectHeight
        data.aspectWidth = aspectWidth
        data.name = whiteboardName
        data.pageCount = pageCount
        data.roomId = CONFERENCE_ID
        ZegoWhiteboardManager.getInstance().createWhiteboardView(data)
        { errorCode, zegoWhiteboardView ->
            Log.d(
                TAG,
                "createPureWhiteboardView,name:${data.name},errorCode:${errorCode}"
            )
            if (errorCode == 0 && zegoWhiteboardView != null) {
                onReceivePureWhiteboardView(zegoWhiteboardView)
            } else {
                ToastUtils.showCenterToast(context.getString(R.string.wb_tip_failed_create_whiteboard, errorCode))
            }
            requestResult.invoke(errorCode)
        }
    }

    /**
     * 删除白板并且同步给房间里其他用户
     */
    fun destroyWhiteboardView(requestResult: (Int) -> Unit) {
        if (isExcel()) {
            var count = whiteboardViewList.size
            var success = true
            var code = 0
            whiteboardViewList.forEach {
                val whiteboardID = it.getWhiteboardViewModel().whiteboardID
                ZegoWhiteboardManager.getInstance().destroyWhiteboardView(whiteboardID)
                { errorCode, _ ->
                    //因为所有的回调都是在主线程，所以不用考虑多线程
                    count--
                    if (errorCode != 0) {
                        success = false
                        code = errorCode
                    }
                    if (count == 0) {
                        if (!success) {
                            ToastUtils.showCenterToast(context.getString(R.string.wb_tip_failed_delete_whiteboard, code))
                        } else {
                            zegoDocsView?.unloadFile()
                            fileLoadSuccessed = false
                        }
                        requestResult.invoke(errorCode)
                    }
                }
            }
        } else {
            ZegoWhiteboardManager.getInstance().destroyWhiteboardView(currentWhiteboardID)
            { errorCode, _ ->
                if (errorCode != 0) {
                    ToastUtils.showCenterToast(context.getString(R.string.wb_tip_failed_delete_whiteboard, errorCode))
                } else {
                    zegoDocsView?.unloadFile()
                    fileLoadSuccessed = false
                }
                requestResult.invoke(errorCode)
            }
        }
    }

    /**
     * 收到房间里其他用户创建的文件白板
     */
    fun onReceiveFileWhiteboard(
        estimatedSize: Size,
        zegoWhiteboardView: ZegoWhiteboardView,
        processResult: (Int, ZegoWhiteboardViewHolder) -> Unit
    ) {
        val fileInfo = zegoWhiteboardView.getWhiteboardViewModel().fileInfo
        Log.d(
            TAG,
            "onReceiveFileWhiteboard() called with: estimatedSize = $estimatedSize, zegoWhiteboardView = ${fileInfo.fileName}"
        )
        addWhiteboardView(zegoWhiteboardView)
        if (zegoDocsView != null) {
            zegoWhiteboardView.visibility = View.GONE
            processResult(0, this)
        } else {
            val fileID = fileInfo.fileID
            visibility = View.GONE
            currentWhiteboardID = zegoWhiteboardView.getWhiteboardViewModel().whiteboardID
            loadFileWhiteBoardView(fileID, estimatedSize) { errorCode: Int, _: ZegoDocsView ->
                if (errorCode == 0) {
                    if (isExcel()) { // excel要等到load完才设置，因为要switchSheet
                        currentWhiteboardID =
                            zegoWhiteboardView.getWhiteboardViewModel().whiteboardID
                    } else {
                        connectDocsViewAndWhiteboardView(zegoWhiteboardView)
                    }
                    processResult.invoke(errorCode, this)
                } else {
                    ToastUtils.showCenterToast(context.getString(R.string.wb_tip_failed_load_file, errorCode))
                    processResult.invoke(errorCode, this)
                    // 可以考虑给个界面按钮点击重试
                }
            }
        }
    }

    /**
     * 加载白板view
     */
    private fun loadFileWhiteBoardView(
        fileID: String,
        estimatedSize: Size,
        requestResult: (Int, ZegoDocsView) -> Unit
    ) {
        Log.i(
            TAG,
            "loadFileWhiteBoardView,start loadFile fileID:${fileID},estimatedSize:${estimatedSize}"
        )
        ZegoDocsView(context).let {
            addDocsView(it, estimatedSize)
            it.loadFile(fileID, "", IZegoDocsViewLoadListener { errorCode ->
                fileLoadSuccessed = errorCode == 0
                if (errorCode == 0) {
                    Log.i(
                        TAG,
                        "loadFileWhiteBoardView loadFile fileID:${fileID} success,getVisibleSize:${it.getVisibleSize()}," +
                                "contentSize:${it.getContentSize()}," + "name:${it.getFileName()}" +
                                "nameList:${it.getSheetNameList()}"
                    )
                } else {
                    Log.i(
                        TAG,
                        "loadFileWhiteBoardView loadFile fileID:${fileID} failed，errorCode：${errorCode}"
                    )
                }
                requestResult.invoke(errorCode, it)
            })
        }
    }

    /**
     * 创建文件白板并且同步给房间里的其他用户
     */
    fun createDocsAndWhiteBoardView(
        fileID: String, estimatedSize: Size, createResult: (Int) -> Unit
    ) {
        loadFileWhiteBoardView(fileID, estimatedSize)
        { errorCode, docsView ->
            if (errorCode == 0) {
                if (isExcel()) {
                    createExcelWhiteboardViewList(docsView, createResult)
                } else {
                    createWhiteBoardViewInner(docsView, 0, createResult)
                }
            } else {
                createResult(errorCode)
                ToastUtils.showCenterToast(context.getString(R.string.wb_tip_failed_load_file, errorCode))
            }
        }
    }

    fun isDocsViewLoadSuccessed(): Boolean {
        return fileLoadSuccessed
    }

    private fun createExcelWhiteboardViewList(
        docsView: ZegoDocsView,
        requestResult: (Int) -> Unit
    ) {
        val sheetCount = getExcelSheetNameList().size
        var processCount = 0
        var resultCode = 0
        for (index in 0 until sheetCount) {
            createWhiteBoardViewInner(docsView, index) { code ->
                if (code != 0) {
                    resultCode = code
                }
                processCount++
                if (processCount == sheetCount) {
                    selectExcelSheet(0) { errorCode, _ ->
                        if (errorCode == 0) {
                            requestResult.invoke(resultCode)
                        } else {
                            requestResult.invoke(errorCode)
                        }
                    }
                }
            }
        }
    }

    private fun createWhiteBoardViewInner(
        docsView: ZegoDocsView, index: Int,
        requestResult: (Int) -> Unit
    ) {
        val data = ZegoWhiteboardViewModel()
        data.aspectWidth = docsView.getContentSize().width
        data.aspectHeight = docsView.getContentSize().height
        data.name = docsView.getFileName()!!
        data.fileInfo.fileID = docsView.getFileID()!!
        data.fileInfo.fileType = docsView.getFileType()
        data.pageCount = docsView.pageCount
        if (isExcel()) {
            data.fileInfo.fileName = docsView.getSheetNameList()[index]
        }
        data.roomId = CONFERENCE_ID

        ZegoWhiteboardManager.getInstance().createWhiteboardView(data)
        { errorCode, zegoWhiteboardView ->
            Log.d(
                TAG,
                "createWhiteboardView,name:${data.name},fileName:${data.fileInfo.fileName}"
            )
            if (errorCode == 0 && zegoWhiteboardView != null) {
                addWhiteboardView(zegoWhiteboardView)
                if (!isExcel()) {
                    currentWhiteboardID =
                        zegoWhiteboardView.getWhiteboardViewModel().whiteboardID
                    connectDocsViewAndWhiteboardView(zegoWhiteboardView)
                }
            } else {
                ToastUtils.showCenterToast(context.getString(R.string.wb_tip_failed_create_whiteboard, errorCode))
            }
            requestResult.invoke(errorCode)
        }
    }

    /**
     * 跳转到某一页，从1开始
     */
    fun flipToPage(targetPage: Int) {
        Log.i(TAG, "targetPage:${targetPage}")
        if (zegoDocsView != null && getFileID() != null && isDocsViewLoadSuccessed()) {
            zegoDocsView!!.flipPage(targetPage) { result ->
                Log.i(TAG, "it.flipToPage() result:$result")
                if (result) {
                    scrollTo(0f, zegoDocsView!!.getVerticalPercent())
                }
            }
        } else {
            scrollTo((targetPage - 1).toFloat() / getPageCount(), 0f)
        }
    }

    /**
     * 上一页
     */
    fun flipToPrevPage(): Int {
        val currentPage = getCurrentPage()
        val targetPage = if (currentPage - 1 <= 0) 1 else currentPage - 1
        if (targetPage != currentPage) {
            flipToPage(targetPage)
        }
        return targetPage
    }

    /**
     * 下一页
     */
    fun flipToNextPage(): Int {
        val currentPage = getCurrentPage()
        val targetPage =
            if (currentPage + 1 > getPageCount()) getPageCount() else currentPage + 1
        if (targetPage != currentPage) {
            flipToPage(targetPage)
        }
        return targetPage
    }

    /**
     * 上一步
     */
    fun previousStep() {
        Log.d(TAG, "previousStep() called,fileLoadSuccessed:${isDocsViewLoadSuccessed()}")
        if (getFileID() != null && isDisplayedByWebView() && isDocsViewLoadSuccessed()) {
            zegoDocsView?.let {
                it.previousStep(IZegoDocsViewScrollCompleteListener { result ->
                    Log.d(TAG, "previousStep:result = $result")
                    if (result) {
                        scrollTo(0f, it.getVerticalPercent(), it.getCurrentStep())
                    }
                })
            }
        }
    }

    /**
     * 下一步
     */
    fun nextStep() {
        Log.i(TAG, "nextStep() called,fileLoadSuccessed:${isDocsViewLoadSuccessed()}")
        if (getFileID() != null && isDisplayedByWebView() && isDocsViewLoadSuccessed()) {
            zegoDocsView?.let {
                it.nextStep(IZegoDocsViewScrollCompleteListener { result ->
                    Log.i(TAG, "nextStep:result = $result")
                    if (result) {
                        scrollTo(0f, it.getVerticalPercent(), it.getCurrentStep())
                    }
                })
            }
        }
    }

    fun getPageCount(): Int {
        return if (getFileID() != null) {
            zegoDocsView!!.getPageCount()
        } else {
            getCurrentWhiteboardModel().pageCount
        }
    }

    /**
     * 第二页滚动到一半，才认为是第二页
     */
    fun getCurrentPage(): Int {
        return if (getFileID() != null) {
            zegoDocsView!!.getCurrentPage()
        } else {
            val percent = currentWhiteboardView!!.getHorizontalPercent()
            val currentPage = round(percent * getPageCount()).toInt() + 1
            Log.i(TAG, "getCurrentPage,percent:${percent},currentPage:${currentPage}")
            return if (currentPage < getPageCount()) currentPage else getPageCount()
        }
    }

    fun setWhiteboardScrollChangeListener(listener: IZegoWhiteboardViewScrollListener) {
        outScrollListener = listener
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        // 保底处理
        zegoDocsView?.unloadFile()
        fileLoadSuccessed = false
    }

    fun addText(text: String, positionX: Int, positionY: Int) {
        currentWhiteboardView?.addText(text, positionX, positionY){}
    }

    fun enableUserOperation(enable: Boolean) {
        if (enable) {
            currentWhiteboardView?.setWhiteboardOperationMode(
                ZegoWhiteboardConstants.ZegoWhiteboardOperationModeDraw
                        or ZegoWhiteboardConstants.ZegoWhiteboardOperationModeZoom
            )
        } else {
            currentWhiteboardView?.setWhiteboardOperationMode(ZegoWhiteboardConstants.ZegoWhiteboardOperationModeZoom)
        }
    }

    fun deleteSelectedGraphics() {
        currentWhiteboardView?.deleteSelectedGraphics(){}
    }

    /**
     * 停止当前正在播放的视频
     */
    fun stopPlayPPTVideo() {
        if (isDisplayedByWebView()) {
            zegoDocsView?.let {
                it.stopPlay(it.currentPage)
            }
        }
    }

    /**
     * size变化的时候调用一下更新白板的 VisibleRegion
     */
    fun reload() {
        if (zegoDocsView != null) {
            zegoDocsView?.reloadFile(IZegoDocsViewLoadListener { loadCode ->
                fileLoadSuccessed = loadCode == 0
                if (loadCode == 0) {
                    Log.d(TAG, "visibleRegion:${zegoDocsView!!.getVisibleSize()}")
                    currentWhiteboardView?.setVisibleRegion(zegoDocsView!!.visibleSize)
                }
            })
        }
    }
}