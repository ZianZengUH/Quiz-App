import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class ConnectedDevicesPage extends StatelessWidget {
  const ConnectedDevicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<MyAppState>(context);

    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget> [
          Container(
            padding: const EdgeInsets.all(5.0),
            color: const Color.fromARGB(50, 6, 86, 6),
            child: const Text(
              'Connected Devices',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold
              ),  
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: appState.connectedDeviceIds.length, // Updated this line
              itemBuilder: (context, index) {
                String deviceId = appState.connectedDeviceIds[index]; // Updated this line
                return ListTile(
                  title: Text(deviceId), // Display device identifier
                  trailing: ElevatedButton(
                    onPressed: () {
                      appState.disconnectFromDevice(deviceId);
                    },
                    child: const Text('Disconnect'),
                  ),
                );
              },
              separatorBuilder: (BuildContext context,int index) {
                  return const Divider();
              }
            ),
          ),
        ],
      ),
    );
  }
}
