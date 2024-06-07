import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:moyugongming/model/vo/eval_result.dart';
import 'api_client.dart';

// Api异常类
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() {
    return "ApiException: $message";
  }
}

class ApiService {
  final Dio _dio = ApiClient().dio;

  Future<EvalResult> evalAudio(
      {required Uint8List audioData,
      required int evalMode,
      required String text}) async {
    String base64Str = base64Encode(audioData);
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String body = jsonEncode(
        {"audioData": base64Str, "evalMode": evalMode, "text": text});
    try {
      final response = await _dio.post("/api/audio",
          data: body, options: Options(headers: headers));
      return EvalResult.fromJson(response.data);
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 400:
          throw ApiException("");
        case 500:
          throw ApiException("服务错误，请稍后再试");
      }
      rethrow;
    }
  }
}
