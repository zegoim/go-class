package im.zego.goclass.debug;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PointF;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.View;

import androidx.annotation.Nullable;

public class TestImageCanvas extends View {
    private static final String TAG = "TestImageCanvas";

    private Bitmap bitmap;
    private String bitmapFilePath;
    private static final int maxBitmapWidth = 1920;
    private static final int maxBitmapHeight = 1080;

    private Paint paint = new Paint();
    private Matrix canvasMatrix = new Matrix();
    private int radius = 16;
    private PointF touchPosition = new PointF();
    /**
     * 从左到右，从上到下依次是点 01234567
     */
    private PointF[] cornerPointsOrigin = new PointF[8];
    /**
     * bitmap 设置了矩阵后，矩阵变化后的点的位置
     */
    private PointF[] cornerPointsNew = new PointF[8];

    private RectF bitmapRect = new RectF();

    /**
     * 当我们点击 点[x] 来拉伸的时候，pointAndScalePoint[x] 返回缩放中心点的index
     */
    private int[] pointAndScalePoint = {7, 6, 5, 4, 3, 2, 1, 0};

    private int dragPointIndex;
    private boolean startDragCorners;
    private boolean startDragBitmap;
    private float originalPositionX = 0;
    private float originalPositionY = 0;
    private float downX;
    private float downY;
    private float lastX;
    private float lastY;
    private ScaleGestureDetector scaleGestureDetector = new ScaleGestureDetector(getContext(), new ScaleGestureDetector.OnScaleGestureListener() {

        @Override
        public boolean onScale(ScaleGestureDetector detector) {
            Log.d(TAG, "onScale() called with: detector = [" + detector.getScaleFactor() + "]");
            canvasMatrix.postScale(detector.getScaleFactor(), detector.getScaleFactor(), detector.getFocusX(), detector.getFocusY());
            invalidate();
            return true;
        }

        @Override
        public boolean onScaleBegin(ScaleGestureDetector detector) {
            return true;
        }

        @Override
        public void onScaleEnd(ScaleGestureDetector detector) {

        }
    });


    public TestImageCanvas(Context context) {
        super(context);
        initView();
    }

    public TestImageCanvas(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initView();
    }

    public TestImageCanvas(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView();
    }

    private void initView() {
        paint.setColor(Color.RED);
    }

    public void setBitmapResource(String filePath) {
        this.bitmapFilePath = filePath;
        bitmap = BitmapFactory.decodeFile(filePath);
        initCornersPosition();
        canvasMatrix.setTranslate(originalPositionX, originalPositionY);
        invalidate();
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        touchPosition.set(event.getX(), event.getY());

        if (event.getActionMasked() == MotionEvent.ACTION_DOWN) {
            dragPointIndex = -1;
            for (int i = 0; i < cornerPointsNew.length; i++) {
                if (isTouchHitPoint(event, cornerPointsNew[i])) {
                    dragPointIndex = i;
                    startDragCorners = true;
                    break;
                }
            }
            if (!startDragCorners) {
                bitmapRect.set(cornerPointsNew[0].x, cornerPointsNew[0].y, cornerPointsNew[7].x, cornerPointsNew[7].y);
                if (isTouchHitBitmap(event, bitmapRect)) {
                    startDragBitmap = true;
                }
            }
            downX = event.getX();
            downY = event.getY();
            lastX = downX;
            lastY = downY;
        }
        if (event.getActionMasked() == MotionEvent.ACTION_MOVE) {
            if (startDragCorners) {
                float dx;
                // 2，4，7 向右是放大
                if (dragPointIndex == 2 || dragPointIndex == 4 || dragPointIndex == 7) {
                    dx = event.getX() - downX;
                    // 1，6 横向不放大
                } else if (dragPointIndex == 1 || dragPointIndex == 6) {
                    dx = 0;
                } else {
                    // 其他是向左放大
                    dx = downX - event.getX();
                }

                float dy;
                // 5，6，7 向下是放大
                if (dragPointIndex == 5 || dragPointIndex == 6 || dragPointIndex == 7) {
                    dy = event.getY() - downY;
                } else if (dragPointIndex == 3 || dragPointIndex == 4) {
                    // 3，4 纵向不放大
                    dy = 0;
                    // 其他是向上放大
                } else {
                    dy = downY - event.getY();
                }

                float scaleX = (1 + dx / bitmap.getWidth());
                float scaleY = (1 + dy / bitmap.getHeight());

                float scaledWidth = bitmap.getWidth() * scaleX;
                float scaledHeight = bitmap.getHeight() * scaleY;
                // 大于最小的宽高才允许缩放，不能缩放到更小，不然会崩溃,而且手指很难判定拉伸方向
                if (scaledWidth > radius * 6 && scaledHeight > radius * 6) {
                    float scaleXFromMatrix = getScaleXFromMatrix(canvasMatrix);
                    float scaleYFromMatrix = getScaleYFromMatrix(canvasMatrix);

                    PointF scaleCenter = cornerPointsNew[pointAndScalePoint[dragPointIndex]];
                    canvasMatrix.postScale(scaleX / scaleXFromMatrix, scaleY / scaleYFromMatrix, scaleCenter.x, scaleCenter.y);
                }
            } else if (startDragBitmap) {
                float dx = event.getX() - lastX;
                float dy = event.getY() - lastY;
                canvasMatrix.postTranslate(dx, dy);
            }
        }
        if (event.getActionMasked() == MotionEvent.ACTION_UP || event.getActionMasked() == MotionEvent.ACTION_CANCEL) {
            if (startDragCorners) {
                float scaleXFromMatrix = getScaleXFromMatrix(canvasMatrix);
                float scaleYFromMatrix = getScaleYFromMatrix(canvasMatrix);
                int dstWidth = (int) (bitmap.getWidth() * scaleXFromMatrix);
                int dstHeight = (int) (bitmap.getHeight() * scaleYFromMatrix);

                Log.d(TAG, "onTouchEvent() called with: scaleXFromMatrix = " + scaleXFromMatrix + ",scaleYFromMatrix = " + scaleYFromMatrix);
                Bitmap originalBitmap = decodeSampledBitmapFromPath(bitmapFilePath, maxBitmapWidth, maxBitmapHeight);
                bitmap = Bitmap.createScaledBitmap(originalBitmap, dstWidth, dstHeight, true);
                canvasMatrix.setTranslate(getTransXFromMatrix(canvasMatrix), getTransYFromMatrix(canvasMatrix));
                initCornersPosition();
            }
            startDragCorners = false;
            startDragBitmap = false;
        }

        lastX = event.getX();
        lastY = event.getY();

        invalidate();
        return true;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if (bitmap != null) {
            for (int i = 0; i < cornerPointsOrigin.length; i++) {
                matrixMapPoint(canvasMatrix, cornerPointsNew[i], cornerPointsOrigin[i]);
            }

            canvas.drawBitmap(bitmap, canvasMatrix, null);

            for (int i = 0; i < cornerPointsOrigin.length; i++) {
                canvas.drawCircle(cornerPointsNew[i].x, cornerPointsNew[i].y, radius, paint);
            }
            canvas.drawCircle(touchPosition.x, touchPosition.y, radius, paint);

        }
    }

    private void initCornersPosition() {
        cornerPointsOrigin[0] = new PointF(0f, 0f);
        cornerPointsOrigin[1] = new PointF(bitmap.getWidth() / 2f, 0f);
        cornerPointsOrigin[2] = new PointF(bitmap.getWidth(), 0f);
        cornerPointsOrigin[3] = new PointF(0f, bitmap.getHeight() / 2f);
        cornerPointsOrigin[4] = new PointF(bitmap.getWidth(), bitmap.getHeight() / 2f);
        cornerPointsOrigin[5] = new PointF(0f, bitmap.getHeight());
        cornerPointsOrigin[6] = new PointF(bitmap.getWidth() / 2f, bitmap.getHeight());
        cornerPointsOrigin[7] = new PointF(bitmap.getWidth(), bitmap.getHeight());

        for (int i = 0; i < cornerPointsOrigin.length; i++) {
            cornerPointsNew[i] = new PointF(cornerPointsOrigin[i].x, cornerPointsOrigin[i].y);
        }
    }


    public static final int TOLERANCE = 10;

    private boolean isTouchHitPoint(MotionEvent event, PointF pointF) {
        boolean xHit = event.getX() > pointF.x - radius - TOLERANCE && event.getX() < pointF.x + radius + TOLERANCE;
        boolean yHit = event.getY() > pointF.y - radius - TOLERANCE && event.getY() < pointF.y + radius + TOLERANCE;
        return xHit && yHit;
    }

    private boolean isTouchHitBitmap(MotionEvent event, RectF rectF) {
        boolean xHit = event.getX() > rectF.left && event.getX() < rectF.right;
        boolean yHit = event.getY() > rectF.top && event.getY() < rectF.bottom;
        return xHit && yHit;
    }

    private float getScaleXFromMatrix(Matrix matrix) {
        float[] values = new float[9];
        matrix.getValues(values);
        return values[0];
    }

    private float getScaleYFromMatrix(Matrix matrix) {
        float[] values = new float[9];
        matrix.getValues(values);
        return values[4];
    }

    private float getTransXFromMatrix(Matrix matrix) {
        float[] values = new float[9];
        matrix.getValues(values);
        return values[2];
    }

    private float getTransYFromMatrix(Matrix matrix) {
        float[] values = new float[9];
        matrix.getValues(values);
        return values[5];
    }

    private void matrixMapPoint(Matrix matrix, PointF dst, PointF src) {
        float[] srcPoint = new float[2];
        srcPoint[0] = src.x;
        srcPoint[1] = src.y;
        matrix.mapPoints(srcPoint);
        dst.set(srcPoint[0], srcPoint[1]);
    }

    public static Bitmap decodeSampledBitmapFromPath(String filePath, int reqWidth, int reqHeight) {

        // 首次加载获取图片的原始宽高
        final BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeFile(filePath, options);

        // 计算缩放比
        options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight);

        // 重新加载图片
        options.inJustDecodeBounds = false;
        return BitmapFactory.decodeFile(filePath, options);
    }

    public static int calculateInSampleSize(BitmapFactory.Options options, int reqWidth, int reqHeight) {
        // 图片的原始宽高
        final int height = options.outHeight;
        final int width = options.outWidth;
        int inSampleSize = 1;

        if (height > reqHeight || width > reqWidth) {

            final int halfHeight = height / 2;
            final int halfWidth = width / 2;

            // 计算缩放比，是2的指数，
            // 取宽高的最小缩放比，如宽的缩放比为2，高的缩放比为4，那么取2作为整体的缩放比
            while ((halfHeight / inSampleSize) >= reqHeight
                    && (halfWidth / inSampleSize) >= reqWidth) {
                inSampleSize *= 2;
            }
        }
        if (inSampleSize < 1) {
            inSampleSize = 1;
        }

        return inSampleSize;
    }
}
