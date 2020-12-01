package im.zego.goclass.tool;

import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import androidx.core.view.GestureDetectorCompat;
import androidx.recyclerview.widget.RecyclerView;

/**
 * 控件想要收到点击事件的回调，需要设置 clickable = true
 */
public class OnRecyclerViewItemTouchListener extends RecyclerView.SimpleOnItemTouchListener {
    private static final String TAG = "OnRecyclerViewItemTouch";
    private GestureDetectorCompat mGestureDetector;
    private RecyclerView attachedRecyclerView;

    public OnRecyclerViewItemTouchListener(RecyclerView recyclerView) {
        attachedRecyclerView = recyclerView;
        mGestureDetector = new GestureDetectorCompat(recyclerView.getContext(), new GestureDetector.SimpleOnGestureListener() {
            @Override
            public boolean onSingleTapUp(MotionEvent e) {
                View pressedChildView = attachedRecyclerView.findChildViewUnder(e.getX(), e.getY());
                if (pressedChildView != null) {
                    RecyclerView.ViewHolder holder = attachedRecyclerView.getChildViewHolder(pressedChildView);
                    if (findCallbackChild(e, pressedChildView, holder)) {
                        return true;
                    }
                    if (pressedChildView.isClickable()) {
                        View.OnClickListener onClickListener = view -> {
                        };
                        onClickListener.onClick(pressedChildView);
                        onItemClick(holder);
                    }
                } else {
                    onNoChildClicked();
                }
                return true;
            }

            @Override
            public boolean onDown(MotionEvent e) {
                View pressedChildView = attachedRecyclerView.findChildViewUnder(e.getX(), e.getY());
                if (pressedChildView != null) {
                    RecyclerView.ViewHolder holder = attachedRecyclerView.getChildViewHolder(pressedChildView);
                    onItemDown(holder);
                } else {
                }
                onRecyclerViewDown();
                return true;
            }

            @Override
            public void onLongPress(MotionEvent e) {
                super.onLongPress(e);
                View pressedChildView = attachedRecyclerView.findChildViewUnder(e.getX(), e.getY());
                if (pressedChildView != null) {
                    RecyclerView.ViewHolder holder = attachedRecyclerView.getChildViewHolder(pressedChildView);
                    View.OnLongClickListener onClickListener = view -> true;
                    onClickListener.onLongClick(pressedChildView);
                    onItemLongPress(holder);
                }
            }
        });
    }

    private boolean findCallbackChild(MotionEvent e, View pressedChildView, RecyclerView.ViewHolder holder) {
        if (pressedChildView instanceof ViewGroup) {
            for (int i = 0; i < ((ViewGroup) pressedChildView).getChildCount(); i++) {
                View child = ((ViewGroup) pressedChildView).getChildAt(i);
                if (child instanceof ViewGroup) {
                    boolean result = findCallbackChild(e, child, holder);
                    if (result) {
                        return true;
                    } else {
                        // 如果没找到，还要继续，不要return退出循环了
                        if (child.isClickable() && inRangeOfView(child, e)) {
                            return true;
                        }
                    }
                } else {
                    if (child.isClickable() && inRangeOfView(child, e)) {
                        View.OnClickListener onClickListener = view -> {
                        };
                        onClickListener.onClick(child);
                        onItemChildClick(holder, child);
                        return true;
                    }
                }
            }
        }
        return false;
    }

    @Override
    public boolean onInterceptTouchEvent(RecyclerView rv, MotionEvent e) {
        mGestureDetector.onTouchEvent(e);
        return false;
    }

    private boolean inRangeOfView(View view, MotionEvent ev) {
        int[] location = new int[2];
        if (view.getVisibility() != View.VISIBLE) {
            return false;
        } else {
            view.getLocationOnScreen(location);
            int x = location[0];
            int y = location[1];
            return ev.getRawX() >= (float) x && ev.getRawX() <= (float) (x + view.getWidth()) && ev.getRawY() >= (float) y && ev.getRawY() <= (float) (y + view.getHeight());
        }
    }

    /**
     * 子view中没有找到可以响应点击事件的控件的时候，才会考虑整个item的点击事件
     *
     * @param vh
     * @param itemChild
     */
    public void onItemChildClick(RecyclerView.ViewHolder vh, View itemChild) {

    }

    /**
     * 子view中没有找到可以响应点击事件的控件的时候，并且整个item可点击，会触发这个回调
     *
     * @param vh
     */
    public void onItemClick(RecyclerView.ViewHolder vh) {

    }

    /**
     * 整个item的按下事件,一般都会触发
     *
     * @param vh
     */
    public void onItemDown(RecyclerView.ViewHolder vh) {

    }

    /**
     * 整个recyclerView的按下事件，总是会触发
     */
    public void onRecyclerViewDown() {

    }

    /**
     * 整个item的长按事件
     *
     * @param holder
     */
    public void onItemLongPress(RecyclerView.ViewHolder holder) {

    }

    public void onNoChildClicked() {

    }
}
