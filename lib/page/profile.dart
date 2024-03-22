import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moyugongming/animation/slide_route.dart';
import 'package:moyugongming/screens/login.dart';
import 'package:moyugongming/screens/personinfo.dart';
import 'package:moyugongming/screens/setting.dart';
import 'package:moyugongming/utils/log_util.dart';
import 'package:moyugongming/widgets/transparent_button.dart';

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _userName;
  bool? _logined;

  @override
  void initState() {
    super.initState();
    // _res();
  }

  void _res() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: _readUserInfo(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // 显示加载指示器
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // 显示错误信息
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 220,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            Color(0xFFFDF7E6),
                            Color(0xFFF3E9EB),
                            Color(0xFFF3F5E6),
                            Color(0xFFFDF2EC),
                            Color(0xFFECF3F6),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [0.0, 0.25, 0.5, 0.75, 1.0]),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25, bottom: 5),
                      child: Column(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (_logined != null &&
                                              _logined == true) {
                                            Navigator.push(
                                                context,
                                                SlideRouteRight(
                                                    page:
                                                        const PersonInfoScreen()));
                                          } else {
                                            return;
                                          }
                                        },
                                        child: const CircleAvatar(
                                            radius: 30, // 头像的半径
                                            backgroundImage: AssetImage(
                                                "assets/icon/avatar.jpg")),
                                      ),
                                    ),
                                    SizedBox(
                                      child: _userName != null
                                          ? Text(_userName!)
                                          : ElevatedButton(
                                              style: ButtonStyle(
                                                minimumSize:
                                                    MaterialStateProperty
                                                        .resolveWith<Size>(
                                                  (Set<MaterialState> states) {
                                                    return const Size(50, 35);
                                                  },
                                                ),
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(Colors.white),
                                                shadowColor:
                                                    MaterialStateProperty.all<
                                                            Color>(
                                                        Colors.transparent),
                                                overlayColor:
                                                    MaterialStateProperty
                                                        .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                                    return Colors.transparent;
                                                  },
                                                ),
                                              ),
                                              onPressed: () {
                                                _navigatorPush(context)
                                                    .then((value) => {
                                                          setState(() {
                                                            _userName = value;
                                                          })
                                                        });
                                              },
                                              child: const Text(
                                                "登录",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12),
                                              )),
                                    )
                                  ],
                                ),
                              )),
                          Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned.fill(
                                          top: 0,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: const Image(
                                              image: AssetImage(
                                                  "assets/background/background.png"),
                                              fit: BoxFit.cover,
                                            ),
                                          )),
                                      Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12)),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Color.fromRGBO(
                                                      22, 23, 26, 0.5),
                                                  offset: Offset(0, 0),
                                                  blurRadius: 12,
                                                  blurStyle: BlurStyle.outer)
                                            ]),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 10, sigmaY: 10),
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      175, 175, 175, 0.1),
                                                ),
                                                child: const SizedBox(
                                                  height: double.infinity,
                                                  width: double.infinity,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                            vertical: 10),
                                                    child: Text('123'),
                                                  ),
                                                ),
                                              )),
                                        ),
                                      )
                                      // Positioned(
                                      //   top: 120,
                                      //   child: ,
                                      // ),
                                    ],
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      color: const Color.fromRGBO(243, 242, 247, 1),
                      child: ListView(
                        padding: const EdgeInsets.only(top: 0),
                        physics: const BouncingScrollPhysics(),
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.zero,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Column(
                                children: [
                                  TransparentButton(
                                    onPressed: () {},
                                    child: Container(
                                        height: 40,
                                        padding: const EdgeInsets.all(12),
                                        child: const Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.access_alarm,
                                                size: 20,
                                                color: Colors.black87),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "常用设置",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black87),
                                            ),
                                            Expanded(
                                                child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                Icons
                                                    .arrow_forward_ios_outlined,
                                                size: 16,
                                                color: Colors.black87,
                                              ),
                                            ))
                                          ],
                                        )),
                                  ),
                                  const Divider(
                                      thickness: 0.7,
                                      indent: 42,
                                      endIndent: 12,
                                      height: 0),
                                  TransparentButton(
                                    onPressed: () {},
                                    child: Container(
                                        height: 40,
                                        padding: const EdgeInsets.all(12),
                                        child: const Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.access_alarm,
                                                size: 20,
                                                color: Colors.black87),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "常用设置",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black87),
                                            ),
                                            Expanded(
                                                child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                Icons
                                                    .arrow_forward_ios_outlined,
                                                size: 16,
                                                color: Colors.black87,
                                              ),
                                            ))
                                          ],
                                        )),
                                  ),
                                  const Divider(
                                      thickness: 0.7,
                                      indent: 42,
                                      endIndent: 12,
                                      height: 0),
                                  TransparentButton(
                                    onPressed: () {},
                                    child: Container(
                                        height: 40,
                                        padding: const EdgeInsets.all(12),
                                        child: const Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.battery_full,
                                                size: 20,
                                                color: Colors.black87),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "关于默语共鸣",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black87),
                                            ),
                                            Expanded(
                                                child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                Icons
                                                    .arrow_forward_ios_outlined,
                                                size: 16,
                                                color: Colors.black87,
                                              ),
                                            ))
                                          ],
                                        )),
                                  ),
                                  const Divider(
                                      thickness: 0.7,
                                      indent: 42,
                                      endIndent: 12,
                                      height: 0),
                                  TransparentButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          SlideRouteRight(
                                              page: const SettingScreen()));
                                    },
                                    child: Container(
                                        height: 40,
                                        padding: const EdgeInsets.all(12),
                                        child: const Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.settings_outlined,
                                                size: 20,
                                                color: Colors.black87),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "设置",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black87),
                                            ),
                                            Expanded(
                                                child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                Icons
                                                    .arrow_forward_ios_outlined,
                                                size: 16,
                                                color: Colors.black87,
                                              ),
                                            ))
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 245)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  Future<String> _navigatorPush(BuildContext context) async {
    final result = await Navigator.push(
        context, SlideRouteBottom(page: const LoginScreen()));
    Completer<String> completer = Completer();
    completer.complete(result);
    Fluttertoast.showToast(
      msg: "登录成功",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    return completer.future;
  }

  /// sharded_preferences读取用户信息和设置信息
  Future<void> _readUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString("userName");
    LogUtil.init(title: "读取用户信息", isDebug: true, limitLength: 200);
    LogUtil.d("userName:$userName");
    if (userName != null) {
      _userName = userName;
      _logined = true;
    } else {
      _logined = false;
    }
  }
}
