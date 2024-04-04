import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required void Function(String data) onSendData, required List<BluetoothDevice> connectedDevices});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _answerController = TextEditingController();
  // Define the default question as a state variable
  final String _defaultQuestion = 'What is the most efficient algorithm for finding a chosen number within 100?';

  void _submitAnswer() {
    // The submit logic here
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
      fontSize: 18, 
      fontWeight: FontWeight.bold, // Use FontWeight.bold for bold text
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        reverse: true, // Ensures that the view scrolls to the bottom when the keyboard is opened
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Display the question inside a container with padding and a border
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child:Text(
                  'Question',
                  style: textStyle,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _defaultQuestion,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 20),
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
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}
