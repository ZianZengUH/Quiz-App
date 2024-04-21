// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:quick_blue/quick_blue.dart';
// import 'package:permission_handler/permission_handler.dart';

//  // !!! Super Important for Andorid Bluetooth to work !!!
// class PermissionsService {
//   Future<bool> requestBluetoothPermissions() async {
//     final status = await Permission.bluetooth.request();
//     return status.isGranted;
//   }

//   Future<bool> requestLocationPermissions() async {
//     final status = await Permission.locationWhenInUse.request();
//     return status.isGranted;
//   }
//   Future<bool> requestBluetoothScanPermissions() async {
//     final status = await Permission.bluetoothScan.request();
//     return status.isGranted;
//   }
//   Future<bool> requestBluetoothConnectPermissions() async {
//     final status = await Permission.bluetoothConnect.request();
//     return status.isGranted;
//   }
// }
// class BLEDevice {
//   String id;
//   String name;

//   BLEDevice({required this.id, required this.name});
// }

// class BLEManager with ChangeNotifier {
//   List<BLEDevice> devices = []; // List to store BLE devices

//   List<String> deviceIds = [];
//   String? connectedDeviceId;
//   Map<String, Map<String, List<String>>> discoveredServices = {}; // deviceId -> (serviceId -> characteristicIds)

//   // !!! Super Important for Andorid Bluetooth to work !!!
//   final PermissionsService _permissionsService = PermissionsService();

//   BLEManager() {
//     checkBLEStatusAndStartScan();
//     // Set the handler for service discovery
//     QuickBlue.setServiceHandler(_handleServiceDiscovery);

//   }

//   void checkBLEStatusAndStartScan() async {
//     final isBluetoothPermissionGranted =
//         await _permissionsService.requestBluetoothPermissions();
//     final isLocationPermissionGranted =
//         await _permissionsService.requestLocationPermissions();
//     final isBluetoothScanPermissionGranted =
//         await _permissionsService.requestBluetoothScanPermissions();
//     final isBluetoothConnectPermissionGranted =
//         await _permissionsService.requestBluetoothConnectPermissions();

//     if (!isBluetoothPermissionGranted) {
//       // Handle the case where permissions are not granted
//       print('\nRequired Bluetooth Permission not granted\n');
//       return;
//     }
//     else if (!isLocationPermissionGranted) {
//       // Handle the case where permissions are not granted
//       print('\nRequired Location Permissions not granted\n');
//       return;
//     }
//     else if (!isBluetoothScanPermissionGranted || !isBluetoothConnectPermissionGranted) {
//       // Handle the case where permissions are not granted
//       print('\nRequired Scan and Connect Permissions not granted\n');
//       return;
//     }
    
//     startScan();
//     }

//   void startScan() {
//     deviceIds.clear();
//     QuickBlue.scanResultStream.listen((result) {
//       var device = BLEDevice(id: result.deviceId, name: result.name ?? 'Unknown Device');
//       if (!devices.any((d) => d.id == device.id)) {
//         devices.add(device);
//         notifyListeners(); // Notify when a new device is added
//       }
//     });

//     QuickBlue.startScan();
//     Future.delayed(const Duration(seconds: 60)).then((_) => stopScan());
//   }

//   void stopScan() {
//     QuickBlue.stopScan();
//     notifyListeners();
//   }

//   Future<bool> get isConnected async {
//     return connectedDeviceId != null;
//   }

//   // Once a service is discovered, this handler will be called
//   void _handleServiceDiscovery(String deviceId, String serviceId, List<String> characteristicIds) {
//     print('_handleServiceDiscovery for device $deviceId, service $serviceId, characteristics $characteristicIds');
    
//     // Update discoveredServices map here
//     if (!discoveredServices.containsKey(deviceId)) {
//       discoveredServices[deviceId] = {};
//     }
//     discoveredServices[deviceId]![serviceId] = characteristicIds;

//     // We can now use these characteristic UUIDs to set notifications or perform read/write operations
//     for (String charUuid in characteristicIds) {

//       QuickBlue.setNotifiable(deviceId, serviceId, charUuid, true as BleInputProperty);
      
//       // We could also immediately read or write to the characteristic if needed
//       // QuickBlue.readValue(deviceId, serviceId, charUuid);
//       // QuickBlue.writeValue(deviceId, serviceId, charUuid, data);

//       QuickBlue.writeValue(deviceId, serviceId, charUuid, utf8.encode(deviceId), true as BleOutputProperty);
//       print("*****\nQuickBlue.writeValue: deviceId: $deviceId; serviceId: $serviceId; charUuid: $charUuid");
      
//     }

//     // Make sure to notify listeners if we need to update the UI based on this discovery
//     notifyListeners();
//   }


//   Future<void> connectToDevice(String deviceId, BuildContext context) async {
//     try {
//       QuickBlue.connect(deviceId);
//       connectedDeviceId = deviceId;
//       notifyListeners();

//       // After connecting, start service discovery and send the device ID to the desktop app
//       // sendDataToDevice(deviceId);
//        QuickBlue.discoverServices(deviceId);

//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Connection Successful"),
//           content: const Text("BLE connection has been established."),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       print("Failed to connect to the device: $e");
//     }
//   }

//   // void sendDataToDevice(String deviceId) {
//   //   const String serviceUUID = "service-uuid";
//   //   const String characteristicUUID = "characteristic-uuid";

//   //   QuickBlue.discoverServices(deviceId);

//   //   QuickBlue.writeValue(deviceId, serviceUUID, characteristicUUID, utf8.encode(deviceId), true as BleOutputProperty);
//   // }


//   @override
//   void dispose() {
//     super.dispose();
//     QuickBlue.stopScan();
//   }
// }
