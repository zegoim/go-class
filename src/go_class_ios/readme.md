# 1. 简介

go_class 是一个集成即构 Express-Video SDK，互动白板和文件共享的功能示例项目，目的是提供一个场景让用户可以更具像化的了解即构的互动白板和文件共享的功能和使用场景。开发人员可以参考该项目，实现自己的项目。本项目是采用objective-c编程语言开发出来的iOS应用。


# 2. 快速开始

#### 环境准备：

* Xcode 7.0 或以上版本 
* iOS 9.0 或以上版本且⽀持⾳视频的 iOS 真机（欲使用模拟器调试请前往官网获取相关sdk并替换）
* iOS 设备已经连接到 Internet

#### 前提条件
请在 [即构管理控制台](https://console.zego.im/acount) 申请 SDK 初始化需要的 AppID 和 AppSign，申请流程请参考 ([项目管理](https://doc-zh.zego.im/zh/1265.html))

#### 运行示例代码
1. AppStore 搜索 Xcode 并下载安装 
    
     ![安装Xcode](http://doc.oa.zego.im/Pics/iOS/GoClass/appstore-xcode.png)


2. 使用Xcode：go_class.xcworkspace 
-     Xcode,选择左上角的File>open...
    
     ![打开文件](http://doc.oa.zego.im/Pics/iOS/GoClass/xcode-open-file.png)
 
-     在解压后的示例代码文件夹中选择go_class.xcworkspace，并初始化Open
     
     ![打开workspace](http://doc.oa.zego.im/Pics/iOS/GoClass/open-workspace.png)


3. 登录Apple ID账号。
-     Xcode，选择左上角的Xcode> Preference。
-     单击Account选项卡，设定左下角的+号，选择添加Apple ID后指示灯Continue。
    
    ![添加Apple ID](http://doc.oa.zego.im/Pics/iOS/GoClass/xcode-account.png)
    
-    输入Apple ID和密码以登录。
    
   ![输入Apple ID&密码](http://doc.oa.zego.im/Pics/iOS/GoClass/xcode-login-apple-id.png)


4. 修改开发者证书和捆绑包标识符。
-     Xcode，预设左侧的go_class项目。
        
    ![预设左侧go_class项目](http://doc.oa.zego.im/Pics/iOS/GoClass/xcode-select-project.png)

-    显示Signing & Capabilities选项卡，在Team中选择自己的开发者证书。
    
   ![修改证书和bundldId](http://doc.oa.zego.im/Pics/iOS/GoClass/sign-capabilities.png)

5.下载的示例代码中所需的SDK初始化所需的`AppID`和`AppSign`，需要修改go_class/Constant目录下的`ZegoAuthConstants.h`文件，请使用此“条件条件”已获取的AppID和AppSign正确填写，否则示例代码无法正常运行。

   ![填写AppID&AppSign](http://doc.oa.zego.im/Pics/iOS/GoClass/appID-AppSign.png)
   
   同时需要将 本地部署的GO 课堂服务端 的host地址配置在 对应字段中。 
   
   ![配置业务服务host](http://doc.oa.zego.im/Pics/iOS/GoClass/host-setting.png)
   
   然后可以通过调用demo 中的ZegoClassEnvManager 单例的 setNormalEnv 方法设置默认环境，也可以在此方法中修改为你的目标环境。 
   ![设置默认环境](http://doc.oa.zego.im/Pics/iOS/GoClass/app-env.png)
   
6.将iOS设备连接到开发电脑，依次Xcode左上角的Generic iOS Device选择该iOS设备。


   ![选择设备](http://doc.oa.zego.im/Pics/iOS/GoClass/run-device.png)


   ![选择真机](http://doc.oa.zego.im/Pics/iOS/GoClass/run-chouse-device.png)


7.单击Xcode左上角的Build按钮编译和运行示例代码

   ![开始运行](http://doc.oa.zego.im/Pics/iOS/GoClass/run-start.png)


# 3. 获取帮助

ZEGO 文档中心有关于 [小班课](https://doc-zh.zego.im/zh/5308.html) 以及 [大班课](https://doc-zh.zego.im/zh/6347.html) 相关介绍。



# 4. 作出贡献
如果您发现了文档中有表述错误，或者代码发现了 BUG，或者希望开发新的特性，或者希望提建议，可以[创建一个 Issue]()。请参考 Issue 模板中对应的指导信息来完善 Issue 的内容，来帮助我们更好地理解您的 Issue。


# 5. FAQ



# 6. LICENSE
