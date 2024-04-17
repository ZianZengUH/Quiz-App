import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:quick_blue/quick_blue.dart';
import 'package:path_provider/path_provider.dart'; // For file operations
import 'package:provider/provider.dart';
import 'package:quiz_app_instructor/connected_devices_page.dart';
import 'package:quiz_app_instructor/create_modify_quiz.dart';
import 'package:quiz_app_instructor/display_quiz.dart';
import 'package:quiz_app_instructor/info_page.dart';
import 'package:quiz_app_instructor/load_quiz.dart';
import 'package:quiz_app_instructor/quiz_data.dart';

void main() => runApp(const MyApp());

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final List<String> _connectedDeviceIds = [];
  final Map<String, Map<String, List<String>>> _servicesAndCharacteristics = {};
  
  List<String> get connectedDeviceIds => _connectedDeviceIds;
  Map<String, Map<String, List<String>>> get servicesAndCharacteristics => _servicesAndCharacteristics;

  MyAppState() {
    QuickBlue.setConnectionHandler((id, state) {
      if (state == BlueConnectionState.connected) {
        if (!_connectedDeviceIds.contains(id)) {
          _connectedDeviceIds.add(id);
          QuickBlue.discoverServices(id); // Begin service discovery
          notifyListeners();
        }
      } else if (state == BlueConnectionState.disconnected) {
        _servicesAndCharacteristics.remove(id); // Cleanup if disconnected
        _connectedDeviceIds.remove(id);
        notifyListeners();
      }
    });

    QuickBlue.setValueHandler(_handleValueChange);
  }

  void _handleValueChange(String deviceId, String characteristicUuid, Uint8List value) {
    String receivedData = utf8.decode(value);
    print("Received data from $deviceId on $characteristicUuid: $receivedData");
    // Process the received data as needed
  }

  void onServiceDiscovered(String deviceId, String serviceId, List<String> characteristicIds) {
    _servicesAndCharacteristics[deviceId] = {serviceId: characteristicIds};
    for (var characteristicId in characteristicIds) {
      QuickBlue.setNotifiable(deviceId, serviceId, characteristicId, true as BleInputProperty);
      // Here to read or write to the characteristic
      QuickBlue.readValue(deviceId, serviceId, characteristicId); 
      // QuickBlue.writeValue(deviceId, serviceId, characteristicId, data); // If we want to write
    }
    notifyListeners();
  }

  void disconnectFromDevice(String deviceId) {
    QuickBlue.disconnect(deviceId);
    _connectedDeviceIds.remove(deviceId);
    notifyListeners();
  }

  @override
  void dispose() {
    for (var deviceId in _connectedDeviceIds) {
      QuickBlue.disconnect(deviceId);
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
      const ConnectedDevicesPage(),
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
                  //color: Theme.of(context).colorScheme.primaryContainer,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/UH_Manoa_ICS_Logo.jpg"),
                      opacity: 0.1,
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


