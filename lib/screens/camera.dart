import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moyugongming/utils/convert_format.dart';
import 'package:moyugongming/utils/log_util.dart';
import 'package:moyugongming/widgets/ring.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen(
      {super.key, required this.cameraList, required this.token});

  final List<CameraDescription> cameraList;
  final String token;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  // 当前摄像头方向
  late Future<void> _initializeControllerFuture;
  late CameraLensDirection _lensDirection;

  // 是否正在流式传输
  bool _isStreaming = false;
  bool _connected = true;
  StreamController<List<int>>? _streamController;
  StreamSubscription? _subScription;

  late WebSocketChannel _channel;

  // 保存手语识别结果
  late StreamController<String> _messageController;
  late StreamSubscription _messageSubscription;
  String message = "";

  @override
  void initState() {
    super.initState();
    _controller =
        CameraController(widget.cameraList.first, ResolutionPreset.low);
    _lensDirection = widget.cameraList.first.lensDirection;
    _initializeControllerFuture = _controller.initialize();

    // String url = "ws://172.26.32.1:8080/ws/video?token=${widget.token}";
    String url = "ws://123.56.184.10:8080/ws/video?token=${widget.token}";
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _messageController = StreamController<String>();
    _listenMessage();
  }

  @override
  void dispose() {
    _controller.dispose();
    _channel.sink.close();
    _messageController.close();
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
                                _connected = false;
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
                            color: Colors.black12.withOpacity(0.2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Stack(
                                  children: [
                                    Positioned.fill(
                                      child: RingWidget(
                                        color: Colors.white,
                                        strokeWidth: 5.0,
                                        innerRadius: 30.0,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: IconButton(
                                          onPressed: () async {
                                            if (!_isStreaming) {
                                              await _startVideoStreaming();
                                              setState(() {
                                                _isStreaming = true;
                                              });
                                            } else {
                                              await _stopVideoStreaming();
                                              setState(() {
                                                _isStreaming = false;
                                              });
                                            }
                                          },
                                          color: Colors.transparent,
                                          icon: _isStreaming
                                              ? Icon(
                                                  Icons.videocam,
                                                  color: Colors.red,
                                                )
                                              : Container(
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.red),
                                                )),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  child: IconButton(
                                      onPressed: () {
                                        _flipCameraDescription();
                                      },
                                      icon: const Icon(
                                        Icons.flip_camera_android,
                                        color: Colors.white,
                                        size: 35,
                                      )),
                                ),
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
                                          onPressed: () {
                                            setState(() {
                                              _messageController.sink
                                                  .add("clear");
                                            });
                                          },
                                          icon: const Icon(
                                              Icons.cleaning_services_rounded)),
                                      Expanded(
                                          child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            StreamBuilder(
                                              stream: _messageController.stream,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData &&
                                                    snapshot.data != null) {
                                                  message += snapshot.data!;
                                                }
                                                if (snapshot.hasData &&
                                                    snapshot.data == "clear") {
                                                  message = "";
                                                }
                                                return Column(
                                                  children: [
                                                    Text(
                                                      message,
                                                      softWrap: true,
                                                      style: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(0.7),
                                                          fontSize: 30,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          decoration:
                                                              TextDecoration
                                                                  .none),
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

  // 反转摄像头
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

  // 开启视频流传输
  Future<void> _startVideoStreaming() async {
    if (_isStreaming) return;

    bool onRecord = false;

    List<int> imageData;
    LogUtil.init(title: "视频传输", isDebug: true, limitLength: 100);
    Completer<void> completer = Completer<void>();
    try {
      _streamController = StreamController<List<int>>();
      // 开始视频流
      _controller.startImageStream((image) async {
        if(onRecord){
          imageData = await FormatConvert.convertUint8List(image);
          _streamController!.sink.add(imageData);
        }else{
          String size = "#width=${image.width}&height=${image.height}";
          try{
            _channel.sink.add(utf8.encode(size));
          }catch(e){
            LogUtil.d(e);
            return;
          }
          onRecord = true;
        }
      });
      // 启用事件流监听
      _subScription = _streamController!.stream.listen((data) async {
        await _sendImageData(data, onRecord).catchError((error) {
          LogUtil.d(error);
          if(error == "size of image is not posted!"){
            _channel.sink.add(data);
          }
        });
      });
      completer.complete();
    } on CameraException catch (e) {
      LogUtil.d(e);
      completer.completeError(e);
    }
    await completer.future;
  }

  /// 异步发送视频帧数据
  /// [imageData]:视频数据
  /// [onRecord]:是否已发送图像大小信息
  Future<void> _sendImageData(List<int> imageData, bool onRecord) async {
    Completer<void> completer = Completer<void>();
    if(onRecord){
      try {
        _channel.sink.add(imageData);
        completer.complete();
      } catch (e) {
        completer.completeError(e);
      }
      return completer.future;
    }else {
      completer.completeError("size of image is not posted!");
    }
  }

  // 关闭视频传输
  Future<void> _stopVideoStreaming() async {
    await _controller.stopImageStream();
    if (_streamController != null) {
      _streamController!.close();
      _streamController = null;
    }
    if (_subScription != null) {
      _subScription?.cancel();
      _subScription = null;
    }
  }

  // 接收服务端回传消息
  void _listenMessage() {
    _messageSubscription = _channel.stream.listen((message) {
      if (message is String) {
        _messageController.sink.add(message);
      }
    }, onDone: () {
      if (_connected) {
        Fluttertoast.showToast(
          msg: "断开连接，即将返回主页",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pop(context);
      }
    }, onError: (error) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: const Text("网络错误"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .popUntil((ModalRoute.withName("/")));
                    },
                    child: const Text('确定'),
                  ),
                ],
              ));
    });
  }
}
