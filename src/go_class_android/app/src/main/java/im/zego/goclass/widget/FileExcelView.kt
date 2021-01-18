package im.zego.goclass.widget

import android.content.Context
import android.graphics.Color
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import im.zego.goclass.R
import im.zego.goclass.dp2px
import im.zego.goclass.tool.OnRecyclerViewItemTouchListener
import kotlinx.android.synthetic.main.layout_drawer_right.view.*

class FileExcelView : RelativeLayout {
    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet) : super(context, attrs)
    constructor(context: Context, attrs: AttributeSet, defStyleAttr: Int)
            : super(context, attrs, defStyleAttr)

    private var onExcelClick: (Int) -> Unit = {}
    private var fileListAdapter: FileExcelAdapter

    init {
        LayoutInflater.from(context).inflate(R.layout.layout_drawer_right, this, true)
        setBackgroundColor(Color.WHITE)
        right_drawer_title.text = context.getString(R.string.wb_file_sheet_list)
        right_drawer_divider.visibility = View.GONE

        main_drawer_list.let {
            fileListAdapter = FileExcelAdapter()
            it.adapter = fileListAdapter
            it.isVerticalScrollBarEnabled = true
            it.layoutManager = LinearLayoutManager(context)
            val divider = RecyclerDivider(context).also { divider ->
                divider.setPadding(
                    dp2px(context, 11f).toInt(),
                    dp2px(context, 11f).toInt()
                )
                divider.setHeight(dp2px(context, 0.5f).toInt())
                divider.setColor(Color.parseColor("#edeff3"))
            }
            it.addItemDecoration(divider)
            val touchListener = object : OnRecyclerViewItemTouchListener(it) {
                override fun onItemClick(vh: RecyclerView.ViewHolder) {
                    if (vh.adapterPosition == RecyclerView.NO_POSITION) {
                        return
                    }
                    onExcelClick.invoke(vh.adapterPosition)
                }
            }
            it.addOnItemTouchListener(touchListener)
        }
    }

    fun setExcelClickedListener(onExcelClick: (Int) -> Unit) {
        this.onExcelClick = onExcelClick
    }

    override fun onTouchEvent(event: MotionEvent?): Boolean {
        return true
    }

    fun updateList(nameList: List<String>) {
        fileListAdapter.updateList(nameList)
        fileListAdapter.notifyDataSetChanged()
    }
}

class FileExcelAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    private var list = mutableListOf<String>()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val view: View =
            LayoutInflater.from(parent.context).inflate(R.layout.item_file_list, parent, false)
        return object : RecyclerView.ViewHolder(view) {}
    }

    override fun getItemCount(): Int {
        return list.size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val nameTextView = holder.itemView.findViewById<TextView>(R.id.item_file_name)
        val dynamicTextView = holder.itemView.findViewById<TextView>(R.id.item_file_dynamic)
        dynamicTextView.visibility = View.GONE
        nameTextView.text = list[position]
    }

    fun updateList(nameList: List<String>) {
        list.clear()
        list.addAll(nameList)
    }
}