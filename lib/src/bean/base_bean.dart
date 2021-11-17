import 'dart:convert';

abstract class BaseBean {
  const BaseBean();

  Map<String, dynamic> toJson();

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());
}
