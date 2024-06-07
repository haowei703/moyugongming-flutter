import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _singleton = ApiClient._internal();
  late Dio dio;

  // 生产环境
  static const String baseOnlineUrl = 'https://api.shiroha.love';
  // 本地开发环境
  static const String baseLocalUrl = 'http://10.107.238.75:8080';

  Future<String?> _readToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    return token;
  }

  factory ApiClient() {
    return _singleton;
  }

  final baseUrl =
      kReleaseMode ? ApiClient.baseOnlineUrl : ApiClient.baseLocalUrl;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );

    // 添加拦截器
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (kDebugMode) {
          print('Request[${options.method}] => PATH: ${options.path}');
        }
        // 读取token，token不为空则携带token
        await _readToken().then((token) {
          if(token != null){
            options.headers['Authorization'] = 'Bearer $token';
          }
        });
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('Response[${response.statusCode}] => DATA: ${response.data}');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (e.type == DioExceptionType.unknown && e.error is SocketException) {
          final error = DioException(
              requestOptions: e.requestOptions,
              type: DioExceptionType.unknown,
              message: "网络连接错误");
          handler.reject(error);
        } else {
          return handler.next(e);
        }
      },
    ));
  }
}
