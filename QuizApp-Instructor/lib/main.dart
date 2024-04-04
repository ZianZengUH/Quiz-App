import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_instructor/create_modify_quiz.dart';
import 'package:quiz_app_instructor/display_quiz.dart';
import 'package:quiz_app_instructor/info_page.dart';
import 'package:quiz_app_instructor/load_quiz.dart';
import 'package:quiz_app_instructor/quiz_data.dart';
import 'package:quiz_app_instructor/utils/extra.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MyAppState()
        ),
        ChangeNotifierProvider(
          create: (context) => QuizData()
        ),
      ],
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
  List<BluetoothDevice> _connectedDevices = [];

  List<BluetoothDevice> get connectedDevices => _connectedDevices;

  void connectToDevice(BluetoothDevice device) {
    // Connect to the selected device
    device.connectAndUpdateStream().then((_) {
      _connectedDevices.add(device);
      notifyListeners();
    });
  }

  void disconnectFromDevice(BluetoothDevice device) {
    // Disconnect from the selected device
    device.disconnectAndUpdateStream().then((_) {
      _connectedDevices.remove(device);
      notifyListeners();
    });
  }

  void sendData(String data) {
    // Send data to all connected devices
    for (var device in _connectedDevices) {
      device.discoverServices().then((services) {
        for (var service in services) {
          service.characteristics.forEach((characteristic) {
            if (characteristic.properties.write) {
              characteristic.write(data.codeUnits).then((_) {
                print('Data sent to device: ${device.id}');
              }).catchError((error) {
                print('Failed to send data to device ${device.id}: $error');
              });
            }
          });
        }
      }).catchError((error) {
        print('Failed to discover services for device ${device.id}: $error');
      });
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    _checkQuizDirExists();

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const InfoPage();
        break;
      case 1:
        page = const CreateQuizPage();
        break;
      case 2:
        page = const LoadQuizPage();
        break;
      case 3:
        page = const ShowQuiz();
        break;
      case 4:
        page = const Placeholder();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

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
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                     selectedIndex = value; 
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                )
              )
            ],
          ),
        );
      }
    );
  }

  // Checks if the "Saved Quizzes" directory exists.
  // If not, create it.
  _checkQuizDirExists() async {
    if (!await Directory('Saved Quizzes').exists()) {
      Directory('Saved Quizzes').create();
    }
  }
}