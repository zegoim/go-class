/**
 * @name constants.js
 * @desc 定义常量
 *
 */

let ZEGOENV = localStorage.getItem('zegoenv')
if (ZEGOENV) {
  ZEGOENV = JSON.parse(ZEGOENV)
} else {
  ZEGOENV = {
    wb: '',
    docs: '',
    goclass: '',
    pptStepMode: '1'
  }
}

const ROLE_TEACHER = 1
const ROLE_STUDENT = 2
const STATE_CLOSE = 1
const STATE_OPEN = 2
const LIVE_START = 'live_start'
const LIVE_END = 'live_end'

export { ZEGOENV, ROLE_TEACHER, ROLE_STUDENT, STATE_CLOSE, STATE_OPEN, LIVE_START, LIVE_END }
