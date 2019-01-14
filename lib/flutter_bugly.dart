import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:convert';
import 'bean/upgrade_info.dart';

class FlutterBugly {
  FlutterBugly._();

  static const MethodChannel _channel = const MethodChannel('flutter_bugly');

  static Future<String> init(
    String appId, {
    bool autoCheckUpgrade = true,
    bool autoDownloadOnWifi = false,
    bool enableHotfix = false,
    bool enableNotification = false, //官方没有适配8.0，配合targetSdkVersion使用
    bool showInterruptedStrategy = true, //设置开启显示打断策略
    bool canShowApkInfo = true, //设置是否显示弹窗中的apk信息
    int initDelay = 0, //延迟初始化,单位秒
    int upgradeCheckPeriod = 60, //升级检查周期设置,单位秒
  }) async {
    Map<String, Object> map = {
      "appId": appId,
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
    return result;
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
}
