import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_example/utils/extra.dart';

import 'new_page.dart';
import 'screens/bluetooth_off_screen.dart';
import 'screens/scan_screen.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const FlutterBlueApp());
}

class FlutterBlueApp extends StatefulWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  int _selectedIndex = 0;
  List<BluetoothDevice> _connectedDevices = [];

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    _disconnectFromAllDevices();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _connectToDevice(BluetoothDevice device) {
    device.connectAndUpdateStream().then((_) {
      setState(() {
        _connectedDevices.add(device);
      });
    }).catchError((error) {
      print('Failed to connect to device: $error');
    });
  }

  void _disconnectFromDevice(BluetoothDevice device) {
    device.disconnectAndUpdateStream().then((_) {
      setState(() {
        _connectedDevices.remove(device);
      });
    }).catchError((error) {
      print('Failed to disconnect from device: $error');
    });
  }

  void _disconnectFromAllDevices() {
    for (var device in _connectedDevices) {
      device.disconnectAndUpdateStream().catchError((error) {
        print('Failed to disconnect from device: $error');
      });
    }
    setState(() {
      _connectedDevices.clear();
    });
  }

void _sendData(String data) {
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

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    switch (_selectedIndex) {
      case 0:
        currentScreen = _adapterState == BluetoothAdapterState.on
            ? ScanScreen(
                onConnect: _connectToDevice,
                onDisconnect: _disconnectFromDevice,
              )
            : BluetoothOffScreen(adapterState: _adapterState);
        break;
      case 1:
        currentScreen = MyHomePage(
          title: '',
          connectedDevices: _connectedDevices,
          onSendData: _sendData,
        );
        break;
      default:
        currentScreen = Container();
    }

    return MaterialApp(
      color: Colors.lightBlue,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz App'),
        ),
        body: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.bluetooth),
                  label: Text('Bluetooth'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.pageview),
                  label: Text('Questions'),
                ),
              ],
            ),
            VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: currentScreen,
            )
          ],
        ),
      ),
    );
  }
}

class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      _adapterStateSubscription ??= FlutterBluePlus.adapterState.listen((state) {
        if (state != BluetoothAdapterState.on) {
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}