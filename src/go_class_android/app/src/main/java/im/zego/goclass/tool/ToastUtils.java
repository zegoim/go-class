package im.zego.goclass.tool;

import android.content.Context;
import android.os.Build;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.StringRes;

import im.zego.goclass.KotlinUtilsKt;
import im.zego.goclass.sdk.ZegoSDKManager;
import im.zego.goclass.R;

/**
 *
 */
public final class ToastUtils {

    private ToastUtils() {
    }

    private static Toast mCenterToast;
    private static Context appContext;

    private static Toast getToast(Context context) {
        Toast toast;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
            // 25 以后，系统做了限制，如果反复点击的都是同一个，会导致后面的暂时显示不出来
            toast = new Toast(context.getApplicationContext());
        } else {
            // 25 以前，toast太频繁会排队一直显示不消失
            // 显示在中间的toast不能覆盖掉显示在上面的toast
            if (mCenterToast == null) {
                mCenterToast = new Toast(context.getApplicationContext());
            }
            toast = mCenterToast;
        }
        //设置Toast显示位置，居中，向 X、Y轴偏移量均为0
        View view = LayoutInflater.from(context).inflate(R.layout.toast_custom, null);
        //设置显示时长
        toast.setDuration(Toast.LENGTH_SHORT);
        toast.setView(view);
        view.setBackground(KotlinUtilsKt.getRoundRectDrawable("#99000000", KotlinUtilsKt.dp2px(context, 5f)));
        return toast;
    }

    private static void showCenterToastInner(Context context, String msg) {
        Toast toast = getToast(context);
        toast.getView().measure(
                View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
                View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED));
        toast.setGravity(Gravity.CENTER, 0, -toast.getView().getMeasuredHeight() / 2);
        //获取自定义视图
        TextView tvMessage = toast.getView().findViewById(R.id.toast_text);
        //设置文本
        tvMessage.setText(msg);
        //显示
        toast.show();
    }


    public static void setAppContext(Context context) {
        appContext = context;
    }


    public static void showCenterToast(String string) {
        showCenterToastInner(appContext, string);
    }

    public static void showCenterToast(@StringRes int stringID) {
        showCenterToastInner(appContext, appContext.getString(stringID));
    }

    public static void showCenterToast(@StringRes int stringID, Object... formatArgs) {
        showCenterToastInner(appContext, appContext.getString(stringID, formatArgs));
    }

    public static void showLoginErrorToast(int errorCode) {
        boolean liveroomMax = ZegoSDKManager.getInstance().isLiveRoom() &&
                (errorCode == 52001104 || errorCode == 52001105);
        boolean expressMax = !ZegoSDKManager.getInstance().isLiveRoom() &&
                errorCode == 1002034;
        if (liveroomMax || expressMax) {
            showCenterToast(R.string.join_max_user_limit, ZegoSDKManager.MAX_USER_COUNT);
        } else {
            showCenterToast(R.string.join_other, errorCode);
        }
    }
}
