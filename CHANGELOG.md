## 0.4.4
* 修复 `UpgradeInfo` 序列化问题。
## 0.4.3
* 修复 Android 端 `setAppChannel` 问题。
## 0.4.2
* 优化 `postCatchedException` 内部方法执行顺序。
## 0.4.1
* 拆分异常过滤和上报条件。
## 0.4.0
* (**破坏性改动**)：移除 `handler`，新增 `onException` 用于捕获全局异常。
## 0.3.4
* 优化 `postCatchedException` 断言
* 导出 `InitResultInfo`
* 代码结构优化
## 0.3.3
* 升级 SDK 包 1.5.23
* 修复布局越界时报Null check operator used on a null value的问题
## 0.3.2+1
* flutterPluginBinding调整至onDetachedFromEngine释放。fix[#85](https://github.com/crazecoder/flutter_bugly/issues/85) @[shingohu](https://github.com/shingohu)
## 0.3.2
* dartfmt
* 修复部分场景不上报的问题
* 升级 NDK 动态库 3.9.0
## 0.3.1
* 解决Androidx环境中调用原生升级无法弹框问题。@[zengxiangxin](https://github.com/zengxiangxin)
* 升级 SDK 包 1.5.0
* 升级 NDK 动态库 3.7.7
* 支持flutter 2.0
## 0.3.0+2
* 修复无限检查更新的问题
## 0.3.0
* 使用MethodCallHandler获取upgradeInfo
* 新增checkUpgradeCount参数
* checkUpgrade不再返回UpgradeInfo，isManual默认改为true，删除useCache参数
## 0.2.9
* nativecrashreport SDK升级到3.7.5
* 升级Android embedding v2
* 修改FileProvider与第三库冲突 [@linyf0721](https://github.com/linyf0721)
## 0.2.8
* android应用更新SDK升级到1.4.2
## 0.2.7
* 异常上报新增debugUpload字段，默认false
* 异常上报新增uploadException方法
* 新增setAppChannel方法
## 0.2.6
* android:networkSecurityConfig改为android:usesCleartextTraffic
## 0.2.5
* 优化iOS和android异常上报控制台排版格式
## 0.2.4+1
* 修复自动适配模式时，debug时网络请求会上报的问题
## 0.2.4
* 自动适配debug、release模式。debug下只打印异常不上报，release只上报，不打印
* 混淆合并，自带flutter和bugly相关混淆规则
## 0.2.3+1
* 修复useCache取值不正确的问题
## 0.2.3
* 优化checkUpgrade方法，等待网络请求更新策略完成后再返回UpgradeInfo（注意点见方法注释）
* 升级com.tencent.bugly:crashreport_upgrade:1.4.1
## 0.2.2
* 新增初始化channel参数，见注释
* 新增setUserTag、putUserData方法，见注释
## 0.2.1+1
* 新增setUserId方法，用于crash用户标识
## 0.2.0+1
* 优化UpgradeInfo获取机制，优先获取网络策略，网络策略没有来得及拉取时，取本地策略
## 0.2.0
* 优化UpgradeInfo获取机制
## 0.1.9+2
* 解决The 'Pods-Runner' target has transitive dependencies that include static binaries
## 0.1.9+1
* 获取更新信息增加非空判断
## 0.1.9
* 解决Android 9.0上联网失败的问题
## 0.1.8
* 增加异常上报过滤
## 0.1.7
* 优化格式化异常信息上报时的逻辑
## 0.1.6+2
* 修改iOS为返回InitResultInfo实体
## 0.1.6+1
* 删除.idea及优化逻辑严谨性
## 0.1.6
* sdk自带6.0以上动态权限，删除插件中的权限动态申请
* 修改为返回InitResultInfo实体
## 0.1.5+1
* 升级 crashreport_upgrade:1.3.7，适配8.0通知栏，以及androidx的应用升级弹窗说明
## 0.1.4+2
* fix crash when FileProvider not find
## 0.1.4+1
* migrate to androidx