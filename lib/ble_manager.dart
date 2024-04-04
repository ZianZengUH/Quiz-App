import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:async';
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
  Future.delayed(Duration(seconds: 10)).then((_) => stopScan());
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

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      connectedDevice = device;
      notifyListeners();
    } catch (e) {
      print("Failed to connect to the device: $e");
      // Handle connection error
    }
  }

  @override
  void dispose() {
    scanSubscription?.cancel();
    super.dispose();
  }
}
