package im.zego.goclass.widget

import android.content.Context
import android.graphics.Color
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import im.zego.goclass.dp2px
import im.zego.goclass.classroom.ClassRoomManager
import im.zego.goclass.classroom.ClassUser
import im.zego.goclass.widget.UserListAdapter.InnerItemOnclickListener
import im.zego.goclass.R
import im.zego.goclass.network.ZegoApiErrorCode
import im.zego.goclass.tool.ToastUtils
import kotlinx.android.synthetic.main.layout_drawer_right.view.*

/**
 * 成员列表
 */
class ClassUserListView : RelativeLayout {
    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet) : super(context, attrs)
    constructor(context: Context, attrs: AttributeSet, defStyleAttr: Int)
            : super(context, attrs, defStyleAttr)

    private var userListAdapter: UserListAdapter

    init {
        LayoutInflater.from(context).inflate(R.layout.layout_drawer_right, this, true)
        setBackgroundColor(Color.WHITE)
        right_drawer_title.let {
            it.text = context.getString(R.string.room_member_joined, ClassRoomManager.mRoomUserMap.size)
            val params = (it.layoutParams as? MarginLayoutParams)
                ?: MarginLayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT
                )
            it.layoutParams = params
        }


        main_drawer_list.let {
            userListAdapter = UserListAdapter()
            isVerticalScrollBarEnabled = true
            it.adapter = userListAdapter
            userListAdapter.setOnInnerItemOnClickListener(object : InnerItemOnclickListener {
                override fun onMicClick(user: ClassUser) {
                    ClassRoomManager.setUserMic(user.userId, !user.micOn) {errorCode ->
                        ToastUtils.showCenterToast(
                            ZegoApiErrorCode.getPublicMsgFromCode(
                                errorCode,
                                context
                            )
                        )
                    }
                }

                override fun onCameraClick(user: ClassUser) {
                    ClassRoomManager.setUserCamera(user.userId, !user.cameraOn) {errorCode ->
                        ToastUtils.showCenterToast(
                            ZegoApiErrorCode.getPublicMsgFromCode(
                                errorCode,
                                context
                            )
                        )
                    }
                }

                override fun onShareClick(user: ClassUser) {
                    ClassRoomManager.setUserShare(user.userId, !user.sharable) {errorCode ->
                        ToastUtils.showCenterToast(
                            ZegoApiErrorCode.getPublicMsgFromCode(
                                errorCode,
                                context
                            )
                        )
                    }
                }
            })
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
        }
    }

    override fun onTouchEvent(event: MotionEvent?): Boolean {
        return true
    }

    fun addUser(classUser: ClassUser) {
        userListAdapter.addData(classUser)
        right_drawer_title.text = context.getString(
            R.string.room_member_joined, userListAdapter.itemCount
        )
    }

    fun removeUser(classUser: ClassUser) {
        userListAdapter.removeData(classUser)
        right_drawer_title.text = context.getString(
            R.string.room_member_joined, userListAdapter.itemCount
        )
    }

    fun updateAll() {
        val userList = ClassRoomManager.mRoomUserMap.values.toMutableList()
        userListAdapter.updateAll(userList)
        right_drawer_title.text =
            context.getString(R.string.room_member_joined, userListAdapter.itemCount)
    }

    private fun onStateChange(
        targetUserId: Long,
        cameraOn: Boolean,
        micOn: Boolean,
        shareOn: Boolean,
    ) {
        ClassRoomManager.mRoomUserMap.forEach {
            if (it.key == targetUserId) {
                it.value.cameraOn = cameraOn
                it.value.micOn = micOn
                it.value.sharable = shareOn
            }
        }
    }

}

class UserListAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private var list = mutableListOf<ClassUser>()
    private var mListener: InnerItemOnclickListener? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val view: View =
            LayoutInflater.from(parent.context).inflate(R.layout.item_user_list, parent, false)
        return object : RecyclerView.ViewHolder(view) {}
    }

    override fun getItemCount(): Int {
        return list.size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val nameTextView = holder.itemView.findViewById<TextView>(R.id.item_file_name)
        val ivMic = holder.itemView.findViewById<ImageView>(R.id.iv_mic)
        val ivCamera = holder.itemView.findViewById<ImageView>(R.id.iv_camera)
        val ivShare = holder.itemView.findViewById<ImageView>(R.id.iv_share)

        val classUser = list[position]
        val me = ClassRoomManager.me()

        var text = classUser.userName
        if (classUser.isTeacher()) {
            text += nameTextView.context.getString(R.string.teacher_suffix)
        } else if (classUser.userId == me.userId) {
            text += nameTextView.context.getString(R.string.room_member_me)
        }
        nameTextView.text = text

        // 老师视角不显示自己的麦克风摄像头等，但是显示学生的
        // 学生视角 全部不显示
        // 大班课 全部不显示
        if (ClassRoomManager.isSmallClass() && me.isTeacher() && classUser.userId != me.userId) {
            ivCamera.visibility = View.VISIBLE
            ivMic.visibility = View.VISIBLE
            ivShare.visibility = View.VISIBLE
        } else {
            ivCamera.visibility = View.GONE
            ivMic.visibility = View.GONE
            ivShare.visibility = View.GONE
        }

        if (me.isTeacher()) {
            if (classUser.micOn) {
                ivMic.setImageResource(R.drawable.mumber_micophone)
            } else {
                ivMic.setImageResource(R.drawable.mumber_micophone_close)
            }

            if (classUser.cameraOn) {
                ivCamera.setImageResource(R.drawable.mumber_camera)
            } else {
                ivCamera.setImageResource(R.drawable.mumber_camera_close)
            }

            if (classUser.sharable) {
                ivShare.setImageResource(R.drawable.mumber_share)
            } else {
                ivShare.setImageResource(R.drawable.mumber_share_close)
            }
            nameTextView.setPadding(0, 0, 0, 0)
        } else {
            nameTextView.setPadding(0, 0, 40, 0)
        }

        mListener?.run {
            ivMic.setOnClickListener {
                this.onMicClick(classUser)
            }
            ivCamera.setOnClickListener {
                this.onCameraClick(classUser)
            }
            ivShare.setOnClickListener {
                this.onShareClick(classUser)
            }
        }
    }

    fun getListData(position: Int): ClassUser? {
        if (position < 0 || position > itemCount - 1) {
            return null
        }
        return list[position]
    }

    fun addData(classUser: ClassUser) {
        list.add(classUser)
        sortList()
        notifyDataSetChanged()
    }

    fun removeData(classUser: ClassUser) {
        list.remove(classUser)
        sortList()
        notifyDataSetChanged()
    }

    fun updateAll(userList: Collection<ClassUser>) {
        list.clear()
        list.addAll(userList)
        sortList()
        notifyDataSetChanged()
    }

    private fun sortList() {
        list.sortWith(object : Comparator<ClassUser> {
            override fun compare(user1: ClassUser, user2: ClassUser): Int {
                val userId = ClassRoomManager.me().userId
                // 先判断老师，老师优先
                if (user1.isTeacher() && !user2.isTeacher()) {
                    return -1
                } else if (!user1.isTeacher() && user2.isTeacher()) {
                    return 1
                } else {
                    // 再判断是不是自己，自己优先
                    return if (user1.userId == userId) {
                        -1
                    } else if (user2.userId == userId) {
                        1
                    } else {
                        // 再判断连麦状态，连麦优先
                        if (user1.isJoinLive() && !user2.isJoinLive()) {
                            -1
                        } else if (!user1.isJoinLive() && user2.isJoinLive()) {
                            1
                        } else {
                            // 都没有连麦或者都在连麦，按加入时间排序
                            (user1.loginTime - user2.loginTime).toInt()
                        }
                    }
                }
            }
        })
    }

    fun setOnInnerItemOnClickListener(listener: InnerItemOnclickListener) {
        mListener = listener
    }

    interface InnerItemOnclickListener {
        fun onMicClick(user: ClassUser)
        fun onCameraClick(user: ClassUser)
        fun onShareClick(user: ClassUser)
    }
}