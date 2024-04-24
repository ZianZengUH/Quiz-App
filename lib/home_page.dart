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

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _answerController = TextEditingController();
  String name = '';
  String classSection = '';

  // Define the default question as a state variable
  //final String _defaultQuestion = 'What is the most efficient algorithm for finding a chosen number within 100?';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString('userName') ?? '';
    classSection = prefs.getString('userClassSection') ?? '';
  }

  void _submitAnswer() {
    String answerText = _answerController.text.trim();
    if (answerText.isNotEmpty) {
      final Map<String, dynamic> userData = {
        'name': name,
        'classSection': classSection,
        'answer': answerText,
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
  Widget build(BuildContext context) {
    TextStyle textStyle = const TextStyle(
      fontSize: 18, 
      fontWeight: FontWeight.bold, // Use FontWeight.bold for bold text
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: DecoratedBox( 
        decoration: const BoxDecoration( 
          image: DecorationImage( 
              image: AssetImage("assets/images/UH_Manoa_ICS_logo.png"),
              opacity: 0.060,
              fit: BoxFit.contain),
        ),
        child: SingleChildScrollView(
          reverse: true, // Ensures that the view scrolls to the bottom when the keyboard is opened
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Display the question inside a container with padding and a border
                //Container(
                  //margin: const EdgeInsets.only(bottom: 10),
                  //child:Text(
                    //'Question',
                    //style: textStyle,
                  //),
                //),
                //Container(
                  //padding: const EdgeInsets.all(16.0),
                  //decoration: BoxDecoration(
                    //border: Border.all(color: Theme.of(context).colorScheme.primary),
                    //borderRadius: BorderRadius.circular(8.0),
                  //),
                  //child: Text(
                    //_defaultQuestion,
                    //style: Theme.of(context).textTheme.titleMedium,
                  //),
                //),
                //const SizedBox(height: 20),
                // Answer TextField
                TextField(
                  controller: _answerController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your answer here',
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
                const SizedBox(height: 20),
                // Align Submit Button to the right
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
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}
