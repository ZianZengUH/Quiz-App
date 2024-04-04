import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:path_provider/path_provider.dart'; // For file operations
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
  List<BluetoothDevice> _connectedDevices = [];
  Map<String, BluetoothDevice> _deviceMap = {};

  List<BluetoothDevice> get connectedDevices => _connectedDevices;

  void connectToDevice(BluetoothDevice device) {
    device.connect().then((_) {
      _connectedDevices.add(device);
      _deviceMap[device.id.toString()] = device;
      notifyListeners();
      setupDataReception(device); // Set up to receive data
    }).catchError((error) {
      print('Error connecting to device: $error');
    });
  }

  void disconnectFromDevice(BluetoothDevice device) {
    device.disconnect().then((_) {
      _connectedDevices.remove(device);
      _deviceMap.remove(device.id.toString());
      notifyListeners();
    }).catchError((error) {
      print('Error disconnecting from device: $error');
    });
  }

  void sendData(String data, {String? targetDeviceId}) {
    if (targetDeviceId != null) {
      _sendDataToDevice(_deviceMap[targetDeviceId]!, data);
    } else {
      for (var device in _connectedDevices) {
        _sendDataToDevice(device, data);
      }
    }
  }

  void _sendDataToDevice(BluetoothDevice device, String data) {
    device.discoverServices().then((services) {
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            characteristic.write(utf8.encode(data)).then((_) {
              print('Data sent to device: ${device.id}');
            }).catchError((error) {
              print('Failed to send data to device ${device.id}: $error');
            });
          }
        }
      }
    }).catchError((error) {
      print('Failed to discover services for device ${device.id}: $error');
    });
  }

  Future<void> setupDataReception(BluetoothDevice device) async {
    var services = await device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.notify) {
          characteristic.setNotifyValue(true).catchError((error) {
            print('Failed to subscribe to notifications: $error');
          });

          characteristic.value.listen((data) {
            onReceivedData(data);
          });
        }
      }
    }
  }

  void onReceivedData(List<int> dataChunk) async {
    String receivedData = utf8.decode(dataChunk);
    await saveReceivedFile(receivedData);
  }

  Future<void> saveReceivedFile(String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/received_file.txt');

    file.writeAsString(content).then((_) {
      print('File saved successfully');
    }).catchError((error) {
      print('Failed to save the file: $error');
    });
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