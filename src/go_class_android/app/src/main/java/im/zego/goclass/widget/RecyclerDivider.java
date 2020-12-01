package im.zego.goclass.widget;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.view.View;

import androidx.recyclerview.widget.RecyclerView;

public class RecyclerDivider extends RecyclerView.ItemDecoration {
    private int paddingStart = 0;
    private int paddingEnd = 0;
    private Rect mBounds = new Rect();
    private Paint mPaint;
    private int dividerHeight;
    private int dividerColor;

    public RecyclerDivider(Context context) {
        mPaint = new Paint();
        mPaint.setAntiAlias(true);
        mPaint.setColor(Color.BLACK);
    }

    public void setPadding(int paddingStart, int paddingEnd) {
        this.paddingStart = paddingStart;
        this.paddingEnd = paddingEnd;
    }

    public void setHeight(int dividerHeight) {
        this.dividerHeight = dividerHeight;
    }

    public void setColor(int color) {
        this.dividerColor = color;
        mPaint.setColor(color);
    }

    @Override
    public void onDraw(Canvas canvas, RecyclerView parent, RecyclerView.State state) {
        super.onDraw(canvas, parent, state);
        if (parent.getLayoutManager() == null) {
            return;
        }
        canvas.save();
        final int left;
        final int right;
        //noinspection AndroidLintNewApi - NewApi lint fails to handle overrides.
        if (parent.getClipToPadding()) {
            left = parent.getPaddingLeft();
            right = parent.getWidth() - parent.getPaddingRight();
            canvas.clipRect(left, parent.getPaddingTop(), right,
                    parent.getHeight() - parent.getPaddingBottom());
        } else {
            left = 0;
            right = parent.getWidth();
        }

        final int childCount = parent.getChildCount();
        for (int i = 0; i < childCount; i++) {
            final View child = parent.getChildAt(i);
            parent.getDecoratedBoundsWithMargins(child, mBounds);
            final int top = mBounds.bottom + Math.round(child.getTranslationY()) - dividerHeight;
            final int bottom = top + dividerHeight;
            canvas.drawRect(left + paddingStart, top, right - paddingEnd, bottom, mPaint);
        }
        canvas.restore();

    }

    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent,
                               RecyclerView.State state) {
        outRect.set(0, 0, 0, dividerHeight);
    }
}
