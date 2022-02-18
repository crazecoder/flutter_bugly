import 'base_bean.dart';

class UpgradeInfo extends BaseBean {
  const UpgradeInfo._({
    this.id = '',
    this.title = '',
    this.newFeature = '',
    this.publishTime = 0,
    this.publishType = 0,
    this.upgradeType = 1, //2为强制更新
    this.popTimes = 0,
    this.popInterval = 0,
    this.versionCode,
    this.versionName = '',
    this.apkMd5,
    this.apkUrl,
    this.fileSize,
    this.imageUrl,
    this.updateType,
  });

  factory UpgradeInfo.fromJson(Map<String, dynamic> json) {
    return UpgradeInfo._(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      newFeature: json['newFeature'] ?? '',
      publishTime: json['publishTime'] ?? 0,
      publishType: json['publishType'] ?? 0,
      upgradeType: json['upgradeType'] ?? 1,
      popTimes: json['popTimes'] ?? 0,
      popInterval: json['popInterval'] ?? 0,
      versionCode: json['versionCode'],
      versionName: json['versionName'] ?? '',
      apkMd5: json['apkMd5'],
      apkUrl: json['apkUrl'],
      fileSize: json['fileSize'],
      imageUrl: json['imageUrl'],
      updateType: json['updateType'],
    );
  }

  final String id;
  final String title;
  final String newFeature;
  final int publishTime;
  final int publishType;
  final int upgradeType;
  final int popTimes;
  final int popInterval;
  final int? versionCode;
  final String versionName;
  final String? apkMd5;
  final String? apkUrl;
  final int? fileSize;
  final String? imageUrl;
  final int? updateType;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'newFeature': newFeature,
      'publishTime': publishTime,
      'publishType': publishType,
      'upgradeType': upgradeType,
      'popTimes': popTimes,
      'popInterval': popInterval,
      'versionCode': versionCode,
      'versionName': versionName,
      'apkMd5': apkMd5,
      'apkUrl': apkUrl,
      'fileSize': fileSize,
      'imageUrl': imageUrl,
      'updateType': updateType,
    };
  }
}
