import Vue from 'vue'
import VueRouter from 'vue-router'
import Room from '@/views/Room.vue'
import Login from '@/views/Login'

Vue.use(VueRouter)
const routes = [
  {
    path: '/login',
    name: 'Login',
    component: Login
  },
  {
    path: '/classroom',
    name: 'Room',
    component: Room
  }
]

const router = new VueRouter({
  routes
})

router.afterEach((to, from) => {
  // warn: 防止当前子进程跳转路由
  if ((to.name == null || to.name === 'Login') && from.name === 'Room') {
    const { ipcRenderer } = window.require('electron')
    ipcRenderer.send('close-window')
  }
})

export default router
