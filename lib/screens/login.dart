import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moyugongming/animation/slide_route.dart';
import 'package:moyugongming/screens/register.dart';
import 'package:moyugongming/screens/webview.dart';
import 'package:moyugongming/utils/log_util.dart';
import 'package:moyugongming/widgets/custom_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../animation/left_right_slide_animation.dart';
import '../utils/http_client_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  final String title = "登录";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _usePhoneCode = true;

  // 获取到的用户名和手机号
  String phoneNumber = "";
  String code = "";
  String password = "";
  bool isChecked = false;

  // 验证码计时
  Timer? _timer;
  int _time = 60;
  bool _isButtonDisabled = false;

  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel(); // 页面销毁时取消定时器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SSLSlideTransition(
                direction: AxisDirection.left,
                position: animation,
                child: child);
          },
          child: inputForm(_usePhoneCode)),
    );
  }

  // 输入表单内容
  Widget inputForm(bool usePhoneCode) {
    return Container(
        key: ValueKey<bool>(usePhoneCode),
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
                  phoneNumber = value;
                },
                keyboardType: TextInputType.number,
                controller: _controller =
                    TextEditingController(text: phoneNumber),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  hintText: '请输入手机号',
                  prefixIcon: const Icon(
                    Icons.phone_android_rounded,
                    color: Color.fromRGBO(77, 162, 249, 1.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      _controller?.clear();
                      phoneNumber = "";
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
                  if (usePhoneCode) {
                    code = value;
                  } else {
                    password = value;
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                  hintText: usePhoneCode ? '请输入验证码' : '请输入密码',
                  prefixIcon: Icon(
                    usePhoneCode ? Icons.security_rounded : Icons.lock,
                    color: Color.fromRGBO(77, 162, 249, 1.0),
                  ),
                  suffixIcon: usePhoneCode
                      ? (!_isButtonDisabled
                          ? TextButton(
                              onPressed: () {
                                if (phoneNumber.length != 11) {
                                  String msg = "";
                                  if (phoneNumber.length == 0) {
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
                                  getSMSCode(phoneNumber);
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
                              child: const Text(
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
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ))
                      : null,
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
            SizedBox(height: 6),
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    activeColor: Colors.red,
                    value: isChecked,
                    side: const BorderSide(width: 2, strokeAlign: 0.5),
                    splashRadius: 10.0,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: const CircleBorder(),
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: '勾选即视为同意',
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
                                        url:
                                            "http://123.56.184.10/privacypolicy",
                                      )));
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ))
                ],
              ),
            ),
            SizedBox(height: 6),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    if (phoneNumber == "") {
                      Fluttertoast.showToast(
                        msg: "手机号不能为空",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } else if (usePhoneCode && code == "") {
                      Fluttertoast.showToast(
                        msg: "验证码不能为空",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } else if (!usePhoneCode && password == "") {
                      Fluttertoast.showToast(
                        msg: "密码不能为空",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } else if (code != "" || password != "") {
                      if (usePhoneCode) {
                        loginRequest(phoneNumber: phoneNumber, code: code)
                            .then((token) async {
                          Map<String, dynamic>? userInfo = await _getUserInfo(
                              phoneNumber: phoneNumber, token: token);
                          if (userInfo != null) {
                            userInfo['token'] = token;
                            userInfo['phoneNumber'] = phoneNumber;
                            await _saveUserInfo(userInfo: userInfo)
                                .then((value) => Navigator.pop(context));
                          }
                        });
                      } else {
                        loginRequest(
                                phoneNumber: phoneNumber, password: password)
                            .then((token) async {
                          Map<String, dynamic>? userInfo = await _getUserInfo(
                              phoneNumber: phoneNumber, token: token);
                          if (userInfo != null) {
                            userInfo['token'] = token;
                            userInfo['phoneNumber'] = phoneNumber;
                            await _saveUserInfo(userInfo: userInfo)
                                .then((value) => Navigator.pop(context));
                          }
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(300, 500),
                      backgroundColor: const Color.fromRGBO(77, 162, 249, 1.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                  child: const Text(
                    "确认登录",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _usePhoneCode = !_usePhoneCode;
                      code = "";
                      password = "";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                  child: Text(_usePhoneCode ? "账号密码登录" : "验证码登录")),
            ),
            SizedBox(
              height: 50,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Align(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                        text: "没有账号？立即",
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                              text: "注册",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final result = await Navigator.push(context,
                                      SlideRouteRight(page: RegisterScreen()));
                                  if (result['msg'] == "注册成功") {
                                    Fluttertoast.showToast(
                                      msg: "注册成功，请重新登录",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                  }
                                },
                              style: TextStyle(
                                  color: Color.fromRGBO(77, 162, 249, 1.0)))
                        ]),
                  ),
                ),
              ),
            ),
          ],
        ));
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
        method: HttpMethod.GET, headers: headers, onSuccess: (response) {
      Fluttertoast.showToast(
        msg: response['data'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
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

  // 登录请求
  Future<String> loginRequest(
      {required String phoneNumber, String? code, String? password}) async {
    if (code == null && password == null) {
      throw ArgumentError('Either code or password must be provided.');
    }
    String path = 'user/login';
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String body;
    if (code != null) {
      body = jsonEncode({"phoneNumber": phoneNumber, "code": code});
    } else {
      body = jsonEncode({"phoneNumber": phoneNumber, "password": password});
    }

    Completer<String> completer = Completer();
    String port = "8080";
    await HttpClientUtils.sendRequestAsync(port, path,
        method: HttpMethod.POST,
        headers: headers,
        body: body, onSuccess: (response) async {
      dynamic token = response['data'];
      if (token != null && token is String) {
        return completer.complete(token);
      }
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
    return completer.future;
  }

  // 请求用户信息
  Future<Map<String, dynamic>?> _getUserInfo(
      {required String phoneNumber, required String token}) async {
    String path = 'user/getUserInfo?phoneNumber=$phoneNumber';
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (token == "") {
      return null;
    }
    Completer<Map<String, dynamic>> completer = Completer();
    String port = "8080";
    HttpClientUtils.sendRequestAsync(port, path,
        method: HttpMethod.GET,
        headers: headers,
        token: token, onSuccess: (response) async {
      completer.complete(response);
    });
    return completer.future;
  }

  /// sharded_preferences写入用户信息和设置信息
  Future<void> _saveUserInfo({required Map<String, dynamic> userInfo}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (userInfo.containsKey("token") &&
        userInfo.containsKey("userName") &&
        userInfo.containsKey("id") &&
        userInfo.containsKey("phoneNumber")) {
      await prefs.setString("token", userInfo['token']);
      await prefs.setString("userName", userInfo['userName']);
      await prefs.setString("id", userInfo['id']);
      await prefs.setString("phoneNumber", userInfo['phoneNumber']);
      LogUtil.init(title: "sp写入键值对", isDebug: true, limitLength: 200);
      LogUtil.d(userInfo);
    }
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
