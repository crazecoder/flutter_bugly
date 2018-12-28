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
    bool enableNotification = false,//官方没有适配8.0，配合targetSdkVersion使用
    int initDelay = 0, //单位秒
  }) async {
    Map<String, Object> map = {
      "appId": appId,
      "autoCheckUpgrade": autoCheckUpgrade,
      "autoDownloadOnWifi": autoDownloadOnWifi,
      "enableNotification": enableNotification,
      "initDelay": initDelay,
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

  static Future<Null> checkUpgrade(
      {bool isManual = false, bool isSilence = false}) async {
    Map<String, Object> map = {
      "isManual": isManual,
      "isSilence": isSilence,
    };
    await _channel.invokeMethod('checkUpgrade', map);
  }
}
