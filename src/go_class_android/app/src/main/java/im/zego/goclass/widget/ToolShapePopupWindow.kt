package im.zego.goclass.widget

import android.content.Context
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import im.zego.goclass.dp2px
import im.zego.goclass.R

class ToolShapePopupWindow(context: Context) : BasePopWindow(
    context,
    contentView = LayoutInflater.from(context).inflate(R.layout.popwindow_shape, null)
) {

    companion object {
        const val SHAPE_NONE = -1
        const val SHAPE_RECTANGLE = 0
        const val SHAPE_OVAL = 1
        const val SHAPE_LINE = 2
    }

    private var curSelectedShape = SHAPE_NONE
    private var rectangle: ImageView = contentView.findViewById(R.id.rectangle)
    private var oval: ImageView = contentView.findViewById(R.id.oval)
    private var line: ImageView = contentView.findViewById(R.id.line)

    var shapeSelectListener: ShapeSelectListener? = null

    init {
        rectangle.setOnClickListener {
            if (curSelectedShape != SHAPE_RECTANGLE) {
                curSelectedShape = SHAPE_RECTANGLE
                onCurShapeChanged()
            }
        }

        oval.setOnClickListener {
            if (curSelectedShape != SHAPE_OVAL) {
                curSelectedShape = SHAPE_OVAL
                onCurShapeChanged()
            }
        }

        line.setOnClickListener {
            if (curSelectedShape != SHAPE_LINE) {
                curSelectedShape = SHAPE_LINE
                onCurShapeChanged()
            }
        }

    }

    private fun onCurShapeChanged() {
        when (curSelectedShape) {
            SHAPE_NONE -> {
                rectangle.isSelected = false
                oval.isSelected = false
                line.isSelected = false
            }
            SHAPE_RECTANGLE -> {
                rectangle.isSelected = true
                oval.isSelected = false
                line.isSelected = false
            }
            SHAPE_OVAL -> {
                rectangle.isSelected = false
                oval.isSelected = true
                line.isSelected = false
            }
            SHAPE_LINE -> {
                rectangle.isSelected = false
                oval.isSelected = false
                line.isSelected = true
            }
            else -> {
                rectangle.isSelected = false
                oval.isSelected = false
                line.isSelected = false
            }
        }

        shapeSelectListener?.onShapeSelected(curSelectedShape)
    }

    fun show(anchor: View) {
        if (!isShowing) {
            show(anchor, Gravity.START, -dp2px(anchor.context, 2f).toInt(), 0)

            if (curSelectedShape == SHAPE_NONE) {
                curSelectedShape = SHAPE_RECTANGLE
                onCurShapeChanged()
            }
        }
    }

    fun selectNone() {
        if (curSelectedShape != SHAPE_NONE) {
            curSelectedShape = SHAPE_NONE
            onCurShapeChanged()
        }
    }


    interface ShapeSelectListener {
        fun onShapeSelected(curShape: Int)
    }


}