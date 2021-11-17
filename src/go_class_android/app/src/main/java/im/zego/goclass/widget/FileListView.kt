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
import androidx.core.view.GravityCompat
import androidx.drawerlayout.widget.DrawerLayout
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.gson.Gson
import com.google.gson.JsonParser
import im.zego.goclass.dp2px
import im.zego.goclass.network.FileData
import im.zego.goclass.tool.OnRecyclerViewItemTouchListener
import im.zego.goclass.tool.SharedPreferencesUtil
import im.zego.goclass.tool.ToastUtils
import im.zego.goclass.R
import kotlinx.android.synthetic.main.layout_drawer_right.view.*
import okhttp3.*
import okhttp3.logging.HttpLoggingInterceptor
import java.io.IOException

/**
 * 点击底部'共享-文件'后弹出的文件列表
 */
class FileListView : RelativeLayout {
    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet) : super(context, attrs)
    constructor(context: Context, attrs: AttributeSet, defStyleAttr: Int)
            : super(context, attrs, defStyleAttr)

    private var onFileClick: (FileData) -> Unit = {}
    private var fileListAdapter: FileListAdapter
    var drawerParent: DrawerLayout? = null
    private val TAG = javaClass.simpleName

    init {
        LayoutInflater.from(context).inflate(R.layout.layout_drawer_right, this, true)
        setBackgroundColor(Color.WHITE)
        right_drawer_bottom.visibility = View.VISIBLE
        right_drawer_divider2.visibility = View.VISIBLE
        right_drawer_title.let {
            it.text = context.getString(R.string.room_file_select_file)
            val params = (it.layoutParams as? MarginLayoutParams)
                ?: MarginLayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT
                )
            it.layoutParams = params
        }

        main_drawer_list.let {
            fileListAdapter = FileListAdapter()
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
                    drawerParent?.closeDrawer(GravityCompat.END)
                    val adapter = it.adapter as FileListAdapter
                    onFileClick.invoke(adapter.getListData(vh.adapterPosition)!!)
                }
            }
            it.addOnItemTouchListener(touchListener)
        }

        val url = "https://storage.zego.im/goclass/config.json"
        val okHttpClient = OkHttpClient.Builder()
            .addInterceptor(HttpLoggingInterceptor().setLevel(HttpLoggingInterceptor.Level.BASIC))
            .build()
        val request: Request = Request.Builder()
            .url(url).build()
        val call: Call = okHttpClient.newCall(request)
        call.enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                ToastUtils.showCenterToast(context.getString(R.string.failed_to_get_file_list))
            }

            override fun onResponse(call: Call, response: Response) {
                val string = response.body!!.string()
                fileListAdapter.setFileListJson(string)
                post {
                    fileListAdapter.notifyDataSetChanged()
                }
            }
        })
    }

    fun setFileClickedListener(onFileClick: (FileData) -> Unit) {
        this.onFileClick = onFileClick
    }

    override fun onTouchEvent(event: MotionEvent?): Boolean {
        return true
    }
}

class FileListAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private var productList = mutableListOf<FileData>()
    private var testList = listOf<FileData>()
    private val TAG = javaClass.simpleName

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val view: View =
            LayoutInflater.from(parent.context).inflate(R.layout.item_file_list, parent, false)
        return object : RecyclerView.ViewHolder(view) {}
    }

    private fun getFileList(): List<FileData> {
        return productList
    }

    override fun getItemCount(): Int {
        return getFileList().size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val nameTextView = holder.itemView.findViewById<TextView>(R.id.item_file_name)
        val dynamicTextView = holder.itemView.findViewById<TextView>(R.id.item_file_dynamic)
        nameTextView.text = getFileList()[position].name
        if (getFileList()[position].isDynamic) {
            dynamicTextView.text = nameTextView.context.getString(R.string.room_file_dynamic)
            dynamicTextView.setBackgroundResource(R.drawable.drawable_file_type_dyn)
        }else if(getFileList()[position].isH5){
            dynamicTextView.text = nameTextView.context.getString(R.string.room_file_h5_file)
            dynamicTextView.setBackgroundResource(R.drawable.drawable_file_type_h5)
        } else {
            dynamicTextView.text = nameTextView.context.getString(R.string.room_file_static_file)
            dynamicTextView.setBackgroundResource(R.drawable.drawable_file_type_sta)
        }
    }

    fun getListData(position: Int): FileData? {
        if (position < 0 || position > itemCount - 1) {
            return null
        }
        return getFileList()[position]
    }

    fun setFileListJson(string: String) {
        Log.d(TAG, "setFileListJson() called with: string = $string")
        val gson = Gson()
        val jsonObject = JsonParser.parseString(string).asJsonObject
        val productJson = jsonObject["docs_prod"]
        val testJson = jsonObject["docs_test"]

        if (productJson != null) {
            productList = gson.fromJson(productJson, Array<FileData>::class.java).toMutableList()
            productList.add(FileData("cqpUKGnH3qg6IzUZ","测试pptx",true,false))
        }
        testList = gson.fromJson(testJson, Array<FileData>::class.java).toList()

        Log.d(TAG, "setFileListJson() called with: productList = $productList")
        Log.d(TAG, "setFileListJson() called with: testList = $testList")
    }
}

