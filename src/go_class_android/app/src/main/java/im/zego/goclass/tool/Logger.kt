package im.zego.goclass.tool

import android.util.Log

/**
 * Android通用Logger工具，在此处可以对log进行控制。如开启/关闭
 */
internal class Logger {
    companion object {
        private const val SDK_TAG = "wb_demo"

        // 可以加个开关控制。根据编译版本来修改该值
        private const val ENABLE_LOG = true

        fun d(tag: String?, msg: String) {
            // 1、通过Android系统api Log输出到控制台
            Log.d(wrapTag(tag), msg)
            // 2、通过ZegoDocsSDK，写入文件
        }

        fun i(tag: String?, msg: String) {
            Log.i(wrapTag(tag), msg)
        }

        fun w(tag: String?, msg: String) {
            Log.w(wrapTag(tag), msg)
        }

        fun e(tag: String?, msg: String) {
            Log.e(wrapTag(tag), msg)
        }

        /**
         * 所有log加上统一的前缀
         */
        private fun wrapTag(tag: String?): String {
            return SDK_TAG + tag
        }

        /**
         * 往sdk写的logMsg,tag 和 msg 直接拼接在一起
         */
        private fun wrapSdkLogMsg(tag: String, msg: String): String {
            return tag + msg
        }
    }
}