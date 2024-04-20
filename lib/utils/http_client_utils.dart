import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:moyugongming/utils/log_util.dart';

enum HttpMethod { GET, POST }

class HttpClientUtils {
  // 服务器生产环境url
  static const String baseOnlineUrl = 'http://123.56.184.10';
  // 本地开发环境url
  static const String baseLocalUrl = 'http://172.26.32.1';

  /// 发送HTTP请求并处理异常
  ///
  /// 发送一个HTTP请求到指定的路径，支持指定请求方法 [method]，请求头 [headers]，请求体 [body]，以及请求成功的回调 [onSuccess] 和异常处理回调函数 [onError]。
  ///
  /// 参数：
  ///   - [path]: 请求路径
  ///   - [method]: 请求的方法，默认为'GET'
  ///   - [headers]: 请求的头部信息
  ///   - [body]: 请求的数据体
  ///   - [onSuccess]: 发送成功的回调
  ///   - [onError]: 异常处理的回调函数
  ///
  /// 返回值：一个 Future，表示发送请求的结果
  static Future<void> sendRequestAsync(String port, String path,
      {required HttpMethod method,
      Map<String, String>? headers,
      dynamic body,
      String? token,
      Function(dynamic)? onSuccess,
      Function(Exception)? onError}) async {
    var url = kReleaseMode
        ? '${HttpClientUtils.baseOnlineUrl}:$port/$path'
        : '${HttpClientUtils.baseLocalUrl}:$port/$path';
    try {
      http.Response response;

      Map<String, String>? updatedHeaders;
      if (token != null) {
        updatedHeaders = {...?headers};
        updatedHeaders['Authorization'] = 'Bearer $token';
      }

      if (method == HttpMethod.GET) {
        response = await http.get(Uri.parse(url),
            headers: token == null ? headers : updatedHeaders);
      } else if (method == HttpMethod.POST) {
        response = await http.post(Uri.parse(url),
            headers: token == null ? headers : updatedHeaders, body: body);
      } else {
        throw UnsupportedError('Unsupported HTTP method: $method');
      }

      LogUtil.init(title: "httpRequest", isDebug: true, limitLength: 500);

      Map<String, dynamic> responseBody =
          jsonDecode(utf8.decode(response.bodyBytes));

      LogUtil.d(response.statusCode);
      if (response.statusCode == 200) {
        // 请求成功，执行回调函数或处理其他逻辑
        LogUtil.d(responseBody);
        onSuccess!(responseBody);
      } else {
        throw HttpException(
            'Request failed. Status code: ${responseBody['code']}, Response: ${responseBody['msg']}');
      }
    } catch (e) {
      // 发生异常，执行回调函数或处理其他逻辑
      if (onError != null) {
        if (e is Exception) {
          onError(e);
          LogUtil.d(e);
        }
      }
    }
  }

  /// 检查与远程主机是否可以建立网络连接
  static Future<bool> checkNetworkState() async {
    LogUtil.init(title: "httpRequest", isDebug: true, limitLength: 30);
    String url = "https://www.shiroha.love";
    try {
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200;
    } on HttpException catch (e) {
      LogUtil.d(e);
      return false;
    }
  }
}
