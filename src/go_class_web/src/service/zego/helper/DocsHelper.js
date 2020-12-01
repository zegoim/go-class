
export class DocsHelper {
  _client = null;
  _zgDocsView = null;
  constructor({ context,client }) {
    this.context = context;
    this._client = client;
  }

  on(eventName, callback) {
    console.log("监听事件: ", eventName);
    this._client && this._client.on(eventName, callback);
  }

  getProxyFunc() {
    return ["uploadFile", "createView", "setTestEnv", "setConfig", "getConfig"];
  }

  docs(methodName = "", ...args) {
    const proxyFunc = this.getProxyFunc();
    if (proxyFunc.some((func) => func === methodName)) {
      console.warn("方法被转发, methods: ", methodName, ", args:", args);
      return this[methodName](...args);
    } else {
      console.warn("不存在该方法, methodName=", methodName);
      return;
    }
  }

  uploadFile(file, renderType) {
    return this._client.uploadFile(file, renderType);
  }

  setTestEnv(isTest) {
    return this._client.setTestEnv(isTest);
  }

  setConfig(key, value) {
    return this._client.setConfig(key, value);
  }

  getConfig(key) {
    return this._client.getConfig(key);
  }

  createView(...options) {
    return this._client.createView(...options);
  }

  // getFileID() {
  //   return this._zgDocsView.getFileID();
  // }

  // getFileType() {
  //   return this._zgDocsView.getFileType();
  // }

  // getCurrentPage() {
  //   return this._zgDocsView.getCurrentPage();
  // }

  // getPageCount() {
  //   return this._zgDocsView.getPageCount();
  // }

  // getContentSize() {
  //   return this._zgDocsView.getContentSize();
  // }

  // getVisibleSize() {
  //   return this._zgDocsView.getVisibleSize();
  // }

  // getVerticalPercent() {
  //   return this._zgDocsView.getVerticalPercent();
  // }

  // loadFile(id) {
  //   return this._zgDocsView.loadFile(id);
  // }

  // flipPage(page, step) {
  //   return this._zgDocsView.flipPage(page, step);
  // }

  // nextStep() {
  //   return this._zgDocsView.nextStep();
  // }

  // previousStep() {
  //   return this._zgDocsView.previousStep();
  // }

  // scrollTo(verticalPercent) {
  //   return this._zgDocsView.scrollTo(verticalPercent);
  // }

  // switchSheet(index) {
  //   return this._zgDocsView.switchSheet(index);
  // }

  // setScaleFactor(zoom, x, y) {
  //   return this._zgDocsView.setScaleFactor(zoom, x, y);
  // }

  // getPPTNotes(page) {
  //   return this._zgDocsView.getPPTNotes(page);
  // }
}
