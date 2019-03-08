class InitResultInfo {
  String message = "";
  bool isSuccess = false;

  InitResultInfo.fromJson(Map<String, dynamic> json)
      : message = json['message'],
        isSuccess = json['isSuccess'];
}