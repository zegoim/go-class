import Vue from 'vue'
import VueRouter from 'vue-router'
import Room from '@/views/Room.vue'
import Login from '@/views/Login'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Login',
    component: Login
  },
  {
    path: '/login',
    name: 'Login',
    component: Login
  },
  {
    path: '/classroom',
    name: 'Room',
    component: Room
  },
]

const router = new VueRouter({
  routes
})

export default router
