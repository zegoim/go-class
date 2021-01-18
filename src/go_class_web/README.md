# 1. 简介

go_class_web 是一个集成即构 Express-Video SDK，互动白板和文件共享的功能示例项目，目的是提供一个场景让用户可以更具像化的了解即构的互动白板和文件共享的功能和使用场景。开发人员可以参考该项目，实现自己的项目。本项目是采用 JavaScript 编程语言，基于开源的 VUE 框架开发出来的前端应用。


# 2. 开发准备


#### 申请 AppID


请在 [即构管理控制台](https://console.zego.im/acount) 申请 SDK 初始化需要的 AppID [获取 AppID 指引](https://doc.zego.im/API/HideDoc/GetAppIDGuide/GetAppIDGuideline.html) 。


#### server


为接入服务器地址，请登录[即构管理控制台](https://console.zego.im/acount)，在对应项目下单击 “配置”，弹出基本信息后单击 “环境配置” 下的 “查看” 按钮，在弹窗中依次选择 “集成的SDK” 和 “Web” 平台便可获取对应的 server 地址


#### token

token 生成方法请参考 [ZEGO开发者中心](https://console.zego.im/acount)。


#### ZEGO GoClass 的后端服务


项目中涉及配置后台服务接口地址，详情[ZEGO GoClass 的后端服务](https://github.com/zegoim/go-class/blob/release/express/docs/GettingStartedServer.md)。


#### 填写运行项目配置参数


将上述相关配置参数填写在 go_class_web/src/utils/config_data.js 文件中


![image.png](https://cdn.nlark.com/yuque/0/2021/png/2309522/1610962055214-49648fb1-aec3-4a9a-83f1-cf9de49a2379.png)


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


Q: 如果想在项目中使用自己的文件体验功能


A: 目前项目中是连接oss服务获取文件列表数据，如需体验自定义文件，可自行上传文件。
上传地址：


1. [国内](https://zegodev.gitee.io/zego-express-webrtc-sample/docsSharing/index.html)
2. [海外](https://zegodev.github.io/zego-express-webrtc-sample/docsSharing/index.html)



具体步骤：


输入appID->userID、token填test->初始化->切换为测试环境->选择要上传的文件->选择renderType->上传->成功后会返回fileID


注意：在连接测试环境的情况下，文件id通过文件共享SDK上传后返回，与appID无关联。


将原先获取文件列表数据的方法删除并将上传文件成功后返回的 fileID 按照规定的数据格式，填到本地数据管理中，如图所示

![image.png](https://cdn.nlark.com/yuque/0/2021/png/2309522/1610523400529-28660639-f65f-46f5-8a0f-e77ea3a4827e.png#align=left&display=inline&height=503&margin=%5Bobject%20Object%5D&name=image.png&originHeight=1006&originWidth=1596&size=245467&status=done&style=none&width=798)


文件共享参考API文档：


1. [国内](https://gitee.com/zegodev/zego-express-webrtc-sample/blob/master/docs/docsSharing/ZegoDocsSDK.md)
2. [海外](https://github.com/zegodev/zego-express-webrtc-sample/blob/master/docs/docsSharing/ZegoDocsSDK.md)



# 7. LICENSE
