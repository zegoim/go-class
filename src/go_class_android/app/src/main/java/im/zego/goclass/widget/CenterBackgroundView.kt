package im.zego.goclass.widget

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import im.zego.goclass.classroom.ClassRoomManager
import im.zego.goclass.R
import kotlinx.android.synthetic.main.layout_room_center_background.view.*

class CenterBackgroundView : ConstraintLayout {
    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet) : super(context, attrs)
    constructor(context: Context, attrs: AttributeSet, defStyleAttr: Int)
            : super(context, attrs, defStyleAttr)

    init {
        LayoutInflater.from(context).inflate(R.layout.layout_room_center_background, this, true)
        // 大班课时，学生视角，显示：等待老师共享
        if (!ClassRoomManager.isSmallClass() && !ClassRoomManager.me().isTeacher()) {
            cl_mini.visibility = GONE
            cl_large.visibility = VISIBLE
        } else {
            cl_mini.visibility = VISIBLE
            cl_large.visibility = GONE
        }
    }

    fun onClickWhiteboard(click: (View) -> Unit) {
        center_bottom_whiteboard.setOnClickListener { click.invoke(center_bottom_whiteboard) }
    }

    fun onClickShareFile(click: (View) -> Unit) {
        center_bottom_file.setOnClickListener { click.invoke(center_bottom_file) }
    }
}