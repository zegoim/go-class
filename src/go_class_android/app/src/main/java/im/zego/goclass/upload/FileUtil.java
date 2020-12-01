package im.zego.goclass.upload;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.net.Uri;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;

public class FileUtil {
    private static final String TAG = "FileUtil";
    private static String PNG_EXTENSION = ".png";

    private static boolean isExternalStorageDocument(Uri uri) {
        return "com.android.externalstorage.documents".equals(uri.getAuthority());
    }

    private static boolean isDownloadsDocument(Uri uri) {
        return "com.android.providers.downloads.documents".equals(uri.getAuthority());
    }

    private static boolean isMediaDocument(Uri uri) {
        return "com.android.providers.media.documents".equals(uri.getAuthority());
    }

    private static String getDataColumn(Context context, Uri uri, String selection,
                                        String[] selectionArgs) {

        Cursor cursor = null;
        final String column = "_data";
        final String[] projection = {
                column
        };

        try {
            cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs,
                    null);
            if (cursor != null && cursor.moveToFirst()) {
                final int column_index = cursor.getColumnIndexOrThrow(column);
                return cursor.getString(column_index);
            }
        } catch (Exception e) {
            Log.i(TAG, "getDataColumn fail uri:" + uri.toString() + " exception:" + e.toString());
        } finally {
            if (cursor != null)
                cursor.close();
        }
        return null;
    }

    public static String getPath(final Context context, final Uri uri) {
        if (DocumentsContract.isDocumentUri(context, uri)) {
            if (isExternalStorageDocument(uri)) {
                final String docId = DocumentsContract.getDocumentId(uri);
                int indexOf = docId.indexOf(":");
                if (indexOf != -1) {
                    final String type = docId.substring(0, indexOf);
                    String path = docId.substring(indexOf + 1);

                    if ("primary".equalsIgnoreCase(type)) {
                        return Environment.getExternalStorageDirectory() + "/" + path;
                    }
                } else {
                    return null;
                }
            } else if (isDownloadsDocument(uri)) {
                final String id = DocumentsContract.getDocumentId(uri);
                if (!TextUtils.isEmpty(id)) {
                    if (id.startsWith("raw:")) {
                        return id.replaceFirst("raw:", "");
                    }
                    try {
                        final Uri contentUri = ContentUris.withAppendedId(
                                Uri.parse("content://downloads/public_downloads"), Long.parseLong(id));


                        return getDataColumn(context, contentUri, null, null);
                    } catch (NumberFormatException e) {
                        return null;
                    }
                }
            } else if (isMediaDocument(uri)) {
                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String type = split[0];

                Uri contentUri = null;
                if ("image".equals(type)) {
                    contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                } else if ("video".equals(type)) {
                    contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                } else if ("audio".equals(type)) {
                    contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                }

                final String selection = "_id=?";
                final String[] selectionArgs = new String[]{
                        split[1]
                };

                return getDataColumn(context, contentUri, selection, selectionArgs);
            }
        } else if ("content".equalsIgnoreCase(uri.getScheme())) {
            return getDataColumn(context, uri, null, null);
        } else if ("file".equalsIgnoreCase(uri.getScheme())) {
            return uri.getPath();
        }
        return null;
    }

    public static String getFilePath(final Context context, final Uri uri) {
        if (null == uri) return null;

        final String scheme = uri.getScheme();
        String data = null;

        if (scheme == null)
            data = uri.getPath();
        else if (ContentResolver.SCHEME_FILE.equals(scheme)) {
            data = uri.getPath();
        } else if (ContentResolver.SCHEME_CONTENT.equals(scheme)) {
            Cursor cursor = context.getContentResolver().query(uri, new String[]{MediaStore.Images.ImageColumns.DATA}, null, null, null);
            if (null != cursor) {
                if (cursor.moveToFirst()) {
                    int index = cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA);
                    if (index > -1) {
                        data = cursor.getString(index);
                    }
                }
                cursor.close();
            }
        }
        return data;
    }

    /**
     * 保存图片到本地
     * @param fileName
     * @param view
     */
    public static void saveImage(String fileName, View view, SaveImageListener listener) {
        Log.i(TAG, "saveImage()  : fileName = " + fileName + ", view = " + view + ", listener = " + listener + "");
        Bitmap bitmap = Bitmap.createBitmap(view.getWidth(), view.getHeight(), Bitmap.Config.RGB_565);
        Canvas canvas = new Canvas(bitmap);
        view.draw(canvas);
        String fileDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM).getPath();
        File file = createFile(fileDir, fileName);
        FileOutputStream fos = null;
        try {
            boolean newFile = file.createNewFile();
            if (!newFile) {
                Log.e(TAG, "saveImage() createNewFile failed ");
                listener.onSave(false);
                return;
            }
            int quality = 100;
            fos = new FileOutputStream(file);
            bitmap.compress(Bitmap.CompressFormat.PNG, quality, fos);
            fos.flush();
        } catch (IOException e) {
            e.printStackTrace();
            Log.e(TAG, "saveImage() createNewFile failed exception :", e);
            listener.onSave(false);
        } finally {
            if (fos != null) {
                try {
                    fos.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        saveImage(view.getContext(), file);
        listener.onSave(true);
    }


    /**
     * 获取待保存图片的路径，如果已有重名，需要重命名。
     * @param filePath
     * @param fileName
     * @return
     */
    private static File createFile(String filePath, String fileName) {
        File fileDir = new File(filePath);
        if (!fileDir.isDirectory()) {
            Log.w(TAG, "createFile() filePath is not a dir : " + filePath);
            return null;
        }
        ArrayList<String> samePrefixFiles = new ArrayList<>();
        String[] fileList = fileDir.list();
        if (fileList == null) {
            Log.w(TAG, "createFile(): fileList is null" );
            return null;
        }

        for (String file : fileList) {
            if (file.startsWith(fileName)) {
                samePrefixFiles.add(file);
            }
        }
        if (samePrefixFiles.size() > 0) {
            String tempFile = fileName + PNG_EXTENSION;
            int fileSuffix = 0;
            while (samePrefixFiles.contains(tempFile)) {
                fileSuffix++;
                tempFile = fileName + getSuffix(fileSuffix) + PNG_EXTENSION;
            }

            fileName = fileName + getSuffix(fileSuffix);
        }


        String pathname = filePath + "/" + fileName + PNG_EXTENSION;
        Log.i(TAG, "createFile: pathname = " + pathname);
        return new File(pathname);
    }

    /**
     * 返回 （index）如(1)、(2)
     * @param index
     * @return
     */
    private static String getSuffix(int index) {
        return "(" + index + ")";
    }

    /**
     * 通知相册去扫描该文件，保证相册中可以查找到该图片。
     * @param context
     * @param imageFile
     */
    private static void saveImage(Context context, File imageFile) {
        ContentResolver localContentResolver = context.getContentResolver();
        ContentValues localContentValues = getImageContentValues(imageFile);
        localContentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, localContentValues);

        Intent localIntent = new Intent("android.intent.action.MEDIA_SCANNER_SCAN_FILE");
        final Uri localUri = Uri.fromFile(imageFile);
        localIntent.setData(localUri);
        context.sendBroadcast(localIntent);
    }

    /**
     * 创建 ContentValues
     * @param imageFile
     * @return
     */
    private static ContentValues getImageContentValues(File imageFile) {
        long dateStr = System.currentTimeMillis();
        ContentValues localContentValues = new ContentValues();

        String imageFileName = imageFile.getName();
        localContentValues.put(MediaStore.MediaColumns.TITLE, imageFileName);
        localContentValues.put(MediaStore.MediaColumns.DISPLAY_NAME, imageFileName);
        localContentValues.put(MediaStore.MediaColumns.MIME_TYPE, "image/png");
        localContentValues.put(MediaStore.MediaColumns.DATE_TAKEN, dateStr);
        localContentValues.put(MediaStore.MediaColumns.DATE_MODIFIED, dateStr);
        localContentValues.put(MediaStore.MediaColumns.DATE_ADDED, dateStr);
        localContentValues.put(MediaStore.MediaColumns.ORIENTATION, 0);
        localContentValues.put(MediaStore.MediaColumns.DATA, imageFile.getAbsolutePath());
        localContentValues.put(MediaStore.MediaColumns.SIZE, imageFile.length());
        return localContentValues;
    }

    /**
     * 保存图片的回调
     */
    public interface SaveImageListener {
        void onSave(boolean success);
    }
}
