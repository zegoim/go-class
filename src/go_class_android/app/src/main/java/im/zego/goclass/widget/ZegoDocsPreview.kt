package im.zego.goclass.widget

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.LinearSmoothScroller
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import im.zego.goclass.tool.Logger
import im.zego.goclass.R
import kotlinx.android.synthetic.main.item_preview_list.view.*

class ZegoDocsPreview : LinearLayout {
    constructor(context: Context?) : super(context)
    constructor(context: Context?, attrs: AttributeSet?) : super(context, attrs)
    constructor(context: Context?, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    )

    init {
        LayoutInflater.from(context).inflate(R.layout.item_preview_list, this, true)
        previewLayouManager = LinearLayoutManager(context)
        previewListAdapter = PreviewListAdapter()

        thumbnail_url_recyclerview.let {
            it.layoutManager = previewLayouManager
            previewListAdapter.thumbnail_url_list = ArrayList()
            it.adapter = previewListAdapter
            isVerticalScrollBarEnabled = true
            it.itemAnimator = null

        }
    }

    private var previewListAdapter: PreviewListAdapter
    private var previewLayouManager:LinearLayoutManager

    companion object {
        const val TAG = "ZegoDocsPreview"
    }

    fun setSelectedListener(onPageSelected: (Int, Int) -> Unit) {
        previewListAdapter.onPageSelected = onPageSelected
    }

    fun setThumbnailUrlList(urls: ArrayList<String>) {
        previewListAdapter.thumbnail_url_list = urls
        previewListAdapter.notifyDataSetChanged()
    }
    /**
     * @param page first page is 0
     */
    fun setSelectedPage(page: Int) {
        if (page < 0) {
            Logger.e(TAG, "setSelectedPage() page $page")
            return
        }
//        if (page == previewListAdapter.selectedPage) {
            //ignore same page msg
//            return
//        }
        Logger.i(TAG, "setSelectedPage() page = $page previewListAdapter.selectedPage ${previewListAdapter.selectedPage}")
        // 1、先处理窗口是否要滑动
        jump(page)
        // 2、变更选中item
        previewListAdapter.selectedPage(page)
    }

    /**
     * @param page 当前选中页，在能上下滑动的前提下，要显示在第二个位置。
     */
    fun jump(page: Int) {
        Logger.i(TAG, "jump() page = $page")
        var prePage = page
        if (prePage < 0) {
            Logger.w(TAG, "jump() error page = $page")
            return
        } else if (prePage > 0) {
            prePage--
        }

        //         * <p>Each instance of SmoothScroller is intended to only be used once. Provide a new
        //         * SmoothScroller instance each time this method is called.
        val smoothScroller = object  : LinearSmoothScroller(context) {
            override fun getVerticalSnapPreference(): Int {
                return SNAP_TO_START
            }
        }
        smoothScroller.targetPosition = prePage
        thumbnail_url_recyclerview.layoutManager?.startSmoothScroll(smoothScroller)
    }

    class PreviewListAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder> () {

        var thumbnail_url_list = ArrayList<String>()
        var selectedPage = -1

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
            val view : View = LayoutInflater.from(parent.context).inflate(R.layout.item_preview, parent, false)
            return object : RecyclerView.ViewHolder(view){}
        }

        override fun getItemCount(): Int {
            return thumbnail_url_list.size
        }

        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
            val isSelected = position == selectedPage
            holder.itemView.setOnClickListener{
                if (selectedPage != position) {
                    // 翻页成功后会有回调，在回调中设置选中item和滑动到指定item
                    onPageSelected(selectedPage, position)
                }
            }

            holder.itemView.isSelected = isSelected
            holder.itemView.findViewById<TextView>(R.id.preview_index).let {
                it.text = (position +1).toString()
                it.isSelected = isSelected
            }

            holder.itemView.findViewById<ImageView>(R.id.preview_img).let {
                Glide.with(it.context).load(thumbnail_url_list[position]).into(it)
                it.isSelected = isSelected
            }
        }

        fun selectedPage(position: Int) {
                var oldSelected = selectedPage
                if (oldSelected != -1) {
                    notifyItemChanged(oldSelected)
                }
                selectedPage = position
                notifyItemChanged(position)
        }

        var onPageSelected: (oldPage: Int, newPage: Int) -> Unit = { _, _ -> }
    }

}