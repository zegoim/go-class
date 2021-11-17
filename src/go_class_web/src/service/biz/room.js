/*
 * @Date: 2020-10-20 10:16:38
 * @LastEditTime: 2020-10-20 11:00:05
 * @LastEditors: Please set LastEditors
 * @Description: 后台业务处理
 * @FilePath: /web-go-class-demo/src/service/biz/room.js
 */

import Vue from 'vue'
import axios from 'axios'
import { Message } from 'element-ui'
import zegoClient from '@/service/zego/zegoClient/index'
import { ROLE_STUDENT, ROLE_TEACHER, STATE_CLOSE, STATE_OPEN, ZEGOENV } from '@/utils/constants'

export const bus = new Vue()

Vue.prototype.$bus = bus

const timeout = 10000
const loginCodes = [10005, 10006]
const errorTips = {
  'Network Error': '网络异常，请检查网络后重试',
  [`timeout of ${timeout}ms exceeded`]: '请求超时，服务器未响应',
  'Internal Server Error': '请求服务器错误',
  'Request failed with status code 502': '请求服务器错误',
  10001: '课堂已有其他老师，不能加入',
  10002: '课堂人数已满，不能加入',
  10003: '用户没有权限修改',
  10004: '目标用户不在教室',
  10005: '需要先登录房间',
  10006: '房间不存在',
  10007: '演示课堂最多开启3路学生音视频'
}

const translateError = res => {
  res.ret.message = errorTips[res.ret.code] || res.ret.message || '网络异常，请检查网络后重试'
}

const handleError = res => {
  Message.closeAll()
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
  testhome: process.env.VUE_APP_TEST_HOME_URL, // 测试环境-国内环境
  testoverseas: process.env.VUE_APP_TEST_OVERSEA_URL, // 测试环境-海外环境
  home: process.env.VUE_APP_HOME_URL, // 正式环境下的国内环境
  overseas: process.env.VUE_APP_HOME_URL // 正式环境下的海外环境
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
  http.defaults.baseURL = hostMap[ZEGOENV.goclass + env] || hostMap.home
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
        isElectron() ? this.electronRegisterPushEvent() : this.registerPushEvent()
        this.getAttendeeList()
          .then(this.getJoinLiveList.bind(this))
          .then(this.getControlAuth.bind(this))
      })
    }
  }

  registerPushEvent() {
    const socket = zegoClient._client.zegoWebRTC.socketCenter.websocket
    if (socket) {
      socket.addEventListener('message', res => {
        const reg = /custommsg.*custom_content.*cmd.*10[1-7]/
        if (!res.data || !reg.test(res.data)) return
        try {
          res = JSON.parse(res.data)
          res = JSON.parse(res.body.custommsg)
          res = JSON.parse(res.custom_content)
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
        str = user.can_share == STATE_CLOSE ? '老师已收回你的共享权限' : '老师已允许你使用共享功能'
      } else if (data.type == 2) {
        str = user.camera == STATE_CLOSE ? '老师已关闭你的摄像头' : '老师已开启你的摄像头'
      } else if (data.type == 3) {
        str = user.mic == STATE_CLOSE ? '老师已关闭你的麦克风' : '老师已开启你的麦克风'
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
      let temp = arr.filter(v => v.uid && v.camera + v.mic > 2).sort((a, b) => a.login_time - b.login_time)
      list.push(...temp)
      // 未加入麦位学生，按加入课堂时间，从前到后排序
      temp = arr.filter(v => v.uid && v.camera + v.mic <= 2).sort((a, b) => a.login_time - b.login_time)
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
      const temp = arr.filter(v => v.uid && v.role == ROLE_STUDENT).sort((a, b) => a.join_live_time - b.join_live_time)
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
