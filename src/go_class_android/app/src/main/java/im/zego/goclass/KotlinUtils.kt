package im.zego.goclass

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue

fun dp2px(context: Context, dpValue: Float): Float {
    return TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP,
        dpValue,
        context.resources.displayMetrics
    )
}

fun getRoundRectDrawable(drawableColor: String, radius: Float): GradientDrawable {
    val drawable = GradientDrawable()
    drawable.shape = GradientDrawable.RECTANGLE
    drawable.setColor(Color.parseColor(drawableColor))
    drawable.cornerRadius = radius
    return drawable
}

fun getCircleDrawable(drawableColor: String, radius: Float): GradientDrawable {
    val drawable = GradientDrawable()
    drawable.shape = GradientDrawable.OVAL
    drawable.setColor(Color.parseColor(drawableColor))
    drawable.setSize((radius * 2).toInt(), (radius * 2).toInt())
    return drawable
}

var CONFERENCE_ID = ""