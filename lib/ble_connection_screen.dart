import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ble_manager.dart';


class BLEConnectionScreen extends StatelessWidget {
  const BLEConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connect to BLE Device")),
      body: Consumer<BLEManager>(
        builder: (context, manager, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: manager.scanResults.length,
                  itemBuilder: (context, index) {
                    final device = manager.scanResults[index];
                    return ListTile(
                      title: Text(device['name'] ?? 'Unknown Device'),
                      subtitle: Text(device['id']),
                      onTap: () async {
                        manager.connectToDevice();
                        bool isConnected = await manager.isConnected;
                        if (isConnected) {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const BLECentralView()));
                        }
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () =>
                    Provider.of<BLEManager>(context, listen: false).startScan(),
                child: const Text("Scan for Devices"),
              ),
              ElevatedButton(
                onPressed: () =>
                    Provider.of<BLEManager>(context, listen: false).stopScan(),
                child: const Text("Stop Scan"),
              ),
            ],
          );
        },
      ),
    );
  }
}

class BLECentralView extends StatefulWidget {
  const BLECentralView({super.key});

  @override
  _BLECentralViewState createState() => _BLECentralViewState();
}

class _BLECentralViewState extends State<BLECentralView> {
  final TextEditingController _readableTextController = TextEditingController();
  final TextEditingController _writeableTextController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BLE Central View")),
      body: Consumer<BLEManager>(
        builder: (context, manager, child) {
          return Column(
            children: [
              TextField(
                controller: _readableTextController,
                decoration:
                    const InputDecoration(labelText: "Readable Characteristic"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // String result = await manager.readCharacteristic();
                  setState(() {
                    // _readableTextController.text = result;
                  });
                },
                child: const Text("Read"),
              ),
              TextField(
                controller: _writeableTextController,
                decoration: const InputDecoration(
                    labelText: "Writeable Characteristic"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await manager
                      .writeCharacteristic(_writeableTextController.text);
                },
                child: const Text("Write"),
              ),
            ],
          );
        },
      ),
    );
  }
}
