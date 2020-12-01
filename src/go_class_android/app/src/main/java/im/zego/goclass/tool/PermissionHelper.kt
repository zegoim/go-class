package im.zego.goclass.tool

import android.app.Activity
import com.easypermission.*

class PermissionHelper {
    companion object {
        private fun onPermissionGranted(
            activity: Activity,
            permission: String,
            grantResult: (Boolean) -> Unit
        ) {
            if (EasyPermission.isPermissionGrant(activity, permission)) {
                grantResult.invoke(true)
            } else {
                EasyPermission.with(activity)
                    .addPermissions(permission)
                    .addRequestPermissionRationaleHandler(permission)
                    { permission, _, nextAction ->
                        nextAction.next(NextActionType.NEXT)
                    }
                    .request(object : PermissionRequestListener() {
                        override fun onCancel(stopPermission: String) {
                        }

                        override fun onGrant(result: MutableMap<String, GrantResult>) {
                            if (result[permission] == GrantResult.GRANT) {
                                grantResult.invoke(true)
                            } else {
                                grantResult.invoke(false)
                            }
                        }
                    })
            }
        }

        fun onAudioPermissionGranted(
            activity: Activity,
            grantResult: (Boolean) -> Unit
        ) {
            onPermissionGranted(activity, Permission.RECORD_AUDIO, grantResult)
        }

        fun onCameraPermissionGranted(
            activity: Activity,
            grantResult: (Boolean) -> Unit
        ) {
            onPermissionGranted(activity, Permission.CAMERA, grantResult)
        }

        fun onReadSDCardPermissionGranted(
            activity: Activity,
            grantResult: (Boolean) -> Unit
        ) {
            onPermissionGranted(activity, Permission.READ_EXTERNAL_STORAGE, grantResult)
        }

        fun onWriteSDCardPermissionGranted(
            activity: Activity,
            grantResult: (Boolean) -> Unit
        ) {
            onPermissionGranted(activity, Permission.WRITE_EXTERNAL_STORAGE, grantResult)
        }
    }
}