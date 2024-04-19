import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 

// Pages
import 'package:quiz_app_instructor/create_modify_quiz.dart';
import 'package:quiz_app_instructor/display_quiz.dart';
import 'package:quiz_app_instructor/info_page.dart';
import 'package:quiz_app_instructor/load_quiz.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Quiz App - Instructor Version',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  HttpServer? _server;
  List<WebSocket> clients = [];

  MyAppState() {
    startServer();
  }

  void startServer() async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 3000);
    print('WebSocket server is running on ws://${_server!.address.address}:${_server!.port}');
    print("@@@@@@@@");
    print('Server running on IP: ${_server!.address.address}, Port: ${_server!.port}');
    print("@@@@@@@@@\n");

     for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            print("______________");
            print('Using interface: ${interface.name}, with IP: ${addr.address}');
            print("______________\n");
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
  }

  void handleWebSocket(WebSocket socket) {
    print('Client connected!');
    clients.add(socket);
    socket.listen(
      (data) async {
        onMessageReceived(data, socket);
      },
      onDone: () {
        onClientDisconnected(socket);
      },
      onError: (error) {
        print('WebSocket error: $error');
        socket.close();
      }
    );
  }

  void onMessageReceived(dynamic data, WebSocket client) {
      print('Message received: $data');
      try {
        final userData = jsonDecode(data);
        if (userData is Map<String, dynamic> && userData.containsKey('name')) {
          manageStudentData(userData['name'].toString());
        } else {
          print("Error: Received data is not as expected.");
        }
      } catch (e) {
        print('Error parsing JSON data: $e');
      }
  }

  Future<void> manageStudentData(String studentName) async {
    Directory studentDir = Directory('students/$studentName');
    File infoFile = File('${studentDir.path}/student info.txt');

    if (!await studentDir.exists()) {
      await studentDir.create(recursive: true);
    }

    if (!await infoFile.exists()) {
      await infoFile.create();
    }

    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await infoFile.writeAsString('$currentDate\n', mode: FileMode.append);
  }

  void onClientDisconnected(WebSocket socket) {
    print('Client disconnected.');
    clients.remove(socket);
    socket.close();
  }

  // To send a message to all connected clients,
  void broadcastMessage(String message) {
    for (WebSocket client in clients) {
      client.add(message);
    }
  }

  @override
  void dispose() {
    clients.forEach((client) => client.close());
    _server?.close();
    super.dispose();
  }
}


// ---------------------MyHomePage--------------------
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    _checkQuizDirExists();
    var appState = Provider.of<MyAppState>(context);

    List<Widget> pages = [
      const InfoPage(),
      const CreateQuizPage(),
      const LoadQuizPage(),
      const ShowQuiz(),
      // const ConnectedDevicesPage(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.question_mark),
                      label: Text('How To Use This Program'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.new_label),
                      label: Text('Create/Modify Quiz'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.file_open),
                      label: Text('Load Quiz'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.screen_share),
                      label: Text('Display Quiz'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.save_as),
                      label: Text('Export Quiz Answers'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bluetooth),
                      label: Text('Connected Devices'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: pages[selectedIndex],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // Checks if the "Saved Quizzes" directory exists. If not, create it.
  void _checkQuizDirExists() async {
    final quizDir = Directory('Saved Quizzes');
    if (!await quizDir.exists()) {
      await quizDir.create();
    }
  }
}


