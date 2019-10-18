import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'bean/upgrade_info.dart';
import 'bean/init_result_info.dart';

class FlutterBugly {
  FlutterBugly._();

  static const MethodChannel _channel =
      const MethodChannel('crazecoder/flutter_bugly');

  ///初始化
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

  ///自定义渠道标识 android专用
  static Future<Null> setAppChannel(String channel) async {
    Map<String, Object> map = {
      "channel": channel,
    };
    await _channel.invokeMethod('setAppChannel', map);
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

  ///获取本地更新策略，即上次未更新的策略
  static Future<UpgradeInfo> getUpgradeInfo() async {
    final String result = await _channel.invokeMethod('getUpgradeInfo');
    var info = _decodeUpgradeInfo(result);
    return info;
  }

  ///检查更新
  ///return 更新策略信息
  static Future<UpgradeInfo> checkUpgrade({
    bool isManual = false,
    bool isSilence = false,
    bool useCache = true,
  }) async {
    if (!Platform.isAndroid) return null;
    Map<String, Object> map = {
      "isManual": isManual, //用户手动点击检查，非用户点击操作请传false
      "isSilence": isSilence, //是否显示弹窗等交互，[true:没有弹窗和toast] [false:有弹窗或toast]
      "useCache": useCache, //是否使用第一次缓存的更新策略，false为实时的，但是bugly会可能返回null
    };
    final String result = await _channel.invokeMethod('checkUpgrade', map);
    var info = _decodeUpgradeInfo(result);
    return info;
  }

  ///异常上报
  static void postCatchedException<T>(
    T callback(), {
    FlutterExceptionHandler handler, //异常捕捉，用于自定义打印异常
    String filterRegExp, //异常上报过滤正则，针对message
    bool debugUpload = false,
  }) {
    bool _isDebug = false;
    assert(_isDebug = true);
    // This captures errors reported by the Flutter framework.
    FlutterError.onError = (FlutterErrorDetails details) async {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    };
    Isolate.current.addErrorListener(new RawReceivePort((dynamic pair) async {
      var isolateError = pair as List<dynamic>;
      var _error = isolateError.first;
      var _stackTrace = isolateError.last;
      Zone.current.handleUncaughtError(_error, _stackTrace);
    }).sendPort);
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
      //默认debug下打印异常，不上传异常
      if (!debugUpload && _isDebug) {
        var details = FlutterErrorDetails(exception: error, stack: stackTrace);
        handler == null
            ? FlutterError.dumpErrorToConsole(details)
            : handler(details);
        return;
      }
      var errorStr = error.toString();
      //异常过滤
      if (filterRegExp != null) {
        RegExp reg = new RegExp(filterRegExp);
        Iterable<Match> matches = reg.allMatches(errorStr);
        if (matches.length > 0) {
          return;
        }
      }
      uploadException(message: errorStr, detail: stackTrace.toString());
    });
  }

  ///上报自定义异常信息，data为文本附件
  ///Android 错误分析=>跟踪数据=>extraMessage.txt
  ///iOS 错误分析=>跟踪数据=>crash_attach.log
  static Future<Null> uploadException(
      {@required String message, @required String detail, Map data}) async {
    var map = {};
    map.putIfAbsent("crash_message", () => message);
    map.putIfAbsent("crash_detail", () => detail);
    if (data != null) map.putIfAbsent("crash_data", () => data);
    await _channel.invokeMethod('postCatchedException', map);
  }

  static UpgradeInfo _decodeUpgradeInfo(String jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return null;
    Map resultMap = json.decode(jsonStr);
    var info = UpgradeInfo.fromJson(resultMap);
    return info;
  }
}
