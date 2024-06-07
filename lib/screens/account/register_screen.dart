import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moyugongming/model/vo/token.dart';
import 'package:moyugongming/screens/account/webview.dart';
import 'package:moyugongming/api/net/user_service.dart';
import 'package:moyugongming/widgets/animation/slide_route.dart';
import 'package:moyugongming/widgets/dialog/custom_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("注册"),
      ),
      body: Center(
        child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.all(20),
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                    hintText: '请输入手机号',
                    prefixIcon: const Icon(
                      Icons.phone_android_rounded,
                      color: Color.fromRGBO(77, 162, 249, 1.0),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _controller?.clear();
                        _phoneNumber = "";
                      },
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: TextFormField(
                  onChanged: (value) {
                    _code = value;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                    hintText: '请输入验证码',
                    prefixIcon: const Icon(
                      Icons.security_rounded,
                      color: Color.fromRGBO(77, 162, 249, 1.0),
                    ),
                    suffixIcon: !_isButtonDisabled
                        ? TextButton(
                            onPressed: () => getSMSCode(_phoneNumber),
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
                          ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: TextFormField(
                  onChanged: (value) {
                    _password = value;
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
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
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () => registerRequest(),
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
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: '注册即视为同意',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12.0,
                        ),
                        children: [
                          TextSpan(
                            text: '《用户服务协议》',
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // 用户协议点击事件处理
                                Navigator.push(
                                    context,
                                    SlideRouteRight(
                                        page: const WebViewScreen(
                                      title: "用户协议",
                                      url: "https://www.shiroha.love",
                                    )));
                              },
                          ),
                          const TextSpan(
                            text: ' 和 ',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: '《隐私政策》',
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // 隐私政策点击事件处理
                                Navigator.push(
                                    context,
                                    SlideRouteRight(
                                        page: const WebViewScreen(
                                      title: "隐私政策",
                                      url: "https://www.shiroha.love/privacypolicy",
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
    // 检验
    if (_phoneNumber.length != 11) {
      String msg = "";
      if (_phoneNumber.isEmpty) {
        msg = "手机号不能为空";
      } else {
        msg = "手机号格式错误";
      }
      Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    if (await userService.sendSmsCode(_phoneNumber)) {
      setState(() {
        _time = 60;
        _isButtonDisabled = true;
        _showTimer();
      });
    } else {
      _showDialog(
        title: "网络未连接",
        content: const Text(
          "请检查网络设置",
          style: TextStyle(fontSize: 16),
        ),
      );
    }
  }

  // 注册请求
  Future<void> registerRequest() async {
    if (_phoneNumber == "" || _code == "" || _password == "") {
      String str = _phoneNumber == "" ? "手机号" : (_code == "" ? "验证码" : "密码");
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
      try {
        JWT jwt = await userService.register(
            phoneNumber: _phoneNumber, password: _password, code: _code);
        _showToast(message: "注册成功");
        _saveUserInfo(jwt: jwt).then((_) => pop());
      } on AuthException catch (e) {
        _showToast(message: e.message);
      }
    }
  }

  void _showToast({required String message}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  _showDialog(
      {String? title, required Widget content, VoidCallback? onClicked}) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        onClicked: onClicked,
        content: content,
      ),
    );
  }

  /// sp写入token和用户信息
  Future<void> _saveUserInfo({required JWT jwt}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("token", jwt.accessToken);
    prefs.setString("uid", jwt.id);
    prefs.setString("username", jwt.username);
    prefs.setString("phoneNumber", _phoneNumber);
  }

  pop() {
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
