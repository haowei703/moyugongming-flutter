import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moyugongming/model/enums/evalmode.dart';
import 'package:moyugongming/model/vo/eval_result.dart';
import 'package:moyugongming/utils/http_client_utils.dart';
import 'package:moyugongming/utils/log_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../animation/slide_route.dart';
import '../model/objects/mic_data.dart';
import '../widgets/custom_dialog.dart';

class AudioEvalPage extends StatefulWidget {
  final EvalMode evalMode;
  const AudioEvalPage({super.key, required this.evalMode});

  @override
  State<AudioEvalPage> createState() => _AudioEvalPageState();
}

class _AudioEvalPageState extends State<AudioEvalPage> {
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  late String _text;
  late List<String> _textList;
  late EvalMode _evalMode;
  late String _token;
  late String _filePath;
  late EvalResult _evalResult;

  late List<MicData> _micData;
  // 是否正在录音
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    // 变量初始化
    _evalMode = widget.evalMode;
    _textList = _evalMode == EvalMode.word
        ? ["我", "爱", "你", "妈", "好"]
        : ["您好", "欢迎光临", "对不起", "没关系"];
    _micData = _textList.map((text) => MicData(content: text)).toList();
    _text = _textList.first;
    _evalResult = const EvalResult(
        suggestedScore: 0, pronAccuracy: 0, pronFluency: 0, words: []);

    // 准备录音
    _readToken();
    createTempFile();
    _initializeRecorder();
    getPermissionStatus().then((value) {
      if (!value) {
        Fluttertoast.showToast(
          msg: "请在设置中打开录音权限！",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Future.delayed(
            const Duration(seconds: 2), () => Navigator.pop(context));
      }
    });
  }

  Future<bool> getPermissionStatus() async {
    Permission permission = Permission.microphone;
    //granted 通过，denied 被拒绝，permanentlyDenied 拒绝且不在提示
    PermissionStatus status = await permission.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      requestPermission(permission);
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else if (status.isRestricted) {
      requestPermission(permission);
    } else {}
    return false;
  }

  ///申请权限
  void requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> createTempFile() async {
    final tempDir = await getTemporaryDirectory();
    final filePath = path.join(tempDir.path, 'temp.wav');
    _filePath = filePath;
  }

  Future<void> _initializeRecorder() async {
    await _audioRecorder.openRecorder();
  }

  // 开启录制
  Future<void> _startRecording() async {
    setState(() {
      isRecording = true;
    });
    await _audioRecorder
        .startRecorder(
            codec: Codec.pcm16WAV,
            sampleRate: 44100,
            bitRate: 16000,
            toFile: _filePath)
        .catchError((e) {
      Fluttertoast.showToast(
        msg: "请求超时",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }

  // 关闭录制
  Future<void> _stopRecording() async {
    setState(() {
      isRecording = false;
    });
    String? url = await _audioRecorder.stopRecorder();
    if (kDebugMode) {
      print("URL:$url");
    }
    _sendMessage();
  }

  @override
  void dispose() {
    _audioRecorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Center(
        child: Stack(children: [
          Column(
            children: [resultView(), listView()],
          ),
          iconBtnPanel()
        ]),
      ),
    );
  }

  Widget resultView() {
    return SizedBox(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "测评结果",
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: Stack(
                    children: [
                      const Positioned(
                          left: 0, top: 0, bottom: 0, child: Text("评测分数")),
                      Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Text(_evalResult.suggestedScore.toString()))
                    ],
                  ))),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: Stack(
                    children: [
                      const Positioned(
                          left: 0, top: 0, bottom: 0, child: Text("精准度")),
                      Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Text(_evalResult.pronAccuracy.toString()))
                    ],
                  ))),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: Stack(
                    children: [
                      const Positioned(
                          left: 0, top: 0, bottom: 0, child: Text("流畅度")),
                      Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Text(_evalResult.pronFluency.toString()))
                    ],
                  ))),
        ],
      ),
    );
  }

  Widget listView() {
    return Expanded(
        child: Container(
            padding: EdgeInsets.zero,
            color: const Color.fromRGBO(249, 249, 249, 1),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _textList.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    height: 50,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _text = _textList[index];
                                    });
                                  },
                                  child: Center(
                                    child: Text(_textList[index]),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const Positioned(
                            bottom: 0,
                            left: 20,
                            right: 20,
                            child: Divider(
                              thickness: 0.8,
                              color: Colors.black,
                              height: 0,
                            )),
                        Positioned(
                            top: 0,
                            bottom: 0,
                            right: 30,
                            child: Align(
                              alignment: Alignment.center,
                              child: Icon(!_micData[index].isPassed
                                  ? Icons.check_box_outline_blank_rounded
                                  : Icons.check_box),
                            ))
                      ],
                    ));
              },
            )));
  }

  Widget iconBtnPanel() {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      child: IconButton(
                          onPressed: () {
                            if (!isRecording) {
                              _startRecording();
                            } else {
                              _stopRecording();
                            }
                          },
                          icon: !isRecording
                              ? const Icon(CupertinoIcons.mic_solid, size: 30)
                              : const Icon(CupertinoIcons.mic_circle_fill,
                                  size: 45)))
                ])));
  }

  Future<void> _sendMessage() async {
    String url = _filePath;
    String port = "8081";
    String path = "api/audio";
    File tempFile = File(url);
    List<int> fileBytes = await tempFile.readAsBytes();
    String base64Str = base64Encode(fileBytes);
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String body = jsonEncode(
        {"audioData": base64Str, "evalMode": _evalMode.value, "text": "我"});
    await _audioRecorder.deleteRecord(fileName: "temp.wav");

    LogUtil.init(title: "测评结果", isDebug: true, limitLength: 50);
    await HttpClientUtils.sendRequestAsync(port, path,
        method: HttpMethod.POST,
        token: _token,
        headers: headers,
        body: body, onSuccess: (response) {
      Map<String, dynamic>? data = response['data'];
      LogUtil.d(data);
      if (data != null) {
        setState(() {
          _evalResult = EvalResult.fromJson(data);
          LogUtil.d(_evalResult.suggestedScore);
        });
        if (_evalResult.suggestedScore >= 60) {
          _showMessage(msg: "测评通过");
        } else {
          _showMessage(msg: "测评未通过");
        }
      }
    }, onError: (error) {
      LogUtil.d(error);
    });
  }

  // 读取token信息
  Future<void> _readToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    LogUtil.init(title: "读取token", isDebug: true, limitLength: 40);
    if (token != null) {
      _token = token;
      LogUtil.d(token);
    }
  }

  void _showMessage({required String msg}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
