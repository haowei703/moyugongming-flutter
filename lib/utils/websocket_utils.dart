import 'dart:core';

import 'package:web_socket_channel/io.dart';

mixin WebSocketUtil {
  static const String baseUrl = "ws://localhost:8080/ws/video";

  Future<void> connectWebsocket(String path, String token,
      {Function? onOpen,
      Function(dynamic)? onMessage,
      Function(dynamic)? onError,
      Function? onClose,
      dynamic data}) async {
    try {
      final channel =
          IOWebSocketChannel.connect("$baseUrl$path?token=$token");
      if (onOpen != null) {
        onOpen();
      }
      channel.stream.listen((message) {
        if (onMessage != null) {
          onMessage(message);
        }
      }, onError: (error) {
        if (onError != null) {
          onError(error);
        }
      }, onDone: () {
        if (onClose != null) {
          onClose();
        }
      });

      if (data != null) {
        if (data is Stream) {
          channel.sink.addStream(data).then((value) => null);
        } else {
          data(channel.sink.add);
        }
      }
    } catch (e) {
      onError!(e);
      e.toString();
    }
  }
}
