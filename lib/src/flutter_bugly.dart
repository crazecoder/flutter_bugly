import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'bean/upgrade_info.dart';
import 'bean/init_result_info.dart';

class FlutterBugly {
  FlutterBugly._();

  static const MethodChannel _channel =
      const MethodChannel('crazecoder/flutter_bugly');

  static Future<InitResultInfo> init({
    String androidAppId,
    String iOSAppId,
    String channel, //自定义渠道标识
    bool autoCheckUpgrade = true,
    bool autoInit = true,
    bool autoDownloadOnWifi = false,
    bool enableHotfix = false,
    bool enableNotification = false, //未适配androidx
    bool showInterruptedStrategy = true, //设置开启显示打断策略
    bool canShowApkInfo = true, //设置是否显示弹窗中的apk信息
    int initDelay = 0, //延迟初始化,单位秒
    int upgradeCheckPeriod = 60, //升级检查周期设置,单位秒
  }) async {
    assert((Platform.isAndroid && androidAppId != null) ||
        (Platform.isIOS && iOSAppId != null));
    Map<String, Object> map = {
      "appId": Platform.isAndroid ? androidAppId : iOSAppId,
      "channel": channel,
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

  ///设置用户标识
  static Future<Null> setUserId(String userId) async {
    Map<String, Object> map = {
      "userId": userId,
    };
    await _channel.invokeMethod('setUserId', map);
  }

  ///设置标签
  ///userTag 标签ID，可在网站生成
  static Future<Null> setUserTag(int userTag) async {
    Map<String, Object> map = {
      "userTag": userTag,
    };
    await _channel.invokeMethod('setUserTag', map);
  }

  ///设置关键数据，随崩溃信息上报
  static Future<Null> putUserData(
      {@required String key, @required String value}) async {
    assert(key != null && key.isNotEmpty);
    assert(value != null && value.isNotEmpty);
    Map<String, Object> map = {
      "key": key,
      "value": value,
    };
    await _channel.invokeMethod('putUserData', map);
  }

  static Future<UpgradeInfo> getUpgradeInfo() async {
    final String result = await _channel.invokeMethod('upgradeListener');
    if (result == null || result.isEmpty) return null;
    Map map = json.decode(result);
    var info = UpgradeInfo.fromJson(map);
    return info;
  }

  static Future<Null> checkUpgrade({
    bool isManual = false,
    bool isSilence = false,
  }) async {
    if (!Platform.isAndroid) return;
    Map<String, Object> map = {
      "isManual": isManual, //用户手动点击检查，非用户点击操作请传false
      "isSilence": isSilence, //是否显示弹窗等交互，[true:没有弹窗和toast] [false:有弹窗或toast]
    };
    await _channel.invokeMethod('checkUpgrade', map);
  }

  static void postCatchedException<T>(
    T callback(), {
    bool useLog = false, //是否打印，默认不打印异常
    FlutterExceptionHandler handler, //异常捕捉，用于自定义打印异常
    String filterRegExp, //异常上报过滤正则，针对message
  }) {
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
      var errorStr = error.toString();
      //异常过滤
      if (filterRegExp != null) {
        RegExp reg = new RegExp(filterRegExp);
        Iterable<Match> matches = reg.allMatches(errorStr);
        if (matches.length > 0) {
          return;
        }
      }
      map.putIfAbsent("crash_message", () => errorStr);
      map.putIfAbsent("crash_detail", () => stackTrace.toString());
      await _channel.invokeMethod('postCatchedException', map);
    });
  }
}
