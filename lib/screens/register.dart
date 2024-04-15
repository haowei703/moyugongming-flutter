import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moyugongming/screens/webview.dart';

import '../animation/slide_route.dart';
import '../utils/http_client_utils.dart';
import '../widgets/custom_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _phoneNumber = "";
  String _code = "";
  String _password = "";

  TextEditingController? _controller;

  // 验证码计时
  Timer? _timer;
  int _time = 60;
  bool _isButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("注册"),
      ),
      body: Center(
        child: Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
                child: TextFormField(
                  onChanged: (value) {
                    _phoneNumber = value;
                  },
                  keyboardType: TextInputType.number,
                  controller: _controller =
                      TextEditingController(text: _phoneNumber),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                    hintText: '请输入手机号',
                    prefixIcon: Icon(
                      Icons.phone_android_rounded,
                      color: Color.fromRGBO(77, 162, 249, 1.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        _controller?.clear();
                        _phoneNumber = "";
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: TextFormField(
                  onChanged: (value) {
                    _code = value;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                    hintText: '请输入验证码',
                    prefixIcon: Icon(
                      Icons.security_rounded,
                      color: Color.fromRGBO(77, 162, 249, 1.0),
                    ),
                    suffixIcon: !_isButtonDisabled
                        ? TextButton(
                            onPressed: () {
                              if (_phoneNumber.length != 11) {
                                String msg = "";
                                if (_phoneNumber.length == 0) {
                                  msg = "手机号不能为空";
                                } else
                                  msg = "手机号格式错误";
                                Fluttertoast.showToast(
                                  msg: msg,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.grey,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              } else {
                                setState(() {
                                  _time = 60;
                                  _isButtonDisabled = true;
                                  _showTimer();
                                });
                                getSMSCode(_phoneNumber);
                              }
                            },
                            style: ButtonStyle(
                              overlayColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.transparent;
                                }
                                return Colors.transparent;
                              }),
                            ),
                            child: Text(
                              '获取验证码',
                              style: TextStyle(color: Colors.blue),
                            ),
                          )
                        : SizedBox(
                            height: double.infinity,
                            width: 80,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "$_time秒后重发",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: TextFormField(
                  onChanged: (value) {
                    _password = value;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                    hintText: '请输入密码',
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Color.fromRGBO(77, 162, 249, 1.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 40,
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      if (_phoneNumber == "" ||
                          _code == "" ||
                          _password == "") {
                        String str = _phoneNumber == ""
                            ? "手机号"
                            : (_code == "" ? "验证码" : "密码");
                        Fluttertoast.showToast(
                          msg: "$str不能为空",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.grey,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else {
                        registerRequest(
                            phoneNumber: _phoneNumber,
                            password: _password,
                            code: _code);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(300, 500),
                        backgroundColor:
                            const Color.fromRGBO(77, 162, 249, 1.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    child: const Text(
                      "确认注册",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )),
              ),
              SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: '注册即视为同意',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.0,
                        ),
                        children: [
                          TextSpan(
                            text: '《用户服务协议》',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // 用户协议点击事件处理
                                Navigator.push(
                                    context,
                                    SlideRouteRight(
                                        page: WebViewScreen(
                                      title: "用户协议",
                                      url: "http://123.56.184.10",
                                    )));
                              },
                          ),
                          TextSpan(
                            text: ' 和 ',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: '《隐私政策》',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // 隐私政策点击事件处理
                                Navigator.push(
                                    context,
                                    SlideRouteRight(
                                        page: WebViewScreen(
                                      title: "隐私政策",
                                      url: "http://123.56.184.10/privacypolicy",
                                    )));
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 验证码计时
  _showTimer() {
    _timer?.cancel(); // 如果_timer已经被赋值，则先取消之前的定时器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_time > 0) {
        setState(() {
          _time--;
        });
      } else {
        _timer?.cancel(); // 时间到，取消定时器
        setState(() {
          _isButtonDisabled = false; // 更新按钮状态
        });
      }
    });
  }

  /// 获取验证码
  Future<void> getSMSCode(String phoneNumber) async {
    String port = "8080";
    String basePath = "user/sendSMS";
    String path = "$basePath?phoneNumber=$phoneNumber";
    Map<String, String> headers = {'Content-Type': 'application/json'};
    HttpClientUtils.sendRequestAsync(port, path,
        method: HttpMethod.GET, headers: headers, onSuccess: (_) {
      Fluttertoast.showToast(msg: "发送成功");
    }, onError: (error) {
      if (error is HttpException) {
        String msg = error.toString();
        RegExp regExp = RegExp(r'Status code: (\d+), Response: (.+)');
        Iterable<RegExpMatch> matches = regExp.allMatches(msg);
        if (matches.isNotEmpty) {
          RegExpMatch match = matches.first;
          String? responseBody = match.group(2);
          _showDialog(content: Text(responseBody!));
        }
      } else if (error is SocketException) {
        _showDialog(
            title: "网络未连接",
            content: const Text(
              "请检查网络设置",
              style: TextStyle(fontSize: 16),
            ));
      }
    });
  }

  // 注册请求
  Future<void> registerRequest(
      {required String phoneNumber,
      required String password,
      required String code}) async {
    String port = "8080";
    String path = 'user/register';
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String body;
    body = jsonEncode(
        {"phoneNumber": phoneNumber, "code": code, "password": password});
    HttpClientUtils.sendRequestAsync(port, path,
        method: HttpMethod.POST,
        headers: headers,
        body: body,
        onSuccess: (response) {}, onError: (error) {
      if (error is HttpException) {
        String msg = error.toString();
        RegExp regExp = RegExp(r'Status code: (\d+), Response: (.+)');
        Iterable<RegExpMatch> matches = regExp.allMatches(msg);
        if (matches.isNotEmpty) {
          RegExpMatch match = matches.first;
          String? responseBody = match.group(2);
          _showDialog(content: Text(responseBody!));
        }
      } else if (error is SocketException) {
        _showDialog(
            title: "网络未连接",
            content: const Text(
              "请检查网络设置",
              style: TextStyle(fontSize: 16),
            ));
      }
    });
  }

  _showDialog(
      {String? title, required Widget content, VoidCallback? onClicked}) {
    showDialog(
        context: context,
        builder: (context) => CustomDialog(
              title: title,
              onClicked: onClicked,
              content: content,
            ));
  }
}
