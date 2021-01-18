import { YOUR_HOME_SMALL_CLASS_APP_ID, YOUR_OVERSEAS_SMALL_CLASS_APP_ID, YOUR_HOME_LARGE_CLASS_APP_ID, YOUR_OVERSEAS_LARGE_CLASS_APP_ID } from './config_data'

let ZEGOENV = sessionStorage.getItem('zegoenv')
if (ZEGOENV) {
  ZEGOENV = JSON.parse(ZEGOENV)
} else {
  ZEGOENV = {
    wb: '',
    docs: '',
    goclass: '',
    pptStepMode: '1',
    deferredRenderingTime: 0
  }
}

const ROOM_TYPE = sessionStorage.getItem('zego_room_type') || 1

const ROLE_TEACHER = 1
const ROLE_STUDENT = 2
const STATE_CLOSE = 1
const STATE_OPEN = 2

const APPID = {
  home: ROOM_TYPE == 1 ? YOUR_HOME_SMALL_CLASS_APP_ID : YOUR_HOME_LARGE_CLASS_APP_ID,
  overseas: ROOM_TYPE == 1 ? YOUR_OVERSEAS_SMALL_CLASS_APP_ID : YOUR_OVERSEAS_LARGE_CLASS_APP_ID
}

console.log('zegoenv', ROOM_TYPE, APPID, ZEGOENV)

export { APPID, ZEGOENV, ROLE_TEACHER, ROLE_STUDENT, STATE_CLOSE, STATE_OPEN }
