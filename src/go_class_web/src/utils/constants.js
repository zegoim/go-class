/**
 * @name constants.js
 * @desc 定义常量
 *
 */

let ZEGOENV = sessionStorage.getItem('zegoenv')
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

/**
 * 目前项目要使得多个场景进入相同roomID不相互影响，一个场景需要一套appID配置
 * ROOM_TYPE 1为小班课，2为大班课
 * 本演示项目仅提供小班课场景演示，如需本地体验大班课需申请appID，如需帮助可联系技术支持
 */

const ROOM_TYPE = sessionStorage.getItem('zego_room_type') || 1
const APPID = {
  home: ROOM_TYPE == 1 ? 1739272706 : 0,
  overseas: ROOM_TYPE == 1 ? 1739272706 : 0
}

console.log('zegoenv', ROOM_TYPE, APPID, ZEGOENV)

/**
 * 文件id通过文件共享SDK上传后返回，现测试环境与appID无关联。即多个appID上传文件到同一个服务器共享。
 * 上传地址请参考README.md
 * 将上传文件成功后返回的 fileID 填到本地数据管理中
 * 其中 isDynamic 仅UI层面显示该文件是否动态 PPT
 */
const DOCS_TEST = [
  { id: "G02cLH_dQv1_NVwz", name: "成绩分析.xls" },
  { id: "f0AhR4e7TRFU1WDE", name: "成绩分析.xlsx" },
  { id: "d0KvOFgae0kt3w5R", name: "儿童美术.ppt" },
  { id: "OuRCC82ojjnt0yGb", name: "数字故事.pdf" },
  { id: "YI_H8iLnoF0iRghn", name: "小学数学题.doc" },
  { id: "WPvCc5zMPPBmOgOt", name: "幼儿成长.pptx", isDynamic: true },
  { id: "3a6aGKutpJwYGSy6", name: "作文.docx" },
  { id: "OgG3AKuEdWGwW4H0", name: "语文课.txt" },
  { id: "Z6SfBhPNkHuGYQwV", name: "a.jpg" },
  { id: "bO_ptIYGusHPa3Uq", name: "b.jpeg" },
  { id: "xAKHOEjtpHRFQAJi", name: "c.png" },
  { id: "-gu5ZUA7TlrRbA-E", name: "d.bmp" }
]

export { APPID, ZEGOENV, ROLE_TEACHER, ROLE_STUDENT, STATE_CLOSE, STATE_OPEN, DOCS_TEST }
