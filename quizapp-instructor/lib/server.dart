import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Server extends ChangeNotifier {
  HttpServer? _server;
  List<WebSocket> clients = [];

  Server() {
    startServer();
  }

  void startServer() async {
    //print(
    //    'WebSocket server is running on ws://${_server!.address.address}:${_server!.port}');
    //print("@@@@@@@@");
    //print(
    //    'Server running on IP: ${_server!.address.address}, Port: ${_server!.port}');
    //print("@@@@@@@@@\n");

    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 &&
            interface.name == 'Wi-Fi') {
          //print("______________");
          //print('Using interface: ${interface.name}, with IP: ${addr.address}');
          //print("______________\n");
          _server = await HttpServer.bind(addr.address, 3000);
        } else if (addr.type == InternetAddressType.IPv4 &&
            interface.name == 'en0') {
          //print("______________");
          //print('Using interface: ${interface.name}, with IP: ${addr.address}');
          //print("______________\n");
          _server = await HttpServer.bind(addr.address, 3000);
        }
      }
    }

    await for (HttpRequest request in _server!) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        // Handle WebSocket connection.
        WebSocket socket = await WebSocketTransformer.upgrade(request);
        handleWebSocket(socket);
      } else {
        request.response
          ..statusCode = HttpStatus.forbidden
          ..write('This server only supports WebSocket connections.')
          ..close();
      }
    }
    dispose();
  }

  void handleWebSocket(WebSocket socket) {
    print('Client connected!');
    clients.add(socket);
    socket.listen((data) async {
      onMessageReceived(data, socket);
    }, onDone: () {
      onClientDisconnected(socket);
    }, onError: (error) {
      print('WebSocket error: $error');
      socket.close();
    });
  }

  void onMessageReceived(dynamic data, WebSocket client) {
    print('Message received: $data');
    try {
      final userData = jsonDecode(data);
      if (userData is Map<String, dynamic> && userData.containsKey('name')) {
        String name = userData['name'].toString();
        String email = userData['email'].toString();
        String phoneIPAddress = userData['phoneIPAddress'].toString();
        String classSection = userData['classSection'].toString();
        String department = userData['department'] as String;
        String? photo = userData['photo'] as String?;
        String? answer = userData['answer'] as String?;
        print('Received Phone IP Address: $phoneIPAddress');
        manageStudentData(name, email, classSection, phoneIPAddress,
            photo: photo, answer: answer, department: department);
      } else {
        print("Error: Received data is not as expected.");
      }
    } catch (e) {
      print('Error parsing JSON data: $e');
    }
  }

  Future<void> manageStudentData(String studentName, String email,
      String classSection, String phoneIPAddress,
      {String? answer, String? photo, String? department}) async {
    // Writes student data to installation directory.
    // <installation directory>/Student Quizzes
    Directory studentQuizzesDir = Directory('Student Quizzes');
    if (!await studentQuizzesDir.exists()) {
      await studentQuizzesDir.create();
    }

    // <installation directory>/Student Quizzes/Section Numbers
    Directory sectionDir =
        Directory('Student Quizzes/$department $classSection');
    if (!await sectionDir.exists()) {
      //await sectionDir.create(recursive: true);
      await sectionDir.create();
    }

    // <installation directory>/Student Quizzes/Section Numbers/<Student's Names>
    Directory studentDir =
        Directory('Student Quizzes/$department $classSection/$studentName');
    if (!await studentDir.exists()) {
      await studentDir.create();
    }

    // // <installation directory>/Student Quizzes/Section Numbers/<Student's Names>/<today's date>
    // String dateFormat = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    // Directory dateDir = Directory('Student Quizzes/$department $classSection/$studentName/$dateFormat');
    // if (!await dateDir.exists()) {
    //   await dateDir.create();
    // }

    // <installation directory>/Student Quizzes/Section Numbers/<Student's Names>/<Pictures>
  Directory pictureDir = Directory(
      'Student Quizzes/$department $classSection/$studentName/Pictures');
  if (!await pictureDir.exists()) {
    await pictureDir.create(recursive: true);
  }

    // Write timestamped answers on student answer submission.
    if (answer != null) {
      File answerFile = File('${studentDir.path}/Answer.txt');
      await answerFile.writeAsString(answer, mode: FileMode.append);
    }

    // Write photo and student info on connection.
  if (photo != null) {
    // Timestamped student info file.
    String dateFormat = DateFormat('yyyy-MM-dd').format(DateTime.now());
    File infoFile = File('${studentDir.path}/Student_info.csv');
    String studentInfo =
        '$studentName,$dateFormat,$phoneIPAddress,$email@hawaii.edu\n';
    await infoFile.writeAsString(studentInfo, mode: FileMode.append);

    // DateFormat photo
    String photoPath = '${pictureDir.path}/Picture_$dateFormat.png';
    File photoFile = File(photoPath);
    final photoBytes = base64Decode(photo);
    await photoFile.writeAsBytes(photoBytes);
    }
  }

  void onClientDisconnected(WebSocket socket) {
    print('Client disconnected.');
    clients.remove(socket);
    socket.close();
  }

  // NOT NEEDED?
  // To send a message to all connected clients
  void broadcastMessage(String message) {
    for (WebSocket client in clients) {
      client.add(message);
    }
  }

  void stopServer() {
    clients.forEach((client) => client.close());
    _server?.close();
  }

  //@override
  //void dispose() {
  //super.dispose();
  //}
}
