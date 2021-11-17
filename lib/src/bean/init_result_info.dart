import 'base_bean.dart';

class InitResultInfo extends BaseBean {
  const InitResultInfo._({
    this.message = '',
    this.appId = '',
    this.isSuccess = false,
  });

  final String message;
  final String appId;
  final bool isSuccess;

  factory InitResultInfo.fromJson(Map<String, dynamic> json) {
    return InitResultInfo._(
      message: json['message'] ?? '',
      appId: json['appId'] ?? '',
      isSuccess: json['isSuccess'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'message': message,
      'appId': appId,
      'isSuccess': isSuccess,
    };
  }
}
