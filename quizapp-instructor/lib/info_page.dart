import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {    
    return const SizedBox(
      child: Column(
        children: <Widget>  [
          Text('HOW TO USE THIS APPLICATION\n'),
          
          Text('Create/Modify Quiz'),
          Text('Set the quiz name, duration, font size, and question.'),
          Text('You can then save the quiz to either "memory only" or "memory and disk"'),
          Text('If you choose "memory only", quiz data will be lost if you close the app'),
          Text('Saving to disk will save your quiz as <quiz name>.quiz in a specific directory.'),
          Text('WARNING - Saving to disk will overwrite whatever file is named <quiz name>.quiz!  Please be careful you don\'t overwrite something by accident!'),
          Text('Windows - C:\\Users\\<your username>\\Documents\\<quiz name>.txt'),
          Text('Mac - TODO\n'),

          Text('Bluetooth Connectivity'),
          Text('This app supports hop connect functionality using Bluetooth.'),
          Text('To connect to devices:'),
          Text('1. Navigate to the Bluetooth page.'),
          Text('2. Scan for available devices.'),
          Text('3. Select the devices you want to connect to.'),
          Text('4. Once connected, you can send quiz data to the connected devices.'),
          Text('5. To disconnect from a device, tap the "Disconnect" button next to the device.\n'),

          Text('Sending Quiz Data'),
          Text('When you have devices connected via Bluetooth:'),
          Text('1. Load or create a quiz.'),
          Text('2. Navigate to the "Display Quiz" page.'),
          Text('3. Tap the "Send Quiz" button to send the quiz data to all connected devices.'),
          Text('4. The quiz data will be sent to the devices, and they can start answering the quiz.\n'),
          
          Text('Load Quiz'),
          Text('Searches in "<Quiz App directory>/Saved Quizzes" folder for your saved quiz files.'),
          Text('Returns a list of .quiz files that you can select from via radial button.'),
          Text('You can then load the quiz and modify it, display it to the class, etc.\n'),
          
          Text('Display Quiz'),
          Text('This page is intended to be shown to your class via projector.'),
          Text('Has a large timer at the top of the screen and the quiz question below it.'),
          Text('There are two buttons that allow you to start and pause the quiz timer\n'),
          
          Text('Export Quiz'),
          Text('Exports the student\'s answers and pictures to disk.'),
          Text('By default, creates a folder named after the quiz name in a specific directory.'),
          Text('Windows - C:\\Users\\<your username>\\Documents\\<quiz name>.txt'),
          Text('Mac - TODO'),
          

        ]
      )
    );
  }
}