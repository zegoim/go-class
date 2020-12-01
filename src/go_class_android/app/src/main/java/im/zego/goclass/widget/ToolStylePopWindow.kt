package im.zego.goclass.widget

import android.content.Context
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import im.zego.zegowhiteboard.ZegoWhiteboardManager
import im.zego.goclass.R
import im.zego.goclass.dp2px
import im.zego.goclass.tool.OnRecyclerViewItemTouchListener
import im.zego.goclass.tool.ZegoUtil.*

class ToolStylePopWindow(context: Context) : BasePopWindow(
    context,
    contentView = LayoutInflater.from(context).inflate(R.layout.popwindow_style, null, false)
) {
    init {
        contentView.findViewById<RecyclerView>(R.id.style_lineWidth_recyclerview).let {
            val widthAdapter = LineWidthAdapter()
            widthAdapter.selectedSize = ZegoWhiteboardManager.getInstance().brushSize
            it.adapter = widthAdapter
            it.layoutManager =
                LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
            it.addOnItemTouchListener(object : OnRecyclerViewItemTouchListener(it) {
                override fun onItemClick(vh: RecyclerView.ViewHolder) {
                    val adapterPosition = vh.adapterPosition
                    if (adapterPosition == RecyclerView.NO_POSITION) {
                        return
                    }
                    widthAdapter.selectedIndex = adapterPosition
                    widthAdapter.notifyDataSetChanged()
                    ZegoWhiteboardManager.getInstance().brushSize =
                        widthAdapter.selectedSize
                }
            })
        }

        contentView.findViewById<RecyclerView>(R.id.style_color_recyclerview).let {
            val colorAdapter = ColorAdapter(context)
            colorAdapter.selectedColor = ZegoWhiteboardManager.getInstance().brushColor
            it.adapter = colorAdapter
            it.layoutManager = GridLayoutManager(context, 6)
            it.addOnItemTouchListener(object : OnRecyclerViewItemTouchListener(it) {
                override fun onItemClick(vh: RecyclerView.ViewHolder) {
                    val adapterPosition = vh.adapterPosition
                    if (adapterPosition == RecyclerView.NO_POSITION) {
                        return
                    }
                    colorAdapter.selectedIndex = adapterPosition
                    colorAdapter.notifyDataSetChanged()
                    ZegoWhiteboardManager.getInstance().brushColor =
                        colorAdapter.selectedColor
                }
            })
        }
        contentView.findViewById<RecyclerView>(R.id.style_font_recyclerview).let {
            val fontAdapter = FontAdapter()
            fontAdapter.selectedSize = ZegoWhiteboardManager.getInstance().fontSize
            it.adapter = fontAdapter
            it.layoutManager =
                LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
            it.addOnItemTouchListener(object : OnRecyclerViewItemTouchListener(it) {
                override fun onItemClick(vh: RecyclerView.ViewHolder) {
                    val adapterPosition = vh.adapterPosition
                    if (adapterPosition == RecyclerView.NO_POSITION) {
                        return
                    }
                    fontAdapter.selectedIndex = adapterPosition
                    fontAdapter.notifyDataSetChanged()
                    ZegoWhiteboardManager.getInstance().fontSize = fontAdapter.selectedSize
                }
            })
        }

        contentView.findViewById<ImageView>(R.id.item_style_font_bold).let {
            it.isSelected = ZegoWhiteboardManager.getInstance().isFontBold
            if (it.isSelected) {
                it.setImageResource(R.drawable.text_bold_select_1)
            } else {
                it.setImageResource(R.drawable.text_bold_1)
            }
            it.background = getFontBgDrawable(it.context)
            it.setOnClickListener { iv ->
                it.isSelected = !it.isSelected
                if (it.isSelected) {
                    it.setImageResource(R.drawable.text_bold_select_1)
                } else {
                    it.setImageResource(R.drawable.text_bold_1)
                }
                ZegoWhiteboardManager.getInstance().isFontBold = it.isSelected
                it.background = getFontBgDrawable(it.context)
            }
        }

        contentView.findViewById<ImageView>(R.id.item_style_font_italic).let {
            it.isSelected = ZegoWhiteboardManager.getInstance().isFontItalic
            if (it.isSelected) {
                it.setImageResource(R.drawable.text_italic_select_1)
            } else {
                it.setImageResource(R.drawable.text_italic_1)
            }
            it.background = getFontBgDrawable(it.context)
            it.setOnClickListener { iv ->
                it.isSelected = !it.isSelected
                if (it.isSelected) {
                    it.setImageResource(R.drawable.text_italic_select_1)
                } else {
                    it.setImageResource(R.drawable.text_italic_1)
                }
                ZegoWhiteboardManager.getInstance().isFontItalic = it.isSelected
                it.background = getFontBgDrawable(it.context)
            }
        }
    }

    fun show(anchor: View) {
        show(anchor, Gravity.START, -dp2px(anchor.context, 3f).toInt(), 0)
    }
}

class ColorAdapter(context: Context) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    private val colorArray: IntArray = context.resources.getIntArray(R.array.graffiti_color)
    internal var selectedIndex = 4
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val view: View = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_style_color, parent, false)
        return object : RecyclerView.ViewHolder(view) {}
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val circle: CircleImageView =
            holder.itemView.findViewById(R.id.item_style_color)
        circle.circleBackgroundColor = colorArray[position]
        val ticker =
            holder.itemView.findViewById<ImageView>(R.id.item_style_ticker)
        if (position == 0) {
            ticker.setImageResource(R.drawable.click_color)
        } else {
            ticker.setImageResource(R.drawable.click_none)
        }
        ticker.visibility = if (position == selectedIndex) View.VISIBLE else View.GONE
    }

    var selectedColor: Int
        get() = colorArray[selectedIndex]
        set(value) {
            val index = colorArray.indexOfFirst { it == value }
            if (index != -1) {
                selectedIndex = index
            }
        }

    override fun getItemCount() = colorArray.size
}

class FontAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    private val fontArray = intArrayOf(18, 24, 36, 48)
    internal var selectedIndex = 1
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val view: View = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_style_font, parent, false)
        return object : RecyclerView.ViewHolder(view) {}
    }

    override fun getItemCount(): Int {
        return fontArray.size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val fontTextView = holder.itemView.findViewById<TextView>(R.id.item_style_font_size)
        val layoutParam = fontTextView.layoutParams as FrameLayout.LayoutParams
        fontTextView.layoutParams = layoutParam
        fontTextView.text = fontArray[position].toString()
        fontTextView.background = getFontBgDrawable(fontTextView.context)
        fontTextView.isSelected = selectedIndex == position
    }

    var selectedSize: Int
        get() = fontArray[selectedIndex]
        set(value) {
            val index = fontArray.indexOfFirst { it == value }
            if (index != -1) {
                selectedIndex = index
            }
        }
}

class LineWidthAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    private val widthArray = intArrayOf(4, 6, 8, 10)
    internal var selectedIndex = 0
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val view: View = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_style_linewidth, parent, false)
        return object : RecyclerView.ViewHolder(view) {}
    }

    override fun getItemCount(): Int {
        return widthArray.size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val lineWidth = holder.itemView.findViewById<ImageView>(R.id.item_style_line_size)
        val layoutParam = lineWidth.layoutParams as FrameLayout.LayoutParams
        val context = lineWidth.context
        when (position) {
            0 -> {
                layoutParam.gravity = Gravity.START
                layoutParam.marginStart = dp2px(context, 16f).toInt()
            }
            itemCount - 1 -> {
                layoutParam.gravity = Gravity.END
                layoutParam.marginEnd = dp2px(context, 16f).toInt()
            }
            else -> {
                layoutParam.gravity = Gravity.CENTER
            }
        }
        layoutParam.height = dp2px(context, (4f + itemCount - 1) * 2).toInt()
        lineWidth.layoutParams = layoutParam
        val brushWidthDrawable =
            getBrushWidthDrawable(dp2px(context, 4f + position).toInt())
        lineWidth.setImageDrawable(brushWidthDrawable)
        lineWidth.isSelected = selectedIndex == position
    }

    var selectedSize: Int
        get() = widthArray[selectedIndex]
        set(value) {
            val index = widthArray.indexOfFirst { it == value }
            if (index != -1) {
                selectedIndex = index
            }
        }
}
