package im.zego.goclass.upload

import android.app.Activity
import android.content.Intent
import android.util.Log
import im.zego.goclass.tool.PermissionHelper
import im.zego.zegodocs.ZegoDocsViewConstants
import im.zego.zegodocs.ZegoDocsViewManager
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.InputStream
import java.text.DecimalFormat

class UploadFileHelper {
    companion object {
        private const val TAG = "UploadHelper"
        private val REQUEST_CODE_UPLOAD = 10000
        private var mRenderType: Int = ZegoDocsViewConstants.ZegoDocsViewRenderTypeVector
        private val percentFormat = DecimalFormat("#0.00")

        fun uploadFile(activity: Activity, renderType: Int) {
            PermissionHelper.onReadSDCardPermissionGranted(activity) { grant ->
                if (grant) {
                    val uploadIntent = Intent().also {
                        it.action = Intent.ACTION_OPEN_DOCUMENT
                        it.flags =
                            Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
                        it.addCategory(Intent.CATEGORY_OPENABLE)
                        it.type = "*/*"
                    }
                    mRenderType = renderType;
                    activity.startActivityForResult(uploadIntent, REQUEST_CODE_UPLOAD)
                }
            }
        }

        fun onActivityResult(
            context: Activity, requestCode: Int, resultCode: Int, data: Intent?,
            uploadResult: (errorCode: Int, state: Int, fileID: String?, uploadPercent: Float) -> Void
        ) {
            if (requestCode == REQUEST_CODE_UPLOAD && resultCode == Activity.RESULT_OK) {
                val fileUri = data?.data
                Log.d(TAG, "fileUri  = $fileUri ")
                if (fileUri != null) {
                    val contentResolver = context.contentResolver
                    try {
                        contentResolver.takePersistableUriPermission(
                            fileUri,
                            Intent.FLAG_GRANT_READ_URI_PERMISSION
                        )
                    } catch (e: SecurityException) {
                        Log.e(TAG, "FAILED TO TAKE PERMISSION")
                    }
                    val filePath = FileUtil.getPath(context, fileUri)
                    uploadFileInner(context, filePath, uploadResult)
                }
            }
        }

        @Throws(IOException::class)
        fun readFullyNoClose(input: InputStream): ByteArray? {
            val bytes = ByteArrayOutputStream()
            val buffer = ByteArray(1024)
            var count: Int
            while (input.read(buffer).also { count = it } != -1) {
                bytes.write(buffer, 0, count)
            }
            return bytes.toByteArray()
        }

        fun closeQuietly(closeable: AutoCloseable?) {
            if (closeable != null) {
                try {
                    closeable.close()
                } catch (rethrown: RuntimeException) {
                    throw rethrown
                } catch (ignored: java.lang.Exception) {
                }
            }
        }

        fun uploadFileInner(
            context: Activity,
            filePath: String,
            uploadResult: (errorCode: Int, state: Int, fileID: String?, uploadPercent: Float) -> Void
        ) {
            ZegoDocsViewManager.getInstance().uploadFile(filePath, mRenderType)
            { state, errorCode, infoMap ->
                when {
                    errorCode != ZegoDocsViewConstants.ZegoDocsViewSuccess -> {
                        uploadResult(errorCode, state, null, 0f)
                    }
                    state == ZegoDocsViewConstants.ZegoDocsViewUploadStateUpload -> {
                        val uploadPercent =
                            infoMap[ZegoDocsViewConstants.UPLOAD_PERCENT] as Float * 100

                        uploadResult(errorCode, state, null, uploadPercent)
                    }
                    state == ZegoDocsViewConstants.ZegoDocsViewUploadStateConvert -> {
                        val fileID = infoMap[ZegoDocsViewConstants.UPLOAD_FILEID] as String
                        uploadResult(errorCode, state, fileID, 100f)
                    }
                }
            }
        }
    }

}