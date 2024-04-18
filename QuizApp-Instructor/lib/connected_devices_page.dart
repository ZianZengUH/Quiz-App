// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'main.dart';

// class ConnectedDevicesPage extends StatelessWidget {
//   const ConnectedDevicesPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var appState = Provider.of<MyAppState>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Connected Devices'),
//       ),
//       body: ListView.builder(
//         itemCount: appState.connectedDeviceIds.length, // Updated this line
//         itemBuilder: (context, index) {
//           String deviceId = appState.connectedDeviceIds[index]; // Updated this line
//           return ListTile(
//             title: Text(deviceId), // Display device identifier
//             trailing: ElevatedButton(
//               onPressed: () {
//                 appState.disconnectFromDevice(deviceId);
//               },
//               child: const Text('Disconnect'),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
