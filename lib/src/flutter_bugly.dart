import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'bean/upgrade_info.dart';
import 'bean/init_result_info.dart';

class FlutterBugly {
  FlutterBugly._();

  static const MethodChannel _channel = const MethodChannel('crazecoder/flutter_bugly');

  static Future<InitResultInfo> init({
    String androidAppId,
    String iOSAppId,
    bool autoCheckUpgrade = true,
    bool autoDownloadOnWifi = false,
    bool enableHotfix = false,
    bool enableNotification = false, //官方没有适配8.0，配合targetSdkVersion使用
    bool showInterruptedStrategy = true, //设置开启显示打断策略
    bool canShowApkInfo = true, //设置是否显示弹窗中的apk信息
    int initDelay = 0, //延迟初始化,单位秒
    int upgradeCheckPeriod = 60, //升级检查周期设置,单位秒
  }) async {
    assert((Platform.isAndroid && androidAppId != null) ||
        (Platform.isIOS && iOSAppId != null));
    Map<String, Object> map = {
      "appId": Platform.isAndroid ? androidAppId : iOSAppId,
      "autoCheckUpgrade": autoCheckUpgrade,
      "autoDownloadOnWifi": autoDownloadOnWifi,
      "enableHotfix": enableHotfix,
      "enableNotification": enableNotification,
      "showInterruptedStrategy": showInterruptedStrategy,
      "canShowApkInfo": canShowApkInfo,
      "initDelay": initDelay,
      "upgradeCheckPeriod": upgradeCheckPeriod,
    };
    final String result = await _channel.invokeMethod('initBugly', map);
    Map resultMap = json.decode(result);
    var resultBean = InitResultInfo.fromJson(resultMap);
    return resultBean;
  }

  static Future<UpgradeInfo> getUpgradeInfo() async {
    final String result = await _channel.invokeMethod('upgradeListener');
    Map map = json.decode(result);
    var info = UpgradeInfo.fromJson(map);
    return info;
  }

  static Future<Null> checkUpgrade({
    bool isManual = false,
    bool isSilence = false,
  }) async {
    Map<String, Object> map = {
      "isManual": isManual, //用户手动点击检查，非用户点击操作请传false
      "isSilence": isSilence, //是否显示弹窗等交互，[true:没有弹窗和toast] [false:有弹窗或toast]
    };
    await _channel.invokeMethod('checkUpgrade', map);
  }

  static void postCatchedException<T>(T callback(),
      {bool useLog = false, FlutterExceptionHandler handler}) {
    var map = {};
    // This captures errors reported by the Flutter framework.
    FlutterError.onError = (FlutterErrorDetails details) async {
      if (useLog || handler != null) {
        // In development mode simply print to console.
        handler == null
            ? FlutterError.dumpErrorToConsole(details)
            : handler(details);
      } else {
        Zone.current.handleUncaughtError(details.exception, details.stack);
      }
    };

    // This creates a [Zone] that contains the Flutter application and stablishes
    // an error handler that captures errors and reports them.
    //
    // Using a zone makes sure that as many errors as possible are captured,
    // including those thrown from [Timer]s, microtasks, I/O, and those forwarded
    // from the `FlutterError` handler.
    //
    // More about zones:
    //
    // - https://api.dartlang.org/stable/1.24.2/dart-async/Zone-class.html
    // - https://www.dartlang.org/articles/libraries/zones
    runZoned<Future<Null>>(() async {
      callback();
    }, onError: (error, stackTrace) async {
      map.putIfAbsent("crash_message", () => error.toString());
      map.putIfAbsent("crash_detail", () => stackTrace.toString());
      await _channel.invokeMethod('postCatchedException', map);
    });
  }
}
