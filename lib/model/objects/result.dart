import 'dart:convert';

class Result {
  final int code;
  final String msg;
  final dynamic data;

  Result({
    required this.code,
    required this.msg,
    required this.data,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      code: json['code'] as int,
      msg: json['msg'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
      'data': data,
    };
  }
}
