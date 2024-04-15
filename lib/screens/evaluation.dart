import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:moyugongming/enum/EvalMode.dart';
import 'package:moyugongming/utils/http_client_utils.dart';
import 'package:moyugongming/utils/log_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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
  String? _jingque;
  String? _liuli;

  @override
  void initState() {
    super.initState();
    _evalMode = widget.evalMode;
    _textList = _evalMode == EvalMode.word
        ? ["我", "爱", "你", "妈", "好"]
        : ["您好", "欢迎光临", "对不起"];
    _text = _textList.first;
    _readToken();
    createTempFile();
    _initializeRecorder();
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
    final filePath = path.join(tempDir.path, 'temp.pcm');
    _filePath = filePath;
  }

  Future<void> _initializeRecorder() async {
    await _audioRecorder.openRecorder();
  }

  // 开启录制
  Future<void> _startRecording() async {
    try {
      if (await getPermissionStatus()) {
        await _audioRecorder.startRecorder(
            codec: Codec.pcm16,
            sampleRate: 44100,
            bitRate: 16000,
            toFile: _filePath);
      } else {
        _showDialog(
            content: const Text("请在设置中打开麦克风权限!"),
            onClicked: () {
              Navigator.pop(context);
            });
      }
    } catch (err) {
      if (kDebugMode) {
        print('Error starting recording: $err');
      }
    }
  }

  // 关闭录制
  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stopRecorder();
    } catch (err) {
      if (kDebugMode) {
        print('Error stopping recording: $err');
      }
    }
  }

  _showDialog(
      {String? title, required Widget content, VoidCallback? onClicked}) {
    showDialog(
        context: context,
        builder: (context) => CustomDialog(
              title: title,
              onClicked: onClicked,
              content: content,
            ));
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(249, 249, 249, 1)),
              child: Center(
                child: Text(
                  _text,
                  style: const TextStyle(
                      fontSize: 40.0, fontWeight: FontWeight.w300),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: IconButton(
                onPressed: () async {
                  bool isRecording = _audioRecorder.isRecording;
                  if (!isRecording) {
                    _startRecording();
                  } else {
                    await _stopRecording();
                    _sendMessage();
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withOpacity(0.7)),
                  child: const Icon(Icons.mic),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("发音精确度"),
                  _jingque != null ? Text(_jingque!) : const Text("")
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("发音流利度"),
                  _liuli != null ? Text(_liuli!) : const Text("")
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
                child: Container(
              color: Colors.grey.withOpacity(0.5),
              child: ListView.builder(
                  itemCount: _textList.length,
                  itemBuilder: (context, int index) {
                    return Center(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _text = _textList[index];
                              });
                            },
                            child: Text(
                              _textList[index],
                              style: const TextStyle(fontSize: 30.0),
                            ),
                          )),
                    );
                  }),
            ))
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    // String? url = await _audioRecorder.getRecordURL(path: _filePath);
    String url = _filePath;
    String port = "8081";
    String path = "api/audio";
    File tempFile = File(url);
    List<int> fileBytes = await tempFile.readAsBytes();
    String base64Str = base64Encode(fileBytes);
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String body = jsonEncode(
        {"audioData": base64Str, "evalMode": _evalMode.value, "text": "我"});
    await _audioRecorder.deleteRecord(fileName: "temp.pcm");

    LogUtil.init(title: "测评结果", isDebug: true, limitLength: 50);
    await HttpClientUtils.sendRequestAsync(port, path,
        method: HttpMethod.POST,
        token: _token,
        headers: headers,
        body: body, onSuccess: (response) {
      LogUtil.d(response.toString());
      if(response['data'] != null){
        setState(() {
          _jingque = response['data']['Response']["PronAccuracy"];
          _liuli = response['data']['Response']["PronFluency"];
        });
      }
    }, onError: (error) {
      LogUtil.d(error);
    });
  }

  // sharded_preferences读取用户信息和设置信息
  Future<void> _readToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    LogUtil.init(title: "读取token", isDebug: true, limitLength: 40);
    if (token != null) {
      _token = token;
      LogUtil.d(token);
    }
  }
}
