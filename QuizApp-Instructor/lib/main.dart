import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Pages
import 'package:quiz_app_instructor/create_modify_quiz.dart';
import 'package:quiz_app_instructor/display_quiz.dart';
import 'package:quiz_app_instructor/info_page.dart';
import 'package:quiz_app_instructor/load_quiz.dart';

// void main() => runApp(const MyApp());
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
  ServerSocket? server;

  MyAppState() {
    startServer(); // Automatically start the server upon instantiation
  }

  void startServer() async {
    try {
      server = await ServerSocket.bind(InternetAddress.anyIPv4, 3000);
      print('Server running on IP: ${server!.address.address}, Port: ${server!.port}');
      await for (var client in server!) {
        print('Connection from ${client.remoteAddress.address}:${client.remotePort}');
        client.listen(
          (data) {
            final message = utf8.decode(data);
            print('Data from ${client.remoteAddress.address}: $message');
            // Here you might process the received data or store it
          },
          onError: (error) {
            print('Error on data stream: $error');
          },
          onDone: () {
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


