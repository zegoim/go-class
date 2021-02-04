package im.zego.goclass.upload

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.core.app.ActivityCompat
import com.easypermission.Permission
import im.zego.goclass.R
import im.zego.goclass.tool.PermissionHelper
import im.zego.goclass.widget.ZegoDialog
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
        // 用于存储上传中文件的 filePath
        private val mUploadingFileSet = HashSet<String>()

        object MimeType {
            const val PPT = "application/vnd.ms-powerpoint"
            const val PPTX = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
            const val DOC = "application/msword"
            const val DOCX = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            const val XLS = "application/vnd.ms-excel"
            const val XLSX = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            const val PDF = "application/pdf"
            const val TXT = "text/plain"
            const val JPG = "image/jpeg"
            const val JPEG = "image/jpeg"
            const val PNG = "image/png"
            const val BMP = "image/bmp"
            const val XMSBMP = "image/x-ms-bmp"
            const val WBMP = "image/vnd.wap.wbmp"
            const val HEIC = "image/heic"
        }

        private val mimeTypesVectorAndIMG = arrayOf(MimeType.PPT,MimeType.PPTX,MimeType.DOC,MimeType.DOCX,MimeType.XLS,
                MimeType.XLSX,MimeType.PDF,MimeType.TXT,MimeType.JPG,MimeType.JPEG,MimeType.PNG,MimeType.BMP,MimeType.XMSBMP,MimeType.WBMP,MimeType.HEIC)

        private val mimeTypesDynamicPPTH5 = arrayOf(MimeType.PPT,MimeType.PPTX)

        fun uploadFile(activity: Activity, renderType: Int) {
            PermissionHelper.onReadSDCardPermissionGranted(activity) { grant ->
                if (grant) {
                    val uploadIntent = Intent().also {
                        it.action = Intent.ACTION_OPEN_DOCUMENT
                        it.flags =
                            Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
                        it.addCategory(Intent.CATEGORY_OPENABLE)
                        it.type = "*/*"
                        when(renderType)
                        {
                            ZegoDocsViewConstants.ZegoDocsViewRenderTypeVectorAndIMG -> it.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypesVectorAndIMG)
                            ZegoDocsViewConstants.ZegoDocsViewRenderTypeDynamicPPTH5 -> it.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypesDynamicPPTH5)
                        }
                    }
                    mRenderType = renderType;
                    activity.startActivityForResult(uploadIntent, REQUEST_CODE_UPLOAD)
                } else {
                    if (!ActivityCompat.shouldShowRequestPermissionRationale(
                            activity,
                            Permission.READ_EXTERNAL_STORAGE
                        )
                    ) {
                        ZegoDialog.Builder(activity)
                            .setTitle(activity.getString(R.string.wb_tip_unable_upload_file))
                            .setMessage(activity.getString(R.string.wb_tip_open_permission))
                            .setPositiveButton(activity.getString(R.string.jump_to_settings)) { dialog, _ ->
                                dialog.dismiss()
                                val intent =
                                    Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                                val uri: Uri = Uri.fromParts("package", activity.packageName, null)
                                intent.data = uri
                                activity.startActivity(intent)
                            }
                            .setNegativeButton(R.string.wb_cancel) { dialog, _ ->
                                dialog.dismiss()
                            }
                            .setNegativeButtonBackground(R.drawable.drawable_dialog_confirm2)
                            .setNegativeButtonTextColor(R.color.colorAccent)
                            .setButtonWidth(80)
                            .setMaxDialogWidth(320)
                            .create().showWithLengthLimit()
                    }
                }
            }
        }

        fun onActivityResult(
            context: Activity, requestCode: Int, resultCode: Int, data: Intent?,
            uploadResult: (errorCode: Int, state: Int, fileID: String?, uploadPercent: Float) -> Unit
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

        /**
         * 若上传文件集合不为空，则当前有文件正在上传，返回 true
         */
        fun isUploadingFile() : Boolean {
            return mUploadingFileSet.isNotEmpty()
        }

        fun clearUploadingFileSet() {
            mUploadingFileSet.clear()
        }

        fun uploadFileInner(
            context: Activity,
            filePath: String,
            uploadResult: (errorCode: Int, state: Int, fileID: String?, uploadPercent: Float) -> Unit
        ) {
            val cacheDir = context.cacheDir.toString()

            ZegoDocsViewManager.getInstance().uploadFile(filePath, mRenderType)
            { state, errorCode, infoMap ->
                when {
                    errorCode != ZegoDocsViewConstants.ZegoDocsViewSuccess -> {
                        mUploadingFileSet.remove(filePath)
                        if(filePath.startsWith(cacheDir))
                        {
                            Log.i(TAG,"upload fail - delete filePath  = $filePath")
                            FileUtil.deleteSingleFile(filePath)
                        }

                        uploadResult(errorCode, state, null, 0f)
                    }
                    state == ZegoDocsViewConstants.ZegoDocsViewUploadStateUpload -> {
                        mUploadingFileSet.add(filePath)
                        val uploadPercent =
                            infoMap[ZegoDocsViewConstants.UPLOAD_PERCENT] as Float * 100

                        uploadResult(errorCode, state, null, uploadPercent)
                    }
                    state == ZegoDocsViewConstants.ZegoDocsViewUploadStateConvert -> {
                        mUploadingFileSet.remove(filePath)
                        if(filePath.startsWith(cacheDir))
                        {
                            Log.i(TAG,"upload success - delete filePath  = $filePath")
                            FileUtil.deleteSingleFile(filePath)
                        }

                        val fileID = infoMap[ZegoDocsViewConstants.UPLOAD_FILEID] as String
                        uploadResult(errorCode, state, fileID, 100f)
                    }
                }
            }
        }
    }

}