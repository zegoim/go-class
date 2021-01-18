import VueI18n from 'vue-i18n'
import Vue from 'vue'
import { en } from './lang/en';
import { zh } from './lang/zh';

Vue.use(VueI18n)
let data  = sessionStorage.getItem('zego_locale')
if(!data) data = 'zh'
console.warn('当前选择语言：',data)
const i18n = new VueI18n({
    locale: data, // 语言标识
    messages: {
        'zh': zh,
        'en': en
    }
})

export default i18n