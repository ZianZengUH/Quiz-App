import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:window_manager/window_manager.dart';

// Pages
//import 'package:quiz_app_instructor/connected_devices_page.dart';
import 'package:quiz_app_instructor/create_modify_quiz.dart';
import 'package:quiz_app_instructor/display_quiz.dart';
import 'package:quiz_app_instructor/info_page.dart';
import 'package:quiz_app_instructor/load_quiz.dart';
import 'package:quiz_app_instructor/quiz_data.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(900, 600),
    minimumSize: Size(900, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    windowButtonVisibility: false,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyAppState()),
        ChangeNotifierProvider(create: (context) => QuizData()),
      ],
      child: MaterialApp(
        title: 'Quiz App - Instructor Version',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  ServerSocket? server;

  MyAppState() {
    startServer(); // Automatically start the server upon instantiation
  }

  void startServer() async {
    try {
      server = await ServerSocket.bind(InternetAddress.anyIPv4, 3000);
      print("@@@@@@@@");
      print('Server running on IP: ${server!.address.address}, Port: ${server!.port}');
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
 
      await for (var client in server!) {
        print('Connection from ${client.remoteAddress.address}:${client.remotePort}');

        final List<int> buffer = []; // Buffer to accumulate data.
        client.listen(
          (data) async {
            buffer.addAll(data); // Accumulate each chunk of data received.
          },
          onError: (error) {
            print('Error on data stream: $error');
          },
          onDone: () async {
            // Data processing
            // Decode the complete data received.
            final completeData = utf8.decode(buffer);
            try {
              final userData = jsonDecode(completeData);
              String studentName = userData['name'];
              await manageStudentData(studentName);
            } catch (e) {
              print('Error parsing JSON data: $e');
            }
            print('Connection closed by the client');
            client.close();
          },
          cancelOnError: true
        );
      }
    } on SocketException catch (e) {
      print('Failed to create server: $e');
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
  @override
  void dispose() {
    if (server != null) {
      server!.close();
      print('Server closed');
    }
    super.dispose();
  }
}


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
      // Placeholder for Export Quiz Answers - you'll need to implement this widget
      const Placeholder(),
      //const ConnectedDevicesPage(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  //backgroundColor: Colors.green,
                  backgroundColor: const Color.fromARGB(255, 6, 86, 6),
                  unselectedLabelTextStyle: const TextStyle(
                    color: Colors.white70),
                  unselectedIconTheme: const IconThemeData(
                    color: Colors.white70),
                  selectedLabelTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                  selectedIconTheme: const IconThemeData(
                    color: Colors.black),
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
                  //color: Theme.of(context).colorScheme.primaryContainer,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/UH_Manoa_ICS_Logo.jpg"),
                      opacity: 0.075,
                      fit: BoxFit.cover,
                      )
                  ),
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


