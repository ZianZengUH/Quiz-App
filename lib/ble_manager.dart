import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  Future<bool> requestBluetoothPermissions() async {
    final status = await Permission.bluetooth.request();
    return status.isGranted;
  }

  Future<bool> requestLocationPermissions() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }
}

class BLEManager with ChangeNotifier {
  List<ScanResult> scanResults = [];
  BluetoothDevice? connectedDevice;
  StreamSubscription? scanSubscription;
  final PermissionsService _permissionsService = PermissionsService();
  
  BLEManager() {
    checkBLEStatusAndStartScan();
  }

  void checkBLEStatusAndStartScan() async {
    final isBluetoothPermissionGranted =
        await _permissionsService.requestBluetoothPermissions();
    final isLocationPermissionGranted =
        await _permissionsService.requestLocationPermissions();

    if (!isBluetoothPermissionGranted || !isLocationPermissionGranted) {
      // Handle the case where permissions are not granted
      print('Required permissions not granted');
      return;
    }

    // Continue with BLE operations since permissions are granted
    final isOn = await FlutterBluePlus.isOn;
    if (isOn) {
      startScan();
    } else {
      // Handle the case where Bluetooth is not turned on
      print('Bluetooth is not turned on');
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
