class InitResultInfo {
  String message = "";
  String appId = "";
  bool isSuccess = false;

  InitResultInfo.fromJson(Map<String, dynamic> json)
      : message = json['message'],
        appId = json['appId'],
        isSuccess = json['isSuccess'];
}
