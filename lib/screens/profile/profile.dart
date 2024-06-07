import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moyugongming/widgets/animation/slide_route.dart';
import 'package:moyugongming/screens/account/login_screen.dart';
import 'package:moyugongming/screens/profile/person_info_page.dart';
import 'package:moyugongming/screens/profile/setting.dart';
import 'package:moyugongming/utils/log_util.dart';

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _userName;
  bool _hasLogin = false;

  @override
  void initState() {
    super.initState();
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
                  topWidget(),
                  content(),
                ],
              ),
            );
          }
        });
  }

  Widget topWidget() {
    return Container(
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        child: GestureDetector(
                          onTap: () {
                            if (_hasLogin == true) {
                              _navigatorPush(context, const PersonInfoScreen());
                            } else {
                              return;
                            }
                          },
                          child: const CircleAvatar(
                              radius: 30, // 头像的半径
                              backgroundImage:
                                  AssetImage("assets/icon/avatar.jpg")),
                        ),
                      ),
                      SizedBox(
                        child: _userName != null
                            ? Text(_userName!)
                            : ElevatedButton(
                                style: ButtonStyle(
                                  minimumSize:
                                      MaterialStateProperty.resolveWith<Size>(
                                    (Set<MaterialState> states) {
                                      return const Size(50, 35);
                                    },
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  shadowColor: MaterialStateProperty.all<Color>(
                                      Colors.transparent),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      return Colors.transparent;
                                    },
                                  ),
                                ),
                                onPressed: () async {
                                  await _navigatorPush(
                                      context, const LoginScreen());
                                },
                                child: const Text(
                                  "登录",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                )),
                      )
                    ],
                  ),
                )),
            Expanded(
                flex: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                              borderRadius: BorderRadius.circular(12),
                              child: const Image(
                                image: AssetImage(
                                    "assets/background/background.png"),
                                fit: BoxFit.cover,
                              ),
                            )),
                        Container(
                          decoration: const BoxDecoration(
                              color: Colors.transparent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(22, 23, 26, 0.5),
                                    offset: Offset(0, 0),
                                    blurRadius: 12,
                                    blurStyle: BlurStyle.outer)
                              ]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color.fromRGBO(175, 175, 175, 0.1),
                                  ),
                                  child: const SizedBox(
                                    height: double.infinity,
                                    width: double.infinity,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: Text(
                                        '签到',
                                        style: TextStyle(color: Colors.white),
                                      ),
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
    );
  }

  Widget content() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        color: const Color.fromRGBO(243, 242, 247, 1),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.only(top: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              children: ListTile.divideTiles(
                context: context,
                color: Colors.grey.shade300,
                tiles: [
                  ListTile(
                    title: const Text("我的钱包"),
                    leading: Icon(Icons.account_balance_wallet,
                        color: Theme.of(context).iconTheme.color),
                    trailing: const Icon(Icons.arrow_forward_ios_outlined),
                    onTap: () {
                      // 处理点击事件
                    },
                  ),
                  ListTile(
                    title: const Text("翻译记录"),
                    leading: Icon(Icons.record_voice_over,
                        color: Theme.of(context).iconTheme.color),
                    trailing: const Icon(Icons.arrow_forward_ios_outlined),
                    onTap: () {
                      // 处理点击事件
                    },
                  ),
                  ListTile(
                    title: const Text("关于默语共鸣"),
                    leading: Icon(Icons.info,
                        color: Theme.of(context).iconTheme.color),
                    trailing: const Icon(Icons.arrow_forward_ios_outlined),
                    onTap: () {
                      // 处理点击事件
                    },
                  ),
                  ListTile(
                    title: const Text("设置"),
                    leading: Icon(Icons.settings,
                        color: Theme.of(context).iconTheme.color),
                    trailing: const Icon(Icons.arrow_forward_ios_outlined),
                    onTap: () {
                      Navigator.push(
                        context,
                        SlideRouteRight(page: const SettingScreen()),
                      );
                    },
                  ),
                ],
              ).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigatorPush(BuildContext context, Widget widget) async {
    await Navigator.push(context, SlideRouteBottom(page: widget));
    await _readUserInfo().then((userInfo) {
      if (userInfo != null) {
        setState(() {
          _userName = userInfo['username'];
        });
      } else {
        setState(() {
          _userName = null;
          _hasLogin = false;
        });
      }
    });
  }

  /// sharded_preferences读取用户信息和设置信息
  Future<Map<String, String>?> _readUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString("username");
    LogUtil.init(title: "读取用户信息", isDebug: true, limitLength: 200);
    LogUtil.d("username:$userName");
    if (userName != null) {
      _userName = userName;
      _hasLogin = true;
      Map<String, String> userInfo = {"username": userName};
      return userInfo;
    } else {
      return null;
    }
  }
}
