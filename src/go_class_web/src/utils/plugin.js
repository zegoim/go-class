import { Message } from 'element-ui'

const protoInstall = {
  install: (Vue, options) => {
    console.log({ options })
    Vue.prototype.$message = Message
    Vue.prototype.showToast = function(msg = '', duration = 3000) {
      Message.closeAll()
      this.$message({
        dangerouslyUseHTMLString: true,
        message: msg,
        customClass: 'common-toast',
        duration
      })
    }
  }
}

export default protoInstall
