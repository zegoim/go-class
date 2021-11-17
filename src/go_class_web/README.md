# 介绍

go_class_web（electron） 是一个集成即构 Express-Video SDK，互动白板和文件共享的功能示例项目，目的是提供一个场景让用户可以更具像化的了解即构的互动白板和文件共享的功能和使用场景。开发人员可以参考该项目，实现自己的项目。本项目是采用 JavaScript 编程语言，基于开源的 VUE 框架开发出来的前端应用。

# 开发准备

#### 安装 32 位 node.js

目前文件转码 sdk 只支持 32 位 node.js，windows 用户需安装 32 位 node.js。

#### 申请 AppID 与 AppSign

请在 [即构管理控制台](https://console.zego.im/acount) 申请 SDK 初始化需要的 AppID 和 AppSign，[获取 AppID 和 AppSign 指引](https://doc.zego.im/API/HideDoc/GetAppIDGuide/GetAppIDGuideline.html) 。

#### AppID

应用 ID，请从 [即构管理控制台](https://console.zego.im/acount) 获取

#### server

为接入服务器地址，请登录[即构管理控制台](https://console.zego.im/acount)，在对应项目下单击 “配置”，弹出基本信息后单击 “环境配置” 下的 “查看” 按钮，在弹窗中依次选择 “集成的 SDK” 和 “Web” 平台便可获取对应的 server 地址

#### token

项目中 token 生成的方法仅为体验功能使用，正式环境 token 的生成请调用自己的后台接口，token 生成方法请参考 [ZEGO 开发者中心](https://console.zego.im/acount)。

#### fileList 文件数据

文件 id 通过文件共享 SDK 上传后返回，与 appID 关联。

如果用户需要使用自己的 appID 的文件，需要先上传，上传地址：

1. [国内](https://zegodev.gitee.io/zego-express-webrtc-sample/docsSharing/index.html)
2. [海外](https://zegodev.github.io/zego-express-webrtc-sample/docsSharing/index.html)

具体步骤：

输入 appID-> userID、token ->初始化-> 选择要上传的文件->选择 renderType->上传->成功后会返回 fileID

文件共享参考 API 文档：

1. [国内](https://gitee.com/zegodev/zego-express-webrtc-sample/blob/master/docs/docsSharing/ZegoDocsSDK.md)
2. [海外](https://github.com/zegodev/zego-express-webrtc-sample/blob/master/docs/docsSharing/ZegoDocsSDK.md)

将上传文件成功后返回的 fileID 填到本地数据管理中，如图所示

![image.png](http://storage.zego.im/goclass/test/goclass.png)

#### 注意事项

# 安装启动

### 一、安装

```
# 访问目标文件
cd goclass_web
# 安装依赖
yarn install
```

### 二、配置

#### 1.配置环境变量

打开工程目录打开.env.development 文件
将相关信息写入对应环境变量

#### 2.写入环境变量（tips: 两边不用写引号）

```
VUE_APP_ZEGO_APPID=国内-小班课
VUE_APP_ZEGO_APPID2=国内-大班课
VUE_APP_ZEGO_APPID3=海外-小班课
VUE_APP_ZEGO_APPID4=海外-大班课

VUE_APP_ZEGO_APPSIGN=
VUE_APP_ZEGO_APPSIGN2=
VUE_APP_ZEGO_APPSIGN3=
VUE_APP_ZEGO_APPSIGN4=

VUE_APP_TOKEN_URL=
VUE_APP_ELECTRON_SDK=express

// 下面为业务域名配置
VUE_APP_HOME_URL=国内正式环境地址
VUE_APP_OVERSEA_URL=海外正式环境地址


```

### 三、启动

```
# 运行项目
yarn run electron:serve
```

### 四、构建

```
1.打包mac
yarn run electron:build:mac
2.打包win
yarn run electron:build:win
```

# 里面包含哪些？

1. 基于即构 Express-Video SDK 提供便捷接入、高清流畅、多平台互通、低延迟、高并发的音视频服务，可以实现一对多，多对多的实时音视频互动，秀场直播，视频会议等场景。
2. 基于即构互动白板服务（ZegoWhiteboard），同一房间的用户，可以在指定的白板画布上进行实时绘制，借助涂鸦、文本、直线、矩形、椭圆、橡皮、激光笔等基础教具，低延迟、高效率地以多种形式交换想法，真正实现轨迹实时同步、音“画”同步。
3. 基于即构文件转码和点播服务（ZegoDocs），提供文件处理相关功能。可将常见文件格式转码为向量、PNG、PDF、HTML5 页面等便于跨平台点播的目标格式，常用于在线教育课件共享、视频会议材料共享、网盘文档预览、邮箱附件预览等场景。

# 更多

请访问 [即构开发者中心](https://doc-zh.zego.im/?fromold=1)
