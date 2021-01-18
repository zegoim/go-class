package im.zego.goclass.upload

import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.provider.MediaStore
import android.util.Log
import android.webkit.MimeTypeMap
import im.zego.goclass.R
import im.zego.goclass.tool.PermissionHelper
import im.zego.goclass.tool.ToastUtils

class UploadPicHelper {

    companion object {
        private val TAG = "UploadPicHelper"
        var supportedImageExtension = arrayOf("jpeg", "jpg", "png", "svg")
        val REQUEST_CODE_FOR_CHOOSE_PICTURE = 123

        fun startChoosePicture(activity: Activity) {
            PermissionHelper.onReadSDCardPermissionGranted(activity) {
                val intent =
                    Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
                intent.type = "image/*"
                intent.putExtra(Intent.EXTRA_MIME_TYPES, getSupportedImageMimeTypes())
                if (intent.resolveActivity(activity.packageManager) != null) {
                    activity.startActivityForResult(intent, REQUEST_CODE_FOR_CHOOSE_PICTURE)
                }
            }
        }

        fun getSupportedImageMimeTypes(): Array<String?>? {
            val supportedImageMimeTypes =
                arrayOfNulls<String>(supportedImageExtension.size)
            for (i in supportedImageExtension.indices) {
                supportedImageMimeTypes[i] = MimeTypeMap.getSingleton()
                    .getMimeTypeFromExtension(supportedImageExtension.get(i))
            }
            return supportedImageMimeTypes
        }

        fun handleActivityResult(
            context: Activity,
            requestCode: Int,
            resultCode: Int,
            data: Intent?,
            uploadResult: (filePath: String) -> Unit
        ) {
            if (requestCode != REQUEST_CODE_FOR_CHOOSE_PICTURE) {
                return
            }
            // 取消上传
            if (resultCode != Activity.RESULT_OK) {
                ToastUtils.showCenterToast(context.getString(R.string.cancel_upload))
                return
            }
            val fileUri = data?.data
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
                uploadResult(FileUtil.getPath(context, fileUri))
            }
        }
    }
}