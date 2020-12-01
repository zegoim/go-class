# 简介

go_class_server 是 ZEGO GoClass 的后端服务。采用 golang 编程语言，基于开源的 HTTP 框架 [beego](https://github.com/astaxie/beego) 开发出来的后端服务应用。开源

版本没有持久化数据，仅依赖于 [redis](https://redis.io/) 存储在线教室间状态，教室间销毁后，相关数据即从 redis 中清除。支持水平扩展，开发者可以根

据实际需要进行扩缩容。



# 快速开始

**环境准备：**

* golang  1.11及以上版本（推荐使用1.13及以上版本）

  >开启 `go module`：
  >
  >```shell
  >go env -w GO111MODULE=on
  >```
  >
  >设置 go 代理：
  >
  >```shell
  >go env -w GOPROXY=https://goproxy.cn
  >```

* redis 2.6及以上版本



**前提条件：**

请到 [即构管理控制台](https://console-express.zego.im/account/login)  注册账号并申请 AppID 与 ServerSecret，申请流程参考 [项目管理](https://doc-zh.zego.im/zh/1265.html)。



**下载源码并进入源码目录：**

```shell
git clone https://github.com/zegoim/go-class.git
cd ./go-class/src/go_class_server/
```



**修改配置：**

进入配置目录：

```shell
cd go_class_room/conf/
```

修改 `app.conf` 中相关配置项：

```ini
RedisAddr = "192.168.100.62:6379" # redis host
RedisPassword = ""    						# redis password
RedisIndex = 8            				# redis数据库

[SmallClass] # 小班课appid相关配置 如果不需要小班课场景，可以不用关心相关配置
AppId = 123456789
AppSecret = "eb2280544902dc1b7ab1fde3985bd083" # 从 zego 控制台获取的 ServerSecret
...
MaxPeopleNum = 10  # 小班课教室间同时在线人数上限
MaxJoinLiveNum = 4 # 小班课教室间同时连麦人数上限

[LargeClass] # 大班课appid相关配置 如果不需要大班课场景，可以不用关心相关配置
AppId = 987654321
AppSecret = "13nce767a02dc1b7bd083ab1fde3985" # 从 zego 控制台获取的 ServerSecret
...
MaxPeopleNum = 50  # 大班课教室间同时在线人数上限
MaxJoinLiveNum = 1 # 大班课教室间同时连麦人数上限
```



**启动服务：**

进入 `go_class_room` 目录并启动：

```shell
cd ../
go run main.go
```



**集群部署：**

go_class_server 支持水平扩展，开发者可以根据实际需要进行部署。

示意图：

![go_class_server_cluster](./images/go_class_server_cluster.png)



# 获取帮助

ZEGO 文档中心有关于 [小班课](https://doc-zh.zego.im/zh/5308.html) 以及 [大班课](https://doc-zh.zego.im/zh/6347.html) 的详细介绍。



# 作出贡献

如果您发现了文档中有表述错误，或者代码发现了 BUG，或者希望开发新的特性，或者希望提建议，可以[创建一个 Issue](https://github.com/zegoim/go-class/issues/new)。请参考 Issue 模板中对应的指导信息来完善 Issue 的内容，来帮助我们更好地理解您的 Issue。



# FAQ



# LICENSE