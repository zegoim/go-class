package im.zego.goclass;

import android.webkit.MimeTypeMap;

/**
 * /frameworks/base/media/java/android/media/MediaFile.java
 */
public class ShareFileSupportType {
    private static final String TAG = "ShareFileSupportType";

    public static String[] supportedExtension = {"pptx", "ppt", "docx", "doc", "xlsx", "xls", "pdf", "txt", "jpeg", "jpg", "png", "bmp"};

    public static String[] getSupportedFileMimeTypes() {
        String[] supportedMimeTypes = new String[supportedExtension.length];
        for (int i = 0; i < supportedExtension.length; i++) {
            supportedMimeTypes[i] = MimeTypeMap.getSingleton().getMimeTypeFromExtension(supportedExtension[i]);
        }
        return supportedMimeTypes;
    }
}
