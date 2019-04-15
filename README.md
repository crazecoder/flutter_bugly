# flutter_bugly [![pub package](https://img.shields.io/pub/v/flutter_bugly.svg)](https://pub.dartlang.org/packages/flutter_bugly)


腾讯Bugly flutter应用更新插件

## 支持Android/iOS 运营统计、原生异常上报、flutter异常上报、应用更新

---

一、引入
--
```yaml
//因为大部分主流插件都已升级androidx，所以pub库升级androidx
//androidx 
dependencies:
  flutter_bugly: lastVersion
  
//support
dependencies:
  flutter_bugly:
    git:
      url: git://github.com/crazecoder/flutter_bugly.git
      ref: dev
```

二、项目配置
---
在android/app/build.gradle的android下加入

```gradle
    defaultConfig {
        ndk {
            //设置支持的SO库架构
            abiFilters 'armeabi-v7a'//, 'arm64-v8a', 'x86', 'x86_64'
        }
    }
```

三、使用
----
```dart
import 'package:flutter_bugly/flutter_bugly.dart';

//使用flutter异常上报
void main()=>FlutterBugly.postCatchedException((){
  runApp(MyApp());
});

FlutterBugly.init(androidAppId: "your android app id",iOSAppId: "your iOS app id");

```

四、release打包（Android）
-----
64-bit
```
flutter build apk --release --target-platform android-arm64
```
32-bit（目前配合armeabi-v7a可以打出32位64位通用包）
```
flutter build apk --release --target-platform android-arm
```

五、支持属性（Android）
-----
```dart
 bool autoCheckUpgrade = true,//自动检查更新开关
 bool autoInit = true,//自动初始化
 bool autoDownloadOnWifi = false,//设置Wifi下自动下载
 bool enableNotification = false,//通知栏
 bool showInterruptedStrategy = true, //设置开启显示打断策略
 bool canShowApkInfo = true, //设置是否显示弹窗中的apk信息
 int initDelay = 0, //延迟初始化，单位秒
 int upgradeCheckPeriod = 0, //升级检查周期设置,单位秒
 
 //手动检查更新
 checkUpgrade({
     bool isManual = false,//用户手动点击检查，非用户点击操作请传false
     bool isSilence = false,//是否显示弹窗等交互，[true:没有弹窗和toast] [false:有弹窗或toast]
 })
```
六、自定义弹窗（Android）
------
通过FlutterBugly.getUpgradeInfo()获取更新策略信息填入自定义flutter widget，手动弹窗

UpgradeInfo参数：
```java
  String id = "";//唯一标识
  String title = "";//升级提示标题
  String newFeature = "";//升级特性描述
  long publishTime = 0;//升级发布时间,ms
  int publishType = 0;//升级类型 0测试 1正式
  int upgradeType = 1;//升级策略 1建议 2强制 3手工
  int popTimes = 0;//提醒次数
  long popInterval = 0;//提醒间隔
  int versionCode;
  String versionName = "";
  String apkMd5;//包md5值
  String apkUrl;//APK的CDN外网下载地址
  long fileSize;//APK文件的大小
  String imageUrl; // 图片url

```

七、说明（Android）
-------
异常上报说明

1、flutter异常上报不属于崩溃，所以如需查看flutter的异常上报，请在【错误分析】tab页查看

![](https://github.com/crazecoder/flutter_bugly/blob/1ff1928b3215a8fa1c8fb99c3071692da322e278/screenshot/crash.png)


2、iOS的异常上报没有过多测试，如出现问题请issue

目前已知问题

~~1、第一次接受到更新策略之后，不会弹窗，即使手动检查更新也不会，需要退出app之后再进入，才会有弹窗（已解决）~~

~~2、官方没有适配8.0的notification，所以如果需要用到notification的时候请关闭后（默认关闭），自己写相关业务逻辑，或者直接把gradle里的targetSdkVersion设成26以下（方法见示例）~~ 官方已适配

~~3、请勿在targetSdkVersion 26以上设置autoDownloadOnWifi = true，会导致在8.0以上机型更新策略没有反应~~

4、因为版本更新弹窗封装进sdk，使用的是support包，所以使用androidx包时，请配合FlutterBugly.getUpgradeInfo()方法自定义弹窗界面 [示例](https://github.com/crazecoder/testsocket/blob/master/lib/ui/home.dart)

非常感谢您的支持
-------
[微信赞赏码](https://github.com/crazecoder/flutter_bugly/blob/39a53324ee419ab045ce09c44971ee7b1f35d3c7/image/mm_reward_qrcode.png)

