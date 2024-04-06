import 'dart:async';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Callbacks {
  Function? onOpen;
  Function? onMessage;
  Function? onClose;
  Function? onError;
}

/// 消息模板
class WebSocketMessage<T> {
  late T _value;

  WebSocketMessage({required T message}) {
    this._value = message;
    init();
  }

  void init() {}

  T getMessage() => _value;
}

/// websocket连接管理类
/// - [path]: 连接路径
///
/// 该类拥有建立连接、接收服务端消息、客户端发送消息、心跳检测、心跳重连等机制
class WebSocketManager {
  // 服务器生产环境url
  final String baseOnlineUrl = 'ws://123.56.184.10:8080/';
  // 本地开发环境url
  final String baseLocalUrl = 'ws://10.107.30.6:8080/';
  final String path;
  final Map<String, String> paramMap;
  late WebSocketChannel _channel;
  StreamSubscription? _messageSubscription;
  bool isConnected = false;
  late Timer _heartbeatTimer;

  WebSocketManager({required this.path, required this.paramMap});


  /// 发起websocket连接并处理异常
  ///
  /// 该方法异步建立WebSocket连接，并在成功后返回WebSocketChannel对象，自动管理WebSocket连接，拥有心跳检测和重连机制
  ///
  ///{Function? onOpen, Function? onMessage, Function? onClose, Function? onError}
  /// 参数：
  ///   - [path]: 请求路径
  ///   - [onOpen]: 连接成功
  ///   - [onMessage]: 消息回调
  ///   - [onClose]: 连接关闭回调
  ///   - [onError]: 异常处理的回调函数
  ///
  /// 返回值：一个 Future，表示发送请求的结果
  Future<void> connectWebsocket() async {
    Completer<void> completer = Completer();
    try {
      String url = kReleaseMode
          ? '$baseOnlineUrl$path?${Uri(queryParameters: paramMap).query}'
          : '$baseLocalUrl$path?${Uri(queryParameters: paramMap).query}';
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel.ready.then((_) {
        isConnected = true;
        startPing();
        completer.complete();
      });
    } catch (e) {
      completer.completeError(e);
      throw Exception(e);
    }
    return completer.future;
  }

  /// 断开连接
  void disconnect() {
    _channel.sink.close();
    isConnected = false;
    _messageSubscription?.cancel();
    stopPing();
  }

  /// 阻塞调用发送消息方法
  void sendMessage(WebSocketMessage message) {
    try {
      _channel.sink.add(message.getMessage());
    } catch (e) {
      throw Exception("消息发送失败");
    }
  }

  /// 异步调用发送消息方法
  Future<void> sendMessageAsync(WebSocketMessage message) async {
    Completer<void> completer = Completer();
    try {
      _channel.sink.add(message.getMessage());
      completer.complete();
    } catch (e) {
      completer.completeError(Exception("send message failed:$e"));
    }
    return completer.future;
  }

  /// 开启心跳
  void startPing() {
    const pingInterval = Duration(seconds: 30);
    _heartbeatTimer = Timer.periodic(pingInterval, (timer) {
      if(isConnected) {
        _channel.sink.add("ping");
      }
    });
  }

  /// 关闭心跳
  void stopPing() {
    _heartbeatTimer.cancel();
  }

  /// 开启监听
  Future<void> listenMessage(Function onMessage, {Function? onError, Function? onClose}) async{
    if (_messageSubscription != null) {
      throw Exception("已设置监听");
    }

    if (!isConnected) {
      throw Exception("websocket未连接");
    }

    _messageSubscription = _channel.stream.listen((message) {
      WebSocketMessage webSocketMessage = WebSocketMessage(message: message);
      onMessage(webSocketMessage.getMessage());
    }, cancelOnError: false);

    if(onError != null){
      _channel.stream.handleError((error) {
        onError(error);
        throw Exception("发生错误$error");
      });
    }

    if(onClose != null){
      _channel.sink.done.then((_) {
        isConnected = false;
        _messageSubscription?.cancel();
        _messageSubscription = null;
        onClose();
      });
    }
  }
}
