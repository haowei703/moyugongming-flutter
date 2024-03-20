import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:moyugongming/widgets/transparent_button.dart';

import '../screens/camera.dart';
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
                SizedBox(
                  child: Text(
                    "工具区",
                    style: TextStyle(),
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          mainAxisExtent: 60.0),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              gradient: LinearGradient(
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
                                    offset: Offset(-1, -1),
                                    color: Colors.black.withOpacity(0.5))
                              ]),
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
                              gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF008888),
                                    Color(0xFF2096CA)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.bottomRight,
                                  stops: [0.3, 1.0]),
                              borderRadius: BorderRadius.circular(12)),
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
                              gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF11B0D7),
                                    Color(0xFF87A3DC)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.bottomRight,
                                  stops: [0.1, 0.8]),
                              borderRadius: BorderRadius.circular(12)),
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
                            gradient: LinearGradient(
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
                                WidgetsFlutterBinding.ensureInitialized();
                                final cameras = await availableCameras();
                                List<CameraDescription> cameraList = [];
                                cameraList.addAll(cameras);
                                push(CameraScreen(cameraList: cameraList));
                              },
                              child: Text(
                                "录音翻译",
                                style: TextStyle(color: Colors.black87),
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
}
