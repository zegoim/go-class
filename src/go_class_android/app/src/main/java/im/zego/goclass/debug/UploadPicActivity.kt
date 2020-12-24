package im.zego.goclass.debug

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import im.zego.goclass.R
import im.zego.goclass.upload.UploadPicHelper
import kotlinx.android.synthetic.main.activity_upload_pic.*

class UploadPicActivity : AppCompatActivity() {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_upload_pic)

        upload_pic_btn.setOnClickListener {
            UploadPicHelper.startChoosePicture(this)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        UploadPicHelper.handleActivityResult(this, requestCode, resultCode, data) { filePath ->
            upload_pic.setBitmapResource(filePath)
        }
    }
}