# 1. 简介

go_class_web 是一个集成即构 Express-Video SDK，互动白板和文件共享的功能示例项目，目的是提供一个场景让用户可以更具像化的了解即构的互动白板和文件共享的功能和使用场景。开发人员可以参考该项目，实现自己的项目。本项目是采用 JavaScript 编程语言，基于开源的 VUE 框架开发出来的前端应用。


# 2. 开发准备

#### 申请 AppID 与 AppSign
请在 [即构管理控制台](https://console.zego.im/acount) 申请 SDK 初始化需要的 AppID 和 AppSign，[获取 AppID 和 AppSign 指引](https://doc.zego.im/API/HideDoc/GetAppIDGuide/GetAppIDGuideline.html) 。
#### AppID
应用ID，请从 [即构管理控制台](https://console.zego.im/acount) 获取

#### server
为接入服务器地址，请登录[即构管理控制台](https://console.zego.im/acount)，在对应项目下单击 “配置”，弹出基本信息后单击 “环境配置” 下的 “查看” 按钮，在弹窗中依次选择 “集成的SDK” 和 “Web” 平台便可获取对应的 server 地址

#### token

项目中token生成的方法仅为体验功能使用，正式环境token的生成请调用自己的后台接口，token 生成方法请参考 [ZEGO开发者中心](https://console.zego.im/acount)。


# 3. 快速启动

### 安装依赖


```
# 访问目标文件
cd go_class_web
# 安装依赖
yarn install
```


### 启动项目


```
# 运行项目
yarn serve
```


### 构建项目


```
# 打包项目
yarn build
```
提示：使用 npm 也可以运行项目。

# 4. 获取帮助

ZEGO 文档中心有关于 [小班课](https://doc-zh.zego.im/zh/5308.html) 以及 [大班课](https://doc-zh.zego.im/zh/6347.html) 的详细介绍。


# 5. 作出贡献

如果您发现了文档中有表述错误，或者代码发现了 BUG，或者希望开发新的特性，或者希望提建议，可以[创建一个 Issue]()。请参考 Issue 模板中对应的指导信息来完善 Issue 的内容，来帮助我们更好地理解您的 Issue。


# 6. FAQ

Q: 如果要在项目替换自己申请的appID该如何操作？

A: 为了让开发者前期能快速体验功能效果，go_class_web/src/utils/constants.js 文件中相关配置中的 APPID 为体验参数。如需替换自己的 APPID，可参考下面流程：
![image.png](https://cdn.nlark.com/yuque/0/2020/png/2309522/1606963176506-130a4827-ced2-48f2-9ef0-398cd49b708f.png)

Q: 为什么下载项目本地运行起来，以老师身份进入课堂却无法使用权限控制和设备控制等功能？

A: 在本体验项目中涉及到角色权限控制和设备控制等功能是通过 ZEGO GoClass 的[后端服务]()实现，体验完整功能可在官网[在线体验](https://doc-zh.zego.im/scene-plan/20)。


Q: 如果想在项目中使用自己的文件体验功能

A: 在连接测试环境等情况下，文件id通过文件共享SDK上传后返回，与appID无关联。

上传地址：
1. [国内](https://zegodev.gitee.io/zego-express-webrtc-sample/docsSharing/index.html)
2. [海外](https://zegodev.github.io/zego-express-webrtc-sample/docsSharing/index.html)

具体步骤：

输入appID->userID、token填test->初始化->切换为测试环境->选择要上传的文件->选择renderType->上传->成功后会返回fileID

将上传文件成功后返回的 fileID 填到本地数据管理中，如图所示
![image.png](https://cdn.nlark.com/yuque/0/2020/png/2309522/1606965200769-c918e63c-801a-4b06-aa2d-5d6fa49f0408.png)

文件共享参考API文档：
1. [国内](https://gitee.com/zegodev/zego-express-webrtc-sample/blob/master/docs/docsSharing/ZegoDocsSDK.md)
2. [海外](https://github.com/zegodev/zego-express-webrtc-sample/blob/master/docs/docsSharing/ZegoDocsSDK.md)


# 7. LICENSE

