// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'ble_manager.dart';
// import 'login_page.dart';

// class BLEConnectionScreen extends StatelessWidget {
//   const BLEConnectionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Connect to BLE Device")),
//       body: Consumer<BLEManager>(
//         builder: (context, manager, child) {
//           return Column(
//             children: [
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: manager.devices.length,
//                   itemBuilder: (context, index) {
//                     final device = manager.devices[index];
//                     return ListTile(
//                       title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
//                       subtitle: Text(device.id),
//                       onTap: () async {
//                         await manager.connectToDevice(device.id, context);
//                         if (await manager.isConnected) {
//                           Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
//                         }
//                       },
//                     );
//                   },
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () => manager.startScan(),
//                 child: const Text("Scan for Devices"),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
