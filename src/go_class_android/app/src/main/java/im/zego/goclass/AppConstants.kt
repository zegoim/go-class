package im.zego.goclass

object AppConstants {

    // 默认思源字体路径
    const val FONT_FAMILY_DEFAULT_PATH = "fonts/SourceHanSansSC-Regular.otf"
    const val FONT_FAMILY_DEFAULT_PATH_BOLD = "fonts/SourceHanSansSC-Bold.otf"

    // 当前所选字体路径
    var FONT_FAMILY_SELECT_PATH = "fonts/SourceHanSansSC-Regular.otf"

    // 日志文件夹名称
    const val LOG_SUBFOLDER = "goclass"

    // 日志文件大小
    const val LOG_SIZE = 5 * 1024 * 1024.toLong()
}