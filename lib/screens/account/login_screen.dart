import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moyugongming/widgets/animation/slide_route.dart';
import 'package:moyugongming/widgets/animation/left_right_slide_animation.dart';
import 'package:moyugongming/screens/account/register_screen.dart';
import 'package:moyugongming/screens/account/webview.dart';
import 'package:moyugongming/widgets/dialog/custom_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moyugongming/api/net/user_service.dart';
import 'package:moyugongming/model/vo/token.dart';

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

  final UserService userService = UserService();

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
      padding: const EdgeInsets.all(20),
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
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _controller?.clear();
                    phoneNumber = "";
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
                if (usePhoneCode) {
                  code = value;
                } else {
                  password = value;
                }
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                hintText: usePhoneCode ? '请输入验证码' : '请输入密码',
                prefixIcon: Icon(
                  usePhoneCode ? Icons.security_rounded : Icons.lock,
                  color: const Color.fromRGBO(77, 162, 249, 1.0),
                ),
                suffixIcon: usePhoneCode
                    ? (!_isButtonDisabled
                        ? TextButton(
                            onPressed: () {
                              if (phoneNumber.length != 11) {
                                String msg = "";
                                if (phoneNumber.isEmpty) {
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
                              } else {
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
          const SizedBox(height: 6),
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
                                      url: "http://123.56.184.10",
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
                                      url: "http://123.56.184.10/privacypolicy",
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
          const SizedBox(height: 6),
          SizedBox(
            height: 40,
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () => loginRequest(),
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
          const SizedBox(height: 10),
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
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Align(
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                    text: "没有账号？立即",
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "注册",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final result = await Navigator.push(context,
                                SlideRouteRight(page: const RegisterScreen()));
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
                        style: const TextStyle(
                          color: Color.fromRGBO(77, 162, 249, 1.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
  void getSMSCode(String phoneNumber) async {
    bool isSuccess = await userService.sendSmsCode(phoneNumber);
    if (isSuccess) {
      _showToast(message: "发送成功，请注意查收");
      setState(() {
        _time = 60;
        _isButtonDisabled = true;
        _showTimer();
      });
    } else {
      _showToast(message: "发送失败，请稍后再试");
    }
  }

  // 检验输入是否正确
  bool verify() {
    if (phoneNumber == "") {
      _showToast(message: "手机号不能为空");
    } else if (_usePhoneCode && code == "") {
      _showToast(message: "验证码不能为空");
    } else if (!_usePhoneCode && password == "") {
      _showToast(message: "密码不能为空");
    } else if (code != "" || password != "") {
      return true;
    }
    return false;
  }

  // 登录请求
  void loginRequest() {
    if (!verify()) {
      return;
    }
    if (_usePhoneCode) {
      userService.login(phoneNumber: phoneNumber, code: code).then((jwt) {
        _showToast(message: "登录成功");
        _saveUserInfo(jwt: jwt).then((_) => pop());
      }).catchError((error) {
        if(error != null && error is AuthException){
          _showToast(message: error.message);
        }
      });
    } else {
      userService
          .login(phoneNumber: phoneNumber, password: password)
          .then((jwt) {
        _showToast(message: "登录成功");
        _saveUserInfo(jwt: jwt).then((_) => pop());
      });
    }
  }

  /// sp写入token和用户信息
  Future<void> _saveUserInfo({required JWT jwt}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("token", jwt.accessToken);
    prefs.setString("uid", jwt.id);
    prefs.setString("username", jwt.username);
    prefs.setString("phoneNumber", phoneNumber);
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

  void _showDialog(
      {String? title, required Widget content, VoidCallback? onClicked}) {
    showDialog(
        context: context,
        builder: (context) => CustomDialog(
              title: title,
              onClicked: onClicked,
              content: content,
            ));
  }

  pop() {
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
