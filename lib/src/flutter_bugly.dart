import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bugly/src/types/log_level.dart';
import 'dart:convert';
import 'bean/init_result_info.dart';

class FlutterBugly {
  FlutterBugly._();

  static const MethodChannel _channel = MethodChannel(
    'crazecoder/flutter_bugly',
  );

  /// 初始化
  static Future<InitResultInfo> init({
    String? androidAppId,
    String? iOSAppId,
    String? ohosAppId,
    String? channel, // 自定义渠道标识
    String? deviceId, // 设备id，鸿蒙为必传参数
    String? appVersion, // App版本
    String? userId, // 用户标识
    bool debugMode = kDebugMode, //开启SDK日志
    //android
    int initDelay = 0, // 延迟初始化，单位秒
    String? deviceModel, // 设备型号
    String? appPackage, // App包名
    bool enableCatchAnrTrace = false, //设置anr时是否获取系统trace文件，默认为false
    bool enableRecordAnrMainStack = true, //设置是否获取anr过程中的主线程堆栈，默认为true
    bool isBuglyLogUpload = true, //设置是否上传自定义日志到bugly，默认为true
    //iOS
    double blockMonitorTimeout = 3, //卡顿阀值
    bool unexpectedTerminatingDetectionEnable = true, //非正常退出事件(SIGKILL)
    bool enableBlockMonitor = true, //卡顿监控
    bool symbolicateInProcessEnable = true, //进程内还原符号
    int? reportLogLevel, // 设置自定义日志上报的级别，默认不上报自定义日志
    //ohos
    String? appKey,//必传参数
    String? buildNum,
  }) async {
    assert(
      (Platform.isAndroid && androidAppId != null) ||
          (Platform.isIOS && iOSAppId != null)||
          (isOhos() && ohosAppId != null && appKey != null && deviceId != null),
    );
    if (!_isSupportPlatform()) {
      return InitResultInfo.fromJson(
          {"isSuccess": false, "appId": null, "message": "当前平台不支持"});
    }
    Map<String, Object?> map = {
      "appId": Platform.isAndroid ? androidAppId : (Platform.isIOS ? iOSAppId : ohosAppId),
      "channel": channel,
      "deviceId": deviceId,
      "appVersion": appVersion,
      "userId": userId,
      "debugMode": debugMode,
      //android
      "deviceModel": deviceModel,
      "initDelay": initDelay,
      "appPackage": appPackage,
      "enableCatchAnrTrace": enableCatchAnrTrace,
      "enableRecordAnrMainStack": enableRecordAnrMainStack,
      "isBuglyLogUpload": isBuglyLogUpload,
      //iOS
      "blockMonitorTimeout": blockMonitorTimeout,
      "unexpectedTerminatingDetectionEnable":
          unexpectedTerminatingDetectionEnable,
      "enableBlockMonitor": enableBlockMonitor,
      "symbolicateInProcessEnable": symbolicateInProcessEnable,
      "reportLogLevel": reportLogLevel,
      //ohos
      "appKey": appKey,
      "buildNum": buildNum,
    };
    final dynamic result = await _channel.invokeMethod('initBugly', map);
    Map resultMap = json.decode(result);
    var resultBean = InitResultInfo.fromJson(resultMap as Map<String, dynamic>);
    return resultBean;
  }

  /// 设置用户标识
  static Future<Null> setUserId(String userId) async {
    if (!_isSupportPlatform()) {
      return;
    }
    Map<String, Object> map = {"userId": userId};
    await _channel.invokeMethod('setUserId', map);
  }

  /// 设置标签
  /// [userSceneTag] 标签 ID，可在网站生成
  static Future<Null> setUserTag(int userSceneTag) async {
    if (!_isSupportPlatform()) {
      return;
    }
    Map<String, Object> map = {"userTag": userSceneTag};
    await _channel.invokeMethod('setUserTag', map);
  }

  ///设置关键数据，随崩溃信息上报
  static Future<Null> putUserData({
    required String key,
    required String value,
  }) async {
    if (!_isSupportPlatform()) {
      return;
    }
    assert(key.isNotEmpty);
    assert(value.isNotEmpty);
    Map<String, Object> map = {"key": key, "value": value};
    await _channel.invokeMethod('putUserData', map);
  }

  /// 异常上报。该方法等同于 [runZonedGuarded]。
  ///
  /// [callback] 运行的内容。
  /// [onException] 自定义异常处理，可用于异常打印、双上报等定制逻辑。该字段不影响上报。
  /// [filterRegExp] 针对 message 正则过滤异常上报。
  /// [debugUpload] 是否在调试模式也上报。
  static void postCatchedException<T>(
    T callback(), {
    FlutterExceptionHandler? onException,
    String? filterRegExp,
    bool debugUpload = false,
  }) {
    if (!_isSupportPlatform()) {
      callback();
      return;
    }
    Isolate.current.addErrorListener(new RawReceivePort((dynamic pair) {
      var isolateError = pair as List<dynamic>;
      var _error = isolateError.first;
      var _stackTrace = isolateError.last;
      Zone.current.handleUncaughtError(_error, _stackTrace);
    }).sendPort);
    // This captures errors reported by the Flutter framework.
    FlutterError.onError = (details) {
      if (details.stack != null) {
        Zone.current.handleUncaughtError(details.exception, details.stack!);
      } else {
        FlutterError.presentError(details);
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
    runZonedGuarded<Future<Null>>(() async {
      callback();
    }, (error, stackTrace) {
      _filterAndUploadException(
        debugUpload,
        onException,
        filterRegExp,
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
    });
  }

  static void _filterAndUploadException(
    debugUpload,
    handler,
    filterRegExp,
    FlutterErrorDetails details,
  ) {
    if (!_filterException(
      debugUpload,
      handler,
      filterRegExp,
      details,
    )) {
      uploadException(
          type: details.exception.runtimeType.toString(),
          message: details.exception.toString(),
          detail: details.stack.toString());
    }
  }

  static void dispose(){}

  static bool _filterException(
    bool debugUpload,
    FlutterExceptionHandler? handler,
    String? filterRegExp,
    FlutterErrorDetails details,
  ) {
    if (handler != null) {
      handler(details);
    } else {
      FlutterError.onError?.call(details);
    }
    // Debug 时默认不上传异常。
    if (!debugUpload && kDebugMode) {
      return true;
    }
    // 异常过滤。
    if (filterRegExp != null) {
      RegExp reg = new RegExp(filterRegExp);
      Iterable<Match> matches = reg.allMatches(details.exception.toString());
      if (matches.length > 0) {
        return true;
      }
    }
    return false;
  }

  /// 上报自定义异常信息，data 为文本附件
  /// Android 错误分析 => 跟踪数据 => extraMessage.txt
  /// iOS 错误分析 => 跟踪数据 => crash_attach.log
  static Future<Null> uploadException({
    required String message,
    required String detail,
    String? type,
    Map? data,
  }) async {
    if (!_isSupportPlatform()) {
      return;
    }
    var map = {};
    map.putIfAbsent("crash_message", () => message);
    map.putIfAbsent("crash_detail", () => detail);
    map.putIfAbsent("crash_type", () => type);
    if (data != null) map.putIfAbsent("crash_data", () => data);
    await _channel.invokeMethod('postCatchedException', map);
  }

  /// 自定义渠道标识 ,单独设置方法仅android可用
  static Future<Null> setAppChannel(String channel) async {
    if (!_isSupportPlatform()) {
      return;
    }
    Map<String, Object> map = {"channel": channel};
    await _channel.invokeMethod('setAppChannel', map);
  }

  /// 设置设备型号 ,单独设置方法仅android可用
  static Future<Null> setDeviceModel(String deviceModel) async {
    if (!_isSupportPlatform()) {
      return;
    }
    Map<String, Object> map = {"deviceModel": deviceModel};
    await _channel.invokeMethod('setDeviceModel', map);
  }

  /// 设置App包名 ,单独设置方法仅android可用
  static Future<Null> setAppPackageName(String appPackage) async {
    if (!_isSupportPlatform()) {
      return;
    }
    Map<String, Object> map = {"appPackage": appPackage};
    await _channel.invokeMethod('setAppPackageName', map);
  }

  /// 设置App版本
  static Future<Null> setAppVersion(String appVersion) async {
    if (!_isSupportPlatform()) {
      return;
    }
    Map<String, Object> map = {"appVersion": appVersion};
    await _channel.invokeMethod('setAppVersion', map);
  }

  /// 设置设备id ,单独设置方法仅android可用
  static Future<Null> setDeviceID(String deviceId) async {
    if (!_isSupportPlatform()) {
      return;
    }
    Map<String, Object> map = {"deviceId": deviceId};
    await _channel.invokeMethod('setDeviceID', map);
  }

  /// 设置用户标识
  static Future<Null> log({
    required String tag,
    required String message,
    LogLevel level = LogLevel.INFO,
  }) async {
    if (!_isSupportPlatform()) {
      return;
    }
    Map<String, Object> map = {
      "log_level": level.index + 1,
      "log_tag": tag,
      "log_message": message
    };
    await _channel.invokeMethod('log', map);
  }

  static bool isOhos() {
    return Platform.operatingSystem == 'ohos';
  }

  /// 判断是否是支持的平台
  static bool _isSupportPlatform() {
    return Platform.isAndroid || Platform.isIOS || isOhos();
  }


}
