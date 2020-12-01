package im.zego.goclass.network

data class FileData(
    val id: String,
    val name: String,
    val isDynamic: Boolean
) {
    override fun toString(): String {
        return "FileData(id='$id', name='$name', isDynamic=$isDynamic)"
    }
}