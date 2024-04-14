import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class AudioEvalPage extends StatefulWidget {
  const AudioEvalPage({super.key});

  @override
  State<AudioEvalPage> createState() => _AudioEvalPageState();
}

class _AudioEvalPageState extends State<AudioEvalPage> {
  FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  bool _isRecording = false;
  final StreamController<Food> _controller = StreamController<Food>();
  late StreamSink<Food> _sink;


  @override
  void initState(){
    super.initState();
    _sink = _controller.sink;
    _initializeRecorder();
  }
  Future<void> _initializeRecorder() async {
    await _audioRecorder.openRecorder();
  }
  // 开启录制
  Future<void> _startRecording() async {
    try {
      await _audioRecorder.startRecorder(
        codec: Codec.pcm16WAV,
        sampleRate: 44100,
        bitRate: 16000,
        toStream: _sink,
      );

      setState(() {
        _isRecording = true;
      });

    } catch (err) {
      print('Error starting recording: $err');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stopRecorder();

      setState(() {
        _isRecording = false;
      });
    } catch (err) {
      print('Error stopping recording: $err');
    }
  }

  @override
  void dispose() {
    _audioRecorder.closeRecorder();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: (){
            _startRecording();
          },
          child: const Text("开始录音"),)
      ),
    );
  }
}
