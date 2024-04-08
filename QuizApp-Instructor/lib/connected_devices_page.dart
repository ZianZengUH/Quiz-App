import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_instructor/main.dart';

class ConnectedDevicesPage extends StatelessWidget {
  const ConnectedDevicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<MyAppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected Devices'),
      ),
      body: ListView.builder(
        itemCount: appState.connectedDevices.length,
        itemBuilder: (context, index) {
          BluetoothDevice device = appState.connectedDevices[index];
          return ListTile(
            title: Text(device.name),
            subtitle: Text(device.id.toString()),
            trailing: ElevatedButton(
              onPressed: () {
                appState.disconnectFromDevice(device);
              },
              child: const Text('Disconnect'),
            ),
          );
        },
      ),
    );
  }
}