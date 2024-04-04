import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ble_manager.dart';
import 'login_page.dart';

class BLEConnectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Connect to BLE Device")),
      body: Consumer<BLEManager>(
        builder: (context, manager, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: manager.scanResults.length,
                  itemBuilder: (context, index) {
                    final device = manager.scanResults[index].device;
                    return ListTile(
                      title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
                      subtitle: Text(device.id.toString()),
                      onTap: () async {
                        await manager.connectToDevice(device);
                        // Await the future value of isConnected
                        bool isConnected = await manager.isConnected;
                        if (isConnected) {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
                        }
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () => manager.startScan(),
                child: Text("Scan for Devices"),
              ),
            ],
          );
        },
      ),
    );
  }
}
