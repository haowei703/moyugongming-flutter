import 'dart:ui';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:moyugongming/utils/convert_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.cameraList});

  final List<CameraDescription> cameraList;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  // 当前摄像头方向
  late Future<void> _initializeControllerFuture;
  late CameraLensDirection _lensDirection;

  // 是否正在流式传输
  bool _isSteaming = false;

  // 是否完成连接
  bool? _isReady;
  late WebSocketChannel _channel;

  // token
  String? _token;

  // 保存手语识别结果
  String message = "";

  @override
  void initState() {
    super.initState();
    _controller =
        CameraController(widget.cameraList.first, ResolutionPreset.max);
    _lensDirection = widget.cameraList.first.lensDirection;
    _initializeControllerFuture = _controller.initialize();
    _readToken().then((_) => _connectChannel());
  }

  @override
  void dispose() {
    _controller.dispose();
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller),
                Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.arrow_back))
                        ],
                      ),
                    )),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      verticalDirection: VerticalDirection.up,
                      children: [
                        SizedBox(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 30),
                            color: Colors.black12.withOpacity(0.7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      if (!_isSteaming) {
                                        _startVideoStreaming();
                                      } else {
                                        _stopVideoStreaming();
                                      }
                                    },
                                    icon: Icon(
                                      Icons.videocam,
                                      color: Colors.white,
                                    )),
                                IconButton(
                                    onPressed: () {
                                      _flipCameraDescription();
                                    },
                                    icon: Icon(
                                      Icons.flip_camera_android,
                                      color: Colors.white,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // 子组件最高高度为
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 200),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              // 背景模糊
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  color: Colors.black.withOpacity(0.4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                              Icons.cleaning_services_rounded)),
                                      Expanded(
                                          child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            StreamBuilder(
                                              stream: _channel.stream,
                                              builder: (context, snapshot) {
                                                if(snapshot.hasData && snapshot.data != null){
                                                  message += snapshot.data;
                                                }
                                                return Column(
                                                  children: [
                                                    Text(
                                                      message,
                                                      softWrap: true,
                                                    )
                                                  ],
                                                );
                                              },
                                            )
                                          ],
                                        ),
                                      ))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                // CameraPreview(_controller)
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  _flipCameraDescription() {
    CameraDescription? cameraDescription;
    for (CameraDescription camera in widget.cameraList) {
      if (camera.lensDirection != _lensDirection) {
        cameraDescription = camera;
      }
    }
    if (cameraDescription != null) {
      setState(() {
        _controller.setDescription(cameraDescription!);
        _lensDirection = cameraDescription.lensDirection;
      });
    }
  }

  // 连接websocket服务器
  Future<void> _connectChannel() async {
    String url = "ws://123.56.184.10:8080/ws/video?token=$_token";
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _channel.ready.then((_) => _isReady = true);
  }

  // 开启视频流传输
  void _startVideoStreaming() async {
    if(_isReady == null || _isReady!){
    _controller.startImageStream((image) {
      // 图像转为单字节数组
      List<int> imageData = FormatConvert.convertUint8List(image);
      _channel.sink.add(imageData);

      setState(() {
        _isSteaming = true;
      });
    });
    }
  }

  // 关闭视频传输
  void _stopVideoStreaming() async {
    _controller.stopImageStream();
    setState(() {
      _isSteaming = false;
    });
  }

  // 读取本地token
  Future<void> _readToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    setState(() {
      _token = token;
    });
  }
}
