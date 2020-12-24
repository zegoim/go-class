package im.zego.goclass.widget

import android.content.Context
import android.util.AttributeSet
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.PopupWindow
import android.widget.ScrollView
import androidx.core.content.ContextCompat
import androidx.core.view.children
import im.zego.goclass.DemoApplication
import im.zego.zegowhiteboard.ZegoWhiteboardConstants
import im.zego.zegowhiteboard.ZegoWhiteboardManager
import im.zego.zegowhiteboard.ZegoWhiteboardView
import im.zego.goclass.R
import im.zego.goclass.classroom.ClassRoomManager
import kotlinx.android.synthetic.main.layout_whiteboard_tools_view.view.*

class WhiteboardToolsView : ScrollView {
    private var onClickSelect: (selected: Boolean) -> Unit = {}
    private var onSelectSelect: () -> Unit = {}
    private var onDragSelect: () -> Unit = {}
    private var onBrushSelect: () -> Unit = {}
    private var onTextClick: () -> Unit = {}
    private var onRectangleSelect: () -> Unit = {}
    private var onEllipseSelect: () -> Unit = {}
    private var onEraserSelect: () -> Unit = {}
    private var onLineSelect: () -> Unit = {}
    private var onStyleClick: (PopupWindow) -> Unit = {}
    private var onClearClick: () -> Unit = {}
    private var onUndoClick: () -> Unit = {}
    private var onRedoClick: () -> Unit = {}

    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet) : super(context, attrs)
    constructor(context: Context, attrs: AttributeSet, defStyleAttr: Int)
            : super(context, attrs, defStyleAttr)


    var zegoWhiteboardViewHolder: ZegoWhiteboardViewHolder? = null
    var zegoWhiteboardView: ZegoWhiteboardView? = null
    
    private var shapePopupWindow = ToolShapePopupWindow(context)

    var lastTextClickedTime: Long = 0

    init {
        LayoutInflater.from(context).inflate(R.layout.layout_whiteboard_tools_view, this).apply {

            click.setOnTouchListener { v, event ->
                // 如果当前展示为非动态 PPT 则该工具无法点击
                !zegoWhiteboardViewHolder!!.isDynamicPPT()
            }

            click.setOnClickListener {

                val selected = unSelectOtherChild(it)
                if (!selected) {
                    zegoWhiteboardViewHolder?.setDocsScaleEnable(false)
                    ZegoWhiteboardManager.getInstance().toolType =
                        ZegoWhiteboardConstants.ZegoWhiteboardViewToolClick
                    shapePopupWindow.selectNone()
                }
            }

            select.setOnClickListener {
                val selected = unSelectOtherChild(it)
                if (!selected) {
                    onSelectSelect.invoke()
                    ZegoWhiteboardManager.getInstance().toolType =
                        ZegoWhiteboardConstants.ZegoWhiteboardViewToolSelector
                    shapePopupWindow.selectNone()
                }
            }

            drag.setOnClickListener {
                if (zegoWhiteboardViewHolder != null) {
                    val selected = unSelectOtherChild(it)
                    if (!selected) {
                        onDragSelect.invoke()
                        shapePopupWindow.selectNone()
                    }
                    ZegoWhiteboardManager.getInstance().toolType =
                        ZegoWhiteboardConstants.ZegoWhiteboardViewToolNone
                }
            }

            brush.setOnClickListener {
                val selected = unSelectOtherChild(it)
                if (!selected) {
                    onBrushSelect.invoke()
                    shapePopupWindow.selectNone()
                    ZegoWhiteboardManager.getInstance().toolType =
                        ZegoWhiteboardConstants.ZegoWhiteboardViewToolPen
                }
            }

            laser.setOnClickListener {
                val selected = unSelectOtherChild(it)
                if (!selected) {
                    shapePopupWindow.selectNone()
                    ZegoWhiteboardManager.getInstance().toolType =
                        ZegoWhiteboardConstants.ZegoWhiteboardViewToolLaser
                }
            }

            text.setOnClickListener {
                val currentTime = System.currentTimeMillis()
                if (currentTime - lastTextClickedTime > 1000) {
                    onTextClick.invoke()
                    zegoWhiteboardView?.addTextEdit(context)
                    zegoWhiteboardViewHolder?.addTextEdit()

                    unSelectOtherChild(select)
                    onSelectSelect.invoke()
                    ZegoWhiteboardManager.getInstance().toolType =
                        ZegoWhiteboardConstants.ZegoWhiteboardViewToolSelector
                    lastTextClickedTime = currentTime
                }
            }
            eraser.setOnClickListener {
                val selected = unSelectOtherChild(it)
                if (!selected) {
                    shapePopupWindow.selectNone()
                    onEraserSelect.invoke()
                    ZegoWhiteboardManager.getInstance().toolType =
                        ZegoWhiteboardConstants.ZegoWhiteboardViewToolEraser
                }
                zegoWhiteboardView?.deleteSelectedGraphics()
                zegoWhiteboardViewHolder?.deleteSelectedGraphics()

            }

            style.setOnClickListener {
                val popWindow = ToolStylePopWindow(context)
                it.isActivated = true
                popWindow.show(this)
                popWindow.setOnDismissListener{
                    style.isActivated = false
                }
                onStyleClick.invoke(popWindow)
            }
            clear.setOnClickListener {
                onClearClick.invoke()
                zegoWhiteboardView?.clear()
                zegoWhiteboardViewHolder?.clear()
            }
            undo.setOnClickListener {
                onUndoClick.invoke()
                zegoWhiteboardView?.undo()
                zegoWhiteboardViewHolder?.undo()
            }
            redo.setOnClickListener {
                onRedoClick.invoke()
                zegoWhiteboardView?.redo()
                zegoWhiteboardViewHolder?.redo()
            }

            save_image.setOnClickListener {
                zegoWhiteboardViewHolder?.saveImage()
            }

            if (DemoApplication.isFinal()) {
                clear_cur_page.visibility = View.GONE
            } else {
                clear_cur_page.visibility = View.VISIBLE
                clear_cur_page.setOnClickListener {
                    zegoWhiteboardViewHolder?.clearCurrentPage()
                }
            }

            shapePopupWindow.shapeSelectListener = object : ToolShapePopupWindow.ShapeSelectListener {
                override fun onShapeSelected(curShape: Int) {
                    when (curShape) {
                        ToolShapePopupWindow.SHAPE_NONE -> {
                            shape.isSelected = false
                        }
                        ToolShapePopupWindow.SHAPE_RECTANGLE -> {
                            unSelectOtherChild(shape)
                            ZegoWhiteboardManager.getInstance().toolType =
                                ZegoWhiteboardConstants.ZegoWhiteboardViewToolRect
                        }
                        ToolShapePopupWindow.SHAPE_OVAL -> {
                            unSelectOtherChild(shape)
                            ZegoWhiteboardManager.getInstance().toolType =
                                ZegoWhiteboardConstants.ZegoWhiteboardViewToolEllipse
                        }
                        ToolShapePopupWindow.SHAPE_LINE -> {
                            unSelectOtherChild(shape)
                            ZegoWhiteboardManager.getInstance().toolType =
                                ZegoWhiteboardConstants.ZegoWhiteboardViewToolLine
                        }
                        else -> {
                            shape.isSelected = false
                        }
                    }
                }
            }
            
            shape.setOnClickListener {
                if (!shapePopupWindow.isShowing) {
                    shapePopupWindow.show(it)
                }
            }

        }

        initTools()
    }

    /**
     * 若选中点击工具，切换到其他非动态 PPT 格式，如静态 ppt、pdf、doc、docx 等
     * 则默认选中画笔工具
     */
    fun selectDefaultChild() {
        unSelectOtherChild(brush)
        onBrushSelect.invoke()
        ZegoWhiteboardManager.getInstance().toolType =
            ZegoWhiteboardConstants.ZegoWhiteboardViewToolPen
    }

    fun initTools() {
        unSelectOtherChild(brush)
        ZegoWhiteboardManager.getInstance().toolType =
            ZegoWhiteboardConstants.ZegoWhiteboardViewToolPen
        ZegoWhiteboardManager.getInstance().brushColor =
            ContextCompat.getColor(context, R.color.default_color)
        ZegoWhiteboardManager.getInstance().brushSize = 6
        ZegoWhiteboardManager.getInstance().fontSize = 24
        ZegoWhiteboardManager.getInstance().isFontBold = false
        ZegoWhiteboardManager.getInstance().isFontItalic = false
    }

    private val TAG = "WhiteboardToolsView"
    override fun setVisibility(visibility: Int) {
        Log.d(TAG, "setVisibility() called with: visibility = $visibility")
        super.setVisibility(visibility)
    }

    /**
     * 返回当前控件的状态，设置为选中，并且取消选中其他控件
     */
    private fun unSelectOtherChild(it: View): Boolean {
        val directChild = getChildAt(0) as ViewGroup
        val selected = it.isSelected
        directChild.children.forEach { child ->
            child.isSelected = false
        }
        it.isSelected = true

        if (it == drag) {
            if (ClassRoomManager.me().sharable) {
                zegoWhiteboardViewHolder?.setUserOperationMode(
                    ZegoWhiteboardConstants.ZegoWhiteboardOperationModeZoom
                            or ZegoWhiteboardConstants.ZegoWhiteboardOperationModeScroll
                )
            } else {
                zegoWhiteboardViewHolder?.setUserOperationMode(
                    ZegoWhiteboardConstants.ZegoWhiteboardOperationModeZoom
                )
            }
        } else {
            if (ClassRoomManager.me().sharable) {
                zegoWhiteboardViewHolder?.setUserOperationMode(
                    ZegoWhiteboardConstants.ZegoWhiteboardOperationModeDraw
                            or ZegoWhiteboardConstants.ZegoWhiteboardOperationModeZoom
                            or ZegoWhiteboardConstants.ZegoWhiteboardOperationModeScroll
                )
            } else {
                zegoWhiteboardViewHolder?.setUserOperationMode(
                    ZegoWhiteboardConstants.ZegoWhiteboardOperationModeZoom
                )
            }
        }

        if (it == click) {
            zegoWhiteboardViewHolder?.setDocsScaleEnable(true)
        }
        return selected
    }

    fun onClickSelected(onClickSelect: (selected: Boolean) -> Unit) {
        this.onClickSelect = onClickSelect
    }

    fun onSelectSelected(onSelectSelect: () -> Unit) {
        this.onSelectSelect = onSelectSelect
    }

    fun onDragSelected(onDragSelect: () -> Unit) {
        this.onDragSelect = onDragSelect
    }

    fun onBrushSelected(onBrushSelect: () -> Unit) {
        this.onBrushSelect = onBrushSelect
    }

    fun onTextClicked(onTextClick: () -> Unit) {
        this.onTextClick = onTextClick
    }

    fun onRectangleSelected(onRectangleSelect: () -> Unit) {
        this.onRectangleSelect = onRectangleSelect
    }

    fun onEllipseSelected(onEllipseSelect: () -> Unit) {
        this.onEllipseSelect = onEllipseSelect
    }

    fun onEraserSelected(onEraserSelect: () -> Unit) {
        this.onEraserSelect = onEraserSelect
    }

    fun onLineSelected(onLineSelect: () -> Unit) {
        this.onLineSelect = onLineSelect
    }

    fun onStyleClicked(onStyleClick: (PopupWindow) -> Unit) {
        this.onStyleClick = onStyleClick
    }

    fun onClearClicked(onClearClick: () -> Unit) {
        this.onClearClick = onClearClick
    }

    fun onUndoClicked(onUndoClick: () -> Unit) {
        this.onUndoClick = onUndoClick
    }

    fun onRedoClicked(onRedoClick: () -> Unit) {
        this.onRedoClick = onRedoClick
    }

    fun isDragSelected(): Boolean {
        return drag.isSelected
    }

    fun isClickSelected(): Boolean {
        return click.isSelected
    }

    fun attachZegoWhiteboardHolderView(whiteboardViewHolder: ZegoWhiteboardViewHolder?) {
        this.zegoWhiteboardViewHolder = whiteboardViewHolder
        if (whiteboardViewHolder != null) {
            whiteboardViewHolder.toolsView = this
            Log.i(
                "TAG",
                "attach ,fileName:${whiteboardViewHolder.getCurrentWhiteboardModel().fileInfo.fileName}"
            )
            if (drag.isSelected) {
//                zegoWhiteboardView?.setCanDraw(false)
                zegoWhiteboardViewHolder?.setCanDraw(false)
            } else {
//                zegoWhiteboardView?.setCanDraw(true)
                zegoWhiteboardViewHolder?.setCanDraw(true)
            }
        }
    }

    fun onWhiteboardChanged() {
        zegoWhiteboardViewHolder?.let {
            if (!it.isDynamicPPT() && isClickSelected()) {
                selectDefaultChild()
            }
        }
    }
    
}