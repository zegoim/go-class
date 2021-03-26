/*
 * @Description: 后台业务处理
 * @FilePath: /web-go-class-demo/src/service/biz/room.js
 */

import Vue from 'vue'
import axios from 'axios'
import { Message } from 'element-ui'
import zegoClient from '@/service/zego/zegoClient/index'
import { ROLE_STUDENT, ROLE_TEACHER, STATE_CLOSE, STATE_OPEN, ZEGOENV } from '@/utils/constants'
import { YOUR_HOME_BACKEND_URL, YOUR_OVERSEAS_BACKEND_URL } from '@/utils/config_data'
import i18n from "../../i18n"
export const bus = new Vue()

Vue.prototype.$bus = bus

const timeout = 10000
// const loginCodes = [10005, 10006]
const loginCodes = [10006]
const errorTips = {
  'Network Error': i18n.t('login.login_network_exception'),
  [`timeout of ${timeout}ms exceeded`]: i18n.t('system.timeout_exceeded'),
  'Internal Server Error': i18n.t('system.internal_serve_error'),
  'Request failed with status code 502': i18n.t('system.request_failed_code_502'),
  10001: i18n.t('login.login_other_teacher_in_the_class'),
  10002: i18n.t('login.login_class_is_full'),
  10003: i18n.t('system.user_no_permission'),
  10004: i18n.t('system.target_user_not_in_room'),
  10005: i18n.t('system.need_login'),
  10006: i18n.t('login.login_room_not_exist'),
  10007: i18n.t('room.room_tip_channels')
}

const translateError = res => {
  res.ret.message = errorTips[res.ret.code] || res.ret.message || i18n.t('login.login_network_exception')
}

const handleError = res => {
  Message.closeAll()
  console.warn(res.ret.message)
  Message({
    customClass: 'common-toast',
    type: 'error',
    message: res.ret.message
  })
  if (loginCodes.includes(res.ret.code)) {
    window.location.hash = '#/login'
  }
}

const hostMap = {
  home: YOUR_HOME_BACKEND_URL,
  overseas: YOUR_OVERSEAS_BACKEND_URL
}
const http = axios.create({
  baseURL: hostMap.home,
  timeout
})

http.interceptors.response.use(
  ({ data }) => {
    if (data.ret.code == 0) {
      return data
    }
    translateError(data)
    handleError(data)
    return Promise.reject(data)
  },
  error => {
    let msg = error.message
    if (msg) {
      msg = errorTips[msg] || msg
      Message.closeAll()
      Message({
        customClass: 'common-toast',
        type: 'error',
        message: msg
      })
    }
    return Promise.reject(error)
  }
)

export const setGoclassEnv = env => {
  http.defaults.baseURL = hostMap[ZEGOENV.goclass+env] || hostMap.home
}
export const postRoomHttp = (api, data) => http.post(api, data)

class RoomStore {
  roomId = ''
  uid = ''
  name = ''
  role = 0
  route = '' // from route name
  room_type = 1
  heartBeatId = 0
  attendeeListSeq = 0
  joinLiveListSeq = 0
  attendeeList = []
  joinLiveList = []
  params = {}
  auth = { camera: STATE_OPEN, mic: STATE_OPEN, can_share: STATE_CLOSE, share: false }
  inited = false

  init({ roomId, uid, name, role, route, room_type }) {
    this.roomId = roomId
    this.uid = +uid
    this.name = name
    this.role = role
    this.route = route
    this.params.room_id = roomId
    this.params.uid = uid
    this.params.room_type = room_type
    if (role == ROLE_TEACHER) {
      this.auth.can_share = STATE_OPEN
      this.auth.share = true
    }
    if (!this.inited) {
      this.inited = true
      // vue组件监听事件设置完毕后才能开始
      setTimeout(() => {
        this.startHeartBeat()
        this.registerPushEvent()
        this.getAttendeeList()
          .then(this.getJoinLiveList.bind(this))
          .then(this.getControlAuth.bind(this))
      })
    }
  }

  registerPushEvent() {
    zegoClient._client.on('IMRecvCustomCommand',(roomid, fromUser, command)=>{
      try {
        let res = JSON.parse(command)
        console.warn('后台 message',res)
        console.log('====edu_zpush====', res)
        if (res.cmd == 102) {
          this.onUserStateChange(res.data)
        } else if (res.cmd == 103) {
          this.notifyAttendeeChange(res.data)
          this.getAttendeeList()
        } else if (res.cmd == 104) {
          this.getJoinLiveList()
          if (this.role == ROLE_STUDENT) {
            this.getAttendeeList()
          }
        } else if (res.cmd == 105) {
          this.onEndTeaching()
        }
      } catch (e) {
        console.error('====edu_zpush====', e)
      }
    })
  }

  onUserStateChange(data) {
    const uid = this.uid
    if (data.type == 1 || !data.users) return
    if (this.role == ROLE_TEACHER) {
      // 老师主动改变自己状态
      if (data.operator_uid == uid && data.users.find(v => v.uid == uid)) return
      // 学生状态改变，老师同步用户列表和连麦列表
      this.getAttendeeList()
      this.getJoinLiveList()
      return
    }
    // 学生主动改变自己状态
    if (this.role == ROLE_STUDENT && data.operator_uid == uid) return
    // 学生自己状态被动改变，消息提示
    const user = data.users.find(v => v.uid == uid)
    if (this.role == ROLE_STUDENT && user) {
      let str = ''
      if (data.type == 4) {
        
        str = user.can_share == STATE_CLOSE ? i18n.t('room.room_student_tip_revoke_share') : i18n.t('room.room_student_tip_permission')
      } else if (data.type == 2) {
        str = user.camera == STATE_CLOSE ? i18n.t('room.room_student_tip_turned_off_camera') : i18n.t('room.room_student_tip_turned_on_camera')
      } else if (data.type == 3) {
        str = user.mic == STATE_CLOSE ? i18n.t('room.room_student_tip_turned_off_mic') : i18n.t('room.room_student_tip_turned_on_mic')
      }
      this.auth.camera = user.camera
      this.auth.mic = user.mic
      this.auth.can_share = user.can_share
      this.auth.share = user.can_share == STATE_OPEN
      Message({ customClass: 'common-toast', type: 'info', message: str })
    }
    // 同步所有人状态
    const map = data.users.reduce((s, v) => {
      s[v.uid] = v
      return s
    }, {})
    bus.$emit('userStateChange', map)
  }

  onEndTeaching() {
    bus.$emit('endTeaching', true)
  }

  async startHeartBeat() {
    if (!this.inited) return
    const { data } = await postRoomHttp('heartbeat', this.params)
    if (data.interval) {
      this.attendeeListSeq = data.attendee_list_seq
      this.joinLiveListSeq = data.join_live_list_seq
      this.stopHeartBeat()
      this.heartBeatId = setInterval(async () => {
        try {
          const { data } = await postRoomHttp('heartbeat', this.params)
          let attendeeListSeq = data.attendee_list_seq
          let joinLiveListSeq = data.join_live_list_seq
          if (attendeeListSeq > this.attendeeListSeq) {
            this.getAttendeeList()
          }
          if (joinLiveListSeq > this.joinLiveListSeq) {
            this.getJoinLiveList()
          }
          this.attendeeListSeq = attendeeListSeq
          this.joinLiveListSeq = joinLiveListSeq
        } catch (e) {
          this.stopHeartBeat()
        }
      }, data.interval * 1000)
    }
  }

  stopHeartBeat() {
    this.heartBeatId && clearInterval(this.heartBeatId)
    this.heartBeatId = 0
  }

  async getAttendeeList() {
    if (!this.inited) return
    const res = await postRoomHttp('get_attendee_list', this.params)
    const list = []
    const arr = res.data.attendee_list
    if (arr && arr.length) {
      let index = arr.findIndex(v => v.uid && v.role == ROLE_TEACHER)
      // 老师排第一位
      if (index != -1) {
        list.push(arr[index])
        arr.splice(index, 1)
      }
      // 学生自己第二位
      if (this.role == ROLE_STUDENT) {
        index = arr.findIndex(v => this.uid == v.uid)
        if (index != -1) {
          list.push(arr[index])
          arr.splice(index, 1)
        }
      }
      // 加入麦位学生，按加入课堂时间，从前到后排序
      let temp = arr
        .filter(v => v.uid && v.camera + v.mic > 2)
        .sort((a, b) => a.login_time - b.login_time)
      list.push(...temp)
      // 未加入麦位学生，按加入课堂时间，从前到后排序
      temp = arr
        .filter(v => v.uid && v.camera + v.mic <= 2)
        .sort((a, b) => a.login_time - b.login_time)
      list.push(...temp)
    }
    this.attendeeList = list
    bus.$emit('roomAttendeesChange', list)
    return list
  }

  async getJoinLiveList() {
    if (!this.inited) return
    const res = await postRoomHttp('get_join_live_list', this.params)
    const teacher =
      this.attendeeList[0]?.role == ROLE_TEACHER
        ? this.attendeeList[0]
        : {
            uid: '',
            nick_name: '',
            role: ROLE_TEACHER,
            camera: STATE_CLOSE,
            mic: STATE_CLOSE,
            can_share: STATE_OPEN,
            join_live_time: 0
          }
    const list = [teacher]
    const arr = res.data.join_live_list
    if (arr && arr.length) {
      let index = arr.findIndex(v => v.uid && v.role == ROLE_TEACHER)
      // 老师排第一位
      if (index != -1) {
        list[0] = arr[index]
        // 标志老师是否连麦
        list[0].joing = true
        arr.splice(index, 1)
      }
      // 学生按加入麦位时间先后顺序排列
      const temp = arr
        .filter(v => v.uid && v.role == ROLE_STUDENT)
        .sort((a, b) => a.join_live_time - b.join_live_time)
      list.push(...temp)
    }
    this.joinLiveList = list
    bus.$emit('roomJoinLivesChange', list)
    return list
  }

  async setUserInfo(params) {
    if (!this.inited) return
    const res = await postRoomHttp('set_user_info', { ...params, ...this.params })
    const id = params.target_uid
    let user = this.attendeeList.find(v => v.uid == id)
    if (user) Object.assign(user, params)
    user = this.joinLiveList.find(v => v.uid == id)
    if (user) Object.assign(user, params)
    return res
  }

  async getControlAuth() {
    if (this.role == ROLE_STUDENT) {
      const id = this.uid
      const self = this.attendeeList.find(v => v.uid == id)
      // 非登录页跳转时，同步后台状态
      if (!this.route && self) {
        this.auth.camera = self.camera
        this.auth.mic = self.mic
        this.auth.can_share = self.can_share
        this.auth.share = self.can_share == STATE_OPEN
      }
      if (this.joinLiveList.length >= 4 && !this.joinLiveList.some(v => v.uid == this.uid)) {
        this.auth.camera = STATE_CLOSE
        this.auth.mic = STATE_CLOSE
      }
      console.log('====roomstore init getControlAuth====', this.route, self, this.auth)
      bus.$emit('userStateChange', { [this.uid]: this.auth })
    }
  }

  close() {
    const id = this.uid
    this.attendeeList.some(v => {
      if (v.uid == id) {
        v.camera = STATE_CLOSE
        v.mic = STATE_CLOSE
        return true
      }
      return false
    })
    this.joinLiveList.some(v => {
      if (v.uid == id) {
        v.camera = STATE_CLOSE
        v.mic = STATE_CLOSE
        return true
      }
      return false
    })
    this.stopHeartBeat()
  }

  notifyAttendeeChange(res) {
    bus.$emit('imAttendeesChange', res)
  }
}

export const roomStore = new RoomStore()
