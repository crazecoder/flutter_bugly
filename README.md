# flutter_bugly
[![Bugly package](https://img.shields.io/pub/v/flutter_bugly.svg)](https://pub.dev/packages/flutter_bugly)
[![Bugly Play package](https://img.shields.io/pub/v/flutter_bugly_play?label=bugly_play)](https://pub.dev/packages/flutter_bugly)
[![Discord](https://img.shields.io/badge/discord-FlutterDev-blue.svg)](https://discord.gg/q6yFDws3Xc)

腾讯 Bugly 插件，支持Android/iOS/OpenHarmoy 运营统计、原生异常上报、flutter 异常上报。应用更新可以使用[pgyer_updater](https://github.com/crazecoder/pgyer_updater)

---

## 一、引入

### AndroidX
```yaml
dependencies:
  flutter_bugly: lastVersion
```

### Google Play（停止维护，官方在新版本已经优化了合规性问题）
```yaml
dependencies:
  flutter_bugly_play: lastVersion
```

### Android Support
```yaml
dependencies:
  flutter_bugly:
    git:
      url: git://github.com/crazecoder/flutter_bugly.git
      ref: dev
```

## 二、项目配置
如果iOS报错building for iOS Simulator, but linking in object file built for iOS时，在 `ios/Podfile` 的 post_install 下加入:
```
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end
```

在 `android/app/build.gradle` 的 android 下加入:

```gradle
    lintOptions {
        // 如打包出现Failed to transform libs.jar to match attributes
        checkReleaseBuilds false
    }
    defaultConfig {
        ndk {
            // 设置支持的 so 库架构 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'
            abiFilters 'armeabi-v7a'
        }
    }
```

## 三、使用

```dart
import 'package:flutter_bugly/flutter_bugly.dart';

/// 使用 flutter 异常上报
void main() {
  FlutterBugly.postCatchedException(() {
    // 如果需要 ensureInitialized，请在这里运行。
    // WidgetsFlutterBinding.ensureInitialized();
    runApp(MyApp());
    FlutterBugly.init(
      androidAppId: "your android app id",
      iOSAppId: "your iOS app id",
      ohosAppId: "your ohos app id",
      deviceId: "your ohos device id",
      appKey: "your ohos bugly app key",
    );
  });

  //如果报错 Zone mismatch.使用下面的方法
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(MyApp());
  }, (exception, stackTrace) async {
    FlutterBugly.uploadException(
      type: exception.runtimeType.toString(),
      message: exception.toString(),
      detail: stackTrace.toString(),
    );
  });
}
//bugly日志
FlutterBugly.log(tag: tag, message: message,level:LogLevel.INFO);
```

## 四、release打包（Android）

64-bit

`flutter build apk --release --target-platform android-arm64`

32-bit（目前配合armeabi-v7a可以打出32位64位通用包）

`flutter build apk --release --target-platform android-arm`

## 五、支持属性（Android）

```dart
 String channel, //自定义渠道标识
 bool autoCheckUpgrade = true,//自动检查更新开关
 bool autoInit = true,//自动初始化
 bool customUpgrade = true, //设置是否使用flutter自定义窗口，false为bugly自带弹窗
 int initDelay = 0, //延迟初始化，单位秒
 
 FlutterBugly.setUserId("user id");
 FlutterBugly.putUserData(key: "key", value: "value");
 int tag = 9527;
 FlutterBugly.setUserTag(tag);
```

## 六、说明（Android）

异常上报说明

1、flutter异常上报不属于崩溃，所以如需查看 flutter 的异常上报，请在「错误分析」tab页查看

![](https://github.com/crazecoder/flutter_bugly/blob/1ff1928b3215a8fa1c8fb99c3071692da322e278/screenshot/crash.png)

2、iOS的异常上报没有过多测试，如出现问题请 issue
