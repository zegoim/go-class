import Vue from 'vue'
import { storage } from '@/utils/tool'
import zegoClient from '@/service/zego/zegoClient/index'

export const streamStore = new Vue({
  data() {
    return {
      streamList: [],
      client: null
    }
  },

  mounted() {},

  methods: {
    async initClient() {
      const { env } = storage.get('loginInfo')
      this.client = await zegoClient.init('live', env)
    }
  }
})
