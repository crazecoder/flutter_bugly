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

