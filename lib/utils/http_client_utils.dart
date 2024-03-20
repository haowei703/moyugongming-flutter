import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:moyugongming/utils/log_util.dart';

enum HttpMethod { GET, POST }

class HttpClientUtils {
  // 服务器生产环境url
  // static const String baseUrl = 'http://123.56.184.10:8080/';
  // 本地开发环境url
  static const String _baseUrl = 'http://172.26.32.1:8080/';

  /// 发送HTTP请求并处理异常
  ///
  /// 发送一个HTTP请求到指定的 [url]，支持指定请求方法 [method]，请求头 [headers]，请求体 [body]，以及异常处理回调函数 [onError]。
  ///
  /// 参数：
  ///   - [url]: 请求的URL
  ///   - [method]: 请求的方法，默认为'GET'
  ///   - [headers]: 请求的头部信息
  ///   - [body]: 请求的数据体
  ///   - [onError]: 异常处理的回调函数
  ///
  /// 返回值：一个 Future，表示发送请求的结果
  static Future<void> sendRequest(String path,
      {required HttpMethod method,
      Map<String, String>? headers,
      dynamic body,
      String? token,
      Function(dynamic)? onSuccess,
      Function(Exception)? onError}) async {
    var url = '${HttpClientUtils._baseUrl}$path';
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

      Map<String, dynamic> responseBody = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        // 请求成功，执行回调函数或处理其他逻辑
        LogUtil.d(responseBody);
        onSuccess!(responseBody);
      } else {
        throw Exception(
            'Request failed. Status code: ${responseBody['code']}, Response: ${responseBody['msg']}');
      }
    } catch (e) {
      // 发生异常，执行回调函数或处理其他逻辑
      if (onError != null) {
        if (e is Exception) {
          onError(e);
          LogUtil.d(e);
        }
      } else {
        LogUtil.d(e);
      }
    }
  }
}
