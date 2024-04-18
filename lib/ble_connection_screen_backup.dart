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
//                   itemCount: manager.scanResults.length,
//                   itemBuilder: (context, index) {
//                     final device = manager.scanResults[index].device;
//                     return ListTile(
//                       title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
//                       subtitle: Text(device.id.toString()),
//                       onTap: () async {
//                         await manager.connectToDevice(device, context);
//                         // Await the future value of isConnected
//                         bool isConnected = await manager.isConnected;
//                         if (isConnected) {
//                           Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
//                         }
//                       },
//                     );
//                   },
//                 ),
//               ),
//              ElevatedButton(
//                 onPressed: () => Provider.of<BLEManager>(context, listen: false).ensureBluetoothIsOn(context),
//                 child: const Text("Scan for Devices"),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
