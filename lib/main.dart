import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ble_connection_screen.dart';
import 'ble_manager.dart';
import 'login_page.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BLEManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: Provider.of<BLEManager>(context, listen: false).isConnected,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else {
            if (snapshot.data == true) {
              return const LoginPage();
            } else {
              return const BLEConnectionScreen();
            }
          }
        },
      ),
    );
  }
}