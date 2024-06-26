import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moyugongming/widgets/animation/slide_route.dart';
import 'package:moyugongming/screens/account/login_screen.dart';
import 'package:moyugongming/widgets/button/transparent_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'camera_screen.dart';
import 'package:moyugongming/utils/log_util.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("主页",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(237, 237, 237, 0.8),
        actions: [
          IconButton(
              onPressed: () {
                // TODO 扫一扫
              },
              icon: const Icon(CupertinoIcons.add)),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(offset: Offset(0, 0), blurRadius: 5),
            ], color: Colors.black),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration:
            const BoxDecoration(color: Color.fromRGBO(243, 242, 247, 1)),
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              mainAxisExtent: 80.0),
                      children: [
                        gridViewItem(
                          text: "录音翻译",
                          linearGradient: const LinearGradient(
                              colors: [Color(0xFFE09FCE), Color(0xFF87A3DC)],
                              begin: Alignment.centerLeft,
                              end: Alignment.bottomRight,
                              stops: [0.3, 1.0]),
                          onPressed: () {},
                        ),
                        gridViewItem(
                          text: "在线语音翻译",
                          linearGradient: const LinearGradient(
                              colors: [Color(0xFF008888), Color(0xFF2096CA)],
                              begin: Alignment.centerLeft,
                              end: Alignment.bottomRight,
                              stops: [0.3, 1.0]),
                          onPressed: () {},
                        ),
                        gridViewItem(
                          text: "文字转手语",
                          linearGradient: const LinearGradient(
                              colors: [Color(0xFF11B0D7), Color(0xFF87A3DC)],
                              begin: Alignment.centerLeft,
                              end: Alignment.bottomRight,
                              stops: [0.1, 0.8]),
                          onPressed: () {},
                        ),
                        gridViewItem(
                          text: "手语翻译",
                          linearGradient: const LinearGradient(
                              colors: [Color(0xFF56D7E3), Color(0xFF00666A)],
                              begin: Alignment.centerLeft,
                              end: Alignment.bottomRight,
                              stops: [0.4, 1.0]),
                          onPressed: () async {
                            btnClicked(onSuccess: (token) async {
                              WidgetsFlutterBinding.ensureInitialized();
                              final cameras = await availableCameras();
                              List<CameraDescription> cameraList = [];
                              cameraList.addAll(cameras);
                              push(CameraScreen(
                                cameraList: cameraList,
                                token: token,
                              ));
                            });
                          },
                        )
                      ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 网格布局item子项
  Widget gridViewItem(
      {required String text,
      required LinearGradient linearGradient,
      required Function onPressed}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          gradient: linearGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(1, -1),
                color: Colors.black.withOpacity(0.3))
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: TransparentButton(
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(color: Colors.black87, fontSize: 16.0),
          ),
        ),
      ),
    );
  }

  push(Widget widget) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
  }

  // 检查登录信息
  btnClicked({required Function onSuccess}) async {
    String? token = await _readToken();
    if (token != null) {
      onSuccess(token);
    } else {
      if (mounted) {
        _showDialog();
      }
    }
  }

  // 读取token信息
  Future<String?> _readToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    LogUtil.init(title: "读取token信息", isDebug: true, limitLength: 200);
    LogUtil.d("token:$token");
    if (token != null) {
      return token;
    } else {
      return null;
    }
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: const Text("请先登录"),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    Navigator.push(
                        context, SlideRouteRight(page: const LoginScreen()));
                  },
                  child: const Text('确定'),
                ),
              ],
            ));
  }

  void _showToast(String message) {
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
}
