class CustomException implements Exception{
  final String message;
  final Map<String,String> map;

  CustomException({this.message,this.map});
  String toString() {
    if (message == null) return NAME;
    return "$NAME: $message\n${map.toString()}";
  }
  static const String NAME = "CustomException";
}