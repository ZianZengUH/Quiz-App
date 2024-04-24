import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
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
        if (addr.type == InternetAddressType.IPv4 && interface.name == 'Wi-Fi') {
          //print("______________");
          //print('Using interface: ${interface.name}, with IP: ${addr.address}');
          //print("______________\n");
          _server = await HttpServer.bind(addr.address, 3000);
        } else if (addr.type == InternetAddressType.IPv4 && interface.name == 'en0') {
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
        String classSection = userData['classSection'].toString();
        String? photo = userData['photo'] as String?;
        String? answer = userData['answer'] as String?;
        manageStudentData(name, email, classSection, photo: photo, answer: answer);

      //} else if (userData.containsKey('type') && userData['type'] == 'answer') {
        //String? answerText = userData['content'].toString();
        //manageStudentData('', '', '', answer: answerText);
      } else {
        print("Error: Received data is not as expected.");
      }
    } catch (e) {
      print('Error parsing JSON data: $e');
    }
  }

  Future<void> manageStudentData(String studentName, String email, String classSection, {String? answer, String? photo}) async {
    //String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    //if (selectedDirectory == null) {
    // User canceled the directory selection
    //  return;
    //}

    // Writes student data to installation directory.
    // <installation directory>/Student Quizzes
    Directory studentQuizzesDir = Directory('Student Quizzes');
    if (!await studentQuizzesDir.exists()) {
      await studentQuizzesDir.create();
    }

    // <installation directory>/Student Quizzes/<today's date>
    String dateFormat = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    Directory dateDir = Directory('Student Quizzes/$dateFormat');
    if (!await dateDir.exists()) {
      await dateDir.create();
    }

    // <installation directory>/Student Quizzes/<today's date>/Section Numbers
    Directory sectionDir = Directory('Student Quizzes/$dateFormat/$classSection');
    if (!await sectionDir.exists()) {
      //await sectionDir.create(recursive: true);
      await sectionDir.create();
    }

    // <installation directory>/Student Quizzes/<today's date>/Section Numbers/<Student's Names>
    Directory studentDir = Directory('Student Quizzes/$dateFormat/$classSection/$studentName');
    print(studentDir.path);
    File infoFile = File('${studentDir.path}/student info.txt');
    print(infoFile.path);
    File answerFile = File('${studentDir.path}/answer.txt');
    print(answerFile.path);

    if (!await studentDir.exists()) {
      await studentDir.create();
    }

    if (!await infoFile.exists()) {
      await infoFile.create();
      // Write student's info file.
      String currentDate =
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      String studentInfo = 
        'Date/Time: $currentDate\nName: $studentName\nEmail: $email\nClass Section: $classSection\n\n';
      await infoFile.writeAsString(studentInfo, mode: FileMode.append);
    }

    // Write student's answer.
    //if (!await answerFile.exists()) {
      //await answerFile.create();
    //}
    print(answer);
    if (answer != null) {
        print('answer is good');
        await answerFile.writeAsString(answer, mode: FileMode.append);
        print('done');
    }

    // Write student's photo.
    if (photo != null) {
      File photoFile = File('${studentDir.path}/profile picture.png');
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

  @override
  void dispose() {
    super.dispose();
  }
}