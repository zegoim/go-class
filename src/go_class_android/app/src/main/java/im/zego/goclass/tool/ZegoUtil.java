package im.zego.goclass.tool;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.graphics.drawable.StateListDrawable;
import android.view.Surface;

import im.zego.goclass.KotlinUtilsKt;

public class ZegoUtil {
    /**
     * 字符串转换成 byte 数组
     * 主要用于 appSign 的转换
     *
     * @param strSignKey 字符串格式的appSign，形如"0x01, 0x02, 0x03, 0x04"
     * @return 根据 strSignKey 转化而来的 byte[]
     * @throws NumberFormatException
     */
    public static byte[] parseSignKeyFromString(String strSignKey) throws NumberFormatException {
        if (!strSignKey.startsWith("0x")) {
            StringBuilder builder = new StringBuilder();
            char[] chars = strSignKey.toCharArray();

            for (int i = 0; i < chars.length; i++) {
                if (i % 2 == 0) {
                    if (i == 0) {
                        builder.append("0x");
                    } else {
                        builder.append(",0x");
                    }
                }
                builder.append(chars[i]);
            }
            strSignKey = builder.toString();
        }

        // 解决客户有可能直接拷贝邮件上的appSign导致错误的问题。
        strSignKey = strSignKey.replaceAll("\\(byte\\)", "");

        String[] keys = strSignKey.split(",");
        if (keys.length != 32) {
            return null;
        }
        byte[] byteSignKey = new byte[32];
        for (int i = 0; i < 32; i++) {
            int data = Integer.valueOf(keys[i].trim().replace("0x", ""), 16);
            byteSignKey[i] = (byte) data;
        }
        return byteSignKey;
    }

    public static int getScreenOrientation(Activity activity) {
        int rotation = activity.getWindowManager().getDefaultDisplay().getRotation();
        int orientation = activity.getResources().getConfiguration().orientation;
        if (orientation == Configuration.ORIENTATION_PORTRAIT) {
            if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_180) {
                return ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;
            } else {
                return ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT;
            }
        }
        if (orientation == Configuration.ORIENTATION_LANDSCAPE) {
            if (rotation == Surface.ROTATION_270 || rotation == Surface.ROTATION_90) {
                return ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
            } else {
                return ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE;
            }
        }
        return ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED;
    }

    public static StateListDrawable getJoinBtnDrawable(Context context) {
        StateListDrawable stateListDrawable = new StateListDrawable();
        float radius = KotlinUtilsKt.dp2px(context, 27.5f);
        stateListDrawable.addState(new int[]{android.R.attr.state_enabled}, KotlinUtilsKt.getRoundRectDrawable("#0044ff", radius));
        stateListDrawable.addState(new int[]{}, KotlinUtilsKt.getRoundRectDrawable("#94b0ff", radius));
        return stateListDrawable;
    }

    public static StateListDrawable getFontBgDrawable(Context context) {
        StateListDrawable stateListDrawable = new StateListDrawable();
        float radius = KotlinUtilsKt.dp2px(context, 12f);
        stateListDrawable.addState(new int[]{android.R.attr.state_selected}, KotlinUtilsKt.getRoundRectDrawable("#0044ff", radius));
        stateListDrawable.addState(new int[]{}, KotlinUtilsKt.getRoundRectDrawable("#f4f5f8", radius));
        return stateListDrawable;
    }

    public static StateListDrawable getBrushWidthDrawable(int sizeInPx) {
        StateListDrawable stateListDrawable = new StateListDrawable();
        stateListDrawable.addState(new int[]{android.R.attr.state_selected}, KotlinUtilsKt.getCircleDrawable("#0044ff", sizeInPx));
        stateListDrawable.addState(new int[]{}, KotlinUtilsKt.getCircleDrawable("#b1b4bd", sizeInPx));
        return stateListDrawable;
    }

    public static void killSelfAndRestart(Context context, Class launcherClass) {
        Intent intent = new Intent(context, launcherClass);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        context.startActivity(intent);
        android.os.Process.killProcess(android.os.Process.myPid());
    }
}
