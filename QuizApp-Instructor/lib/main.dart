import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_blue/quick_blue.dart';
import 'package:ble_peripheral/ble_peripheral.dart';

// Pages
import 'package:quiz_app_instructor/connected_devices_page.dart';
import 'package:quiz_app_instructor/create_modify_quiz.dart';
import 'package:quiz_app_instructor/display_quiz.dart';
import 'package:quiz_app_instructor/info_page.dart';
import 'package:quiz_app_instructor/load_quiz.dart';
import 'package:quiz_app_instructor/quiz_data.dart';

// void main() => runApp(const MyApp());
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BlePeripheral.initialize();

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  List<String> connectedDeviceIds = [];  // List to store connected device identifiers

  MyAppState() {
    _setUpPeripheral();
  }
  
  void disconnectFromDevice(String deviceId) {
    // Logic to disconnect from a device
    // BlePeripheral.disconnect(deviceId);  
    connectedDeviceIds.remove(deviceId);  // Remove the device from the list
    notifyListeners();  // Notify UI of the change
  }

  Future<void> _setUpPeripheral() async {
    String serviceUUID = "25AE1441-05D3-4C5B-8281-93D4E07420CF";
    String answerCharacteristicUUID = "25AE1443-05D3-4C5B-8281-93D4E07420CF";

    await BlePeripheral.addService(
      BleService(
        uuid: serviceUUID,
        primary: true,
        characteristics: [
          BleCharacteristic(
            uuid: answerCharacteristicUUID,
            properties: [
              CharacteristicProperties.read.index,
              CharacteristicProperties.notify.index,
              CharacteristicProperties.write.index
            ],
            permissions: [
              AttributePermissions.readable.index,
              AttributePermissions.writeable.index
            ],
          ),
        ],
      )  
    );

    // Handle write requests and return a WriteRequestResult
    BlePeripheral.setWriteRequestCallback((String deviceId, String characteristicId, int offset, Uint8List? value) {
      try {
        if (value == null) {
          // If value is null, we assume the write operation cannot proceed
          return WriteRequestResult(
            value: null,
            offset: null,
            status: 1  // Error code indicating null value received
          );
        }

        if (characteristicId == answerCharacteristicUUID) {
          String receivedAnswer = utf8.decode(value);
          print("Received answer from $deviceId: $receivedAnswer");
          
          // Process the answer here
          // processStudentAnswer(deviceId, receivedAnswer);

          // Update any state or notify listeners about the new data
          notifyListeners();

          return WriteRequestResult(
            value: value,
            offset: offset,
            status: 0  // 0  for successful operation
          );
        }

        return WriteRequestResult(
          value: null,
          offset: null,
          status: 2  // Error code for unmatched characteristic ID
        );
      }catch (e) {
        print('Exception handling write request: $e');
      }
    });

    await BlePeripheral.startAdvertising(
      services: [serviceUUID],
      localName: "QuizApp-Instructor",
    );
  }

  // Add processStudentAnswer implementation here if necessary

  @override
  void dispose() {
    // BlePeripheral.stopAdvertising();
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


