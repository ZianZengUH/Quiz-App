import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'websocket_manager.dart';

//########################## Home Page ##########################

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final TextEditingController _answerController = TextEditingController();
  String name = '';
  String classSection = '';
  String? department = 'ICS';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString('userName') ?? '';
    classSection = prefs.getString('userClassSection') ?? '';
    department = prefs.getString('userDepartment') ?? '';
  }

  void _submitAnswer() {
    String answerText = _answerController.text.trim();
    if (answerText.isNotEmpty) {
      final Map<String, dynamic> userData = {
        'name': name,
        'classSection': classSection,
        'answer': answerText,
        'department': department,
      };
      WebSocketManager().sendMessage(json.encode(userData));
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Thank you for your submission 😊'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      print("Answer is empty, not sending.");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Do nothing if inactive or detached.
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      return;
    }

    if (state == AppLifecycleState.paused) {
      final Map<String, dynamic> userData = {
        'name': name,
        'classSection': classSection,
        'answer': '(!!!!! APP MINIMIZED !!!!!)',
      };
      WebSocketManager().sendMessage(json.encode(userData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 71, 148, 56),
            Color(0xFF004D40),
          ],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/UH_Manoa_ICS_logo.png"),
              opacity: 0.060,
              fit: BoxFit.contain,
            ),
          ),
          child: SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: _answerController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your answer here',
                      hintStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _submitAnswer,
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
