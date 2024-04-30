// websocket_manager.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  factory WebSocketManager() => _instance;

  WebSocketManager._internal();

  WebSocket? _socket;

  bool get isConnected => _socket != null && _socket!.readyState == WebSocket.open;

  Map<String, double>? classroomLocation;

  Future<bool> connect(String uri) async {
    try {
      _socket = await WebSocket.connect(uri).timeout(const Duration(seconds: 180));
      _socket!.listen(
        (data) {
          // Handle incoming data
          var message = jsonDecode(data);
          if (message['type'] == 'location') {
            var classroomLocation = message['data'];
            _storeClassroomLocation(classroomLocation); // Store it in shared preferences
          } else {
              // Handle other messages
            }
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

  
  Future<void> _storeClassroomLocation(Map<String, double> location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('classroomLatitude', location['latitude']!);
    await prefs.setDouble('classroomLongitude', location['longitude']!);
  }

  Future<Map<String, double>> getClassroomLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'latitude': prefs.getDouble('classroomLatitude')!,
      'longitude': prefs.getDouble('classroomLongitude')!,
    };
  }

}
