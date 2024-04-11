import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:path_provider/path_provider.dart'; // For file operations
import 'package:provider/provider.dart';
import 'package:quiz_app_instructor/connected_devices_page.dart';
import 'package:quiz_app_instructor/create_modify_quiz.dart';
import 'package:quiz_app_instructor/display_quiz.dart';
import 'package:quiz_app_instructor/info_page.dart';
import 'package:quiz_app_instructor/load_quiz.dart';
import 'package:quiz_app_instructor/quiz_data.dart';
import 'package:window_manager/window_manager.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final List<BluetoothDevice> _connectedDevices = [];
  final Map<String, BluetoothDevice> _deviceMap = {};
  

  MyAppState() {
    checkBluetoothStatus();
    startListeningForConnectionChanges();
  }

  // Simulated Bluetooth status check
  Future<void> checkBluetoothStatus() async {
    // Placeholder for actual Bluetooth status check
    bool isBluetoothEnabled = true; // This should be replaced with actual check
    if (!isBluetoothEnabled) {
      // Show an alert or handle accordingly
      print("Bluetooth is off. Please turn it on.");
    }
  }

  List<BluetoothDevice> get connectedDevices => _connectedDevices;

    void connectToDevice(BluetoothDevice device) {
      device.connect().then((_) {
        _connectedDevices.add(device);
        _deviceMap[device.id.toString()] = device;
        notifyListeners();
        setupDataReception(device);
        
        // Check if the device is connected
        if (device.isConnected) {
          print('Mobile app is connected');
        } else {
          print('Mobile app is not connected');
        }
      }).catchError((error) {
        print('Error connecting to device: $error');
      });
    }

  void handleDeviceConnection(BluetoothDevice device) {
    if (device.isConnected) {
      if (!_connectedDevices.contains(device)) {
        _connectedDevices.add(device);
        _deviceMap[device.id.toString()] = device;
        notifyListeners();
        setupDataReception(device);
        print('Mobile app is connected: ${device.id}');
      }
    } else {
      if (_connectedDevices.contains(device)) {
        _connectedDevices.remove(device);
        _deviceMap.remove(device.id.toString());
        notifyListeners();
        print('Mobile app is disconnected: ${device.id}');
      }
    }
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

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  void startListeningForConnectionChanges() {
    _scanSubscription = FlutterBluePlus.scanResults.listen(
      (List<ScanResult> scanResults) {
        for (var scanResult in scanResults) {
          if (scanResult.advertisementData.connectable) {
            handleDeviceConnection(scanResult.device);
          }
        }
      },
      onError: (error) {
        print('Error listening for device connection changes: $error');
      },
    );
  }

  void stopListeningForConnectionChanges() {
    _scanSubscription?.cancel();
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
            String receivedData = utf8.decode(data);
            print('Received mobile device ID: $receivedData');
            // Store the mobile device ID or perform any desired action
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
    var appState = Provider.of<MyAppState>(context);

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
      case 5:
        page = const ConnectedDevicesPage();        
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
                    NavigationRailDestination(
                      icon: Icon(Icons.bluetooth),
                      label: Text('Connected Devices'),
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