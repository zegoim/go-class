package im.zego.goclass.network

data class FileData(
    val id: String,
    val name: String,
    val isDynamic: Boolean,
    val isH5: Boolean
) {
    override fun toString(): String {
        return "FileData(id='$id', name='$name', isDynamic=$isDynamic,isH5:$isH5)"
    }
}