import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moyugongming/utils/convert_format.dart';
import 'package:moyugongming/utils/log_util.dart';
import 'package:moyugongming/utils/websocket_utils.dart';
import 'package:moyugongming/widgets/ring.dart';

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

  late Future<void> _initializeControllerFuture;
  // 当前摄像头方向
  late CameraLensDirection _lensDirection;

  // websocket管理实例
  late WebSocketManager manager;

  // 是否正在流式传输
  bool _isStreaming = false;

  // 保存手语识别结果
  late StreamController<String> _messageController;
  String _message = "";
  bool _hasData = true;

  @override
  void initState() {
    super.initState();
    _controller =
        CameraController(widget.cameraList.first, ResolutionPreset.low);
    _lensDirection = widget.cameraList.first.lensDirection;
    _initializeControllerFuture = _controller.initialize();
    _messageController = StreamController<String>.broadcast();
    Map<String, String> paramMap = {"token": widget.token};
    manager = WebSocketManager(path: "ws/video", paramMap: paramMap);
    manager.connectWebsocket().then((_) {
      _listenMessage();
    }).catchError((error) {
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageController.close();
    manager.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    return FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: SizedBox(
                        width: screenWidth,
                        height: screenWidth * _controller.value.aspectRatio,
                        child: CameraPreview(_controller),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back))
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
                                          onPressed: () {
                                            if (!_isStreaming) {
                                              _startVideoStreaming();
                                              setState(() {
                                                _isStreaming = true;
                                              });
                                            } else {
                                              _stopVideoStreaming();
                                              setState(() {
                                                _isStreaming = false;
                                              });
                                            }
                                          },
                                          color: Colors.transparent,
                                          icon: _isStreaming
                                              ? const Icon(
                                                  Icons.videocam,
                                                  color: Colors.red,
                                                )
                                              : Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
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
                          constraints: const BoxConstraints(maxHeight: 200),
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
                                              _message = "";
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
                                                if (snapshot.hasError) {
                                                  return const Text("错误");
                                                }
                                                if (_hasData &&
                                                    snapshot.hasData) {
                                                  _message += snapshot.data!;
                                                  _hasData = !_hasData;
                                                }
                                                return Column(
                                                  children: [
                                                    Text(
                                                      _message,
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

    List<int> imageData;
    LogUtil.init(title: "视频传输", isDebug: true, limitLength: 100);
    try {
      await _controller.startImageStream((image) {
        imageData = FormatConvert.convertUint8List(image);
        _sendImageData(imageData);
      });
    } on CameraException catch (e) {
      LogUtil.d(e);
    }
  }

  /// 异步发送视频帧数据
  Future<void> _sendImageData(List<int> imageData) async {
    Completer<void> completer = Completer<void>();
    try {
      WebSocketMessage<List<int>> webSocketMessage =
          WebSocketMessage(message: imageData);
      await manager.sendMessageAsync(webSocketMessage);
      completer.complete();
    } catch (e) {
      completer.completeError(e);
    }
    return completer.future;
  }

  // 关闭视频传输
  Future<void> _stopVideoStreaming() async {
    _controller.stopImageStream();
  }

  // 接收服务端回传消息
  void _listenMessage() async {
    await manager.listenMessage((message) {
      if (message != "pong") {
        _messageController.sink.add(message);
        _hasData = true;
        LogUtil.init(title: "监听到服务端消息", isDebug: true, limitLength: 20);
        LogUtil.d("$message");
      }
    }, onError: (error) {
      Fluttertoast.showToast(
        msg: "与服务器断开连接，即将返回主页",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.pop(context);
    });
  }
}
