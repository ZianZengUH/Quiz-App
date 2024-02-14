import 'package:flutter/material.dart';
import 'package:quiz_app/controllers/bluetooth_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<BluetoothController>(
        init: BluetoothController(),
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container( 
                  height: 180, 
                  width: double.infinity, 
                  color: Colors.blue,
                  child: const Center(
                    child: Text("Bluetooth App",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {}
                    child: Text(),
                  ),
                )
              ],
            ),
          );
        }),
    );
  }
}