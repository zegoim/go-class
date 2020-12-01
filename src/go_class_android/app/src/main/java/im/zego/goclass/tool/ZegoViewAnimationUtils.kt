package im.zego.goclass.tool

import android.view.View
import android.view.animation.AnimationUtils

class ZegoViewAnimationUtils {
    companion object {
        private const val ANIMATION_DURATION = 300L
        @JvmStatic
        fun startLeftViewAnimation(view: View, show: Boolean) {
            if (show) {
                if (view.visibility == View.VISIBLE) {
                    return
                }
                val animation = AnimationUtils.makeInAnimation(view.context, true)
                animation.duration = ANIMATION_DURATION
                view.animation = animation
                view.visibility = View.VISIBLE
            } else {
                if (view.visibility != View.VISIBLE) {
                    return
                }
                val animation = AnimationUtils.makeOutAnimation(view.context, false)
                animation.duration = ANIMATION_DURATION
                view.animation = animation
                view.visibility = View.GONE
            }
        }

        @JvmStatic
        fun startRightViewAnimation(view: View, show: Boolean) {
            if (show) {
                if (view.visibility == View.VISIBLE) {
                    return
                }
                val animation = AnimationUtils.makeInAnimation(view.context, false)
                animation.duration = ANIMATION_DURATION
                view.animation = animation
                view.visibility = View.VISIBLE
            } else {
                if (view.visibility != View.VISIBLE) {
                    return
                }
                val animation = AnimationUtils.makeOutAnimation(view.context, true)
                animation.duration = ANIMATION_DURATION
                view.animation = animation
                view.visibility = View.GONE
            }
        }
    }
}