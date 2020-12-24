package im.zego.goclass.debug;

import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import org.jetbrains.annotations.NotNull;

import java.util.Timer;
import java.util.TimerTask;
import im.zego.goclass.upload.UploadFileHelper;
import im.zego.zegodocs.IZegoDocsViewScrollCompleteListener;
import im.zego.zegodocs.ZegoDocsView;
import im.zego.zegodocs.ZegoDocsViewConstants;
import im.zego.goclass.R;

import static im.zego.goclass.KotlinUtilsKt.dp2px;

/**
 * 上传文件页面
 */
public class UploadFileActivity extends AppCompatActivity {

    private final String TAG = getClass().getSimpleName();

    private final float wbAspectWidth = 16f;
    private final float wbAspectHeight = 9f;

    private TextView textView;
    private ViewGroup container;
    private ZegoDocsView docsView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_upload);

        initView();
    }

    private void initView() {
        container = findViewById(R.id.container);
        textView = findViewById(R.id.text1);

        // 上传动态文件
        findViewById(R.id.upload_dynamic).setOnClickListener(v -> {
            docsView.unloadFile();
            textView.setText("");
            UploadFileHelper.Companion.uploadFile(this, ZegoDocsViewConstants.ZegoDocsViewRenderTypeDynamicPPTH5);
        });
        // 上传静态文件
        findViewById(R.id.upload_static).setOnClickListener(v -> {
            docsView.unloadFile();
            textView.setText("");
            UploadFileHelper.Companion.uploadFile(this, ZegoDocsViewConstants.ZegoDocsViewRenderTypeVectorAndIMG);
        });
        // 下一页
        findViewById(R.id.next_page).setOnClickListener(v -> {
            setInitSize();
        });
        // 上一页
        findViewById(R.id.prev_page).setOnClickListener(v -> {
            matchParentSize();
            unLoadFile();
        });
        // 重新加载
        findViewById(R.id.reload).setOnClickListener(v -> {
        });

        docsView = new ZegoDocsView(this);
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        params.gravity = Gravity.CENTER;
        container.addView(docsView, params);
    }

    /**
     * 跳到指定页面
     * @param i 页数
     */
    private void flipPage(int i) {
        docsView.flipPage((i), b -> Log.d(TAG, "onScrollComplete() called with: b = [" + b + "]"));
    }

    @Override
    public void onConfigurationChanged(@NonNull Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        Log.d(TAG, "onConfigurationChanged() called with: newConfig = [" + newConfig + "]");
        // 设置 docsView
        docsView.post(() -> {
            int deviceWidth = (int) dp2px(this, newConfig.screenWidthDp);
            int deviceHeight = (int) dp2px(this, newConfig.screenHeightDp);

            int selfWidth;
            int selfHeight;
            if (newConfig.orientation == Configuration.ORIENTATION_PORTRAIT
            ) {
                selfWidth = deviceWidth;
                selfHeight = (int) (selfWidth / (wbAspectWidth / wbAspectHeight));
            } else {
                selfHeight = deviceHeight;
                selfWidth = (int) (selfHeight * (wbAspectWidth / wbAspectHeight));
            }

            Log.d(TAG, "onConfigurationChanged() called with: selfWidth = [" + selfWidth + "]" + "selfHeight = [" + selfHeight + "]");
            ViewGroup.LayoutParams layoutParams = docsView.getLayoutParams();
            layoutParams.width = selfWidth;
            layoutParams.height = selfHeight;
            docsView.setLayoutParams(layoutParams);
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        // 上传文件回调
        UploadFileHelper.Companion.onActivityResult(this, requestCode, resultCode, data, (errorCode, state, fileID, percent) -> {
            Log.d(TAG, "onActivityResult() called with: errorCode = [" + errorCode + "], state = [" + state + "], fileID = [" + fileID + "]" + ",percent:" + percent);
            if (errorCode != 0) {
                updateStatus("上传文件失败");
            } else {
                if (state == ZegoDocsViewConstants.ZegoDocsViewUploadStateUpload) {
                    updateStatus("上传进度：" + percent + "%");
                    if (percent == 100) {
                        updateStatus("上传完成，正在转码文件...");
                    }
                } else if (state == ZegoDocsViewConstants.ZegoDocsViewUploadStateConvert) {
                    updateStatus("转码完成，fileID =" + fileID);
                    loadDocsFile(fileID);
                }
            }
            return null;
        });
    }

    /**
     * 更新文件状态说明
     *
     * @param string 文件状态说明
     */
    public void updateStatus(String string) {
        textView.setText(string);
    }

    /**
     * 加载文件
     * @param fileID 文件 ID
     */
    public void loadDocsFile(@NotNull String fileID) {
        docsView.loadFile(fileID, "", errorCode -> {
            Log.d(TAG, "onLoadFile() called with: errorCode = [" + errorCode + "]");
            if (errorCode != 0) {
                String text = textView.getText().toString();
                updateStatus(text + "\n loadFile:" + errorCode);
            }
        });
    }

    public void unLoadFile() {
        docsView.unloadFile();
    }

    public void timerScroll() {
        Handler handler = new Handler();
        final float[] percent = {docsView.getVerticalPercent()};
        TimerTask task = new TimerTask() {
            @Override
            public void run() {
                percent[0] += 0.0002f;
                handler.post(() -> docsView.scrollTo(percent[0], new IZegoDocsViewScrollCompleteListener() {
                    @Override
                    public void onScrollComplete(boolean result) {
                        Log.d(TAG, "onScrollComplete() called with: result = [" + result + "]");
                    }
                }));

            }
        };
        Timer timer = new Timer();
        timer.schedule(task, 0, 100);
        handler.postDelayed(timer::cancel, 20000);
    }

    public void reSizeWhenOritationChanged(Configuration newConfig) {
        docsView.post(() -> {
            int deviceWidth = (int) dp2px(this, newConfig.screenWidthDp);
            int deviceHeight = (int) dp2px(this, newConfig.screenHeightDp);


            int selfWidth;
            int selfHeight;
            if (newConfig.orientation == Configuration.ORIENTATION_PORTRAIT
            ) {
                selfWidth = deviceWidth;
                selfHeight = (int) (selfWidth / (wbAspectWidth / wbAspectHeight));
            } else {
                selfHeight = deviceHeight;
                selfWidth = (int) (selfHeight * (wbAspectWidth / wbAspectHeight));
            }

            Log.d(TAG, "onConfigurationChanged() called with: selfWidth = [" + selfWidth + "]" + "selfHeight = [" + selfHeight + "]");
            ViewGroup.LayoutParams layoutParams = docsView.getLayoutParams();
            layoutParams.width = selfWidth;
            layoutParams.height = selfHeight;
            docsView.setLayoutParams(layoutParams);
        });
    }

    public void minusSize() {
        ViewGroup.LayoutParams layoutParams = docsView.getLayoutParams();
        layoutParams.width = (int) (layoutParams.width * 0.9f);
        layoutParams.height = (int) (layoutParams.width / docsView.getAspectRadio());
        docsView.setLayoutParams(layoutParams);
    }

    public void plusSize() {
        ViewGroup.LayoutParams layoutParams = docsView.getLayoutParams();
        layoutParams.width = (int) (layoutParams.width * 1.1f);
        layoutParams.height = (int) (layoutParams.width / docsView.getAspectRadio());
        docsView.setLayoutParams(layoutParams);
    }

    public void matchParentSize() {
        ViewGroup.LayoutParams layoutParams = docsView.getLayoutParams();
        layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT;
        layoutParams.height = ViewGroup.LayoutParams.MATCH_PARENT;
        docsView.setLayoutParams(layoutParams);
    }

    public void setInitSize() {
        ViewGroup.LayoutParams layoutParams = docsView.getLayoutParams();
        layoutParams.width = 1078;
        layoutParams.height = 606;
        docsView.setLayoutParams(layoutParams);


    }
}