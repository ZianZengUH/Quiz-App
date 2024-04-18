import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral_central/flutter_ble_peripheral_central.dart';

// class PermissionsService {
//   Future<bool> requestBluetoothPermissions() async {
//     final status = await Permission.bluetooth.request();
//     return status.isGranted;
//   }

//   Future<bool> requestLocationPermissions() async {
//     final status = await Permission.locationWhenInUse.request();
//     return status.isGranted;
//   }
// }

class BLEManager with ChangeNotifier {
  final FlutterBlePeripheralCentral _blePlugin = FlutterBlePeripheralCentral();
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  String? connectedDeviceId;
  String? question;

  // BLEManager() {
  //   checkBLEStatusAndStartScan();
  // }

  // void checkBLEStatusAndStartScan() async {
  //   final isBluetoothPermissionGranted =
  //       await _permissionsService.requestBluetoothPermissions();
  //   final isLocationPermissionGranted =
  //       await _permissionsService.requestLocationPermissions();

  //   if (!isBluetoothPermissionGranted || !isLocationPermissionGranted) {
  //     // Handle the case where permissions are not granted
  //     print('Required permissions not granted');
  //     return;
  //   }

  //   // Continue with BLE operations since permissions are granted
  //   final isOn = await FlutterBluePlus.isOn;
  //   if (isOn) {
  //     startScan();
  //   } else {
  //     // Handle the case where Bluetooth is not turned on
  //     print('Bluetooth is not turned on');
  //   }
  // }
  
  // Future<void> ensureBluetoothIsOn(BuildContext context) async {
  //   final isOn = await FlutterBluePlus.isOn;
  //   if (!isOn) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text("Bluetooth is off"),
  //         content: const Text("Please turn on Bluetooth to connect to devices."),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text("OK"),
  //           ),
  //         ],
  //       ),
  //     );
  //   } else {
  //     startScan();
  //   }
  // }
List<Map<String, dynamic>> scanResults = [];

  void startScan() {
    scanResults.clear();
    _scanSubscription = _blePlugin.scanAndConnect().listen((event) {
      Map<String, dynamic> responseMap = jsonDecode(event);
      if (responseMap.containsKey('scanResult')) {
        scanResults.add(responseMap['scanResult']);
      }
      notifyListeners();
    });
  }
  
  // Future<void> connectToDevice(String deviceId) async {
  //   await _blePlugin.connect(deviceId);
  //   connectedDeviceId = deviceId;
  //   notifyListeners();
  // }
//   FlutterBluePlus.startScan(oneByOne: true);

//   // Optional: Stop scan after a certain time
//   Future.delayed(const Duration(seconds: 10)).then((_) => stopScan());
// }


  void stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Future<bool> get isConnected async {
    return connectedDeviceId != null;
  }

  void connectToDevice() {
    _connectionSubscription = _blePlugin.scanAndConnect().listen((event) {
      Map<String, dynamic> responseMap = jsonDecode(event);
      if (responseMap.containsKey('state')) {
        String state = responseMap['state'];
        if (state == 'connected') {
          connectedDeviceId = responseMap['deviceId'];
        } else if (state == 'disconnected') {
          connectedDeviceId = null;
        }
        notifyListeners();
      }
    });
  }

  Future<void> disconnect() async {
    await _blePlugin.bleDisconnect();
    connectedDeviceId = null;
    notifyListeners();
  }

  Future<void> readCharacteristic() async {
    String? result = await _blePlugin.bleReadCharacteristic();
    question = result;
    notifyListeners();
  }

  Future<void> writeCharacteristic(String data) async {
    await _blePlugin.bleWriteCharacteristic(data);
  }

  // Future<void> connectToDevice(BluetoothDevice device, BuildContext context) async {
  //   try {
  //     await device.connect();
  //     connectedDevice = device;
  //     notifyListeners();

  //     await discoverServices(device);


  //     // Show success dialog
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text("Connection Successful"),
  //         content: const Text("BLE connection has been established."),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text("OK"),
  //           ),
  //         ],
  //       ),
  //     );    
  //   } catch (e) {
  //     print("Failed to connect to the device: $e");
  //           // Show success dialog
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text("Failed to connect to the device"),
  //         content: const Text("BLE connection has been established."),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text("OK"),
  //           ),
  //         ],
  //       ),
  //     );
  //     // Consider showing an error dialog here as well
  //   }
  // }
  // Future<void> discoverServices(BluetoothDevice device) async {
  //   List<BluetoothService> services = await device.discoverServices();
  //   for (var service in services) {
  //     for (var characteristic in service.characteristics) {
  //       if (characteristic.properties.read) {
  //         readableCharacteristic = characteristic;
  //       }
  //       if (characteristic.properties.write) {
  //         writeableCharacteristic = characteristic;
  //       }
  //     }
  //   }
  // }

  // Future<String> readCharacteristic() async {
  //   if (readableCharacteristic != null) {
  //     List<int> value = await readableCharacteristic!.read();
  //     return utf8.decode(value);
  //   }
  //   return '';
  // }

  // Future<void> writeCharacteristic(String data) async {
  //   if (writeableCharacteristic != null) {
  //     await writeableCharacteristic!.write(utf8.encode(data));
  //   }
  // }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }
}