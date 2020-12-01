package im.zego.goclass.widget

import android.content.Context
import android.view.*
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import im.zego.goclass.tool.OnRecyclerViewItemTouchListener
import im.zego.goclass.R


class FontFamilyPopWindow(context: Context) : BasePopWindow(
    context,
    contentView = LayoutInflater.from(context).inflate(R.layout.popwindow_font_family, null, false)
) {
    private var selectedListener: (String) -> Unit = {}
    private var list =
        listOf(context.getString(R.string.font_sc), context.getString(R.string.font_system))

    init {
        contentView.findViewById<RecyclerView>(R.id.font_family_list).let {
            it.adapter = FontFamilyListAdapter(list)
            it.layoutManager = LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false)
            it.addOnItemTouchListener(object : OnRecyclerViewItemTouchListener(it) {
                override fun onItemClick(vh: RecyclerView.ViewHolder) {
                    val adapterPosition = vh.adapterPosition
                    if (adapterPosition == RecyclerView.NO_POSITION) {
                        return
                    }
                    val itemView = vh.itemView.findViewById<TextView>(R.id.item_font_family_name)
                    selectedListener.invoke(itemView.text.toString())
                }
            })
        }
    }

    fun show(anchor: View) {
        show(anchor, Gravity.BOTTOM)
    }

    fun setOnItemClickListener(listener: (String) -> Unit) {
        this.selectedListener = listener
    }
}

class FontFamilyListAdapter(list: List<String>) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    private val fontList = list

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val view: View =
            LayoutInflater.from(parent.context)
                .inflate(R.layout.item_font_family_list, parent, false)
        return object : RecyclerView.ViewHolder(view) {}
    }

    override fun getItemCount(): Int {
        return fontList.size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val nameTextView = holder.itemView.findViewById<TextView>(R.id.item_font_family_name)
        nameTextView.text = fontList[position]
    }
}