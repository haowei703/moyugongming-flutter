import 'package:dio/dio.dart';
import 'package:moyugongming/model/objects/result.dart';
import 'package:moyugongming/model/vo/token.dart';
import 'api_client.dart';

// 处理用户认证的异常类
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() {
    return "AuthException: $message";
  }
}

class UserService {
  final Dio _dio = ApiClient().dio;

  // 登录请求
  Future<JWT> login(
      {required String phoneNumber, String? code, String? password}) async {
    // 验证码或密码至少有一个不为null
    if (code == null && password == null) {
      throw ArgumentError('Either code or password must be provided.');
    }

    // 请求头
    Map<String, String> headers = {'Content-Type': 'application/json'};
    // 请求体
    Map<String, String?> body = code != null
        ? {"phoneNumber": phoneNumber, "code": code}
        : {"phoneNumber": phoneNumber, "password": password};

    try {
      final response = await _dio.post("/user/login",
          data: body, options: Options(headers: headers));

      // 解析Result响应体返回提取的JWT对象
      Result result = Result.fromJson(response.data);
      return JWT.fromJson(result.data);
    } on DioException catch (e) {
      _handleDioError(e);
      if (e.type == DioExceptionType.badResponse) {
        switch (e.response?.statusCode) {
          case 400:
            throw AuthException("验证码错误");
          case 401:
            throw AuthException("用户名或密码错误");
          case 403:
            throw AuthException("用户名或密码错误");
          case 404:
            throw AuthException("该手机号未注册");
        }
      }
      rethrow;
    }
  }

  /// 注册
  ///
  /// [phoneNumber] 手机号
  /// [password] 密码
  /// [code] 验证码
  Future<JWT> register(
      {required String phoneNumber,
      required String password,
      required String code}) async {

    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, String> body = {
      "phoneNumber": phoneNumber,
      "password": password,
      "code": code
    };

    try {
      final response = await _dio.post("/user/register",
          data: body, options: Options(headers: headers));

      // 解析Result响应体返回提取的JWT对象
      Result result = Result.fromJson(response.data);
      return JWT.fromJson(result.data);
    } on DioException catch (e) {
      _handleDioError(e);
      if (e.type == DioExceptionType.badResponse) {
        switch (e.response?.statusCode) {
          case 400:
            throw Exception("验证码错误");
          case 409:
            throw Exception("该手机号已经注册");
        }
      }
      rethrow;
    }
  }

  /// 获取验证码
  Future<bool> sendSmsCode(String phoneNumber) async {
    Map<String, String> queryParam = {"phoneNumber": phoneNumber};
    try {
      final response = await _dio.get("/user/sms", queryParameters: queryParam);
      return response.statusCode! == 200;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    }
  }

  // DioException处理方法
  void _handleDioError(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        break;
      case DioExceptionType.sendTimeout:
        break;
      case DioExceptionType.receiveTimeout:
        break;
      case DioExceptionType.badCertificate:
        break;
      case DioExceptionType.badResponse:
        break;
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.connectionError:
        break;
      case DioExceptionType.unknown:
        break;
    }
  }
}
