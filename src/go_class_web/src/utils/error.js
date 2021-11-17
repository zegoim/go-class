import ElementUI from "element-ui";

const errorMsg = {
  1000001105: "课堂人数已满，不能加入",
  1002034: "课堂人数已满，不能加入",
  1102018: "token失效",
  1102016: "token错误",
};

export default {
  timeout: 2001000004,
  showErrorCodeMsg(code, cb) {
    if (!code) return;
    if (!errorMsg[code]) {
      console.warn('errorMsg中无对应错误提示语');
      return;
    }
    ElementUI.Message({
      dangerouslyUseHTMLString: true,
      message: errorMsg[code],
      customClass: "common-toast",
      duration: 3000,
    });
    if (cb) cb();
  },
};
