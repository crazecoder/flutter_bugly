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

  static const MethodChannel _channel = MethodChannel(
    'crazecoder/flutter_bugly',
  );

  static final StreamController<UpgradeInfo> _onCheckUpgrade =
      StreamController<UpgradeInfo>.broadcast();

  static int _checkUpgradeCount = 0;
  static int _count = 0;
  static bool _postCaught = false;

  /// 初始化
  static Future<InitResultInfo> init({
    String? androidAppId,
    String? iOSAppId,
    String? channel, // 自定义渠道标识
    bool autoCheckUpgrade = true,
    bool autoInit = true,
    bool autoDownloadOnWifi = false,
    bool enableHotfix = false,
    bool enableNotification = false, // 未适配 androidx
    bool showInterruptedStrategy = true, // 设置开启显示打断策略
    bool canShowApkInfo = true, // 设置是否显示弹窗中的 apk 信息
    int initDelay = 0, // 延迟初始化，单位秒
    int upgradeCheckPeriod = 0, //升级检查周期设置，单位秒
    int checkUpgradeCount = 1, // UpgradeInfo 为 null 时，再次 check 的次数，经测试 1 为最佳
    bool customUpgrade = true, // 是否自定义升级，这里默认 true 为了兼容老版本
  }) async {
    assert(
      (Platform.isAndroid && androidAppId != null) ||
          (Platform.isIOS && iOSAppId != null),
    );
    assert(_postCaught, 'Run postCatchedException first.');
    _channel.setMethodCallHandler(_handleMessages);
    _checkUpgradeCount = checkUpgradeCount;
    Map<String, Object?> map = {
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
      "customUpgrade": customUpgrade,
    };
    final dynamic result = await _channel.invokeMethod('initBugly', map);
    Map resultMap = json.decode(result);
    var resultBean = InitResultInfo.fromJson(resultMap as Map<String, dynamic>);
    return resultBean;
  }

  static Future<Null> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case 'onCheckUpgrade':
        UpgradeInfo? _info = _decodeUpgradeInfo(call.arguments["upgradeInfo"]);
        if (_info != null && _info.apkUrl != null) {
          _count = 0;
          _onCheckUpgrade.add(_info);
        } else {
          if (_count < _checkUpgradeCount) {
            _count++;
            checkUpgrade(isManual: false);
          }
        }
        break;
    }
  }

  /// 自定义渠道标识，Android 专用
  static Future<Null> setAppChannel(String channel) async {
    assert(Platform.isAndroid, 'setAppChannel only supports on Android.');
    if (Platform.isAndroid) {
      Map<String, Object> map = {"channel": channel};
      await _channel.invokeMethod('setAppChannel', map);
    }
  }

  /// 设置用户标识
  static Future<Null> setUserId(String userId) async {
    Map<String, Object> map = {"userId": userId};
    await _channel.invokeMethod('setUserId', map);
  }

  /// 设置标签
  /// [userTag] 标签 ID，可在网站生成
  static Future<Null> setUserTag(int userTag) async {
    Map<String, Object> map = {"userTag": userTag};
    await _channel.invokeMethod('setUserTag', map);
  }

  ///设置关键数据，随崩溃信息上报
  static Future<Null> putUserData({
    required String key,
    required String value,
  }) async {
    assert(key.isNotEmpty);
    assert(value.isNotEmpty);
    Map<String, Object> map = {"key": key, "value": value};
    await _channel.invokeMethod('putUserData', map);
  }

  ///获取本地更新策略，即上次未更新的策略
  static Future<UpgradeInfo?> getUpgradeInfo() async {
    final String? result = await _channel.invokeMethod('getUpgradeInfo');
    var info = _decodeUpgradeInfo(result);
    return info;
  }

  /// 检查更新，返回更新策略信息
  static Future<Null> checkUpgrade({
    bool isManual = true,
    bool isSilence = false,
  }) async {
    if (!Platform.isAndroid) return null;
    if (isManual) _count = 0;
    Map<String, Object> map = {
      "isManual": isManual, // 用户手动点击检查，非用户点击操作请传 false
      "isSilence": isSilence, // 是否显示弹窗等交互，[true:没有弹窗和toast] [false:有弹窗或toast]
    };
    await _channel.invokeMethod('checkUpgrade', map);
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
    bool _isDebug = false;
    assert(_isDebug = true);
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
    _postCaught = true;
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
        _isDebug,
        onException,
        filterRegExp,
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
    });
  }

  static void _filterAndUploadException(
    debugUpload,
    _isDebug,
    handler,
    filterRegExp,
    FlutterErrorDetails details,
  ) {
    if (!_filterException(
      debugUpload,
      _isDebug,
      handler,
      filterRegExp,
      details,
    )) {
      uploadException(
          message: details.exception.toString(),
          detail: details.stack.toString());
    }
  }

  static bool _filterException(
    bool debugUpload,
    bool _isDebug,
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
    if (!debugUpload && _isDebug) {
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
    Map? data,
  }) async {
    var map = {};
    map.putIfAbsent("crash_message", () => message);
    map.putIfAbsent("crash_detail", () => detail);
    if (data != null) map.putIfAbsent("crash_data", () => data);
    await _channel.invokeMethod('postCatchedException', map);
  }

  static UpgradeInfo? _decodeUpgradeInfo(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return null;
    Map resultMap = json.decode(jsonStr);
    var info = UpgradeInfo.fromJson(resultMap as Map<String, dynamic>);
    return info;
  }

  static Stream<UpgradeInfo> get onCheckUpgrade => _onCheckUpgrade.stream;

  static void dispose() {
    _count = 0;
    _onCheckUpgrade.close();
    _postCaught = false;
  }
}
