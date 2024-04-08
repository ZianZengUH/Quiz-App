import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';



class BLEManager with ChangeNotifier {
  List<ScanResult> scanResults = [];
  BluetoothDevice? connectedDevice;
  StreamSubscription? scanSubscription;

  BLEManager() {
    checkBLEStatusAndStartScan();
  }

  void checkBLEStatusAndStartScan() async {
    final isOn = await FlutterBluePlus.isOn;
    if (isOn) {
      startScan();
    }
  }

  Future<void> ensureBluetoothIsOn(BuildContext context) async {
    final isOn = await FlutterBluePlus.isOn;
    if (!isOn) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Bluetooth is off"),
          content: const Text("Please turn on Bluetooth to connect to devices."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      startScan();
    }
  }

void startScan() {
  scanResults.clear();
  // Use the new startScan method with oneByOne parameter
  scanSubscription = FlutterBluePlus.scanResults.listen((List<ScanResult> resultList) {
    for (final result in resultList) {
      // Add scan results one by one, checking if they're already in the list
      if (!scanResults.any((existingResult) => existingResult.device.id == result.device.id)) {
        scanResults.add(result);
        notifyListeners();
      }
    }
  });

  FlutterBluePlus.startScan(oneByOne: true);

  // Optional: Stop scan after a certain time
  Future.delayed(const Duration(seconds: 10)).then((_) => stopScan());
}


  void stopScan() {
    scanSubscription?.cancel();
    scanSubscription = null;
    FlutterBluePlus.stopScan();
    notifyListeners();
  }

  Future<bool> get isConnected async {
    return connectedDevice != null;
  }

  Future<void> connectToDevice(BluetoothDevice device, BuildContext context) async {
    try {
      await device.connect();
      connectedDevice = device;
      notifyListeners();

      // Send the mobile device ID to the desktop app
      await device.discoverServices();
      for (var service in device.servicesList) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            await characteristic.write(utf8.encode(device.id.toString()));
            break;
          }
        }
      }

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Connection Successful"),
          content: const Text("BLE connection has been established."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Failed to connect to the device: $e");
      // Consider showing an error dialog here as well
    }
  }

  @override
  void dispose() {
    scanSubscription?.cancel();
    super.dispose();
  }
}
