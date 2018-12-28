class UpgradeInfo {
  String id = "";
  String title = "";
  String newFeature = "";
  int publishTime = 0;
  int publishType = 0;
  int upgradeType = 1;
  int popTimes = 0;
  int popInterval = 0;
  int versionCode;
  String versionName = "";
  String apkMd5;
  String apkUrl;
  int fileSize;
  String imageUrl;
  int updateType;

  UpgradeInfo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        newFeature = json['newFeature'],
        publishTime = json['publishTime'],
        publishType = json['publishType'],
        upgradeType = json['upgradeType'],
        popTimes = json['popTimes'],
        popInterval = json['popInterval'],
        versionCode = json['versionCode'],
        versionName = json['versionName'],
        apkMd5 = json['apkMd5'],
        apkUrl = json['apkUrl'],
        fileSize = json['fileSize'],
        imageUrl = json['imageUrl'],
        updateType = json['updateType'];
}
