import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'new_page.dart'; // Import the new page widget
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
  int _selectedIndex = 0; // Index for navigation rail items

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
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    switch (_selectedIndex) {
      case 0:
        currentScreen = _adapterState == BluetoothAdapterState.on
            ? const ScanScreen()
            : BluetoothOffScreen(adapterState: _adapterState);
        break;
      case 1:
        currentScreen = MyHomePage(title: '',); // New page widget
        break;
      default:
        currentScreen = Container(); // Placeholder, you can handle this case based on your requirements
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
