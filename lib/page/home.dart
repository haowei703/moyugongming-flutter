import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moyugongming/animation/slide_route.dart';
import 'package:moyugongming/screens/login.dart';
import 'package:moyugongming/utils/http_client_utils.dart';
import 'package:moyugongming/widgets/transparent_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../screens/camera.dart';
import '../screens/genImage.dart';
import '../utils/log_util.dart';
import '../widgets/my_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _token;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
        appBar: MyAppBar(
          title: "主页",
        ),
        drawer: Drawer(
          child: ListView(),
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(color: Color.fromRGBO(243, 242, 247, 1)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  child: Text(
                    "工具区",
                    style: TextStyle(),
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: GridView(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          mainAxisExtent: 80.0),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE09FCE),
                                    Color(0xFF87A3DC)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.bottomRight,
                                  stops: [0.3, 1.0]),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: const Offset(-1, -1),
                                    color: Colors.black.withOpacity(0.5))
                              ]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: TransparentButton(
                              onPressed: () {},
                              child: const Text(
                                "录音翻译",
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 16.0),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: Offset(1, -1),
                                    color: Colors.black.withOpacity(0.5))
                              ],
                              gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF008888),
                                    Color(0xFF2096CA)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.bottomRight,
                                  stops: [0.3, 1.0]),
                              borderRadius: BorderRadius.circular(12)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: TransparentButton(
                              onPressed: () {},
                              child: const Text(
                                "在线录音翻译",
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 16.0),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: Offset(-1, 1),
                                    color: Colors.black.withOpacity(0.5))
                              ],
                              gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF11B0D7),
                                    Color(0xFF87A3DC)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.bottomRight,
                                  stops: [0.1, 0.8]),
                              borderRadius: BorderRadius.circular(12)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: TransparentButton(
                              onPressed: () {
                                push(const GenImageScreen());
                              },
                              child: const Text(
                                "文字转手语",
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 16.0),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: Offset(1, 1),
                                  color: Colors.black.withOpacity(0.5))
                            ],
                            gradient: const LinearGradient(
                                colors: [Color(0xFF56D7E3), Color(0xFF00666A)],
                                begin: Alignment.centerLeft,
                                end: Alignment.bottomRight,
                                stops: [0.4, 1.0]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: TransparentButton(
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
                              child: const Text(
                                "手语翻译",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                Expanded(child: Container())
              ],
            ),
          ),
        ));
  }

  push(Widget widget) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
  }

  // 检查登录信息
  btnClicked({required Function onSuccess}) async {
    Map<String, String>? userInfo = await _readUserInfo();
    if (userInfo != null) {
      onSuccess(userInfo['token']);
    } else {
      if (mounted) {
        _showDialog();
      }
    }
  }

  // 读取token信息
  Future<Map<String, String>?> _readUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    LogUtil.init(title: "读取token信息", isDebug: true, limitLength: 200);
    LogUtil.d("token:$token");
    if (token != null) {
      return {"token": token};
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
                            context, SlideRouteRight(page: const LoginScreen()))
                        .then((_) {
                      _readUserInfo().then((userInfo) {
                        if (userInfo != null) {
                          Fluttertoast.showToast(
                            msg: "登录成功",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                      });
                    });
                  },
                  child: const Text('确定'),
                ),
              ],
            ));
  }
}
