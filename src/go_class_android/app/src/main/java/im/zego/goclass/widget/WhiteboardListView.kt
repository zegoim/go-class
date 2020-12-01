package im.zego.goclass.widget

import android.content.Context
import android.graphics.Color
import android.util.AttributeSet
import android.util.Log
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.drawerlayout.widget.DrawerLayout
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import im.zego.goclass.tool.OnRecyclerViewItemTouchListener
import im.zego.goclass.R
import im.zego.goclass.dp2px
import im.zego.zegowhiteboard.model.ZegoWhiteboardViewModel
import kotlinx.android.synthetic.main.layout_drawer_right.view.*

class WhiteboardListView : RelativeLayout {
    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet) : super(context, attrs)
    constructor(context: Context, attrs: AttributeSet, defStyleAttr: Int)
            : super(context, attrs, defStyleAttr)

    private var onWhiteboardItemClosed: (Long) -> Unit = {}
    private var onWhiteboardItemSelected: (ZegoWhiteboardViewModel?) -> Unit = {}

    private val TAG = "WhiteboardListView"
    var whiteboardListAdapter: WhiteboardListAdapter
    var drawerParent: DrawerLayout? = null

    init {
        LayoutInflater.from(context).inflate(R.layout.layout_drawer_right, this, true)
        setBackgroundColor(Color.WHITE)
        right_drawer_title.let {
            it.text = context.getString(R.string.whiteboard_list_title)
            val params = (it.layoutParams as? MarginLayoutParams)
                ?: MarginLayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT
                )
            it.layoutParams = params
        }

        main_drawer_list.let {
            whiteboardListAdapter = WhiteboardListAdapter()
            it.adapter = whiteboardListAdapter
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
                override fun onItemChildClick(vh: RecyclerView.ViewHolder, itemChild: View) {
                    if (itemChild.id == R.id.item_close) {
                        if (vh.adapterPosition == RecyclerView.NO_POSITION) {
                            return
                        }
                        val simpleListAdapter = it.adapter as WhiteboardListAdapter
                        simpleListAdapter.getListData(vh.adapterPosition)?.let { model ->
                            val title =
                                context.getString(R.string.tips_close_whiteboard, model.name)
                            val zegoDialog = ZegoDialog.Builder(context).setMessage(title)
                                .setPositiveButton(R.string.button_confirm) { dialog, _ ->
                                    dialog.dismiss()
                                    onWhiteboardItemClosed.invoke(model.whiteboardID)
                                }
                                .setNegativeButton(R.string.button_cancel) { dialog, _ ->
                                    dialog.dismiss()
                                }.create()
                            zegoDialog.showWithLengthLimit()
                        }
                    }
                }

                override fun onItemClick(vh: RecyclerView.ViewHolder) {
                    if (vh.adapterPosition == RecyclerView.NO_POSITION) {
                        return
                    }
                    val simpleListAdapter = it.adapter as WhiteboardListAdapter
                    val listData = simpleListAdapter.getListData(vh.adapterPosition)

                    onWhiteboardItemSelected.invoke(listData)
                }
            }
            it.addOnItemTouchListener(touchListener)
        }
    }

    fun addWhiteboard(zegoWhiteboardViewModel: ZegoWhiteboardViewModel) {
        Log.i(TAG, "addWhiteboard,${zegoWhiteboardViewModel.whiteboardID}")
        if (whiteboardListAdapter.add(zegoWhiteboardViewModel)) {
            whiteboardListAdapter.sortList()
            whiteboardListAdapter.notifyDataSetChanged()
        }
    }

    fun setSelectedWhiteboard(whiteboardID: Long) {
        if (whiteboardListAdapter.containsWhiteboardID(whiteboardID)) {
            whiteboardListAdapter.selectedWhiteboardID = whiteboardID
            whiteboardListAdapter.sortList()
            whiteboardListAdapter.notifyDataSetChanged()
        }
    }

    fun getNextSelectID(whiteboardID: Long): Long {
        val listData = whiteboardListAdapter.getListData(0)
        return listData?.whiteboardID ?: 0L
    }

    fun containsFileID(zegoWhiteboardViewModel: ZegoWhiteboardViewModel): Boolean {
        return whiteboardListAdapter.containsFileID(zegoWhiteboardViewModel.fileInfo.fileID)
    }

    fun removeWhiteboard(whiteboardID: Long) {
        Log.i(TAG, "removeWhiteboard,${whiteboardID}")
        val selected = whiteboardListAdapter.selectedWhiteboardID
        if (whiteboardListAdapter.remove(whiteboardID)) {
            setSelectedWhiteboard(selected)
            whiteboardListAdapter.notifyDataSetChanged()
        }
    }

    fun removeAllWhiteboard(){
        whiteboardListAdapter.removeAll()
    }

    fun setWhiteboardItemSelectedListener(onWhiteboardItemSelected: (ZegoWhiteboardViewModel?) -> Unit) {
        this.onWhiteboardItemSelected = onWhiteboardItemSelected
    }

    fun setWhiteboardItemDeleteListener(onWhiteboardItemClosed: (Long) -> Unit) {
        this.onWhiteboardItemClosed = onWhiteboardItemClosed
    }

    override fun onTouchEvent(event: MotionEvent?): Boolean {
        return true
    }
}

class WhiteboardListAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    private var list: MutableList<ZegoWhiteboardViewModel> = mutableListOf()
    var selectedPosition = 0

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val view: View =
            LayoutInflater.from(parent.context)
                .inflate(R.layout.item_whiteboard_list, parent, false)
        return object : RecyclerView.ViewHolder(view) {}
    }

    override fun getItemCount(): Int {
        list.distinct()
        return list.size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val nameTextView = holder.itemView.findViewById<TextView>(R.id.item_name)
        nameTextView.text = list[position].name
        nameTextView.isSelected = selectedPosition == position
    }

    fun add(zegoWhiteboardViewModel: ZegoWhiteboardViewModel): Boolean {
        val firstOrNull =
            list.firstOrNull { zegoWhiteboardViewModel.whiteboardID == it.whiteboardID }
        return if (firstOrNull == null) {
            list.add(zegoWhiteboardViewModel)
            true
        } else {
            false
        }
    }

    var selectedWhiteboardID: Long
        set(value) {
            val indexOfFirst = list.indexOfFirst { it.whiteboardID == value }
            selectedPosition = indexOfFirst
        }
        get() {
            val listData = getListData(selectedPosition)
            return listData?.whiteboardID ?: -1
        }

    fun remove(whiteboardID: Long): Boolean {
        var result = false
        list.firstOrNull { whiteboardID == it.whiteboardID }?.let {
            result = true
            list.remove(it)
        }
        return result
    }

    fun getListData(position: Int): ZegoWhiteboardViewModel? {
        if (position < 0 || position > itemCount - 1) {
            return null
        }
        return list[position]
    }

    fun containsWhiteboardID(whiteboardID: Long): Boolean {
        val firstOrNull = list.firstOrNull { whiteboardID == it.whiteboardID }
        return firstOrNull != null
    }

    fun containsFileID(fileID: String): Boolean {
        val firstOrNull = list.firstOrNull { fileID == it.fileInfo.fileID }
        return firstOrNull != null && fileID.isNotEmpty()
    }

    fun sortList() {
        list.sortByDescending { it.createTime }
    }

    fun removeAll(){
        list.clear()
    }
}
