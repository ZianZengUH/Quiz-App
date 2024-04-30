// websocket_manager.dart

import 'dart:async';
import 'dart:io';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  factory WebSocketManager() => _instance;

  WebSocketManager._internal();

  WebSocket? _socket;

  bool get isConnected => _socket != null && _socket!.readyState == WebSocket.open;

  Future<bool> connect(String uri) async {
    try {
      _socket = await WebSocket.connect(uri).timeout(const Duration(seconds: 5));
      _socket!.listen(
        (data) {
          // Handle incoming data
        },
        onDone: () {
          _socket = null;
        },
        onError: (error) {
          _socket = null;
        },
      );
      return true;
    } catch (e) {
      _socket = null;
      return false;
    }
  }

  void sendMessage(String message) {
    if (isConnected) {
      _socket!.add(message);
      print("WebSocket message is sent");
    } else {
      print("WebSocket is not connected.");
    }
  }

  void disconnect() {
    _socket?.close();
    _socket = null;
  }
}
